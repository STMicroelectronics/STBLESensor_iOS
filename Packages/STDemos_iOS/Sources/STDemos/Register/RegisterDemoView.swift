//
//  RegisterDemoView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 21/10/2026.
//


import SwiftUI
import STBlueSDK
import STUI

public struct RegisterDemoView: View {
    
    @StateObject private var viewModel: RegisterDemoViewModel
    @State private var delegateHandler: RegisterBlueDelegateHandler?
    
    let node: Node
    let registerDemoType: RegisterDemoType
    
    init (node: Node, registerDemoType: RegisterDemoType) {
        self.node = node
        self.registerDemoType = registerDemoType
        _viewModel = StateObject(wrappedValue: RegisterDemoViewModel(node: node))
    }
    
    public var body: some View {
        
        let registerName =
        switch self.registerDemoType {
        case .mlc:
            "Decision Tree"
        case .fsm:
            "Program"
        case .stredl:
            "STRed"
        }
        
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.registersStatus, id: \.registerId) { register in
                    RegisterStatusView(
                        registerName: registerName,
                        register: register
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding([.horizontal, .vertical], 16)
        }
        .onAppear {
            delegateHandler = RegisterBlueDelegateHandler(viewModel: viewModel)
            if let delegateHandler = delegateHandler {
                BlueManager.shared.addDelegate(delegateHandler)
            }
            if let feature = node.characteristics.allFeatures().first(where: { $0.name == registerDemoType.featureName }) {
                //Enable the notifications
                BlueManager.shared.enableNotifications(for: node, feature: feature)
            }
            
            //Read from Debug Console the labels that must used for this demo
            viewModel.retrieveLabelData(type: registerDemoType)
            
            if let feature = node.characteristics.allFeatures().first(where: { $0.name == registerDemoType.featureName }) {
                //Make one Read for reading the initial value
                BlueManager.shared.read(feature: feature, for: node)
            }
        }
        .onDisappear {
            if let feature = node.characteristics.allFeatures().first(where: { $0.name == registerDemoType.featureName }) {
                BlueManager.shared.disableNotifications(for: node, feature: feature)
            }
            
            if let delegateHandler = delegateHandler {
                BlueManager.shared.removeDelegate(delegateHandler)
            }
        }
    }
}

class RegisterBlueDelegateHandler: NSObject, BlueDelegate {
    var viewModel: RegisterDemoViewModel
    
    init(viewModel: RegisterDemoViewModel) {
        self.viewModel = viewModel
    }
    
    func manager(_ manager: BlueManager, discoveringStatus isDiscovering: Bool) {}
    func manager(_ manager: BlueManager, didDiscover node: Node) {}
    func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node]) {}
    
    func manager(_ manager: BlueManager, didChangeStateFor node: Node) {}
    
    func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {}
    func manger(_ service: BlueManager, receivedDebugConsoleDataFor node: Node, data: Data) {}
    func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
        guard let sample = sample else { return }
        
        switch sample {
        case is FeatureSample<MachineLearningCoreData>,
            is FeatureSample<FiniteStateMachineData>,
            is FeatureSample<STREDLData>:
            viewModel.evaluateSample(sample) // Works if viewModel can take the matched type/any
        default:
            break
        }
        
    }
}
