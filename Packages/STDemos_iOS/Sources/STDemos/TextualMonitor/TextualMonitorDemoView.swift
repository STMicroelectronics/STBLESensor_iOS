//
//  TextualMonitorDemoView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 14/10/2026.
//

import SwiftUI
import STBlueSDK

public struct TextualMonitorDemoView: View {
    
    @StateObject private var viewModel: TextualMonitorViewModel
    @State private var delegateHandler: TextualMonitorBlueDelegateHandler?
    @State private var selectedFeatureIndex: Int = 0
    
    let node: Node
    
    init (node: Node) {
        self.node = node
        _viewModel = StateObject(wrappedValue: TextualMonitorViewModel(node: node))
    }
    
    public var body: some View {
        VStack (alignment: .center, spacing: 8) {
            HStack {
                Menu {
                    ForEach(Array(viewModel.listOfFeatures.enumerated()), id: \.offset) { index, feature in
                        Button {
                            selectedFeatureIndex = index
                            if let feature {
                                viewModel.selectFeature(feature)
                            } else {
                                viewModel.unSelectFeature()
                            }
                        } label: {
                            Text(feature?.shortName ?? "select one feature")
                        }
                    }
                }
                label: {
                    Label(viewModel.selectedFeature?.shortName ?? "select one feature", systemImage: "chevron.down")
                }
                .disabled(viewModel.terminalStatus == .printing)
                
                Spacer()
                
                switch(viewModel.terminalStatus) {
                case .idle:
                    Button("Play", systemImage: "play", action: viewModel.switchTerminalStatus).buttonStyle(.borderedProminent).disabled(viewModel.selectedFeature == nil)
                case .printing:
                    Button("Stop", systemImage: "stop", action: viewModel.switchTerminalStatus).buttonStyle(.borderedProminent)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            
            ScrollView {
                Text(viewModel.logText)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .textSelection(.enabled)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading).padding(16)
            
        }.onAppear() {
            delegateHandler = TextualMonitorBlueDelegateHandler(viewModel: self.viewModel)
            
            if let delegateHandler = delegateHandler {
                BlueManager.shared.addDelegate(delegateHandler)
            }
            
            selectedFeatureIndex = 0
            self.viewModel.loadFeatures(node: node)
        }.onDisappear() {
            
            if viewModel.terminalStatus != .idle {
                viewModel.switchTerminalStatus()
            }
            
            if let delegateHandler = delegateHandler {
                BlueManager.shared.removeDelegate(delegateHandler)
            }
            
            self.viewModel.clearFeatures()
            selectedFeatureIndex = 0
        }
    }
}

class TextualMonitorBlueDelegateHandler: NSObject, BlueDelegate {
    var viewModel: TextualMonitorViewModel
    
    init(viewModel: TextualMonitorViewModel) {
        self.viewModel = viewModel
    }
    
    func manager(_ manager: STBlueSDK.BlueManager, discoveringStatus isDiscovering: Bool) {
    }
    
    func manager(_ manager: STBlueSDK.BlueManager, didDiscover node: STBlueSDK.Node) {
    }
    
    func manager(_ manager: STBlueSDK.BlueManager, didRemoveDiscovered nodes: [STBlueSDK.Node]) {
    }
    
    func manager(_ manager: STBlueSDK.BlueManager, didChangeStateFor node: STBlueSDK.Node) {
    }
    
    func manager(_ manager: STBlueSDK.BlueManager, didUpdateValueFor node: STBlueSDK.Node, feature: any STBlueSDK.Feature, sample: (any STBlueSDK.AnyFeatureSample)?) {
        viewModel.updateTerminalText(feature: feature, sample: sample)
    }
    
    func manager(_ manager: STBlueSDK.BlueManager, didReceiveCommandResponseFor node: STBlueSDK.Node, feature: any STBlueSDK.Feature, response: any STBlueSDK.FeatureCommandResponse) {
    }
    
    func manger(_ service: STBlueSDK.BlueManager, receivedDebugConsoleDataFor node: STBlueSDK.Node, data: Data) {}
}
