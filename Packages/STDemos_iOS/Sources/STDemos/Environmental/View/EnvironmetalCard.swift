//
//  EnvironmetalCard.swift
//  STDemos
//
//  Created by Luca Pezzoni on 06/10/2026.
//

import SwiftUI
import Foundation
import STUI
import STCore

public struct EnvironmentalCard: View {
    
    private var value:Double?
    private var envType: EnvironmentalType
    private let showSwitch:Bool
    private let onImageTap: (() -> Void)?
    
    @State var offset: Double = 0.0
    @State private var offsetText: String = "0"
    @State var alternative: Bool = false
    
    
    init(envType: EnvironmentalType, value:Double?, onImageTap: (() -> Void)? = nil) {
        self.envType = envType
        self.value = value
        self.showSwitch =  envType == .temperature
        self.onImageTap = onImageTap
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Image(envType.getImage(value), bundle: STDemos.bundle)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100.0, height: 100.0)
                .accessibilityLabel("Environmental image")
                .onTapGesture {
                    onImageTap?()
                }
            
            Text(envType.getLabel(value, offset: offset, alternative: alternative))
                .font(.body)
                .bold()
                .lineLimit(1)
                .allowsTightening(true)
            
            Spacer()
            
            
            VStack(alignment: .center, spacing: 4) {
                if showSwitch {
                    Toggle(isOn: $alternative){
                        Text("°C/°F")
                            .font(.caption)
                    }
                    .tint(SUIColorLayout.primary.color)
                    .toggleStyle(.switch)
                    .padding([.bottom],8)
                }
                
                HStack{
                    Text("+/-").font(.caption)
                    
                    SwiftUI.TextField("Offset", text: $offsetText)
                        .keyboardType(.decimalPad)
                        .onChange(of: offsetText) { _, newValue in
                            let normalized = newValue.replacingOccurrences(of: ",", with: ".")
                            if let parsedOffset = Double(normalized) {
                                offset = parsedOffset
                            }
                        }
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding(8)
                        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                }
            }.fixedSize(horizontal: true, vertical: false)
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(8)
        .padding(8)
        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

//#Preview {
//    EnvironmentalCard(envType: .temperature, value: 2.5)
//}
