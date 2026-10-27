//
//  ActivityTypeExtension.swift
//  STDemos
//
//  Created by Luca Pezzoni on 26/10/2026.
//

import STBlueSDK

extension ActivityType {
    
    func getImageName() -> String? {
        switch self {
        case .noActivity:
            return nil
        case .stationary:
            return "activity_standing"
        case .walking:
            return "activity_walking"
        case .fastWalking:
            return "activity_fastWalking"
        case .jogging:
            return "activity_running"
        case .biking:
            return "activity_biking"
        case .driving:
            return "activity_driving"
        case .adultInCar:
            return "activity_adult_in_car"
        case .stairs:
            return "activity_stairs"
        case .error:
            return nil
        }
    }
}
