//
//  MultiNeuralNetwork+UIImage.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK

extension AudioClass {
    public var image: UIImage? {
        switch self {
        case .unknown:
            return ImageLayout.image(with: "fitness_unknown", in: .module)
        case .indoor:
            return ImageLayout.image(with: "audioScene_inside", in: .module)
        case .outdoor:
            return ImageLayout.image(with: "audioScene_outside", in: .module)
        case .inVehicle:
            return ImageLayout.image(with: "audioScene_inDriving", in: .module)
        case .babyIsCrying:
            return ImageLayout.image(with: "audioScene_babyCrying", in: .module)
        case .off:
            return nil
        case .on:
            return nil
        }
    }
}

extension ActivityType {
    public var image: UIImage? {
        switch self {
        case .noActivity:
            return ImageLayout.image(with: "fitness_unknown", in: .module)
        case .standing:
            return ImageLayout.image(with: "activity_standing", in: .module)
        case .walking:
            return ImageLayout.image(with: "activity_walking", in: .module)
        case .fastWalking:
            return ImageLayout.image(with: "activity_fastWalking", in: .module)
        case .jogging:
            return ImageLayout.image(with: "activity_running", in: .module)
        case .biking:
            return ImageLayout.image(with: "activity_biking", in: .module)
        case .driving:
            return ImageLayout.image(with: "activity_driving", in: .module)
        case .stairs:
            return ImageLayout.image(with: "activity_stairs", in: .module)
        case .adultInCar:
            return ImageLayout.image(with: "activity_adult_in_car", in: .module)
        case .error:
            return ImageLayout.image(with: "fitness_unknown", in: .module)
        }
    }
}
