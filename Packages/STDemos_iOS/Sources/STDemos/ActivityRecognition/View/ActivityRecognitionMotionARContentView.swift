//
//  ActivityRecognitionMotionARContentView.swift
//  STDemos
//
//  Created by Luca Pezzoni on 23/10/2026.
//

import SwiftUI
import STBlueSDK
import STUI

private func getARContentViewAllCases(showFastWalking: Bool)  -> [ActivityType] {
    return if showFastWalking {
        [.stationary, .walking, .fastWalking , .jogging, .biking, .driving]
    } else {
        [.stationary, .walking, .fastWalking , .jogging, .biking, .driving]
    }
}

public struct ActivityRecognitionMotionARContentView: View {
    
    let showFastWalking: Bool
    let activity: ActivityType?
    
    init(showFastWalking: Bool, activity: ActivityType?) {
        self.showFastWalking = showFastWalking
        self.activity = activity
    }
    
    var visibleRows: [ActivityType] {
        getARContentViewAllCases(showFastWalking: showFastWalking)
    }
    
    public var body: some View {
        GeometryReader { geometry in
            let rowHeight = visibleRows.isEmpty ? 0 : geometry.size.height / CGFloat(visibleRows.count)
            
            VStack(spacing: 0) {
                ForEach(visibleRows, id: \.self) { activity in
                    if let realActivity = activity.getImageName() {
                        HStack(alignment: .center,  spacing: 16) {
                            Image(realActivity, bundle: STDemos.bundle)
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxHeight: .infinity)
                                .foregroundColor(
                                    self.activity == activity
                                    ? SUIColorLayout.primary.color
                                    : SUIColorLayout.stGray5.color
                                )
                            
                            Text(activity.description)
                                .foregroundColor(
                                    self.activity == activity
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
    }
}
