//
//  BaseFirmwareService.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

internal class BaseFirmwareService: FirmwareService {

    var firmwareType: FirmwareType?
    var url: URL?
    var firmwareData: Data?
    var callback: FirmwareUpgradeCallback?

    func currentVersion(_ completion: @escaping FirmwareVersionCompletion) {
        
    }

    func upgradeFirmware(with url: URL, type: FirmwareType, callback: FirmwareUpgradeCallback) {

        
        if(url.startAccessingSecurityScopedResource()==true) {
            do {
                let fileHandler = try FileHandle(forReadingFrom: url)
                
                let data = fileHandler.readDataToEndOfFile()
                fileHandler.closeFile()
                startLoading(with: url, type: type, firmwareData: data, callback: callback)
            } catch {
                print("Unexpected error: \(error).")
                callback.completion(url, .invalidFwFile)
            }
        } else {
            if url.description.contains("Containers/Data/Application") {
                do {
                    let fileHandler = try FileHandle(forReadingFrom: url)
                    let data = fileHandler.readDataToEndOfFile()
                    fileHandler.closeFile()
                    startLoading(with: url, type: type, firmwareData: data, callback: callback)
                } catch {
                    print("Unexpected error: \(error).")
                    callback.completion(url, .invalidFwFile)
                }
            } else {
                callback.completion(url, .invalidFwFile)
            }
        }
        
        url.stopAccessingSecurityScopedResource()
    }

    func startLoading(with url: URL, type: FirmwareType, firmwareData: Data, callback: FirmwareUpgradeCallback) {
        self.url = url
        self.firmwareType = type
        self.firmwareData = firmwareData
        self.callback = callback
    }
}
