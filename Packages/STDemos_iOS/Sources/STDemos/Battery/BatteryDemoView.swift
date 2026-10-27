//
//  BatteryDemoView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 16/10/2026.
//

import SwiftUI
import STBlueSDK
import STUI

extension NodeType {
    var imageSwiftUI: Image? {
        guard let imageName = self.imageName else { return nil }
        return Image(imageName, bundle: STUI.bundle)
    }
}

public struct BatteryDemoView: View {
    
    @StateObject private var viewModel = BatteryDemoviewModel()
    @State private var delegateHandler: BatteryNodeBlueDelegateHandler?
    @State private var rssiTimer: Timer?
    
    let node: Node
    
    init (node: Node) {
        self.node = node
    }
    
    private func getBatteryStatusImage(level: Float?, status: BatteryStatus) -> String {
        
        if let level = level, !level.isNaN {
            let batteryRangeImage: Int = 20
            
            let levelIndex = Int((level / Float(batteryRangeImage)) + 0.5) * batteryRangeImage
            
            if status != .charging {
                return String(format: "battery_%d", levelIndex)
            } else {
                return String(format: "battery_%dc", levelIndex)
            }
            
        } else {
            //Fallback
            return "battery_0"
        }
        
    }
    
    public var body: some View {
        VStack (alignment: .leading, spacing: 4) {
            
            Spacer()
                .frame(height: 8)
            
            BatteryCard {
                self.node.type.imageSwiftUI?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100.0, height: 100.0)
                    .padding(.leading, 16)
                
                VStack(alignment: .leading, spacing: 8) {
                    if let name = node.name {
                        Text(name)
                    }
                    
                    if let address = node.address {
                        Text(address)
                    }
                }
                
                Spacer()
            }
            
            BatteryCard {
                //Image(systemName: "wave.3.forward")
                Image("img_signal_bars", bundle: STUI.bundle)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100.0, height: 100.0)
                    .foregroundColor(SUIColorLayout.primary.color)
                    .padding(.leading, 16)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Rssi: \(viewModel.rssi) [dBm]")
                }
                
                Spacer()
            }
            
            BatteryCard {
                
                if let level = viewModel.level {
                    Image(getBatteryStatusImage(level: level, status: viewModel.status), bundle: STUI.bundle)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100.0, height: 100.0)
                        .padding(.leading, 16)
                } else {
                    Image(systemName: "wave.3.forward")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100.0, height: 100.0)
                        .foregroundColor(SUIColorLayout.primary.color)
                        .padding(.leading, 16)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    if let level = viewModel.level {
                        Text("Charge: \(level, specifier: "%.1f") %")
                    }
                    
                    if viewModel.status != .unknown {
                        Text("Status: \(viewModel.status.description)")
                    }
                    
                    if let voltage = viewModel.voltage {
                        Text("Voltage: \(voltage, specifier: "%.3f") [V]")
                    }
                    
                    if let current = viewModel.current, !current.isNaN {
                        Text("Current: \(current, specifier: "%.2f") [mA]")
                    } else {
                        Text("Current: not available")
                    }
                }
                
                Spacer()
            }
            
            Spacer()
        }
        .onAppear {
            delegateHandler = BatteryNodeBlueDelegateHandler(viewModel: viewModel)
            if let delegateHandler = delegateHandler {
                BlueManager.shared.addDelegate(delegateHandler)
            }
            
            rssiTimer?.invalidate()
            rssiTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                BlueManager.shared.readRSSI(for: node)
            }
        }
        .onDisappear {
            rssiTimer?.invalidate()
            rssiTimer = nil
            
            if let delegateHandler = delegateHandler {
                BlueManager.shared.removeDelegate(delegateHandler)
            }
        }
    }
}

class BatteryNodeBlueDelegateHandler: NSObject, BlueDelegate {
    var viewModel: BatteryDemoviewModel
    
    init(viewModel: BatteryDemoviewModel) {
        self.viewModel = viewModel
    }
    
    
    func manager(_ manager: BlueManager, discoveringStatus isDiscovering: Bool) {}
    func manager(_ manager: BlueManager, didDiscover node: Node) {}
    func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node]) {}
    
    func manager(_ manager: BlueManager, didChangeStateFor node: Node) {
        guard let rssi = node.rssi else { return }
        viewModel.updateRSSI(with: rssi)
    }
    
    func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {}
    func manger(_ service: BlueManager, receivedDebugConsoleDataFor node: Node, data: Data) {}
    func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
        guard let sample = sample else { return }
        switch sample {
        case let sample as FeatureSample<BatteryData>:
            viewModel.evaluateSample(sample)
        default:
            break
        }
    }
}
