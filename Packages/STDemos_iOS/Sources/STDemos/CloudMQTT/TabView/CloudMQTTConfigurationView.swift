//
//  CloudMQTTAppConfigView.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import Foundation
import STUI
import STBlueSDK
import STCore

public struct CloudMQTTConfigurationView: View {
    
    let node: Node
    
    @StateObject private var mqttViewModel = CloudMQTTViewModel()
    
    @State private var isPasswordVisible: Bool = false
    
    @State private var showInfos = false
    @State private var brokerUrl: String = ""
    @State private var port: String = "1883"
    @State private var userName: String = ""
    @State private var password: String = ""
    @State private var deviceID: String = ""
    
    @State private var action: Int? = 0

    @State private var navigateToNextView = false
    @State private var showErrorDialog = false
    @State private var isConnecting = false
    
    init (node: Node) {
        self.node = node
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                Text("MQTT Server Configuration")
                    .font(.system(size: 24.0))
                    .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                //MARK: - Server Configuration
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("Host Url")
                        .font(.stInfoBold)
                        .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    SwiftUI.TextField("Broker URL", text: $brokerUrl)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    
                    Text("Port")
                        .font(.stInfoBold)
                        .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                        .frame(alignment: .leading)
                    
                    SwiftUI.TextField("", text: $port)
                        .accentColor(.black)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    
                    Text("User Name")
                        .font(.stInfoBold)
                        .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                    
                    SwiftUI.TextField("Optional", text: $userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    
                    Text("Password")
                        .font(.stInfoBold)
                        .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                    
                    HStack {
                        Group {
                            if isPasswordVisible {
                                SwiftUI.TextField("Optional", text: $password)
                            } else {
                                SwiftUI.SecureField("Optional", text: $password)
                            }
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(ColorLayout.primary.auto.swiftUIColor)
                        }
                    }
                    
                    Text("Device ID")
                        .font(.stInfoBold)
                        .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                    
                    SwiftUI.TextField("", text: $deviceID)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: 4)
                
                //MARK: - Show Info
                Button(action: {
                    withAnimation { showInfos.toggle() }
                }) {
                    Label {
                        Text("Show Info")
                    } icon: {
                        ImageLayout.SUICommon.infoFilled?.resizable()
                            .frame(width: 24, height: 24)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if showInfos {
                    VStack(alignment: .leading) {
                        
                        Text("Every feature will be published on one topic ") +
                        Text("\"DeviceId/featureName\"").bold() +
                        Text(".\nExample for") +
                        Text(" Accelerometer ").bold() +
                        Text("with DeviceId=") +
                        Text("TestDevice").bold() +
                        Text(":\n")
                        
                        
                        Text("topic:")
                        Text("TestDevice/Accelerometer").bold()
                        Text("message:")
                        Text("{\"x\":\"400.0\", \"y\":\"446.0\", \"z\":\"829.0\"}").bold()
                    }
                    .frame(maxWidth: .infinity ,alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .transition(.asymmetric(insertion: .move(edge: .top).combined(with: .opacity),
                                            removal: .move(edge: .top).combined(with: .opacity)))
                }
                
                //MARK: - CONNECT Button
                VStack {
                    Button(action: {
                        isConnecting = true
                        mqttViewModel.onConnect = {
                            isConnecting = false
                            navigateToNextView = true
                            print("🟢 Connection DONE")
                        }
                        
                        mqttViewModel.onConnectionError = { error in
                            isConnecting = false
                            showErrorDialog = true
                            print("🔴 Connection FAILED: \(error)")
                        }
                        
                        mqttViewModel.saveMqttSessionConfigurationAndConnect(brokerUrl, port, userName, password, deviceID)
                    }) {
                        Text("CONNECT")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(ColorLayout.primary.auto.swiftUIColor)
                            .cornerRadius(12)
                    }
                    .disabled(isConnecting)
                    
                    NavigationLink(destination: CloudMQTTDevUploadView(node: node, mqttViewModel: mqttViewModel), isActive: $navigateToNextView) {
                        EmptyView()
                    }
                }
                .padding()
                .alert(isPresented: $showErrorDialog) {
                    Alert(title: Text("Connection Failed"),
                          message: Text("Unable to connect to the broker. Please check your credentials or network."),
                          dismissButton: .default(Text("OK")))
                }

                
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .padding()
        }
        .onAppear {
            let configuration = mqttViewModel.loadMqttSessionConfiguration()
            if let configuration {
                brokerUrl = configuration.hostUrl
                port = configuration.port
                if let username = configuration.username {
                    userName = username
                }
                if let password = configuration.password {
                    self.password = password
                }
                deviceID = configuration.deviceID
            }
        }
    }
}
