//
//  DemoPermission.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STCore

public protocol DemoPermission {
    var appModesEnabled: [AppMode] { get }
    var userTypesEnabled: [UserType] { get }
    var isLocked: Bool { get }
}

extension Demo: DemoPermission {
    public var appModesEnabled: [AppMode] {
        switch self {
        default:
            return [ .beginner, .expert ]
        }
    }

    public var userTypesEnabled: [UserType] {
        switch self {
        default:
            return [ .developer, .studentOrResearcher, .engineerOrSale, .other]
        }
    }

    public var isLocked: Bool {
        guard let loginService: LoginService = Resolver.shared.resolve() else { return false }
        switch self {
//        case .flow, .cloud, .extendedConfiguration:
        case .extendedConfiguration:
            return !loginService.isAuthenticated
        default:
            return false
        }
    }
    
    public var isLockedForNotExpert: Bool {
        guard let sessionService: SessionService = Resolver.shared.resolve() else { return false }
        switch self {
        case .extendedConfiguration, .pnpLike:
            switch sessionService.app?.appMode {
            case .expert:
                return false
            default:
                return true
            }
        default:
            return false
        }
    }

}
