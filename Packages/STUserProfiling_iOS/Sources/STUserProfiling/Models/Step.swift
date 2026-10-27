//
//  Step.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct Step: Identifiable {
    public let id: UUID

    public let navigationTitle: String
    public let title: String
    public let titleLabel: String
    public let next: String
    public let options: [Option]
    
    public init(navigationTitle: String,
                title: String,
                titleLabel: String,
                next: String,
                options: [Option]) {
        self.id = UUID()
        self.navigationTitle = navigationTitle
        self.title = title
        self.titleLabel = titleLabel
        self.next = next
        self.options = options
    }
}
