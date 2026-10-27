//
//  CarryPositionDemoView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 19/10/2026.
//


import SwiftUI
import STBlueSDK
import STUI

public struct CarryPositionDemoView: View {
    
    @StateObject private var viewModel = CarryPositionDemoViewModel()
    @State private var delegateHandler: CarryPostionBlueDelegateHandler?
    
    let node: Node
    
    init (node: Node) {
        self.node = node
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            if(viewModel.position == .unknown) {
                //Waiting the data
                Text("Waiting data…").font(.title)
                    .bold()
                    .foregroundColor(SUIColorLayout.primary.color)
                
            } else if (viewModel.position == .error) {
                //If there will be one error
                Text("Error").font(.title)
                    .bold()
                    .foregroundColor(SUIColorLayout.errorRed.color)
            }
            
            GeometryReader { geometry in
                let visibleRows = CarryPositionType.allCases.filter { $0.getImageName() != nil }
                let rowHeight = visibleRows.isEmpty ? 0 : geometry.size.height / CGFloat(visibleRows.count)

                VStack(spacing: 0) {
                    ForEach(CarryPositionType.allCases, id: \.self) { position in
                        if let realPosition = position.getImageName() {
                            HStack(alignment: .center,  spacing: 16) {
                                Image(realPosition, bundle: STDemos.bundle)
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: .infinity)
                                    .foregroundColor(
                                        viewModel.position == position
                                        ? SUIColorLayout.primary.color
                                        : SUIColorLayout.stGray5.color
                                    )
                                
                                Text(position.getDescription())
                                    .foregroundColor(
                                        viewModel.position == position
                                        ? SUIColorLayout.primary.color
                                        : SUIColorLayout.stGray5.color
                                    )
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: rowHeight, alignment: .leading)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .onAppear {
            delegateHandler = CarryPostionBlueDelegateHandler(viewModel: viewModel)
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

class CarryPostionBlueDelegateHandler: NSObject, BlueDelegate {
    var viewModel: CarryPositionDemoViewModel
    
    init(viewModel: CarryPositionDemoViewModel) {
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
        case let sample as FeatureSample<CarryPositionData>:
            viewModel.evaluateSample(sample)
        default:
            break
        }
    }
}
