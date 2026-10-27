//
//  JsonNfcDemoView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 26/10/2026.
//


import SwiftUI
import STBlueSDK
import STUI

public struct JsonNfcDemoView: View {
    
    @StateObject private var viewModel: JsonNfcDemoViewModel
    
    @State private var delegateHandler: JsonNfcBlueDelegateHandler?
    
    let node: Node
    
    init (node: Node) {
        self.node = node
        _viewModel = StateObject(wrappedValue: JsonNfcDemoViewModel(node: node))
    }
    
    public var body: some View {
        ScrollView {
            ZStack(alignment: .center) {
                if viewModel.supportedModes == nil {
                    //Waiting the data
                    Text("Waiting data…").font(.title)
                        .bold()
                        .foregroundColor(SUIColorLayout.primary.color)
                }
                
                VStack(spacing: 16) {
                    if viewModel.hasGenericText {
                        GenericTextCardContent(viewModel: viewModel)
                    }
                    
                    if viewModel.hasNFCURL {
                        URLCardContent(viewModel: viewModel)
                    }
                    
                    if viewModel.hasNFCWiFi {
                        WiFiCardContent(viewModel: viewModel)
                    }
                    
                    if viewModel.hasNFCVCard {
                        VCardContent(viewModel: viewModel)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 4)
            .alert(viewModel.messageToShow, isPresented: $viewModel.showMessage) {
                Button("OK", role: .cancel) { }
            }
        }
        .onAppear {
            delegateHandler = JsonNfcBlueDelegateHandler(viewModel: viewModel)
            if let delegateHandler = delegateHandler {
                BlueManager.shared.addDelegate(delegateHandler)
            }
            
            if node.characteristics.first(with: JsonNFCFeature.self) != nil {
                viewModel.readModes()
            }
        }
        .onDisappear {
            if let delegateHandler = delegateHandler {
                BlueManager.shared.removeDelegate(delegateHandler)
            }
        }
    }
}

class JsonNfcBlueDelegateHandler: NSObject, BlueDelegate {
    var viewModel: JsonNfcDemoViewModel
    
    init(viewModel: JsonNfcDemoViewModel) {
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
        case let sample as FeatureSample<JsonNFCData>:
            viewModel.evaluateSample(sample)
        default:
            break
        }
    }
}
