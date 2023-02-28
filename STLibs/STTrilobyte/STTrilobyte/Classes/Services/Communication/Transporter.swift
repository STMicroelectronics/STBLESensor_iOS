//
//  Transporter.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 24/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation
import BlueSTSDK

enum TransporterError: Error {
    case none(message: String)
    case timeout
    case generic
    
    var localizedDescription: String {
        switch self {
        case .none(let message):
            return message
        case .timeout:
            return "transport_timeout_error".localized()
        case .generic:
            return "transport_generic_error".localized()
        }
    }
}

class Transporter: NSObject {
    
    private var completion: BlueSTCompletion<TransporterError> = nil
    private var node: BlueSTSDKNode?
    
    func send(_ data: Data, to node: BlueSTSDKNode, completion: BlueSTCompletion<TransporterError>) {
        self.node = node
        self.completion = completion
        node.debugConsole?.add(self)
        
        node.debugConsole?.writeMessageData(data)
    }
}

extension Transporter: BlueSTSDKDebugOutputDelegate {
    func debug(_ debug: BlueSTSDKDebug, didStdOutReceived msg: String) {
        guard let completion = self.completion else { return }
        //print("RECEIVED: " + msg)
        NSLog("RECEIVED: " + msg)
        
        if msg.withoutTerminator() == ResponseMessage.flowRequestReceived.rawValue ||
            msg.withoutTerminator() == ResponseMessage.flowParseOK.rawValue ||
            msg.contains(ResponseMessage.flowError.rawValue) {
            node?.debugConsole?.remove(self)
            completion(.none(message: msg.withoutTerminator()))
        }
    }
    
    func debug(_ debug: BlueSTSDKDebug, didStdErrReceived msg: String) {
        guard let completion = self.completion else { return }
        print("ERROR: " + msg.withoutTerminator())
        node?.debugConsole?.remove(self)
        completion(.generic)
    }
    
    func debug(_ debug: BlueSTSDKDebug, didStdInSend msg: String, error: Error?) {
    }
}
