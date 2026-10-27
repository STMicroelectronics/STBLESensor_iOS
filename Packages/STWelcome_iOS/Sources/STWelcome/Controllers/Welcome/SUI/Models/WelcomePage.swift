//
//  WelcomePage.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import SwiftUI

public struct WelcomePage {
    public let id = UUID()
    public let image: Image?
    public let title: String?
    public let content: String?
    public let next: String?
    public let isNextHidden: Bool
    
    public init(image: Image?, title: String?, content: String?, next: String?, isNextHidden: Bool = false) {
        self.image = image
        self.title = title
        self.content = content
        self.next = next
        self.isNextHidden = isNextHidden
    }
}
