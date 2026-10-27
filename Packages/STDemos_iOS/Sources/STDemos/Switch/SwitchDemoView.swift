//
//  SwitchDemoView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 27/10/2026.
//

import SwiftUI
import STBlueSDK
import STUI

public struct SwitchDemoView: View {
    
    @StateObject private var viewModel: SwitchDemoViewModel
    @State private var delegateHandler: SwitchBlueDelegateHandler?
    @State private var isImageOn = false
    
    @State  private var title: String
    
    private var titleImage: String {
        isImageOn ? "switch_led_on" : "switch_led_off"
    }
    
    let node: Node
    
    init (node: Node) {
        self.node = node
        self.title = if(node.type == .sensorTileBox || node.type == .sensorTileBoxPro || node.type == .sensorTileBoxProB || node.type == .sensorTileBoxProC) {
            "The led is switching on when an event is detected"
        } else {
            "Click on the image to change the led status"
        }
        _viewModel = StateObject(wrappedValue: SwitchDemoViewModel(node: node))
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            
            Text(title)
                .font(.title)
                .bold()
                .foregroundColor(SUIColorLayout.primary.color)
                .multilineTextAlignment(.center)
            
            Spacer().frame(height: 32)
            
            
            Image(titleImage, bundle: STDemos.bundle)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    viewModel.sendSwitchTypeCommand(  viewModel.status != 0 ? .switchOff : .switchOn)
                }
            
            Spacer()
            
        }
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .padding(16)
        .onAppear {
            delegateHandler = SwitchBlueDelegateHandler(viewModel: viewModel)
            if let delegateHandler = delegateHandler {
                BlueManager.shared.addDelegate(delegateHandler)
            }
            
            //Read Initial value
            if let switchFeature = node.characteristics.first(with: SwitchFeature.self) {
                BlueManager.shared.read(feature: switchFeature, for: node)
            }
        }
        .onDisappear {
            if let delegateHandler = delegateHandler {
                BlueManager.shared.removeDelegate(delegateHandler)
            }
        }
        .onChange(of: viewModel.status) { _, status in
            withAnimation(.easeInOut(duration: 0.4)) {
                isImageOn = status != 0
            }
        }
    }
}

class SwitchBlueDelegateHandler: NSObject, BlueDelegate {
    var viewModel: SwitchDemoViewModel
    
    init(viewModel: SwitchDemoViewModel) {
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
        case let sample as FeatureSample<SwitchData>:
            viewModel.evaluateSample(sample)
        default:
            break
        }
    }
}
