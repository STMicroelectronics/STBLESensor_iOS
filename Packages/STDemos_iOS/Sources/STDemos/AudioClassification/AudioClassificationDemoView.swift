//
//  AudioClassificationDemoView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 19/10/2026.
//

import SwiftUI
import STBlueSDK
import STUI

public struct AudioClassificationDemoView: View {
    
    @StateObject private var viewModel = AudioClassificationDemoViewModel()
    @State private var delegateHandler: AudioClassificationBlueDelegateHandler?
    
    let node: Node
    
    init (node: Node) {
        self.node = node
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            if viewModel.algorithm == nil {
                //Waiting the data
                Text("Waiting data…").font(.title)
                    .bold()
                    .foregroundColor(SUIColorLayout.primary.color)
                
            }
            
            if viewModel.algorithm != 1 {
                AudioClassificationGenericView(classification: viewModel.classifcation)
            } else {
                AudioClassificationBabyCryingView(classification: viewModel.classifcation)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .onAppear {
            delegateHandler = AudioClassificationBlueDelegateHandler(viewModel: viewModel)
            if let delegateHandler = delegateHandler {
                BlueManager.shared.addDelegate(delegateHandler)
            }
            
            if let audioClassificationFeature = node.characteristics.first(with: AudioClassificationFeature.self) {
                BlueManager.shared.read(feature: audioClassificationFeature, for: node)
            }
            
        }
        .onDisappear {
            if let delegateHandler = delegateHandler {
                BlueManager.shared.removeDelegate(delegateHandler)
            }
        }
    }
}

class AudioClassificationBlueDelegateHandler: NSObject, BlueDelegate {
    var viewModel: AudioClassificationDemoViewModel
    
    init(viewModel: AudioClassificationDemoViewModel) {
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
        case let sample as FeatureSample<AudioClassificationData>:
            viewModel.evaluateSample(sample)
        default:
            break
        }
    }
}
