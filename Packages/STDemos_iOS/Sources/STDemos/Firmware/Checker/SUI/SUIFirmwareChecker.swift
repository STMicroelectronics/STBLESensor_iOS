//
//  SUIFirmwareChecker.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STBlueSDK

public struct SUIFirmwareChecker: Hashable {
    public let id = UUID()
    public let node: Node
    public let firmwares: Firmwares
    public let completion: ((Bool) -> Void)?

    public init(node: Node, firmwares: Firmwares, completion: ((Bool) -> Void)? = nil) {
        self.node = node
        self.firmwares = firmwares
        self.completion = completion
    }

    public static func == (lhs: SUIFirmwareChecker, rhs: SUIFirmwareChecker) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Action
public enum SUIFirmwareCheckerAction {
    case cancel(dontAskAgain: Bool)
    case install(firmware: Firmware, dontAskAgain: Bool)
}
