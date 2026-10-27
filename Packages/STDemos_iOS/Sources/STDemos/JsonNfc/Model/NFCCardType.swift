//
//  NFCCardType.swift
//  STDemos
//
//  Created by Luca Pezzoni on 26/10/2026.
//

public enum NFCCardType {
    case genericText
    case nfcWiFi
    case nfcVCard
    case nfcURL
}

extension NFCCardType {
    func getImageName () -> String {
        switch self {
        case .genericText:
            return "textformat.characters"
        case .nfcWiFi:
            return "wifi"
        case .nfcVCard:
            return "person.text.rectangle"
        case .nfcURL:
            return "link"
        }
    }
    
    func getShortDescription() -> String {
        switch self {
        case .genericText:
            return "Text"
        case .nfcWiFi:
            return "WiFi"
        case .nfcVCard:
            return "VCard"
        case .nfcURL:
            return "URL"
        }
    }
}
