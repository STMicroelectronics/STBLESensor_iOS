//
//  Profile.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

public typealias ProfileCallback = (Profile) -> Void

public struct Profile {
    public let steps: [Step]
    public let callback: (Profile) -> Void
    
    public init(steps: [Step], callback: @escaping ProfileCallback) {
        self.steps = steps
        self.callback = callback
    }
}
