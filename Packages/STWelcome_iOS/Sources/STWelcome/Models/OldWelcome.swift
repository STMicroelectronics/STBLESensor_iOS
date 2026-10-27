//
//  OldWelcome.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public typealias OldWelcomeCallback = () -> Void

public struct OldWelcome {
    public let pages: [OldWelcomePage]
    public let licenseUrl: URL?
    public let callback: OldWelcomeCallback
    
    public init(pages: [OldWelcomePage], licenseUrl: URL?, callback: @escaping OldWelcomeCallback) {
        self.pages = pages
        self.licenseUrl = licenseUrl
        self.callback = callback
    }
}
