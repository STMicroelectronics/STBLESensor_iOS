//
//  CloudMQTTView.swift
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

public struct CloudMQTTMainView: View {
    
    @State private var brokerUrl: String = ""
    @State private var port: String = ""
    @State private var userName: String = ""
    @State private var password: String = ""
    @State private var deviceID: String = ""
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground() // Prevents transparent/blur effect
        appearance.backgroundColor = ColorLayout.primary.auto // Your desired background color

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        UITabBar.appearance().backgroundColor = ColorLayout.primary.auto
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
    }
    
    public var body: some View {
//        TabView (selection: $model.tabViewSelectedIndex){
        TabView() {
//            CloudMQTTAppConfigView()
//                .tag(0)
//                .tabItem {
//                    Label {
//                        Text("App Config")
//                    } icon: {
//                        ImageLayout.SUICommon.builcConfig
//                    }
//                }
            
//            CloudMQTTDevUploadView()
//                .tag(1)
//                .tabItem {
//                    Label {
//                        Text("Dev Upload")
//                    } icon: {
//                        ImageLayout.SUICommon.cloudUpload
//                    }
//                    
//                }
        }
        .tint(.white)
//        .environmentObject(model)
    }
}

#Preview {
    LegacyView()
}
