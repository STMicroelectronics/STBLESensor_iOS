//
//  OldProfile.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public typealias OldProfileCallback = (OldProfile) -> Void

public class OldProfile {
    var callback: OldProfileCallback
    public var steps: [OldStep]
    
    public init(steps: [OldStep], callback: @escaping OldProfileCallback) {
        self.steps = steps
        self.callback = callback
    }
}
