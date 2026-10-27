//
//  PedometerDemoView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 19/10/2026.
//


import SwiftUI
import STBlueSDK
import STUI

public struct PedometerDemoView: View {
    
    @StateObject private var viewModel = PedometerDemoViewModel()
    @State private var delegateHandler: PedometerBlueDelegateHandler?
    @State private var isImageFlipped = false
    
    let node: Node
    
    init (node: Node) {
        self.node = node
    }
    
    public var body: some View {
        VStack(spacing: 32) {
            
            Image("pedometer", bundle: STDemos.bundle)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity)
                .rotation3DEffect(
                    .degrees(isImageFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0)
                )
            
            
            VStack(spacing: 8) {
                // Animated Counter Text
                Text("\(viewModel.steps)")
                    .font(.title)
                    .bold()
                    .foregroundColor(SUIColorLayout.primary.color)
                    .contentTransition(.numericText(value: Double(viewModel.steps)))
                    .animation(.easeInOut(duration: 0.3), value: viewModel.steps)
                
                Text("\(viewModel.frequency) Steps/Min")
                    .font(.title)
                    .foregroundColor(SUIColorLayout.primary.color)
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .onAppear {
            delegateHandler = PedometerBlueDelegateHandler(viewModel: viewModel)
            if let delegateHandler = delegateHandler {
                BlueManager.shared.addDelegate(delegateHandler)
            }
        }
        .onDisappear {
            if let delegateHandler = delegateHandler {
                BlueManager.shared.removeDelegate(delegateHandler)
            }
        }
        .onChange(of: viewModel.steps) { _, _ in
            withAnimation(.easeInOut(duration: 0.4)) {
                isImageFlipped.toggle()
            }
        }
    }
}

class PedometerBlueDelegateHandler: NSObject, BlueDelegate {
    var viewModel: PedometerDemoViewModel
    
    init(viewModel: PedometerDemoViewModel) {
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
        case let sample as FeatureSample<PedometerData>:
            viewModel.evaluateSample(sample)
        default:
            break
        }
    }
}
