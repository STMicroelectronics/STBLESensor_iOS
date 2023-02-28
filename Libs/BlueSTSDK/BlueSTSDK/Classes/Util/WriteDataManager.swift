//
//  WriteDataManager.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 24/02/21.
//

import Foundation

class WriteDataManager {
    class WriteData {
        let data: Data
        let completion: (Bool) -> Void
        init(data: Data, completion: @escaping (Bool) -> Void) {
            self.data = data
            self.completion = completion
        }
    }
    
    private var commands: [WriteData] = []
    private var isSending = false
    private let feature: BlueSTSDKFeature
    
    var debug = false
    
    init(feature: BlueSTSDKFeature) {
        self.feature = feature
    }
    
    func enqueueCommand(_ cmd: WriteData) {
        commands.append(cmd)
        
        if !isSending {
            dequeueCommand()
        }
    }
    
    private func dequeueCommand() {
        guard !commands.isEmpty, !isSending else { return }
        
        isSending = true
        
        let command = commands.removeFirst()
        
        sendWrite(command.data) { [weak self] success in
            command.completion(success)
            self?.isSending = false
            self?.dequeueCommand()
        }
    }
    
    private func sendWrite(_ data: Data, completion: @escaping (Bool) -> Void) {
        if debug {
            debugPrint("start write bytes: \(data.count) -> \(data)")
        }
        
        var bytes: [Data] = []
        var byteSend = 0
        
        while data.count - byteSend > 20 {
            let part = data[byteSend...byteSend + 19]
            bytes.append(part)
            byteSend += 20
        }
        if byteSend != data.count {
            let part = data[byteSend...]
            bytes.append(part)
        }
        
        guard !bytes.isEmpty else { completion(false); return }
        
        let parts = bytes.count
        
        func writeBytesPart(_ bytes: [Data], atIndex index: Int, completion: @escaping (Bool) -> Void) {
            if index < parts {
                if self.debug {
                    debugPrint("writing bytes: \(bytes[index])")
                }
                feature.writeBytes(bytes[index]) { success in
                    if success {
                        if index < parts {
                            writeBytesPart(bytes, atIndex: index + 1, completion: completion)
                        } else {
                            completion(true)
                        }
                    } else {
                        completion(false)
                    }
                }
            } else {
                completion(true)
            }
        }
        
        writeBytesPart(bytes, atIndex: 0) { success in
            if self.debug {
                debugPrint("bytes write completion: \(success)")
            }
            
            completion(success)
        }
    }
}
