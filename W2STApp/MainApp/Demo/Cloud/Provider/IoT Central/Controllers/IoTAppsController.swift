//
//  IoTAppsController.swift
//  W2STApp
//
//  Created by Dimitri Giani on 27/05/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import Foundation

class IoTAppsController {
    static let IoTCentrals = "IoTCentrals"
    static let shared = IoTAppsController()
    
    var deviceID: String = ""
    var deviceName: String = ""
    
    var apps: [IoTCentralApp] {
        get {
            if let data = UserDefaults.standard.object(forKey: IoTAppsController.IoTCentrals) as? Data,
               let centrals = try? JSONDecoder().decode([IoTCentralApp].self, from: data) {
                return centrals
            }
            return []
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            UserDefaults.standard.setValue(data, forKey: IoTAppsController.IoTCentrals)
            UserDefaults.standard.synchronize()
        }
    }
    
    func removeApp(_ app: IoTCentralApp) {
        if let index = apps.firstIndex(where: { $0.subdomain == app.subdomain }) {
            apps.remove(at: index)
        }
    }
}
