//
//  PlotDemoView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 12/10/2026.
//

import SwiftUI
import STBlueSDK

public struct PlotDemoView: View {
    
    @StateObject private var viewModel: PlotDemoViewModel
    @State private var delegateHandler: PlotNodeBlueDelegateHandler?
    @State private var selectedFeatureIndex: Int = 0
    
    let node: Node
    
    init (node: Node) {
        self.node = node
        _viewModel = StateObject(wrappedValue: PlotDemoViewModel(node: node))
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
                .disabled(viewModel.plotStatus == .plotting)
                
                //                SwiftUI.Picker("Feature", selection: $selectedFeatureIndex) {
                //                    ForEach(Array(viewModel.listOfFeatures.indices), id: \.self) { index in
                //                        Text(viewModel.listOfFeatures[index]?.shortName ?? "select one feature").font(.body)
                //                            .tag(index)
                //                    }
                //                }
                //                .pickerStyle(.menu)
                //                .onChange(of: selectedFeatureIndex) { _, newValue in
                //                    guard viewModel.listOfFeatures.indices.contains(newValue) else {
                //                        viewModel.unSelectFeature()
                //                        return
                //                    }
                //
                //                    if let feature = viewModel.listOfFeatures[newValue] {
                //                        viewModel.selectFeature(feature)
                //                    } else {
                //                        viewModel.unSelectFeature()
                //                    }
                //                }
                
                Spacer()
                
                switch(viewModel.plotStatus) {
                case .idle:
                    Button("Play", systemImage: "play", action: viewModel.switchPlotStatus).buttonStyle(.borderedProminent).disabled(viewModel.selectedFeature == nil)
                case .plotting:
                    Button("Stop", systemImage: "stop", action: viewModel.switchPlotStatus).buttonStyle(.borderedProminent)
                }
                
                
                
            }.frame(maxWidth: .infinity).padding(16)
            
            Text(viewModel.yAxisTitleLabel)
                .frame(maxWidth: .infinity,alignment: .leading)
                .padding([.leading, .trailing],8)
            
            PlotView(dataSets: viewModel.dataSets).padding([.leading, .trailing,],8)
            
            Text(viewModel.xAxisTitleLabel)
                .frame(maxWidth: .infinity,alignment: .trailing)
                .padding([.leading, .trailing],8)
            
            Text(viewModel.sampleDescription)
                .font(.caption)
                .lineLimit(1)
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing, .bottom],8)
            
        }.onAppear() {
            delegateHandler = PlotNodeBlueDelegateHandler(viewModel: self.viewModel)
            
            if let delegateHandler = delegateHandler {
                BlueManager.shared.addDelegate(delegateHandler)
            }
            
            selectedFeatureIndex = 0
            self.viewModel.loadFeatures(node: node)
        }.onDisappear() {
            
            if viewModel.plotStatus != .idle {
                viewModel.switchPlotStatus()
            }
            
            if let delegateHandler = delegateHandler {
                BlueManager.shared.removeDelegate(delegateHandler)
            }
            
            self.viewModel.clearFeatures()
            selectedFeatureIndex = 0
        }
    }
}

class PlotNodeBlueDelegateHandler: NSObject, BlueDelegate {
    var viewModel: PlotDemoViewModel
    
    init(viewModel: PlotDemoViewModel) {
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
        viewModel.updatePlotEntry(feature: feature, sample: sample)
    }
    
    func manager(_ manager: STBlueSDK.BlueManager, didReceiveCommandResponseFor node: STBlueSDK.Node, feature: any STBlueSDK.Feature, response: any STBlueSDK.FeatureCommandResponse) {
    }
    
    func manger(_ service: STBlueSDK.BlueManager, receivedDebugConsoleDataFor node: STBlueSDK.Node, data: Data) {}
}
