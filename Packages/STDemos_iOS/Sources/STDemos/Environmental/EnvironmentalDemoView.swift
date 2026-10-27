//
//  EnvironmentalView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 06/10/2026.
//

import SwiftUI
import STUI
import STBlueSDK
import STCore

public struct EnvironmentalDemoView: View {
    
    @StateObject private var viewModel: EnvironmentalDemoViewModel
    @State private var delegateHandler: EnvironmentalNodeBlueDelegateHandler?
    
    let node: Node
    
    init (node: Node) {
        self.node = node
        _viewModel = StateObject(wrappedValue: EnvironmentalDemoViewModel(node: node))
    }
    
    public var body: some View {
        VStack (alignment: .leading, spacing: 8) {
            
            Spacer()
                .frame(height: 32)
            
            if viewModel.hasTemperature {
                EnvironmentalCard(envType: .temperature,  value: viewModel.temperature, onImageTap: viewModel.readTemperatureFeature)
            }
            
            if viewModel.hasHumidity {
                EnvironmentalCard(envType: .humidity, value: viewModel.humidity, onImageTap: viewModel.readHumidityFeature)
            }
            
            if viewModel.hasPressure {
                EnvironmentalCard(envType: .pressure, value: viewModel.pressure, onImageTap: viewModel.readPressureFeature)
            }
            
            Spacer()
        }
        .onAppear {
            delegateHandler = EnvironmentalNodeBlueDelegateHandler(viewModel: viewModel)
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

class EnvironmentalNodeBlueDelegateHandler: NSObject, BlueDelegate {
    var viewModel: EnvironmentalDemoViewModel
    
    init(viewModel: EnvironmentalDemoViewModel) {
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
        case let sample as FeatureSample<PressureData>:
            viewModel.evaluateEvent(sample)
        case let sample as FeatureSample<HumidityData>:
            viewModel.evaluateEvent(sample)
        case let sample as FeatureSample<TemperatureData>:
            viewModel.evaluateEvent(sample)
        default:
            break
        }
    }
}
