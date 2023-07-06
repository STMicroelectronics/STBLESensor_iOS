//
//  MotionAlgorithms+UIImage.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import Foundation
import STBlueSDK
import STUI

extension DeskTypeDetection {
    
    public var icon: UIImage? {
        switch self {
            case .sittingDesk:
                return ImageLayout.image(with: "motion_algo_desktop_sitting", in: .module)
            case .standingDesk:
                return ImageLayout.image(with: "motion_algo_desktop_standing", in: .module)
            case .unknown:
                return ImageLayout.image(with: "fitness_unknown", in: .module)
        }
    }
    
}

extension PoseEstimation {
    
    public var icon: UIImage? {
        switch self {
            case .layingDown:
                return ImageLayout.image(with: "motion_algo_pose_lying_down", in: .module)
            case .sitting:
                return ImageLayout.image(with: "motion_algo_pose_sitting", in: .module)
            case .standing:
                return ImageLayout.image(with: "motion_algo_pose_standing", in: .module)
            case .unknown:
                return ImageLayout.image(with: "fitness_unknown", in: .module)
        }
    }
    
}

extension VerticalContext{
    
    public var icon: UIImage? {
        switch self {
        case .elevator:
            return ImageLayout.image(with: "motion_algo_vertical_elevator", in: .module)
        case .escalator:
            return ImageLayout.image(with: "motion_algo_vertical_escalator", in: .module)
        case .floor:
            return ImageLayout.image(with: "motion_algo_vertical_floor", in: .module)
        case .stairs:
            return ImageLayout.image(with: "motion_algo_vertical_stairs", in: .module)
        case .upDown:
            return ImageLayout.image(with: "motion_algo_vertical_updown", in: .module)
        case .unknown:
            return ImageLayout.image(with: "fitness_unknown", in: .module)
        }
        
    }
}
