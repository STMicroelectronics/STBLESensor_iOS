//
//  RootView.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import STWelcome
import STUserProfiling
import STCore

struct STBLESensorRootView: View {
    @State private var currentStep: AppStep = {
        let session: SessionService? = Resolver.shared.resolve()
        return (session?.isWelcomeNeeded ?? true) ? .welcome : .main
    }()

    var body: some View {
        Group {
            switch currentStep {
            case .welcome:
                createWelcomeView()

            case .profiling:
                UserProfilingFlowView { appMode, userType in
                    completeProfiling(appMode: appMode, userType: userType)
                }

            case .main:
                MainTabView()
            }
        }
        .animation(.easeInOut, value: currentStep)
    }

    // MARK: - Navigation Logic
    private func createWelcomeView() -> some View {
        let pages = [WelcomePage.pageOne, WelcomePage.pageTwo, WelcomePage.pageThree, WelcomePage.pageFour]
        let url = Bundle.main.url(forResource: "License", withExtension: "md")

        let welcomeData = Welcome(pages: pages, licenseUrl: url) {
            currentStep = .profiling
        }
        return WelcomeView(welcome: welcomeData)
    }

    private func completeProfiling(appMode: AppMode, userType: UserType) {
        if let sessionService: SessionService = Resolver.shared.resolve() {
            sessionService.update(appMode: appMode, userType: userType)
        }
        currentStep = .main
    }
}

enum AppStep {
    case welcome
    case profiling
    case main
}
