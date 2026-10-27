//
//  EventDemoView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 16/10/2026.
//

import SwiftUI
import STBlueSDK
import STUI

public struct EventCounterDemoView: View {
    
    @StateObject private var viewModel = EventCounterDemoViewModel()
    @State private var delegateHandler: EventCounterNodeBlueDelegateHandler?
    
    let node: Node
    
    init (node: Node) {
        self.node = node
    }
    
    public var body: some View {
        VStack(spacing: 64) {
            Text("# Events")
                .font(.title)
                .bold()
                .foregroundColor(SUIColorLayout.primary.color)
                .padding([.top, .bottom], 16)
            
            // Animated Counter Text
            Text("\(viewModel.counter)")
                .font(.system(size: 128, weight: .bold))
                .foregroundColor(SUIColorLayout.primary.color)
                .contentTransition(.numericText(value: Double(viewModel.counter)))
                .animation(.easeInOut(duration: 0.3), value: viewModel.counter)
                .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
        .onAppear {
            delegateHandler = EventCounterNodeBlueDelegateHandler(viewModel: viewModel)
            if let delegateHandler = delegateHandler {
                BlueManager.shared.addDelegate(delegateHandler)
            }
        }
        .onDisappear {
            if let delegateHandler = delegateHandler {
                BlueManager.shared.removeDelegate(delegateHandler)
            }
        }
    }
}

class EventCounterNodeBlueDelegateHandler: NSObject, BlueDelegate {
    var viewModel: EventCounterDemoViewModel
    
    init(viewModel: EventCounterDemoViewModel) {
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
        case let sample as FeatureSample<EventCounterData>:
            viewModel.evaluateSample(sample)
        default:
            break
        }
    }
}
