//
//  CommunicationService.swift
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

protocol Uploadable {
    func data() -> Data?
}

typealias BlueSTCompletion<T> = ((T) -> Void)?

class CommunicationService: NSObject {
    
    static let shared = CommunicationService()
    
//    private let discoverer = Discoverer()
    private let uploader = Uploader()
//    private let connector = Connector()
    private let transporter = Transporter()
    
//    func startDiscoveringNodes(_ updateBlock: (DiscoverUpdateBlock?)) {
//        discoverer.startDiscoveringNodes(updateBlock)
//    }
//    
//    func stopDiscoveringNodes() {
//        discoverer.stopDiscoveringNodes()
//    }
    
    func upload(toUpload: Uploadable, to node: Node, completion: BlueSTCompletion<UploaderError>) {
        uploader.delegate = self
        uploader.upload(toUpload: toUpload, to: node, completion: completion)
    }
    
}

extension CommunicationService: UploaderDelegate {
    
    func requestTransport(to node: Node, uploader: Uploader, data: Data, completion: BlueSTCompletion<TransporterError>) {
        transporter.send(data, to: node) { error  in
            guard let completion = completion else { return }
            completion(error)
        }
    }
    
//    func requestConnection(to node: Node, uploader: Uploader, completion: BlueSTCompletion<ConnectorError>) {
//        connector.connect(to: node) { error in
//            guard let completion = completion else { return }
//            completion(error)
//        }
//    }
}
