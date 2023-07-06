//
//  Welcome.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public typealias WelcomeCallback = () -> Void

public struct Welcome {
    public let pages: [WelcomePage]
    public let licenseUrl: URL?
    public let callback: WelcomeCallback
    
    public init(pages: [WelcomePage], licenseUrl: URL?, callback: @escaping WelcomeCallback) {
        self.pages = pages
        self.licenseUrl = licenseUrl
        self.callback = callback
    }
}
