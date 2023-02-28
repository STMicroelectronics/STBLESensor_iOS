//
//  CommunicationService.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 24/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation
import BlueSTSDK

protocol Uploadable {
    func data() -> Data?
}

typealias BlueSTCompletion<T> = ((T) -> Void)?

class CommunicationService: NSObject {
    
    static let shared = CommunicationService()
    
    private let discoverer = Discoverer()
    private let uploader = Uploader()
    private let connector = Connector()
    private let transporter = Transporter()
    
    func startDiscoveringNodes(_ updateBlock: (DiscoverUpdateBlock?)) {
        discoverer.startDiscoveringNodes(updateBlock)
    }
    
    func stopDiscoveringNodes() {
        discoverer.stopDiscoveringNodes()
    }
    
    func upload(toUpload: Uploadable, to node: BlueSTSDKNode, completion: BlueSTCompletion<UploaderError>) {
        uploader.delegate = self
        uploader.upload(toUpload: toUpload, to: node, completion: completion)
    }
    
}

extension CommunicationService: UploaderDelegate {
    
    func requestTransport(to node: BlueSTSDKNode, uploader: Uploader, data: Data, completion: BlueSTCompletion<TransporterError>) {
        transporter.send(data, to: node) { error  in
            guard let completion = completion else { return }
            completion(error)
        }
    }
    
    func requestConnection(to node: BlueSTSDKNode, uploader: Uploader, completion: BlueSTCompletion<ConnectorError>) {
        connector.connect(to: node) { error in
            guard let completion = completion else { return }
            completion(error)
        }
    }
}
