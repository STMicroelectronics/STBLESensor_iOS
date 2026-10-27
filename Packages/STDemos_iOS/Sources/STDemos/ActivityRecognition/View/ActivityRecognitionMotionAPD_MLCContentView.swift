//
//  ActivityRecognitionMotionAPD_MLCContentView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 23/10/2026.
//

import SwiftUI
import STBlueSDK
import STUI

private func getAPD_MLCContentViewAllCases()  -> [ActivityType] {
    return [.noActivity, .adultInCar]
}

public struct ActivityRecognitionMotionAPD_MLCContentView: View {
    
    let activity: ActivityType?
    
    init(activity: ActivityType?) {
        self.activity = activity
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let rowHeight = geometry.size.height / CGFloat(2)
            
            VStack(spacing: 0) {
                
                HStack(alignment: .center,  spacing: 16) {
                    Image("activity_adult_not_in_car", bundle: STDemos.bundle)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: .infinity)
                        .foregroundColor(
                            self.activity == .noActivity
                            ? SUIColorLayout.primary.color
                            : SUIColorLayout.stGray5.color
                        )
                    
                    Text("Adult not in car")
                        .foregroundColor(
                            self.activity == .noActivity
                            ? SUIColorLayout.primary.color
                            : SUIColorLayout.stGray5.color
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: rowHeight, alignment: .leading)
                
                HStack(alignment: .center,  spacing: 16) {
                    Image("activity_adult_in_car", bundle: STDemos.bundle)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: .infinity)
                        .foregroundColor(
                            self.activity == .adultInCar
                            ? SUIColorLayout.primary.color
                            : SUIColorLayout.stGray5.color
                        )
                    
                    Text("Adult in car")
                        .foregroundColor(
                            self.activity == .adultInCar
                            ? SUIColorLayout.primary.color
                            : SUIColorLayout.stGray5.color
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: rowHeight, alignment: .leading)
            }
        }
    }
}

