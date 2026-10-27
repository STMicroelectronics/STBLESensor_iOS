//
//  WelcomeViewModel.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

final class WelcomeViewModel: ObservableObject {

    @Published var currentPageIndex: Int = 0
    @Published var showLicense: Bool = false

    let welcome: Welcome

    var totalPages: Int {
        welcome.pages.count
    }

    var currentPage: WelcomePage {
        welcome.pages[currentPageIndex]
    }

    init(welcome: Welcome) {
        self.welcome = welcome
        self.showLicense = welcome.licenseUrl != nil
    }

    func didTapNext() {
        welcome.callback()
    }
}
