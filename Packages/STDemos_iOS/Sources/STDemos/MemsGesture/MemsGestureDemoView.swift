//
//  MemsGestureDemoView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 23/10/2026.
//

import SwiftUI
import STBlueSDK
import STUI

public struct MemsGestureDemoView: View {
    
    @StateObject private var viewModel = MemsGestureDemoViewModel()
    @State private var delegateHandler: MemsGestureBlueDelegateHandler?
    
    let node: Node
    
    init (node: Node) {
        self.node = node
    }
    
    public var body: some View {
        ZStack(alignment: .center) {
            if viewModel.gesture == nil {
                //Waiting the data
                Text("Waiting data…").font(.title)
                    .bold()
                    .foregroundColor(SUIColorLayout.primary.color)
                
            }
            
            MemsGestureContentView(gesture: viewModel.gesture)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .onAppear {
            delegateHandler = MemsGestureBlueDelegateHandler(viewModel: viewModel)
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


public struct MemsGestureContentView: View {
    
    let gesture: GestureType?
    
    public var body: some View {
        GeometryReader { geometry in
            let rowHeight = geometry.size.height / CGFloat(3) - 48
            
            VStack(alignment: .center, spacing: 0) {
                
                Image("mems_gesture_glance", bundle: STDemos.bundle)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: rowHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(gesture == .glance ? Color.yellow : Color.clear, lineWidth: 4)
                    )
                    .foregroundColor(
                        gesture == .glance
                        ? SUIColorLayout.primary.color
                        : SUIColorLayout.stGray5.color
                    )
                
                Image("mems_gesture_pickUp", bundle: STDemos.bundle)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.leading, 8) //for image too near to the border
                    .frame(height: rowHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(gesture == .pickUp ? Color.yellow : Color.clear, lineWidth: 4)
                    )
                    .foregroundColor(
                        gesture == .pickUp
                        ? SUIColorLayout.primary.color
                        : SUIColorLayout.stGray5.color
                    )
                
                Image("mems_gesture_wakeUp", bundle: STDemos.bundle)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: rowHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(gesture == .wakeUp ? Color.yellow : Color.clear, lineWidth: 4)
                    )
                    .foregroundColor(
                        gesture == .wakeUp
                        ? SUIColorLayout.primary.color
                        : SUIColorLayout.stGray5.color
                    )
                
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical,16)
        }
    }
}


class MemsGestureBlueDelegateHandler: NSObject, BlueDelegate {
    var viewModel: MemsGestureDemoViewModel
    
    init(viewModel: MemsGestureDemoViewModel) {
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
        case let sample as FeatureSample<MemsGestureData>:
            viewModel.evaluateSample(sample)
        default:
            break
        }
    }
}
