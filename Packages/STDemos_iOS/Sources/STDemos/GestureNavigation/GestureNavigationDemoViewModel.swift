//
//  GestureNavigationDemoViewModel.swift
//  STDemos
//
//  Created by Luca Pezzoni on 22/10/2026.
//

import Foundation
import STBlueSDK

class GestureNavigationDemoViewModel: ObservableObject {
    @Published var gestureWithTimeStamp: NavigationGestureWithTimestampType = NavigationGestureWithTimestampType(gesture: .UNDEFINED, timestamp: 0)
    @Published var button: NavigationButtonType = .UNDEFINED
    @Published var firstDataReceived: Bool = false
    
    func evaluateSample(_ sample: FeatureSample<GestureNavigationData>) {
        if let gesture = sample.data?.gesture.value  {
            self.gestureWithTimeStamp = NavigationGestureWithTimestampType(gesture: gesture, timestamp: sample.timestamp)
        }
        
        if let button = sample.data?.button.value {
            self.button = button
        }
        
        if !firstDataReceived {
            firstDataReceived = true
        }
    }
}
