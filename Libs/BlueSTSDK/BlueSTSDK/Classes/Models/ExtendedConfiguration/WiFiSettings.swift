//
//  WiFiSettings.swift
//  BlueSTSDK
//
//  Created by Dimitri Giani on 29/04/21.
//

import Foundation

public struct WiFiSettings: Codable {
    public enum WiFiSecurity: String, CaseIterable {
        case OPEN = "OPEN"
        case WEP = "WEP"
        case WPA = "WPA"
        case WPA2 = "WPA2"
        case WPAWPA2 = "WPA/WPA2"
    }
    
    public let enable: Bool?
    public let ssid: String?
    public let password: String?
    public let securityType: String?
    
    public init(enable: Bool?, ssid: String?, password: String?, securityType: String?) {
        self.enable = enable
        self.ssid = ssid
        self.password = password
        self.securityType = securityType
    }
}
