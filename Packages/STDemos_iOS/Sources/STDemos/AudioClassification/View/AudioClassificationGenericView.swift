//
//  AudioClassificationView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 20/10/2026.
//

import SwiftUI
import STBlueSDK
import STUI

public struct AudioClassificationGenericView: View {
    let classification: AudioClass
    
    public var body: some View {
        GeometryReader { geometry in
            let rowHeight = geometry.size.height / CGFloat(3) - 32
            
            VStack(alignment: .center, spacing: 0) {
                
                Image("audioScene_inside", bundle: STDemos.bundle)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: rowHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(classification == .indoor ? Color.yellow : Color.clear, lineWidth: 4)
                        //.stroke(Color.yellow , lineWidth: 4)
                    )
                    .foregroundColor(
                        classification == .indoor
                        ? SUIColorLayout.primary.color
                        : SUIColorLayout.stGray5.color
                    )
                
                Image("audioScene_outside", bundle: STDemos.bundle)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(8) //for image too near to the border
                    .frame(height: rowHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(classification == .outdoor ? Color.yellow : Color.clear, lineWidth: 4)
                        //.stroke(Color.yellow , lineWidth: 4)
                    )
                    .foregroundColor(
                        classification == .outdoor
                        ? SUIColorLayout.primary.color
                        : SUIColorLayout.stGray5.color
                    )
                
                Image("audioScene_inDriving", bundle: STDemos.bundle)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: rowHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(classification == .inVehicle ? Color.yellow : Color.clear, lineWidth: 4)
                        //.stroke(Color.yellow , lineWidth: 4)
                    )
                    .foregroundColor(
                        classification == .inVehicle
                        ? SUIColorLayout.primary.color
                        : SUIColorLayout.stGray5.color
                    )
                
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical,16)
        }
    }
}
