//
//  PnPLSpontaneousMessageType.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI

public enum PnPLSpontaneousMessageType {
    case error
    case warning
    case info
    case ok

    var title: String {
        switch self {
        case .error:
            return "ERROR:"
        case .warning:
            return "WARNING:"
        case .info:
            return "INFO:"
        case .ok:
            return "OK:"
        }
    }
    
    var dialogIconImage: UIImage? {
        switch self {
        case .error:
            return ImageLayout.Common.infoFilled?.maskWithColor(color: self.associatedColor)
        case .warning:
            return ImageLayout.Common.warningFilled?.maskWithColor(color: self.associatedColor)
        case .info:
            return ImageLayout.Common.infoFilled?.maskWithColor(color: self.associatedColor)
        case .ok:
            return ImageLayout.Common.done?.maskWithColor(color: self.associatedColor)
        }
    }
    
    var associatedColor: UIColor {
        switch self {
        case .error:
            return ColorLayout.errorRed.auto
        case .warning:
            return ColorLayout.yellow.auto
        case .info:
            return ColorLayout.infoBlue.auto
        case .ok:
            return ColorLayout.successGreen.auto
        }
    }
}

public struct PnPLSpontaneousMessageTypeAndDescription {
    public let type: PnPLSpontaneousMessageType
    public let description: String
    public let extra: String?
    public let actionTitle: String?
    public let url: String?

    public init(type: PnPLSpontaneousMessageType, description: String, extra: String? = nil, actionTitle: String? = nil, url: String? = nil) {
        self.type = type
        self.description = description
        self.extra = extra
        self.actionTitle = actionTitle
        self.url = url
    }
}
