//
//  CloudMQTTDevUploadView.swift
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

public struct CloudMQTTDevUploadView: View {
    
    @State var mqttViewModel: CloudMQTTViewModel
    @State private var mqttFeature: [MQTTFeature]
    @State private var activeTopics: [String] = []
    @State var status: Bool = false
    
    private let delegateHandler: BlueDelegateHandler?
    let node: Node
    
    init(node: Node, mqttViewModel: CloudMQTTViewModel) {
        self.node = node
        self.mqttViewModel = mqttViewModel
        self.delegateHandler = BlueDelegateHandler(mqttViewModel: mqttViewModel)
        var features = node.characteristics.allFeatures()
        features = features.filter { $0.isDataNotifyFeature }
        var mqttFeature: [MQTTFeature] = []
        features.forEach { feature in
            mqttFeature.append(MQTTFeature(feature: feature, enabled: feature.isNotificationsEnabled))
        }
        self.mqttFeature = mqttFeature
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            
            Text("Device Connection")
                .font(.system(size: 24.0))
                .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            //MARK: - Server Configuration
            VStack(alignment: .leading, spacing: 16) {
                
                VStack(alignment: .leading) {
                    Text("STATUS").font(.stInfoBold) + Text("\(status ? " 🟢 CONNECTED" : " 🔴 DISCONNECTED")").font(.stInfo)
                    
                }

                HStack {
                    Text("TOPIC").font(.stInfoBold)
                    Text(mqttViewModel.currentTopic)
                        .font(.stInfo)
                        .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Text("MESSAGE")
                    .font(.stInfoBold)
                    .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                 
                Text(mqttViewModel.currentMessagePayload)
                    .font(.stInfo)
                    .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: 4)
            
            Text("Select Feature")
                .font(.system(size: 24.0))
                .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            List {
                ForEach(mqttFeature.indices, id: \.self) { index in
                    Toggle(mqttFeature[index].feature.name, isOn: Binding(
                        get: { mqttFeature[index].enabled },
                        set: { newValue in
                            mqttFeature[index].enabled = newValue
                            let feature = mqttFeature[index].feature
                            let featureName = removeFeatureSuffix(from: feature.name)
                            if newValue {
                                featureEnabled(featureName: featureName, feature: feature)
                            } else {
                                featureDisabled(featureName: featureName, feature: feature)
                            }
                        }
                    ))
                }
            }
            .listRowInsets(EdgeInsets()) // Remove padding from rows
            .listRowBackground(Color.clear) // Remove row background
            .listStyle(PlainListStyle()) // Remove grouped style background
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Upload Data")
        .padding()
        .onAppear {
            status = mqttViewModel.isConnStateConnected()
            if let delegateHandler = delegateHandler {
                BlueManager.shared.addDelegate(delegateHandler)
            }
        }
        .onDisappear {
            if let delegateHandler = delegateHandler {
                BlueManager.shared.removeDelegate(delegateHandler)
            }
            resetMqttUploadParameters()
        }
    }
    
    func featureEnabled(featureName: String, feature: Feature) {
        let topic = "\(mqttViewModel.session?.deviceID ?? "")/\(featureName)"
        mqttViewModel.subscribe(to: topic)
        activeTopics.append(topic)
        BlueManager.shared.enableNotifications(for: node, feature: feature)
        Logger.debug(text: "✅ Enabled: \(featureName)")
    }
    
    func featureDisabled(featureName: String, feature: Feature) {
        let topic = "\(mqttViewModel.session?.deviceID ?? "")/\(featureName)"
        mqttViewModel.unsubscribe(to: topic)
        activeTopics.removeAll(where: { $0 == topic })
        BlueManager.shared.disableNotifications(for: node, feature: feature)
        Logger.debug(text: "🚫 Disabled: \(featureName)")
    }
    
    func removeFeatureSuffix(from string: String) -> String {
        let suffix = "Feature"
        if string.hasSuffix(suffix) {
            return String(string.dropLast(suffix.count))
        } else {
            return string
        }
    }
    
    func resetMqttUploadParameters() {
        mqttViewModel.currentTopic = "---"
        mqttViewModel.currentMessagePayload = "---"
        mqttFeature.forEach { activeFeature in
            if activeFeature.enabled {
                BlueManager.shared.disableNotifications(for: node, feature: activeFeature.feature)
            }
        }
        activeTopics.forEach { topic in
            mqttViewModel.unsubscribe(to: topic)
        }
        mqttViewModel.mqtt?.disconnect()
    }

}

class BlueDelegateHandler: NSObject, BlueDelegate {
    
    let mqttViewModel: CloudMQTTViewModel
    
    init(mqttViewModel: CloudMQTTViewModel) {
        self.mqttViewModel = mqttViewModel
    }
    
    func manager(_ manager: BlueManager, discoveringStatus isDiscovering: Bool) {}
    func manager(_ manager: BlueManager, didDiscover node: Node) {}
    func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node]) {}
    func manager(_ manager: BlueManager, didChangeStateFor node: Node) {}
    func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
        guard let sample = sample else { return }
        Logger.debug(text: "\(sample.description)")
        
        mqttViewModel.currentMessagePayload = createJsonPayload(sample.description) ?? "---"
        
        if let deviceID = mqttViewModel.session?.deviceID {
            mqttViewModel.currentTopic = "\(deviceID)/\(removeFeatureSuffix(from: feature.name))"
            mqttViewModel.publish(message: mqttViewModel.currentMessagePayload, to: mqttViewModel.currentTopic)
        }
    }
    
    func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {}
    
    func removeFeatureSuffix(from string: String) -> String {
        let suffix = "Feature"
        if string.hasSuffix(suffix) {
            return String(string.dropLast(suffix.count))
        } else {
            return string
        }
    }
    
    func createJsonPayload(_ rawPayload: String) -> String? {
        var dict = [String: String]()
        let lines = rawPayload.split(separator: "\n")

        for line in lines {
            let parts = line.split(separator: ":", maxSplits: 1)
            if parts.count == 2 {
                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let value = parts[1].trimmingCharacters(in: .whitespaces)
                dict[key] = value
            }
        }

        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted]),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return nil
    }
}
