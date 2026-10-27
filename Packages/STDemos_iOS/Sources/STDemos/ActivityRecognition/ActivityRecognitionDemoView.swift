//
//  ActivityRecognitionDemoView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 23/10/2026.
//

import SwiftUI
import STBlueSDK
import STUI

public struct ActivityRecognitionDemoView: View {
    
    @StateObject private var viewModel = ActivityRecognitionDemoViewModel()
    @State private var delegateHandler: ActivityRecognitionBlueDelegateHandler?
    
    let node: Node
    
    init (node: Node) {
        self.node = node
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            if viewModel.activity == nil {
                //Waiting the data
                Text("Waiting data…").font(.title)
                    .bold()
                    .foregroundColor(SUIColorLayout.primary.color)
                
            }
            
            switch viewModel.algorithmId {
            case 1:
                // GMP activity recognition
                ActivityRecognitionMotionARContentView(showFastWalking: false, activity: viewModel.activity)
            case 2:
                // IGN activity recognition
                ActivityRecognitionMotionIGNContentView(activity: viewModel.activity)
            case 3:
                //activity recognition from mlc
                ActivityRecognitionMotionARContentView(showFastWalking: false,activity: viewModel.activity)
            case 4:
                //adult presence recognition from mlc
                ActivityRecognitionMotionAPD_MLCContentView(activity: viewModel.activity)
            default:
                //default view
                ActivityRecognitionMotionARContentView(showFastWalking: true , activity: viewModel.activity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .onAppear {
            delegateHandler = ActivityRecognitionBlueDelegateHandler(viewModel: viewModel)
            if let delegateHandler = delegateHandler {
                BlueManager.shared.addDelegate(delegateHandler)
            }
            
            if let activityRecognitionFeature = node.characteristics.first(with: ActivityFeature.self) {
                BlueManager.shared.read(feature: activityRecognitionFeature, for: node)
            }
            
        }
        .onDisappear {
            if let delegateHandler = delegateHandler {
                BlueManager.shared.removeDelegate(delegateHandler)
            }
        }
    }
}

class ActivityRecognitionBlueDelegateHandler: NSObject, BlueDelegate {
    var viewModel: ActivityRecognitionDemoViewModel
    
    init(viewModel: ActivityRecognitionDemoViewModel) {
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
        case let sample as FeatureSample<ActivityData>:
            viewModel.evaluateSample(sample)
        default:
            break
        }
    }
}
