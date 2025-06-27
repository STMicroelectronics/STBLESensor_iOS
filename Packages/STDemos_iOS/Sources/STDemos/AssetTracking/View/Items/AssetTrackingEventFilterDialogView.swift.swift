//
//  AssetTrackingEventFilterDialogView.swift.swift
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

//struct AssetTrackingEventFilterDialogView: View {
//    @Binding var isFilterDialogVisible: Bool
//    @Binding var isShockEventsVisible: Bool
//    @Binding var isFallEventsVisible: Bool
//
//    var body: some View {
//        VStack(spacing: 16) {
//            Text("Filter Events")
//                .font(.system(size: 18.0).bold())
//                .foregroundColor(ColorLayout.primary.auto.swiftUIColor)
//            
//            Divider()
//
//            Text("Select which events you want to see:")
//                .font(.system(size: 13.0).weight(.light))
//                .foregroundColor(ColorLayout.text.auto.swiftUIColor)
//            
//            HStack (spacing: 8) {
//                Button(action: {
//                    isShockEventsVisible = false
//                }) {
//                    Text("Shock")
//                        .foregroundColor(.white)
//                        .padding(.vertical, 12)
//                        .frame(width: 120)
//                        .background(isShockEventsVisible ? ColorLayout.primary.auto.swiftUIColor : ColorLayout.notActiveColor.auto.swiftUIColor)
//                        .cornerRadius(24)
//                        .padding(.vertical, 8)
//                }
//                
//                Button(action: {
//                    isFallEventsVisible = false
//                }) {
//                    Text("Fall")
//                        .foregroundColor(.white)
//                        .padding(.vertical, 12)
//                        .frame(width: 120)
//                        .background(isFallEventsVisible ? ColorLayout.primary.auto.swiftUIColor : ColorLayout.notActiveColor.auto.swiftUIColor)
//                        .cornerRadius(24)
//                        .padding(.vertical, 8)
//                }
//            }
//                
//            HStack {
//                Spacer()
//                Button(action: {
//                    isFilterDialogVisible = false
//                }) {
//                    Text("OK")
//                        .foregroundColor(.white)
//                        .padding(.vertical, 12)
//                        .frame(width: 120)
//                        .background(ColorLayout.primary.auto.swiftUIColor)
//                        .cornerRadius(8)
//                        .padding(.vertical, 8)
//                }
//            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(radius: 10)
//    }
//}
