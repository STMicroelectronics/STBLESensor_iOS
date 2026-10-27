//
//  PredictiveStatusExtension.swift
//  STDemos
//
//  Created by Luca Pezzoni on 27/10/2026.
//

import Foundation
import STBlueSDK

extension PredictiveStatus {
    func getImageName() -> String? {
        switch self {
        case .good:
            return "predictive_good"
        case .warning:
            return "predictive_warning"
        case .bad:
            return "predictive_bad"
        case .unknown:
            return nil
        }
    }
    
    func getStatusString() -> String {
        switch self {
        case .good:
            return "Good"
        case .warning:
            return "Warning"
        case .bad:
            return "Alarm"
        case .unknown:
            return "Unknown"
        }
    }
}


