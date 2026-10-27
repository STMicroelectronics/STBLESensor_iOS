//
//  WiFiCardContent.swift
//  STDemos
//
//  Created by Luca Pezzoni on 26/10/2026.
//

import SwiftUI
import STBlueSDK
import STUI

private let wiFiEncryptionStrings: [WifiEncryption] = [
    WifiEncryption("NONE", 1),
    WifiEncryption("WEP", 2),
    WifiEncryption("TKIP", 4),
    WifiEncryption("AES", 8),
]

private let wiFiAuthenticationStrings: [WifiAuthenticationString] = [
    WifiAuthenticationString("NONE", 1),
    WifiAuthenticationString("WPAPSK", 2),
    WifiAuthenticationString("SHARED", 4),
    WifiAuthenticationString("WPA", 8),
    WifiAuthenticationString("WPA2", 16),
    WifiAuthenticationString("WPA2PSK", 32),
]

struct WiFiCardContent: View {
    @ObservedObject var viewModel: JsonNfcDemoViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var internalTextPasswordValue: String = ""
    @State private var internalTextSSIDValue: String = ""
    @State private var wiFiEncryptionIndex: Int = 0
    @State private var wiFiAuthenticationIndex: Int = 0
    
    var body: some View {
        NFCCard (nfcCardType: .nfcWiFi) {
            VStack(alignment: .center, spacing: 8) {
                
                
                HStack {
                    Text("Encryption")
                    Spacer()
                    
                    SwiftUI.Picker("Encryption", selection: $wiFiEncryptionIndex) {
                        ForEach(wiFiEncryptionStrings.indices, id: \.self) { index in
                            Text(wiFiEncryptionStrings[index].displayName).tag(index)
                        }
                    }
                    .pickerStyle(.menu)
                    
                }.frame(maxWidth: .infinity)
                
                HStack {
                    Text("Authentication")
                    Spacer()
                    
                    SwiftUI.Picker("Authentication", selection: $wiFiAuthenticationIndex) {
                        ForEach(wiFiAuthenticationStrings.indices, id: \.self) { index in
                            Text(wiFiAuthenticationStrings[index].displayName).tag(index)
                        }
                    }
                    .pickerStyle(.menu)
                    
                }.frame(maxWidth: .infinity)
                
                
                HStack {
                    Text("Password")
                    
                    Spacer()
                    SwiftUI.SecureField("", text: $internalTextPasswordValue)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                        .textContentType(.password)
                        .autocapitalization(.none)
                }.frame(maxWidth: .infinity)
                
                HStack {
                    Text("SSID")
                    
                    Spacer()
                    SwiftUI.TextField("", text: $internalTextSSIDValue)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                        .autocapitalization(.none)
                }.frame(maxWidth: .infinity)
                
                HStack {
                    Spacer()
                    Button(action: {
                        isTextFieldFocused = false
                        let command = JsonWriteCommand<String>(
                            command: nil,
                            genericText: nil,
                            nfcWiFi: JsonWIFI(networkSSID: internalTextSSIDValue,
                                              networkKey: internalTextPasswordValue,
                                              authenticationType: wiFiAuthenticationStrings[wiFiAuthenticationIndex].rawValue,
                                              encryptionType: wiFiEncryptionStrings[wiFiEncryptionIndex].rawValue),
                            nfcVCard: nil,
                            nfcURL: nil
                        )
                        viewModel.sendJsonCommand(command,"NDEF Record Written on NFC")
                    }) {
                        Text("Write to NFC")
                    }.buttonStyle(.borderedProminent)
                }.frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
        }
    }
}
