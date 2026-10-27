//
//  JsonNfcDemoViewModel.swift
//  STDemos
//
//  Created by Luca Pezzoni on 26/10/2026.
//

import Foundation
import STBlueSDK


private let commandReadModes = "ReadModes"
private let commandWiFi = "NFCWiFi"
private let commandVCard = "NFCVCard"
private let commandUrl = "NFCURL"
private let commandText = "GenericText"

class JsonNfcDemoViewModel: ObservableObject {
    
    @Published var supportedModes: String? = nil
    @Published var hasNFCWiFi: Bool = false
    @Published var hasNFCVCard: Bool = false
    @Published var hasNFCURL: Bool = false
    @Published var hasGenericText: Bool = false
    
    let node: Node
    
    public init(node: Node) {
        self.node = node
    }
    
    var messageToShow: String = ""
    @Published var showMessage: Bool = false
    
    func evaluateSample(_ sample: FeatureSample<JsonNFCData>) {
        if let answer = sample.data?.response.value?.answer {
            self.supportedModes = answer
            
            self.hasNFCWiFi = answer.contains(commandWiFi)
            self.hasNFCVCard = answer.contains(commandVCard)
            self.hasNFCURL = answer.contains(commandUrl)
            self.hasGenericText = answer.contains(commandText)
        }
    }
    
    func readModes() {
        let command = JsonWriteCommand<String>(
            command: commandReadModes,
            genericText: nil,
            nfcWiFi: nil,
            nfcVCard: nil,
            nfcURL: nil
        )
        sendJsonCommand(command)
    }
    
    func sendJsonCommand(_ command: JsonWriteCommand<String>, _ message: String = "") {
        if let jsonNFCFeature = node.characteristics.first(with: JsonNFCFeature.self) {
            
            BlueManager.shared.sendJsonCommand(
                StandardJsonCommand(value: command),
                maxWriteLength: 20,
                to: node,
                feature: jsonNFCFeature
            )
            
            if !message.isEmpty {
                self.messageToShow = message
                self.showMessage = true
            }
        }
    }
}
