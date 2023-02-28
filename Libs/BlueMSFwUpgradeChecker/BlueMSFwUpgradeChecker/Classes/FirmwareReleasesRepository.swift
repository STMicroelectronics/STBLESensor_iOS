//
//  FirmwareReleasesRepository.swift
//  BlueMSFwUpgradeChecker
//
//  Created by Giovanni Visentini on 07/05/2019.
//  Copyright © 2019 STCentralLab. All rights reserved.
//

import Foundation

class FirmwareReleasesRepository{
    
    private static let LAST_SYNC_KEY = "BlueMSFwUpgradeChecker.lastSync"
    private static let LAST_DATA_KEY = "BlueMSFwUpgradeChecker.lastData"
    private static let MIN_REMOTE_REFRESH = TimeInterval(24*60*60) //1day
    
    private static let DECODER:JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(FirmwareReleasesRepository.DATE_FORMATTER)
        return decoder
    }()
    
    private static let ENCODER:JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(FirmwareReleasesRepository.DATE_FORMATTER)
        return encoder
    }()
    
    private static let DATE_FORMATTER:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat="dd-MM-yyyy"
        return formatter
    }()
    
    private let localStorage = UserDefaults.standard
    private let remoteDataUrl:URL
    
    init( remoteDataUrl:URL){
            self.remoteDataUrl = remoteDataUrl
    }
    
    public func loadFwReleases(_ callback:@escaping (FirmwareReleases?)->()){
        if(needRemoteRefresh()){
            loadRemote{ releases in
                callback(releases)
                if let releases = releases{
                    self.localStore(fwReleases: releases)
                }
            }
        }else{
            callback(localLoad())
        }
    }

    private func needRemoteRefresh()->Bool{
        guard let lastSync = localStorage.object(forKey: FirmwareReleasesRepository.LAST_SYNC_KEY) as? Date else{
            return true
        }
        return (Date().timeIntervalSince(lastSync) > FirmwareReleasesRepository.MIN_REMOTE_REFRESH)
    }
    
    private func loadRemote(_ callback:@escaping (FirmwareReleases?)->()){
        let request = URLRequest(url: remoteDataUrl)
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let rawData = data else{
                callback(nil)
                return
            }
            let decoder = FirmwareReleasesRepository.DECODER
            let fwRelease = try? decoder.decode(FirmwareReleases.self, from: rawData)
            callback(fwRelease)
        }
        task.resume()
    }
    
    
    private func localStore(fwReleases:FirmwareReleases){
        guard let data = try? FirmwareReleasesRepository.ENCODER.encode(fwReleases) else {
            NSLog("Impossible to store the fw release data")
            return
        }
        localStorage.set(data, forKey: FirmwareReleasesRepository.LAST_DATA_KEY)
        localStorage.set(Date(), forKey: FirmwareReleasesRepository.LAST_SYNC_KEY)
    }
    
    private func localLoad()->FirmwareReleases?{
        guard let data = localStorage.data(forKey: FirmwareReleasesRepository.LAST_DATA_KEY) else {
            return nil
        }
        //the data is correct, but the lastUpgrade field is decoded in a wrong way.. 
        guard let fwReleases = try? FirmwareReleasesRepository.DECODER.decode(FirmwareReleases.self, from: data) else {
            return nil
        }
        return fwReleases
    }
}
