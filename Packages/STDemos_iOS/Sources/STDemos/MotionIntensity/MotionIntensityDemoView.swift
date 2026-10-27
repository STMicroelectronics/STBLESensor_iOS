//
//  MotionIntensityDemoView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 19/10/2026.
//
import SwiftUI
import STBlueSDK
import STUI

public struct MotionIntensityDemoView: View {
    
    @StateObject private var viewModel = MotionIntensityDemoViewModel()
    @State private var delegateHandler: MotionIntensityBlueDelegateHandler?
    
    let node: Node
    
    init (node: Node) {
        self.node = node
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            let size = UIScreen.main.bounds.width * 0.7
            
            Text("The Intensity is proportional to the movement")
                .font(.title)
                .foregroundColor(SUIColorLayout.primary.color)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding([.top,.bottom], 24)
            
            
            // The Gauge View
            CircularGauge(
                value: Double(viewModel.motionIntensity),
                minValue: 0, //Min of Motion Intensity
                maxValue: 10, //Max of Motion Intensity
                lineWidth: 32,
                label: "Intensity"
            )
            .frame(width: size, height: size)
            
            HStack() {
                Text("Resting").font(.title)
                Spacer()
                Text("Sprinting").font(.title)
            }.frame(width: size)
            
            Spacer()
            
        }
        .padding(.horizontal, 16)
        .onAppear {
            delegateHandler = MotionIntensityBlueDelegateHandler(viewModel: viewModel)
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

class MotionIntensityBlueDelegateHandler: NSObject, BlueDelegate {
    var viewModel: MotionIntensityDemoViewModel
    
    init(viewModel: MotionIntensityDemoViewModel) {
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
        case let sample as FeatureSample<MotionIntensityData>:
            viewModel.evaluateSample(sample)
        default:
            break
        }
    }
}
