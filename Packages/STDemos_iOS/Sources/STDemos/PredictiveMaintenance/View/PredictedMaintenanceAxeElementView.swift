//
//  PredictedMaintenanceAxeElementView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 27/10/2026.
//

import SwiftUI
import STBlueSDK
import STUI

struct PredictedMaintenanceAxeElementView: View {
    var axeName: String
    var statusValue: PredictiveStatus?
    var point: PointPredictive?
    var format: String = "Peak: %.2f"
    
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            // Status Icon
            if let status = statusValue {
                
                if let imageName = status.getImageName() {
                    Image(imageName,  bundle: STDemos.bundle)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                } else {
                    Image("predictive_warning",  bundle: STDemos.bundle)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(SUIColorLayout.stGray5.color)
                }
            }
            
            // Content Column
            VStack(alignment: .leading, spacing: 4) {
                if let status = statusValue {
                    Text("\(axeName): \(status.getStatusString())")
                        .font(.subheadline)
                        .foregroundColor(SUIColorLayout.primary.color)
                }
                
                if let point = point {
                    if let freq = point.freq, !freq.isNaN {
                        Text(String(format: "Frequency (Hz): %.2f", freq))
                            .font(.subheadline)
                            .foregroundColor(SUIColorLayout.primary.color)
                    }
                    
                    if let value = point.value, !value.isNaN {
                        Text(String(format: format, value))
                            .font(.subheadline)
                            .foregroundColor(SUIColorLayout.primary.color)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
    }
}
