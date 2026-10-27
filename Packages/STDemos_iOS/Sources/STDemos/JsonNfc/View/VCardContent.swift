//
//  VCardContent.swift
//  STDemos
//
//  Created by Luca Pezzoni on 26/10/2026.
//

import SwiftUI
import STBlueSDK
import STUI

struct VCardContent: View {
    @ObservedObject var viewModel: JsonNfcDemoViewModel
    @FocusState private var isTextFieldFocused: Bool
    @State private var nameTextValue: String = ""
    @State private var formattedNameTextValue: String = ""
    @State private var titleTextValue: String = ""
    @State private var orgTextValue: String = ""
    @State private var homeAddressTextValue: String = ""
    @State private var workAddressTextValue: String = ""
    @State private var addressTextValue: String = ""
    @State private var homePhoneTextValue: String = ""
    @State private var workPhoneTextValue: String = ""
    @State private var cellularPhoneTextValue: String = ""
    @State private var homeEmailTextValue: String = ""
    @State private var workEmailTextValue: String = ""
    @State private var urlTextValue: String = ""
    
    
    var body: some View {
        NFCCard (nfcCardType: .nfcVCard) {
            VStack(alignment: .center, spacing: 8) {
                HStack {
                    Text("Name")
                    
                    Spacer()
                    SwiftUI.TextField("", text: $nameTextValue)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                        .autocapitalization(.sentences)
                }.frame(maxWidth: .infinity)
                
                HStack {
                    Text("Formatted Name")
                    
                    Spacer()
                    SwiftUI.TextField("", text: $formattedNameTextValue)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                        .autocapitalization(.sentences)
                }.frame(maxWidth: .infinity)
                
                HStack {
                    Text("Title")
                    
                    Spacer()
                    SwiftUI.TextField("", text: $titleTextValue)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                        .autocapitalization(.sentences)
                }.frame(maxWidth: .infinity)
                
                HStack {
                    Text("Home Address")
                    
                    Spacer()
                    SwiftUI.TextField("", text: $homeAddressTextValue)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                        .autocapitalization(.sentences)
                }.frame(maxWidth: .infinity)
                
                HStack {
                    Text("Home Phone")
                    
                    Spacer()
                    SwiftUI.TextField("", text: $homePhoneTextValue)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)
                        .focused($isTextFieldFocused)
                }.frame(maxWidth: .infinity)
                
                HStack {
                    Text("Home Email")
                    
                    Spacer()
                    SwiftUI.TextField("", text: $homeEmailTextValue)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .focused($isTextFieldFocused)
                        .autocapitalization(.none)
                }.frame(maxWidth: .infinity)
                
                HStack {
                    Text("Address")
                    
                    Spacer()
                    SwiftUI.TextField("", text: $addressTextValue)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                        .autocapitalization(.sentences)
                }.frame(maxWidth: .infinity)
                
                HStack {
                    Text("Cellular Phone")
                    
                    Spacer()
                    SwiftUI.TextField("", text: $cellularPhoneTextValue)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)
                        .focused($isTextFieldFocused)
                }.frame(maxWidth: .infinity)
                
                HStack {
                    Text("Organization")
                    
                    Spacer()
                    SwiftUI.TextField("", text: $orgTextValue)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                        .autocapitalization(.none)
                }.frame(maxWidth: .infinity)
                
                HStack {
                    Text("Work Address")
                    
                    Spacer()
                    SwiftUI.TextField("", text: $workAddressTextValue)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                        .autocapitalization(.none)
                }.frame(maxWidth: .infinity)
                
                HStack {
                    Text("Work Phone")
                    
                    Spacer()
                    SwiftUI.TextField("", text: $workPhoneTextValue)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)
                        .focused($isTextFieldFocused)
                }.frame(maxWidth: .infinity)
                
                HStack {
                    Text("Work Email")
                    
                    Spacer()
                    SwiftUI.TextField("", text: $workEmailTextValue)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .focused($isTextFieldFocused)
                        .autocapitalization(.none)
                }.frame(maxWidth: .infinity)
                
                HStack {
                    Text("URL")
                    
                    Spacer()
                    SwiftUI.TextField("", text: $urlTextValue)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.URL)
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
                            nfcWiFi: nil,
                            nfcVCard: JsonVCard(name: nameTextValue.isEmpty ? nil : nameTextValue,
                                                formattedName: formattedNameTextValue.isEmpty ? nil : formattedNameTextValue,
                                                title: titleTextValue.isEmpty ? nil : titleTextValue,
                                                org: orgTextValue.isEmpty ? nil : orgTextValue,
                                                homeAddress: homeAddressTextValue.isEmpty ? nil : homeAddressTextValue,
                                                workAddress: workAddressTextValue.isEmpty ? nil : workAddressTextValue,
                                                address: addressTextValue.isEmpty ? nil : addressTextValue,
                                                homeTel: homePhoneTextValue.isEmpty ? nil : homePhoneTextValue,
                                                workTel: workPhoneTextValue.isEmpty ? nil : workPhoneTextValue,
                                                cellTel: cellularPhoneTextValue.isEmpty ? nil : cellularPhoneTextValue,
                                                homeEmail: homeEmailTextValue.isEmpty ? nil : homeEmailTextValue,
                                                workEmail: workEmailTextValue.isEmpty ? nil : workEmailTextValue,
                                                url: urlTextValue.isEmpty ? nil : urlTextValue),
                            nfcURL: nil)
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
