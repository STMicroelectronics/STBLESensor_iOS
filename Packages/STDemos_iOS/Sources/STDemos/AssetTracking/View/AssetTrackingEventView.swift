//
//  AssetTrackingEventView.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import Foundation
import STUI
import STBlueSDK
import STCore

public struct AssetTrackingEventView: View {
    
    @StateObject private var viewModel = AssetTrackingEventViewModel()
    @State private var delegateHandler: AssetTrackingNodeBlueDelegateHandler?
    @State private var isFallBoxFlashing = false
    @State private var isShockBoxFlashing = false
    
    @State private var showDialog = false
    @State private var showFilterDialog = false
    @State private var selectedShockEventItem: AssetTrackingShockEventDetected?
    
    @State private var isFallEventsVisible = true
    @State private var isShockEventsVisible = true
    
    let node: Node
    
    init (node: Node) {
        self.node = node
    }
    
    public var body: some View {
        ZStack {
            VStack(spacing: 8) {
                //MARK: - Summary
                Text("Summary")
                    .font(.system(size: 16.0).bold())
                    .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(alignment: .center) {
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 8) {
                        Image("asset_tracking_event_fall", bundle: STDemos.bundle)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:60.0, height:60.0)
                            .padding(8)
                            .background(isFallBoxFlashing ? ColorLayout.yellow.auto.swiftUIColor : ColorLayout.notActiveColor.auto.swiftUIColor)
                            .cornerRadius(8)
                            .padding(8)
                            .animation(.easeInOut(duration: 0.3), value: isFallBoxFlashing)
                        Text("Fall Detected")
                            .font(.system(size: 13.0).bold())
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                            .frame(alignment: .center)
                        Text("\(viewModel.fallTotalEvents) Events")
                            .font(.system(size: 13.0).weight(.light))
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                            .frame(alignment: .center)
                    }
                    .frame(alignment: .center)
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 8) {
                        Image("asset_tracking_event_shock", bundle: STDemos.bundle)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width:60.0, height:60.0)
                            .padding(8)
                            .background(isShockBoxFlashing ? ColorLayout.yellow.auto.swiftUIColor : ColorLayout.notActiveColor.auto.swiftUIColor)
                            .cornerRadius(8)
                            .padding(8)
                            .animation(.easeInOut(duration: 0.3), value: isShockBoxFlashing)
                        Text("Shock Detected")
                            .font(.system(size: 13.0).bold())
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                            .frame(alignment: .center)
                        Text("\(viewModel.shockTotalEvents) Events")
                            .font(.system(size: 13.0).weight(.light))
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                            .frame(alignment: .center)
                    }
                    .frame(alignment: .center)
                    
                    Spacer()
                }
                .frame(alignment: .center)
                
                //MARK: - Number of Events & Last Time
                
                if viewModel.currentStatus == nil {
                    HStack(spacing: 8) {
                        Text("Total Events")
                            .font(.system(size: 14.0).weight(.light))
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Text("\(viewModel.assetTrackingEvents.count)")
                            .font(.system(size: 14.0).weight(.bold))
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    Divider()
                }
                
                HStack(spacing: 8) {
                    Text("Last Event Time")
                        .font(.system(size: 14.0).weight(.light))
                        .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Text("\(viewModel.lastTimestampEvent)")
                        .font(.system(size: 14.0).weight(.bold))
                        .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                
                Divider()
                
                if viewModel.currentStatus != nil {
                    HStack(spacing: 8) {
                        Text("Status:")
                            .font(.system(size: 14.0).weight(.light))
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)

                        Text("\(viewModel.currentStatus ?? "N/A")")
                            .font(.system(size: 14.0).weight(.bold))
                            .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                        
                        Spacer()
                    }

                    AssetTrackingEventsAmpsView(currentMicroAmps: viewModel.amps ?? 0, powerIndex: viewModel.powerIndex ?? 0)
                    
                    Divider()
                }
                
                //MARK: - CLEAR button
//                HStack(spacing: 8) {
//                    Text("Events:")
//                        .font(.system(size: 16.0).bold())
//                        .foregroundColor(ColorLayout.text.auto.swiftUIColor)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    Spacer()
//                    Button(action: {
//                        viewModel.clearEvents()
//                    }) {
//                        Text("CLEAR")
//                            .foregroundColor(.white)
//                            .padding(.vertical, 12)
//                            .frame(maxWidth: .infinity)
//                            .background(ColorLayout.primary.auto.swiftUIColor)
//                            .cornerRadius(8)
//                            .padding(.vertical, 8)
//                    }
//                }
                HStack(spacing: 8) {
                    Text("Events:")
                        .font(.system(size: 14.0).bold())
                        .foregroundColor(ColorLayout.text.auto.swiftUIColor)

                    Spacer()
                    
                    HStack(spacing: 1) {
                        Button(action: {
                            isFallEventsVisible.toggle()
                        }) {
                            HStack {
                                if isFallEventsVisible {
                                    Image(systemName: "checkmark")
                                }
                                Text("Fall")
                                    .font(.system(size: 12.0).weight(.light))
                            }
                            .frame(minWidth: 80)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 8)
                            .background(isFallEventsVisible ? ColorLayout.primary.auto.swiftUIColor : ColorLayout.stGray5.auto.swiftUIColor)
                            .foregroundColor(isFallEventsVisible ? .white : ColorLayout.primary.auto.swiftUIColor)
                        }
                        .clipShape(RoundedCorner(radius: 20, corners: [.topLeft, .bottomLeft]))

                        Button(action: {
                            isShockEventsVisible.toggle()
                        }) {
                            HStack {
                                if isShockEventsVisible {
                                    Image(systemName: "checkmark")
                                }
                                Text("Shock")
                                    .font(.system(size: 12.0).weight(.light))
                            }
                            .frame(minWidth: 80)
                            .padding(.vertical, 16)
                            .padding(.horizontal, 8)
                            .background(isShockEventsVisible ? ColorLayout.primary.auto.swiftUIColor : ColorLayout.stGray5.auto.swiftUIColor)
                            .foregroundColor(isShockEventsVisible ? .white : ColorLayout.primary.auto.swiftUIColor)
                        }
                        .clipShape(RoundedCorner(radius: 20, corners: [.topRight, .bottomRight]))
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 1)
                    )

                    Spacer()
                    
                    Button(action: {
                        viewModel.clearEvents()
                    }) {
                        ImageLayout.SUICommon.delete?.resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.white)
                            .padding(14)
                            .background(ColorLayout.primary.auto.swiftUIColor)
                            .cornerRadius(8)
                    }
                }
                
                //MARK: - List of Events
                ScrollViewReader { scrollProxy in
                    List {
                        ForEach(evaluateActiveFilters(), id: \.timestamp) { item in
                            VStack(spacing: 0) {
                                if let fallEvent = item.fall {
                                    AssetTrackingFallEventView(fallEvent: fallEvent, timestamp: item.timestamp)
                                        .onAppear {
                                            self.animateCurrentBoxEvent(item: item)
                                        }
                                }
                                if let shockEvent = item.shock {
                                    AssetTrackingShockEventView(shockEvent: shockEvent, timestamp: item.timestamp)
                                        .onAppear {
                                            self.animateCurrentBoxEvent(item: item)
                                        }
                                        .onTapGesture {
                                            selectedShockEventItem = shockEvent
                                            showDialog = true
                                        }
                                }
                            }
                            .id(item.timestamp)
                        }
                        .listRowInsets(EdgeInsets()) // Remove padding from rows
                        .listRowBackground(Color.clear) // Remove row background
                        .listRowSeparator(.hidden) // Remove row line divider
                    }
                    .listStyle(PlainListStyle()) // Remove grouped style background
                    .background(Color.clear) // Remove List background
                    .onChange(of: viewModel.assetTrackingEvents.first?.timestamp) { newID in
                        if let id = newID {
                            withAnimation {
                                scrollProxy.scrollTo(id, anchor: .top)
                            }
                        }
                    }
                }
            }
            .padding()
            
            // Filter FAB Button
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        showFilterDialog = true
//                    }) {
//                        ImageLayout.SUICommon.filter?.resizable()
//                            .frame(width: 24, height: 24)
//                            .foregroundColor(ColorLayout.primary.auto.swiftUIColor)
//                            .padding()
//                            .background(ColorLayout.secondary.auto.swiftUIColor)
//                            .clipShape(Circle())
//                            .shadow(radius: 4)
//                    }
//                    .padding()
//                }
//            }
//            
//            if showFilterDialog {
//                Color.black.opacity(0.2)
//                    .ignoresSafeArea()
//                    .onTapGesture {
//                        showFilterDialog = false
//                    }
//                
//                AssetTrackingEventFilterDialogView(isFilterDialogVisible: $showFilterDialog, isShockEventsVisible: $isShockEventsVisible, isFallEventsVisible: $isFallEventsVisible)
//                    .frame(maxWidth: 310)
//                    .transition(.scale)
//                    .zIndex(1)
//            }
            
            if showDialog, let item = selectedShockEventItem {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showDialog = false
                    }
                
                ShockEventDetailsDialogView(item: item, isVisible: $showDialog)
                    .frame(maxWidth: 310)
                    .transition(.scale)
                    .zIndex(1)
            }
        }
        .animation(.easeInOut, value: showDialog)
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
            delegateHandler = AssetTrackingNodeBlueDelegateHandler(viewModel: viewModel)
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
    
    private func animateCurrentBoxEvent(item: AssetTrackingEventDetected) {
        if item.fall != nil {
            isFallBoxFlashing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                isFallBoxFlashing = false
            }
        } else if item.shock != nil {
            isShockBoxFlashing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                isShockBoxFlashing = false
            }
        }
    }
    
    private func getCurrentTimestamp() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
    
    private func evaluateActiveFilters() -> [AssetTrackingEventDetected] {
        var filteredEvents = viewModel.assetTrackingEvents
        
        if !isFallEventsVisible {
            filteredEvents = filteredEvents.filter { $0.fall == nil && $0.shock != nil }
        }
        if !isShockEventsVisible {
            filteredEvents = filteredEvents.filter { $0.fall != nil && $0.shock == nil }
        }
        
        return filteredEvents
    }
}

class AssetTrackingNodeBlueDelegateHandler: NSObject, BlueDelegate {
    var viewModel: AssetTrackingEventViewModel

    init(viewModel: AssetTrackingEventViewModel) {
        self.viewModel = viewModel
    }
    
    private func timestampCorrect(_ timestamp: UInt64) {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone.current

        let localTime = formatter.string(from: date)
        print(localTime)
    }
    
    func manager(_ manager: BlueManager, discoveringStatus isDiscovering: Bool) {}
    func manager(_ manager: BlueManager, didDiscover node: Node) {}
    func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node]) {}
    func manager(_ manager: BlueManager, didChangeStateFor node: Node) {}
    func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {}
    func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
        guard let sample = sample else { return }
        if let sample = sample as? FeatureSample<AssetTrackingEventData> {
            viewModel.evaluateEvent(sample)
        }
    }
}

extension Array where Element == Float {
    func computeNorm() -> Float {
        let norm = self.reduce(0) { $0 + $1 * $1 }
        return sqrt(norm)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
