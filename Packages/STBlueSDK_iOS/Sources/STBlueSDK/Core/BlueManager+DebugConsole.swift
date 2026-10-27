//
//  BlueManage+DebugConsole.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import CoreBluetooth

public extension BlueManager {
    
    @discardableResult
    func sendMessage(_ message: String, to node: Node, completion: DebugConsoleCallback) -> Bool {
        guard let nodeService = nodeServices.nodeService(with: node),
              let debugConsole = nodeService.debugConsole,
              let data = DebugConsole.stringToData(message) else { return false }

        debugConsole.addDelegate(completion)
        debugConsole.write(data: data)

        return true
    }
    
    @discardableResult
    func sendMessageWithoutQueue(_ message: String, to node: Node, completion: DebugConsoleCallback) -> Bool {
        guard let nodeService = nodeServices.nodeService(with: node),
              let debugConsole = nodeService.debugConsole,
              let data = DebugConsole.stringToData(message) else { return false }

        debugConsole.addDelegate(completion)
        debugConsole.writeWithoutQueue(data)

        return true
    }
    
    @discardableResult
    func sendMessageWithoutQueueNoCallBack(_ message: String, to node: Node) -> Bool {
        guard let nodeService = nodeServices.nodeService(with: node),
              let debugConsole = nodeService.debugConsole,
              let data = DebugConsole.stringToData(message) else { return false }

        debugConsole.writeWithoutQueue(data)

        return true
    }
    
    func getTermCharacteristic(to node: Node) -> CBCharacteristic? {
        guard let nodeService = nodeServices.nodeService(with: node),
              let debugConsole = nodeService.debugConsole  else { return nil }
        return debugConsole.termCharacteristic
    }
    
    @discardableResult
    func sendData(_ data: Data, to node: Node, completion: DebugConsoleCallback) -> Bool {
        guard let nodeService = nodeServices.nodeService(with: node),
              let debugConsole = nodeService.debugConsole else {return false}
        
        debugConsole.addDelegate(completion)
        debugConsole.write(data: data)

        return true
    }
}
