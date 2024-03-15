//
//  Uploader.swift
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
import STUI

enum ConnectorError: Error {
    case none
    case connection
    
    var localizedDescription: String {
        switch self {
        case .none:
            return "Board connection complete"
        case .connection:
            return "Error during connection"
        }
    }
}

enum RequestMessage: String {
    case flow = "SF"
}

enum ResponseMessage: String {
    case flowRequestReceived = "Flow_Req_Received"
    case flowParsingOngoing = "Parsing_flow"
    case flowParseOK = "Flow_parse_ok"
    case flowError = "Error:"
}

enum UploaderError: Error {
    case none(message: String?)
    case deviceNotValid
    case fwVersionNotValid
//    case connection(error: ConnectorError)
    case trasmission(error: TransporterError)
    
    var localizedDescription: String {
        switch self {
        case .none:
            return "App loaded.\nDisconnect and reconnect to the board to activate the new feature."
        case .deviceNotValid:
            return "This functionality is available only with a SensorTile.box or SensorTile.box PRO board."
        case .fwVersionNotValid:
            return "Firmware version not valid"
//        case .connection(let error):
//            return error.localizedDescription
        case .trasmission(let error):
            return trasmissionLocalizedDescription(with: error)
        }
    }
    
    func trasmissionLocalizedDescription(with error: TransporterError) -> String {
        switch error {
        case .none(let message):
            if message.hasPrefix(ResponseMessage.flowError.rawValue) || message.contains(ResponseMessage.flowError.rawValue) {
                var errorCode = Int(message.replacingOccurrences(of: ResponseMessage.flowError.rawValue, with: ""))
                if let code = extractErrorCode(from: message, searchPattern: ResponseMessage.flowError.rawValue) {
                    errorCode = Int(code)
                }
                
                switch errorCode {
                case 0:
                    return "Firmware version error" /// App uploaded failed. Please update the board firmware
                case 1:
                    return "Parsing error" /// An error occurred on the board during App analysis.
                case 2:
                    return "Missing SD card error" /// SD card missing. Insert the memory card and try again.
                case 3:
                    return "USB not connected error" /// USB cable not connected. Connect the USB cable and try again
                case 4:
                    return "Missing SD file error" /// SD file needed for the app not found.
                case 5:
                    return "SD card input/output error" /// IO error during the app start up
                case 6:
                    return "Timeout error" /// There was an timeout error loading the App on the board.
                case 7:
                    return "Upload error" /// There was an error loading the App on the board.
                case 8:
                    return "App version error" /// App upload failed. Please update the application.
                case 9:
                    return "Flow compatibility error" /// App upload failed. Sequence of Sensors/Functions not compatible.
                case 10:
                    return "Flow NO error"
                case 11:
                    return "Flow recived"
                case 12:
                    return "Flow recived and parsed"
                default:
                    return "Unknown error"
                }
            } else {
                return error.localizedDescription == ResponseMessage.flowParseOK.rawValue ? "App loaded. Reconnect to the board to activate the new feature." : error.localizedDescription
            }
            
        default:
            return error.localizedDescription
        }
    }
    
    private func extractErrorCode(from message: String, searchPattern pattern: String) -> String? {
        if let range = message.range(of: pattern) {
            let startIndex = range.upperBound
            return String(message[startIndex...])
        }
        return nil
    }
}

protocol UploaderDelegate: AnyObject {
//    func requestConnection(to node: Node, uploader: Uploader, completion: BlueSTCompletion<ConnectorError>)
    func requestTransport(to node: Node, uploader: Uploader, data: Data, completion: BlueSTCompletion<TransporterError>)
}

class Uploader: NSObject {
    
    var toUpload: Uploadable?
    var completion: BlueSTCompletion<UploaderError> = nil
    
    weak var delegate: UploaderDelegate?
    
    func upload(toUpload: Uploadable, to node: Node, completion: BlueSTCompletion<UploaderError>) {
        self.toUpload = toUpload
        self.completion = completion
        
        if !(node.type == .sensorTileBox || node.type == .sensorTileBoxPro || node.type == .sensorTileBoxProB) {
            complete(with: .deviceNotValid)
            return
        }
        
        guard delegate != nil else { return }
        
        self.upload(toUpload: toUpload, to: node)
//        delegate.requestConnection(to: node, uploader: self) { [weak self] error in
//            guard let self = self else { return }
//            
//            switch error {
//            case .none:
//                self.upload(toUpload: toUpload, to: node)
//            default:
//                self.complete(with: .trasmission(error: .generic))
//            }
//        }
    }
}

private extension Uploader {
    
    func upload(toUpload: Uploadable, to node: Node) {
        
        guard let uploadData = toUpload.data() else {
            self.complete(with: .trasmission(error: .generic))
            return
        }
        
        print("----> Json <----")
        print("\(String(data: uploadData, encoding: .utf8) ?? "Error")")
        print("----> Json <----")
        
        let dataLength = CFSwapInt32HostToBig(UInt32(uploadData.count)).data
        let now = Date().toLocalDate()
        let nowData = CFSwapInt32HostToBig(UInt32(now.timeIntervalSince1970)).data
        
        guard let requestUploadData = RequestMessage.flow.rawValue.data(using: .utf8) else { return }
        
        var requestTransportData = Data()
        requestTransportData.append(requestUploadData)
        requestTransportData.append(dataLength)
        requestTransportData.append(nowData)
        
        if let msg = String(data: requestUploadData, encoding: .utf8) {
            print("SENT: " + msg)
        }
        
        self.delegate?.requestTransport(to: node, uploader: self, data: requestTransportData) { error in
            
            switch error {
            case .none(let message):
                if message == ResponseMessage.flowRequestReceived.rawValue {
                    StandardHUD.shared.show(with: "Request Recived.\n\n... Uploading ...")
                    self.delegate?.requestTransport(to: node, uploader: self, data: uploadData) { error in
                        self.complete(with: .trasmission(error: error))
                    }
                } else {
                    self.complete(with: .trasmission(error: error))
                }
            default:
                self.complete(with: .trasmission(error: error))
            }
        }
    }
    
    func complete(with error: UploaderError) {
        guard let completion = self.completion else {
            return
        }
        
        DispatchQueue.main.async {
            completion(error)
        }
    }
}


fileprivate extension Date {
    func toLocalDate()->Date{
        let timeZone = TimeZone.current
        let offset = TimeInterval(timeZone.secondsFromGMT(for: self))
        return Date(timeInterval: offset, since: self)
    }
}

extension UInt32 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt32>.size)
    }
}
