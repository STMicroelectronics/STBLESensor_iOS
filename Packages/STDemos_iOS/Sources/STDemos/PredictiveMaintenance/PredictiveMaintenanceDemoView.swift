//
//  PredictiveMaintenanceDemoView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 27/10/2026.
//

import SwiftUI
import STBlueSDK
import STUI

public struct PredictiveMaintenanceDemoView: View {
    
    @StateObject private var viewModel = PredictiveMaintenanceDemoViewModel()
    @State private var delegateHandler:  PredictiveMaintenanceBlueDelegateHandler?
    @State private var isImageFlipped = false
    
    let node: Node
    
    init (node: Node) {
        self.node = node
    }
    
    public var body: some View {
        ScrollView {
            ZStack(alignment: .center) {
                if viewModel.speedStatus == nil && viewModel.accelerationStatus == nil && viewModel.frequencyStatus == nil {
                    //Waiting the data
                    Text("Waiting data…").font(.title)
                        .bold()
                        .foregroundColor(SUIColorLayout.primary.color)
                        .padding(.top, 128)
                }
                VStack(spacing: 8) {
                    
                    if let speedStatus = viewModel.speedStatus {
                        PredictedMaintenanceElementView(title: "RMS Speed Status",
                                                        value: speedStatus,
                                                        format: "RMS Speed (mm/s): %.2f")
                    }
                    
                    if let accelerationStatus = viewModel.accelerationStatus {
                        PredictedMaintenanceElementView(title: "Acceleration Peak Status",
                                                        value: accelerationStatus,
                                                        format: "Acc Peak (m/s^2): %.2f")
                    }
                    
                    if let frequencyStatus = viewModel.frequencyStatus {
                        PredictedMaintenanceElementView(title: "Frequency Domain Status",
                                                        value: frequencyStatus,
                                                        format: "Max amplitude (m/s^2): %.2f")
                    }
                    
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .onAppear {
            delegateHandler = PredictiveMaintenanceBlueDelegateHandler(viewModel: viewModel)
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

class PredictiveMaintenanceBlueDelegateHandler: NSObject, BlueDelegate {
    var viewModel: PredictiveMaintenanceDemoViewModel
    
    init(viewModel: PredictiveMaintenanceDemoViewModel) {
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
        case let sample as FeatureSample<PredictiveSpeedStatusData>:
            viewModel.evaluateSample(sample)
        case let sample as FeatureSample<PredictiveAccelerationStatusData>:
            viewModel.evaluateSample(sample)
        case let sample as FeatureSample<PredictiveFrequencyDomainStatusData>:
            viewModel.evaluateSample(sample)
        default:
            break
        }
    }
}
