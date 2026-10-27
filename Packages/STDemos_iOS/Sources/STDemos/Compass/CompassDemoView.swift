//
//  CompassDemoView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 07/10/2026.
//

import SwiftUI
import STUI
import STBlueSDK
import STCore


extension Orientation {
    public var description: String {
        switch self {
        case .north:
            return "N"
        case .northEast:
            return "NE"
        case .east:
            return "E"
        case .southEast:
            return "SE"
        case .south:
            return "S"
        case .southWest:
            return "SW"
        case .west:
            return "W"
        case .northWest:
            return "NW"
        }
    }
}

public struct CompassDemoView: View {
    
    @StateObject private var viewModel: CompassDemoViewModel
    @State private var delegateHandler: CompassNodeBlueDelegateHandler?
    
    let node: Node
    
    init (node: Node) {
        self.node = node
        _viewModel = StateObject(wrappedValue: CompassDemoViewModel(node: node))
    }
    
    public var body: some View {
        VStack (alignment: .center, spacing: 8) {
            
            Text(viewModel.orientation.description).font(.title)
            
            ZStack {
                Image("img_compass_background", bundle: STDemos.bundle)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Image("img_compass_needle", bundle: STDemos.bundle)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .rotationEffect(.degrees(Double(viewModel.angle)))
                
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            
            
            Text(String(format: "%.2f°",viewModel.angle))
                .font(.title)
                .padding([.bottom],8)
            
            HStack {
                Spacer()
                
                Button {
                    delegateHandler?.resetCalibration()
                } label: {
                    Image("calibration", bundle: STDemos.bundle)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 32)
                        .foregroundColor(
                            viewModel.calibrationStatus == .configured
                            ? SUIColorLayout.green.color
                            : SUIColorLayout.primary.color
                        )
                }
                .padding([.trailing],16)
            }
            
        }
        .onAppear {
            delegateHandler = CompassNodeBlueDelegateHandler(viewModel: viewModel,node: node)
            
            if(node.hasDebugConsole){
                if let bleChar = BlueManager.shared.getTermCharacteristic(to: node) {
                    BlueManager.shared.enableNofitications(for: node, characteristic: bleChar)
                }
            }
            
            if let delegateHandler = delegateHandler {
                BlueManager.shared.addDelegate(delegateHandler)
                delegateHandler.getCalibration()
            }
        }
        .onDisappear {
            if(node.hasDebugConsole){
                if let bleChar = BlueManager.shared.getTermCharacteristic(to: node) {
                    BlueManager.shared.disableNotifications(for: node, characteristic: bleChar)
                }
            }
            
            if let delegateHandler = delegateHandler {
                BlueManager.shared.removeDelegate(delegateHandler)
            }
        }
        .sheet(isPresented: $viewModel.isPresentingCalibrationView) {
            CompassCalibrationView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

class CompassNodeBlueDelegateHandler: NSObject, BlueDelegate {
    var viewModel: CompassDemoViewModel
    var node: Node
    
    
    
    init(viewModel: CompassDemoViewModel,node: Node) {
        self.viewModel = viewModel
        self.node = node
    }
    
    func manager(_ manager: BlueManager, discoveringStatus isDiscovering: Bool) {}
    func manager(_ manager: BlueManager, didDiscover node: Node) {}
    func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node]) {}
    func manager(_ manager: BlueManager, didChangeStateFor node: Node) {}
    
    func manger(_ service: BlueManager, receivedDebugConsoleDataFor node: Node, data: Data) {
        guard let text = String(bytes: data, encoding: .isoLatin1) else { return }
        viewModel.calibrationStatus = text.decodeCalibrationStatus()
        if(viewModel.calibrationStatus == .configured){
            viewModel.isPresentingCalibrationView = false
        }
    }
    
    func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {
        
        if feature.type.mask == response.featureMask,
           let response = response as? AutoConfigurationCommandResponse {
            Logger.debug(text: "\(response.description) (\(response.data.extractUInt8(fromOffset: 0)))")
            Logger.debug(text: "\(response.status == .configured ? "CONFIGURED" : "NOT CONFIGURED")")
            viewModel.calibrationStatus = response.status
        }
    }
    
    func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
        
        //Logger.log(level: .debug, category: "", text: "received 2\(feature.name)")
        
        guard let sample = sample else { return }
        switch sample {
        case let sample as FeatureSample<CompassData>:
            viewModel.evaluateEvent(sample)
        case let sample as FeatureSample<EulerAngleData>:
            viewModel.evaluateEvent(sample)
        default:
            Logger.log(level: .debug, category: "", text: "CompassDemo manager \(sample.description) Not Requested")
            break
        }
    }
    
    func resetCalibration() {
        viewModel.calibrationStatus = .notConfigured
        viewModel.isPresentingCalibrationView = true
        
        if let feature = node.characteristics.features(with: Demo.compass.features).first {
            if(BlueManager.shared.sendCommand(FeatureCommand(type: AutoConfigurationCommand.start,
                                                             data: AutoConfigurationCommand.start.payload),
                                              to: node,
                                              feature: feature) == false) {
                //if there is not the configuration feature... try to send to Debug Console
                viewModel.sendCommandOnDebugConsole("startMagnCalib")
            }
        }
    }
    
    func getCalibration() {
        if let feature = node.characteristics.features(with: Demo.compass.features).first {
            if(BlueManager.shared.sendCommand(FeatureCommand(type: AutoConfigurationCommand.get,
                                                             data: AutoConfigurationCommand.get.payload),
                                              to: node,
                                              feature: feature) == false) {
                //if there is not the configuration feature... try to send to Debug Console
                viewModel.sendCommandOnDebugConsole("getMagnCalibStatus")
            }
        }
    }
}
