//
//  AudioClassificationBabyCrying.swift
//  STDemos
//
//  Created by Luca Pezzoni on 20/10/2026.
//

import SwiftUI
import STBlueSDK
import STUI

public struct AudioClassificationBabyCryingView: View {
    
    let classification: AudioClass
    
    public var body: some View {
        GeometryReader { geometry in
            let rowHeight = geometry.size.height / CGFloat(2) - 32
            
            VStack(alignment: .center, spacing: 0) {
                
                Image("audioScene_babyCrying", bundle: STDemos.bundle)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: rowHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(classification == .babyIsCrying ? Color.yellow : Color.clear, lineWidth: 4)
                    )
                    .foregroundColor(
                        classification == .babyIsCrying
                        ? SUIColorLayout.primary.color
                        : SUIColorLayout.stGray5.color
                    )
                
                Image("audioScene_babyNotCrying", bundle: STDemos.bundle)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: rowHeight)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(classification == .unknown ? Color.yellow : Color.clear, lineWidth: 4)
                    )
                    .foregroundColor(
                        classification == .unknown
                        ? SUIColorLayout.primary.color
                        : SUIColorLayout.stGray5.color
                    )
                
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical,16)
        }
    }
}
