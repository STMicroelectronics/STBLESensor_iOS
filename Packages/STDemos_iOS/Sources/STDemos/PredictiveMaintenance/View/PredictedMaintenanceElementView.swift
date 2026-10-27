//
//  PredictedMaintenanceElementView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 27/10/2026.
//

import SwiftUI
import STBlueSDK
import STUI

struct PredictedMaintenanceElementView: View {
    var title: String
    var value: ViewStatusPredictive
    var format: String = "Peak: %.2f"
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            
            Text(title)
                .font(.title2)
                .bold()
                .foregroundColor(SUIColorLayout.primary.color)
            
            Divider().padding(.horizontal, 8)
            
            PredictedMaintenanceAxeElementView(axeName: "X", statusValue: value.xStatus,point: value.x , format: format)
            PredictedMaintenanceAxeElementView(axeName: "Y", statusValue: value.yStatus,point: value.y , format: format)
            PredictedMaintenanceAxeElementView(axeName: "Z", statusValue: value.zStatus,point: value.z , format: format)

        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(8)
        .padding(8)
        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}
