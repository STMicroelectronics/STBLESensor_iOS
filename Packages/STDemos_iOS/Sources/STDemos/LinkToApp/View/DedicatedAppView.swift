//
//  DedicatedAppView.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import SwiftUI
import STUI

public struct DedicatedAppView: View {
    
    var dedicatedAppInfo: DedicatedAppInfo?
    
    init(dedicatedAppInfo: DedicatedAppInfo) {
        self.dedicatedAppInfo = dedicatedAppInfo
    }
    
    public var body: some View {
        
        VStack(spacing: 16) {
            Text(dedicatedAppInfo?.name ?? "")
                .font(.stTitle.bold())
                .foregroundColor(ColorLayout.primary.auto.swiftUIColor)
            
            Text(dedicatedAppInfo?.shortDescription ?? "")
                .font(.callout)
                .foregroundColor(ColorLayout.text.auto.swiftUIColor)
            
            Image(dedicatedAppInfo?.imageName ?? "", bundle: STDemos.bundle)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .cornerRadius(20)
            
            Text(dedicatedAppInfo?.description ?? "")
                .font(.stInfo)
                .foregroundColor(ColorLayout.text.auto.swiftUIColor)
                .multilineTextAlignment(.center)
            
            Image(.appstorebadge)
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .onTapGesture {
                    if let urlString = dedicatedAppInfo?.url {
                        if let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
        }
        .padding()
    }
}

//#Preview {
//    DedicatedAppView()
//}
