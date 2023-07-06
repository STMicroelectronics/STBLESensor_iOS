//
//  AccelerationEvent+Extension.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import UIKit
import STUI
import STBlueSDK

extension AccelerationEventCommand {
    public var image: UIImage? {
        switch self {
        case .orientation(_):
            return ImageLayout.image(with: "acc_event_orientation_up", in: .module)
        case .tilt(_):
            return ImageLayout.image(with: "acc_event_tilt", in: .module)
        case .freeFall(_):
            return ImageLayout.image(with: "acc_event_free_fall", in: .module)
        case .singleTap(_):
            return ImageLayout.image(with: "acc_event_single_tap", in: .module)
        case .doubleTap(_):
            return ImageLayout.image(with: "acc_event_double_tap", in: .module)
        case .wakeUp(_):
            return ImageLayout.image(with: "acc_event_wake_up", in: .module)
        case .pedometer(_):
            return ImageLayout.image(with: "pedometer", in: .module)
        default:
            return ImageLayout.image(with: "acc_event_none", in: .module)
        }
    }
}

extension AccelerationEventCommand {
    public var isMultiple: Bool {
        switch self {
        case .multiple(_):
            return true
        default:
            return false
        }
    }
    
    public var isOrientation: Bool {
        switch self {
        case .orientation(_):
            return true
        default:
            return false
        }
    }
    
    public var isTilt: Bool {
        switch self {
        case .tilt(_):
            return true
        default:
            return false
        }
    }
    
    public var isFreeFall: Bool {
        switch self {
        case .freeFall(_):
            return true
        default:
            return false
        }
    }
    
    public var isSingleTap: Bool {
        switch self {
        case .singleTap(_):
            return true
        default:
            return false
        }
    }
    
    public var isDoubleTap: Bool {
        switch self {
        case .doubleTap(_):
            return true
        default:
            return false
        }
    }
    
    public var isWakeUp: Bool {
        switch self {
        case .wakeUp(_):
            return true
        default:
            return false
        }
    }
    
    public var isPedometer: Bool {
        switch self {
        case .pedometer(_):
            return true
        default:
            return false
        }
    }
}

extension AccelerationEventCommand {
    public var command: AccelerationEventCommand? {
        switch self {
        case .orientation(_):
            return AccelerationEventCommand.orientation(enabled: true)
        case .tilt(_):
            return AccelerationEventCommand.tilt(enabled: true)
        case .freeFall(_):
            return AccelerationEventCommand.freeFall(enabled: true)
        case .singleTap(_):
            return AccelerationEventCommand.singleTap(enabled: true)
        case .doubleTap(_):
            return AccelerationEventCommand.doubleTap(enabled: true)
        case .wakeUp(_):
            return AccelerationEventCommand.wakeUp(enabled: true)
        case .pedometer(_):
            return AccelerationEventCommand.pedometer(enabled: true)
        case .multiple(_):
            return AccelerationEventCommand.multiple(enabled: true)
        case .none:
            return AccelerationEventCommand.none
        }
    }
}

extension UIView {
    func shake(_ duration: Double? = 0.3) {
        self.transform = CGAffineTransform(translationX: 20, y: 0)
        UIView.animate(withDuration: duration ?? 0.4, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
    }
}

extension AccelerationEventType {
    public var image: UIImage? {
        switch self {
        case .orientationTopLeft:
            return ImageLayout.image(with: "acc_event_orientation_top_left", in: .module)
        case .orientationTopRight:
            return ImageLayout.image(with: "acc_event_orientation_top_right", in: .module)
        case .orientationBottomLeft:
            return ImageLayout.image(with: "acc_event_orientation_bottom_left", in: .module)
        case .orientationBottomRight:
            return ImageLayout.image(with: "acc_event_orientation_bottom_right", in: .module)
        case .orientationUp:
            return ImageLayout.image(with: "acc_event_orientation_up", in: .module)
        case .orientationDown:
            return ImageLayout.image(with: "acc_event_orientation_down", in: .module)
        default:
            return nil
        }
    }
}
