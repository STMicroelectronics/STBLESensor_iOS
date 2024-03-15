//
//  RegisterAiViewModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import STUI
import STBlueSDK
import STCore
import UIKit

public class RegisterAiViewModel: BaseCellViewModel<RegisterAiData, RegisterAiCell> {
    
    public override func configure(view: RegisterAiCell) {
        TextLayout.title2.apply(to: view.registerTitleTextLabel)
        TextLayout.title.size(16.0).apply(to: view.registerAlgorithmTextLabel)
        TextLayout.title.size(14.0).apply(to: view.registerValueTextLabel)

        if let param = param {
            
            view.registerTitleTextLabel.text = param.title
            
            if let labelledValue = param.labelledValue {
                view.registerImageView.image = getAiValueImage(labelledValue)
                if let intRawValue = Int(param.rawValue) {
                    view.registerValueTextLabel.text = "Value: \(labelledValue) - 0x\(String(intRawValue, radix: 16))"
                }
            } else {
                view.registerImageView.image = ImageLayout.image(with: "mlc_new_icon", in: .module)?.maskWithColor(color: ColorLayout.primary.auto)
                if let intRawValue = Int(param.rawValue) {
                    view.registerValueTextLabel.text = "Value: 0x\(String(intRawValue, radix: 16))"
                }
            }
            
            if param.algorithm != nil {
                view.registerAlgorithmTextLabel.text = param.algorithm
            } else {
                view.registerAlgorithmTextLabel.isHidden = true
            }
        }

        view.registerImageView.contentMode = .scaleAspectFill
    }
    
    func getAiValueImage(_ value: String) -> UIImage? {
        switch value {
        /// Activity Recognition
        case "Walking":
            return ImageLayout.image(with: "mlc_walking", in: .module)
        case "Running":
            return ImageLayout.image(with: "mlc_running", in: .module)
        case "Standing":
            return ImageLayout.image(with: "mlc_standing", in: .module)
        case "Biking":
            return ImageLayout.image(with: "mlc_biking", in: .module)
        case "Driving":
            return ImageLayout.image(with: "mlc_driving", in: .module)
            
        /// Head Gesture
        case "Nod":
            return ImageLayout.image(with: "mlc_nod", in: .module)
        case "Shake":
            return ImageLayout.image(with: "mlc_shake", in: .module)
        case "Swing":
            return ImageLayout.image(with: "mlc_swing", in: .module)
        case "Steady head":
            return ImageLayout.image(with: "mlc_steady_head", in: .module)
            
        /// Vibration
        case "No vibration":
            return ImageLayout.image(with: "mlc_no_vibration", in: .module)
        case "Low vibration":
            return ImageLayout.image(with: "mlc_low_vibration", in: .module)
        case "High vibration":
            return ImageLayout.image(with: "mlc_high_vibration", in: .module)
            
        /// Asset Tracking
        case "Stationary upright":
            return ImageLayout.image(with: "mlc_stationary_upright", in: .module)
        case "Stationary not upright":
            return ImageLayout.image(with: "mlc_stationary_no_upright", in: .module)
        case "Motion":
            return ImageLayout.image(with: "mlc_motion", in: .module)
        case "Shaking":
            return ImageLayout.image(with: "mlc_shaking", in: .module)
            
        /// Door opening/closing/still
        case "Door closing":
            return ImageLayout.image(with: "mlc_door_closing", in: .module)
        case "Door still":
            return ImageLayout.image(with: "mlc_door_still", in: .module)
        case "Door Opening":
            return ImageLayout.image(with: "mlc_door_opening", in: .module)
            
        /// Gym activity recognition
        case "No activity":
            return ImageLayout.image(with: "mlc_standing", in: .module)
        case "Biceps curls":
            return ImageLayout.image(with: "mlc_biceps_curls", in: .module)
        case "Lateral raises":
            return ImageLayout.image(with: "mlc_lateral_raises", in: .module)
        case "Squat":
            return ImageLayout.image(with: "mlc_squat", in: .module)
            
        /// Vehicle
        case "Car moving":
            return ImageLayout.image(with: "mlc_car_moving", in: .module)
        case "Car still":
            return ImageLayout.image(with: "mlc_car_still", in: .module)
            
        /// Yoga Pose
        case "The tree":
            return ImageLayout.image(with: "mlc_the_tree", in: .module)
        case "Boat pose":
            return ImageLayout.image(with: "mlc_boat_pose", in: .module)
        case "Bow pose":
            return ImageLayout.image(with: "mlc_bow_pose", in: .module)
        case "Plank inverse":
            return ImageLayout.image(with: "mlc_plank_inverse", in: .module)
        case "Side angle":
            return ImageLayout.image(with: "mlc_side_angle", in: .module)
        case "Plank":
            return ImageLayout.image(with: "mlc_plank", in: .module)
        case "Meditation pose":
            return ImageLayout.image(with: "mlc_meditation_pose", in: .module)
        case "Cobra":
            return ImageLayout.image(with: "mlc_cobra", in: .module)
        case "Child":
            return ImageLayout.image(with: "mlc_child", in: .module)
        case "Downward dog pose":
            return ImageLayout.image(with: "mlc_downward_dog_pose", in: .module)
        case "Seated forward":
            return ImageLayout.image(with: "mlc_seated_forward", in: .module)
        case "Bridge":
            return ImageLayout.image(with: "mlc_bridge", in: .module)
        default:
            return ImageLayout.image(with: "mlc_new_icon", in: .module)?.maskWithColor(color: ColorLayout.primary.auto)
        }
    }
}
