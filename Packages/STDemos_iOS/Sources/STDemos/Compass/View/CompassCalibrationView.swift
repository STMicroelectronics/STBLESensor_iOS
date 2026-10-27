//
//  CompassCalibrationView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 12/10/2026.
//

import SwiftUI
import STUI

public struct CompassCalibrationView: View {
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        
        VStack(spacing: 24) {
            Text("Calibration on Going")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Image("calibration", bundle: STDemos.bundle)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 240, maxHeight: 240)
            
            Text("Usage: move the board as shown in the image")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                dismiss()
            } label: {
                Text("Ok")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundColor(.white)
                    .background(SUIColorLayout.primary.color)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.clear)
    }
}
