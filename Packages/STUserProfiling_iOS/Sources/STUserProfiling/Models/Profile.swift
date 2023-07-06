//
//  Profile.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public typealias ProfileCallback = (Profile) -> Void

public class Profile {
    var callback: ProfileCallback
    public var steps: [Step]
    
    public init(steps: [Step], callback: @escaping ProfileCallback) {
        self.steps = steps
        self.callback = callback
    }
}
