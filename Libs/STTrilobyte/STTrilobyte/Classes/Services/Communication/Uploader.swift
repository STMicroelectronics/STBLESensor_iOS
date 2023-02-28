//
//  Uploader.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 23/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import Foundation
import BlueSTSDK
import BlueSTSDK_Gui

enum RequestMessage: String {
    case flow = "SF"
}

enum ResponseMessage: String {
    case flowRequestReceived = "Flow_Req_Received"
    case flowParseOK = "Flow_parse_ok"
    case flowError = "Error:"
}

enum UploaderError: Error {
    case none(message: String?)
    case deviceNotValid
    case fwVersionNotValid
    case connection(error: ConnectorError)
    case trasmission(error: TransporterError)
    
    var localizedDescription: String {
        switch self {
        case .none:
            return "upload_uploaded_successfully".localized()
        case .deviceNotValid:
            return "wrong_board_error".localized()
        case .fwVersionNotValid:
            return "upload_error_fw_version_not_valid".localized()
        case .connection(let error):
            return error.localizedDescription
        case .trasmission(let error):
            return trasmissionLocalizedDescription(with: error)
        }
    }
    
    func trasmissionLocalizedDescription(with error: TransporterError) -> String {
        switch error {
        case .none(let message):
            if message.hasPrefix(ResponseMessage.flowError.rawValue) {
                let errorCode = Int(message.replacingOccurrences(of: ResponseMessage.flowError.rawValue, with: ""))
                
                switch errorCode {
                case 0:
                    return "board_fw_version_error".localized()
                case 1:
                    return "board_parsing_error".localized()
                case 2:
                    return "board_missing_sd_error".localized()
                case 3:
                    return "board_usb_error".localized()
                case 4:
                    return "needed_file_not_present".localized()
                case 5:
                    return "board_io_error".localized()
                case 6:
                    return "board_generic_upload_error".localized()
                default:
                    return "app_version_error".localized()
                }
            } else {
                return error.localizedDescription == ResponseMessage.flowParseOK.rawValue ? "upload_uploaded_successfully".localized() : error.localizedDescription
            }
            
        default:
            return error.localizedDescription
        }
    }
}

protocol UploaderDelegate: class {
    func requestConnection(to node: BlueSTSDKNode, uploader: Uploader, completion: BlueSTCompletion<ConnectorError>)
    func requestTransport(to node: BlueSTSDKNode, uploader: Uploader, data: Data, completion: BlueSTCompletion<TransporterError>)
}

class Uploader: NSObject {
    
    var toUpload: Uploadable?
    var completion: BlueSTCompletion<UploaderError> = nil
    
    weak var delegate: UploaderDelegate?
    
    func upload(toUpload: Uploadable, to node: BlueSTSDKNode, completion: BlueSTCompletion<UploaderError>) {
        self.toUpload = toUpload
        self.completion = completion
        
        if node.type != .sensor_Tile_Box {
            complete(with: .deviceNotValid)
            return
        }
        
        guard let delegate = delegate else { return }
        
        delegate.requestConnection(to: node, uploader: self) { [weak self] error in
            guard let self = self else { return }
            
            switch error {
            case .none:
                self.upload(toUpload: toUpload, to: node)
            default:
                self.complete(with: .connection(error: error))
            }
        }
    }
}

private extension Uploader {
    
    func upload(toUpload: Uploadable, to node: BlueSTSDKNode) {
        
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
