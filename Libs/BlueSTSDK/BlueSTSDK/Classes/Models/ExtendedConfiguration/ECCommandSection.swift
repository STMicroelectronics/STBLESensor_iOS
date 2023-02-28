//
//  ECCommandSection.swift
//  W2STApp
//
//  Created by Dimitri Giani on 28/04/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import Foundation

public enum ECCommandSection: String {
    case boardReport
    case boardSecurity
    case boardControl
    case boardSettings
    case customCommands
}

public extension ECCommandSection {
    var title: String {
        "ext.command.section.\(rawValue).title"
    }
    
    var iconName: String {
        switch self {
            case .boardReport:
                return "ic_ext_conf_report"
            case .boardSecurity:
                return "ic_ext_conf_security"
            case .boardControl:
                return "ic_ext_conf_control"
            case .boardSettings:
                return "ic_ext_conf_settings"
            case .customCommands:
                return "ic_ext_conf_custom_commands"
        }
    }
    
    var commands: [ECCommandType] {
        switch self {
            case .boardReport:
                return [.UID, .versionFw, .info, .help, .powerStatus]
            case .boardSecurity:
                return [.changePIN, .clearDB, .readCert, .setCert]
            case .boardControl:
                return [.DFU, .off]
            case .boardSettings:
                return [.setName, .readCustomCommand, .setTime, .setDate, .readSensorsConfig, .setWiFi]
            case .customCommands:
                return []
        }
    }
}
