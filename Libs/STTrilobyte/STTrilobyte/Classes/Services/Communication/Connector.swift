//
//  Connector.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 24/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation
import BlueSTSDK

enum ConnectorError: Error {
    case none
    case connection
    
    var localizedDescription: String {
        switch self {
        case .none:
            return "connection_success".localized()
        case .connection:
            return "connection_error".localized()
        }
    }
}

class Connector: NSObject {
    
    var connectionCompletion: BlueSTCompletion<ConnectorError> = nil
    
    func connect(to node: BlueSTSDKNode, completion: BlueSTCompletion<ConnectorError> ) {
        connectionCompletion = completion
        node.addStatusDelegate(self)
        node.connect()
    }
}

extension Connector: BlueSTSDKNodeStateDelegate {
    func node(_ node: BlueSTSDKNode, didChange newState: BlueSTSDKNodeState, prevState: BlueSTSDKNodeState) {
        
        guard let completion = connectionCompletion else { return }
        
        switch newState {
        case .connected:
            print("New State: \(newState.rawValue)")
            completion(.none)
        case .lost, .dead, .unreachable:
            print("New State: \(newState.rawValue)")
            completion(.connection)
        default:
            print("New State: \(newState.rawValue)")
        }
    }
}
