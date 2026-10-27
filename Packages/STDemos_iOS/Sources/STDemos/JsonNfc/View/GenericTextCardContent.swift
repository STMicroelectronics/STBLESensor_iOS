//
//  GenericTextCardContent.swift
//  STDemos
//
//  Created by Luca Pezzoni on 26/10/2026.
//

import SwiftUI
import STBlueSDK
import STUI

struct GenericTextCardContent: View {
    @ObservedObject var viewModel: JsonNfcDemoViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var internalTextValue: String = ""
    
    var body: some View {
        NFCCard (nfcCardType: .genericText) {
            VStack(alignment: .center, spacing: 8) {
                HStack {
                    Text("Text")
                    
                    Spacer()
                    SwiftUI.TextField("", text: $internalTextValue)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                        .autocapitalization(.sentences)
                }
                .frame(maxWidth: .infinity)
                
                HStack {
                    Spacer()
                    Button(action: {
                        isTextFieldFocused = false
                        let command = JsonWriteCommand<String>(
                            command: nil,
                            genericText: internalTextValue,
                            nfcWiFi: nil,
                            nfcVCard: nil,
                            nfcURL: nil
                        )
                        viewModel.sendJsonCommand(command,"NDEF Record Written on NFC")
                    }) {
                        Text("Write to NFC")
                    }.buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8)
            }
        }
    }
}
