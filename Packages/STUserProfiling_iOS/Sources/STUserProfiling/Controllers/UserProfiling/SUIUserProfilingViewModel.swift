//
//  UserProfilingViewModel.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

@Observable
final class SUIUserProfilingViewModel {
    let profile: Profile
    var currentStepIndex: Int = 0

    var currentStep: Step {
        profile.steps[currentStepIndex]
    }

    var selectedContent: String? {
        currentStep.options.first(where: { $0.isSelected })?.content
    }

    init(profile: Profile) {
        self.profile = profile
    }

    func select(option: Option) {
        currentStep.options.forEach { $0.isSelected = false }
        option.isSelected = true
    }

    func nextStep(onFinished: @escaping () -> Void) {
        if currentStepIndex + 1 < profile.steps.count {
            currentStepIndex += 1
        } else {
            profile.callback(profile)
            onFinished()
        }
    }
}
