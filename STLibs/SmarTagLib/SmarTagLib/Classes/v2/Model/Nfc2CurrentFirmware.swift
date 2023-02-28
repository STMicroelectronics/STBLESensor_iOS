//
//  Nfc2CurrentFirmware.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class Nfc2CurrentFirmware {
    
    private static let currentFwKey = "Nfc2CurrentFwKey"
    
    public init() {
        Self.self
    }
    
    public func currentFw() -> Nfc2Firmware? {
        let userDefaults = UserDefaults.standard
        
        let storedCurrentFw = userDefaults.object(forKey: Nfc2CurrentFirmware.currentFwKey)
        
        if let storedCurrentFw = storedCurrentFw as? Data {
            let decoder = JSONDecoder()
            if let loadedCurrentFw = try? decoder.decode(Nfc2Firmware.self, from: storedCurrentFw) {
                return loadedCurrentFw
            }
        }
        
        return nil
    }
    
    @discardableResult
    func storeCurrentFw(_ currentFw: Nfc2Firmware?) -> Nfc2Firmware? {
        let userDefaults = UserDefaults.standard
        
        guard let currentFw = currentFw else {
            userDefaults.removeObject(forKey: Nfc2CurrentFirmware.currentFwKey)
            userDefaults.synchronize()
            return currentFw
        }
    
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(currentFw) {
            userDefaults.set(encoded, forKey: Nfc2CurrentFirmware.currentFwKey)
            userDefaults.synchronize()
            return currentFw
        }
        
        return nil
    }
}
