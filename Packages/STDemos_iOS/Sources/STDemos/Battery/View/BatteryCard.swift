//
//  BatteryCard.swift
//  STDemos
//
//  Created by Luca Pezzoni on 16/10/2026.
//

import SwiftUI
import Foundation
import STUI
import STCore

public struct BatteryCard<Content: View>: View {
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 8) {
            content
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(Color.white)
        .cornerRadius(8)
        .padding(8)
        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}
