//
//  Option.swift
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

public final class Option: ObservableObject, Identifiable {
    public let id = UUID()

    public let title: String
    public let subtitle: String?
    public let content: String?
    public let checkedImage: Image?
    public let uncheckedImage: Image?
    public let image: Image?

    @Published public var isSelected: Bool

    public init(
        title: String,
        subtitle: String?,
        content: String?,
        checkedImage: Image?,
        uncheckedImage: Image?,
        image: Image?,
        isSelected: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
        self.checkedImage = checkedImage
        self.uncheckedImage = uncheckedImage
        self.image = image
        self.isSelected = isSelected
    }
}
