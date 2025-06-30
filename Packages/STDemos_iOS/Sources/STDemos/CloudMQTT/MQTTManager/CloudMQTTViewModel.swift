//
//  CloudMQTTViewModel.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import CocoaMQTT
import Foundation
import STBlueSDK

// MARK: - MQTTSession
public struct MQTTSession: Codable {
    public var hostUrl: String
    public var port: String
    public var username: String?
    public var password: String?
    public var deviceID: String
}

// MARK: - MQTTFeature
public struct MQTTFeature: Identifiable {
    public let id = UUID()
    public let feature: Feature
    public var enabled: Bool
}

class CloudMQTTViewModel: ObservableObject {
    var mqtt: CocoaMQTT?
    public var session: MQTTSession?
    public var onConnect: (() -> Void)?
    public var onConnectionError: ((String) -> Void)?
    @Published public var currentMessagePayload: String = "---"
    @Published public var currentTopic: String = "---"
    
    func saveMqttSessionConfigurationAndConnect(_ hostUrl: String,
                                     _ port: String,
                                     _ username: String?,
                                     _ password: String?,
                                     _ deviceID: String) {
        
        let mqttSession = MQTTSession(
            hostUrl: hostUrl,
            port: port,
            username: username,
            password: password,
            deviceID: deviceID)
        
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(mqttSession) {
            UserDefaults.standard.set(encoded, forKey: "MqttConfiguration")
        }
        
        session = mqttSession
        
        connect(mqttSession)
    }
    
    func loadMqttSessionConfiguration() -> MQTTSession? {
        if let savedData = UserDefaults.standard.data(forKey: "MqttConfiguration") {
            let decoder = JSONDecoder()
            if let loadedConfiguration = try? decoder.decode(MQTTSession.self, from: savedData) {
                return loadedConfiguration
            }
        }
        return nil
    }
    
    private func connect(_ session: MQTTSession) {
        let clientID = "iOSClient-\(UUID().uuidString.prefix(6))"
        
        if let numberPort = UInt16(session.port) {
            mqtt = CocoaMQTT(clientID: clientID, host: session.hostUrl, port: numberPort)
            mqtt?.username = session.username
            mqtt?.password = session.password
            mqtt?.delegate = self
            mqtt?.connect()
        } else {
            print("Conversion failed: string is not a valid UInt16")
        }
    }
    
    public func subscribe(to topic: String) {
        mqtt?.subscribe(topic)
    }
    
    public func unsubscribe(to topic: String) {
        mqtt?.unsubscribe(topic)
    }
    
    public func publish(message: String, to topic: String) {
        mqtt?.publish(topic, withString: message)
    }
    
    public func isConnStateConnected() -> Bool {
        guard let mqtt = mqtt else { return false }
        return mqtt.connState == .connected
    }
}

extension CloudMQTTViewModel: CocoaMQTTDelegate {
    public func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        if ack == .accept {
            onConnect?()
            print("✅ MQTT connected successfully!")
        } else {
            onConnectionError?("❌ MQTT connection failed: \(ack)")
            print("\(ack)")
        }
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("Message published: \(message.string ?? "")")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        print("Received message: \(message.string ?? "")")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("didSubscribeTopics")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("didUnsubscribeTopics")
    }
    
    public func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("mqttDidPing")
    }
    
    public func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("mqttDidReceivePong")
    }
    
    public func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: (any Error)?) {
        print("mqttDidDisconnect with error: \(err.debugDescription)")
    }
}
