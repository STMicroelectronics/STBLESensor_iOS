//
//  Transporter.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STBlueSDK
import STCore

enum TransporterError: Error {
    case none(message: String)
    case timeout
    case generic
    
    var localizedDescription: String {
        switch self {
        case .none(let message):
            return message
        case .timeout:
            return "Timeout"
        case .generic:
            return "Error"
        }
    }
}

class Transporter: NSObject {
    
    private var completion: BlueSTCompletion<TransporterError> = nil
    private var node: Node?
    
    func send(_ data: Data, to node: Node, completion: BlueSTCompletion<TransporterError>) {
        self.node = node
        self.completion = completion
        
        BlueManager.shared.sendData(
            data,
            to: node,
            completion: DebugConsoleCallback(
                timeOut: 10.0,
                onCommandResponds: { [weak self] textMsg in
                    guard self != nil else { return }
                    
                    NSLog("[FLOW] DEBUG CONSOLE\nMessage RECEIVED: " + textMsg)
                    
                    if textMsg.withoutTerminator() == ResponseMessage.flowRequestReceived.rawValue ||
                        textMsg.withoutTerminator() == ResponseMessage.flowParsingOngoing.rawValue ||
                        textMsg.withoutTerminator() == ResponseMessage.flowParseOK.rawValue ||
                        textMsg.contains(ResponseMessage.flowError.rawValue) {
                        (completion!)(.none(message: textMsg.withoutTerminator()))
                    } else if (textMsg.withoutTerminator().contains(ResponseMessage.flowParseOK.rawValue)){
                        (completion!)(.none(message: ResponseMessage.flowParseOK.rawValue.withoutTerminator()))
                    }
                }, onCommandError: {
                    (completion!)(.none(message: "Error.\nSomething went wrong. Please restart the board"))
                }
            )
        )
    }
}

extension String {
    func withoutTerminator() -> String {
        return self.replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "\n", with: "")
    }
}
