//
//  SUIFirmwareSelect.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//

import Foundation
import STBlueSDK

public struct SUIFirmwareSelect: Hashable {
    public let id = UUID()
    public let node: Node
    public let firmware: Firmware?
    public let isMandatory: Bool
    public let completion: ((Bool) -> Void)?

    public init(
        node: Node,
        firmware: Firmware? = nil,
        isMandatory: Bool = false,
        completion: ((Bool) -> Void)? = nil
    ) {
        self.node = node
        self.firmware = firmware
        self.isMandatory = isMandatory
        self.completion = completion
    }

    public static func == (lhs: SUIFirmwareSelect, rhs: SUIFirmwareSelect) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
