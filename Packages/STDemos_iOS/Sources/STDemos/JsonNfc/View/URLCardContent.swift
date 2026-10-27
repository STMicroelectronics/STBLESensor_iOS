//
//  URLCardContent.swift
//  STDemos
//
//  Created by Luca Pezzoni on 26/10/2026.
//

import SwiftUI
import STBlueSDK
import STUI

private let urlHeaderStrings: [UrlHeaderString] = [
    UrlHeaderString("http://www.", 1),
    UrlHeaderString("https://www.", 2),
]

struct URLCardContent: View {
    @ObservedObject var viewModel: JsonNfcDemoViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var internalTextValue: String = ""
    @State private var selectedUrlHeaderIndex: Int = 0
    
    var body: some View {
        NFCCard (nfcCardType: .nfcURL) {
            VStack(alignment: .center, spacing: 8) {
                
                
                HStack {
                    Text("URL Type")
                    Spacer()
                    
                    SwiftUI.Picker("URL Type", selection: $selectedUrlHeaderIndex) {
                        ForEach(urlHeaderStrings.indices, id: \.self) { index in
                            Text(urlHeaderStrings[index].displayName).tag(index)
                        }
                    }
                    .pickerStyle(.menu)
                    
                }.frame(maxWidth: .infinity)
                
                HStack {
                    Text("SSID")
                    
                    Spacer()
                    SwiftUI.TextField("", text: $internalTextValue)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.URL)
                        .focused($isTextFieldFocused)
                        .autocapitalization(.none)
                }
                .frame(maxWidth: .infinity)
                
                HStack {
                    Spacer()
                    Button(action: {
                        isTextFieldFocused = false
                        let command = JsonWriteCommand<String>(
                            command: nil,
                            genericText: nil,
                            nfcWiFi: nil,
                            nfcVCard: nil,
                            nfcURL: urlHeaderStrings[selectedUrlHeaderIndex].displayName + internalTextValue
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
