//
//  STBLESensor+Welcome.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import STUI
import STWelcome
import STUserProfiling
import STCore

struct UserProfilingFlowView: View {
    private let profile: Profile
    private let onFinished: (AppMode, UserType) -> Void

    init(onFinished: @escaping (AppMode, UserType) -> Void) {
        self.onFinished = onFinished
        self.profile = .defaultProfile
    }

    var body: some View {
        NavigationStack {
            SUIUserProfilingView(profile: profile) {
                onFinished(profile.selectedAppMode, profile.selectedUserType)
            }
        }
    }
}

extension Profile {
    var selectedAppMode: AppMode {
        let index = steps[0].options.firstIndex(where: \.isSelected) ?? 0
        return index == 0 ? .beginner : .expert
    }

    var selectedUserType: UserType {
        guard let selectedIndex = steps[1].options.firstIndex(where: \.isSelected) else {
            return .none
        }

        let optionsMap: [UserType] = [
            .developer,
            .studentOrResearcher,
            .engineerOrSale,
            .other
        ]

        guard optionsMap.indices.contains(selectedIndex) else { return .none }
        return optionsMap[selectedIndex]
    }
}

extension Profile {
    static var defaultProfile: Profile {
        let sessionService: SessionService? = Resolver.shared.resolve()
        let selection = (
            appMode: sessionService?.app?.appMode ?? .beginner,
            userType: sessionService?.app?.userType ?? .developer
        )

        let steps: [Step] = [
            .selectedStepOne(selectedAppMode: selection.appMode),
            .selectedStepTwo(selectedUserType: selection.userType)
        ]

        return Profile(steps: steps, callback: { _ in })
    }
}

extension WelcomePage {

    static var pageOne: WelcomePage {
        WelcomePage(image: Image("img_welcome1"),
                    title: Localizer.Welcome.PageOne.title.localized,
                    content: Localizer.Welcome.PageOne.content.localized,
                    next: Localizer.Welcome.PageOne.next.localized,
                    isNextHidden: true)
    }

    static var pageTwo: WelcomePage {
        WelcomePage(image: Image("img_welcome2"),
                    title: Localizer.Welcome.PageTwo.title.localized,
                    content: Localizer.Welcome.PageTwo.content.localized,
                    next: Localizer.Welcome.PageTwo.next.localized,
                    isNextHidden: true)
    }

    static var pageThree: WelcomePage {
        WelcomePage(image: Image("img_welcome3"),
                    title: Localizer.Welcome.PageThree.title.localized,
                    content: Localizer.Welcome.PageThree.content.localized,
                    next: Localizer.Welcome.PageThree.next.localized,
                    isNextHidden: true)
    }

    static var pageFour: WelcomePage {
        WelcomePage(image: Image("img_welcome4"),
                    title: Localizer.Welcome.PageFour.title.localized,
                    content: Localizer.Welcome.PageFour.content.localized,
                    next: Localizer.Welcome.PageFour.next.localized,
                    isNextHidden: false)
    }
}

extension Step {
    static var stepOne: Step {
        selectedStepOne(selectedAppMode: .beginner)
    }

    static func selectedStepOne(selectedAppMode: AppMode) -> Step {
        Step(navigationTitle: Localizer.UserProfiling.StepOne.Text.navigationTitle.localized,
             title: "What is your proficiency level?",
             titleLabel: Localizer.UserProfiling.StepOne.Text.title.localized,
             next: Localizer.UserProfiling.StepOne.Text.next.localized,
             options: [
                Option(title: Localizer.UserProfiling.StepOne.OptionOne.title.localized,
                       subtitle: Localizer.UserProfiling.StepOne.OptionOne.subtitle.localized,
                       content: Localizer.UserProfiling.StepOne.OptionOne.content.localized,
                       checkedImage: ImageLayout.SUICommon.checkedImage,
                       uncheckedImage: ImageLayout.SUICommon.uncheckedImage,
                       image: nil,
                       isSelected: selectedAppMode != .expert),
                Option(title: Localizer.UserProfiling.StepOne.OptionTwo.title.localized,
                       subtitle: Localizer.UserProfiling.StepOne.OptionTwo.subtitle.localized,
                       content: Localizer.UserProfiling.StepOne.OptionTwo.content.localized,
                       checkedImage: ImageLayout.SUICommon.checkedImage,
                       uncheckedImage: ImageLayout.SUICommon.uncheckedImage,
                       image: nil,
                       isSelected: selectedAppMode == .expert)
             ])
    }

    static var stepTwo: Step {
        selectedStepTwo(selectedUserType: .developer)
    }

    static func selectedStepTwo(selectedUserType: UserType) -> Step {
        Step(navigationTitle: Localizer.UserProfiling.StepTwo.Text.navigationTitle.localized,
             title: "What is your profile?",
             titleLabel: Localizer.UserProfiling.StepTwo.Text.title.localized,
             next: Localizer.UserProfiling.StepTwo.Text.next.localized,
             options: [
                Option(title: Localizer.UserProfiling.StepTwo.OptionOne.title.localized,
                       subtitle: Localizer.UserProfiling.StepTwo.OptionOne.subtitle.localized,
                       content: Localizer.UserProfiling.StepTwo.OptionOne.content.localized,
                       checkedImage: ImageLayout.SUICommon.checkedImage,
                       uncheckedImage: ImageLayout.SUICommon.uncheckedImage,
                       image: Image("img_developer"),
                       isSelected: selectedUserType == .developer ||
                       selectedUserType == .aiDeveloper ||
                       selectedUserType == .none),
                Option(title: Localizer.UserProfiling.StepTwo.OptionTwo.title.localized,
                       subtitle: Localizer.UserProfiling.StepTwo.OptionTwo.subtitle.localized,
                       content: Localizer.UserProfiling.StepTwo.OptionTwo.content.localized,
                       checkedImage: ImageLayout.SUICommon.checkedImage,
                       uncheckedImage: ImageLayout.SUICommon.uncheckedImage,
                       image: Image("img_university"),
                       isSelected: selectedUserType == .studentOrResearcher),
                Option(title: Localizer.UserProfiling.StepTwo.OptionThree.title.localized,
                       subtitle: Localizer.UserProfiling.StepTwo.OptionThree.subtitle.localized,
                       content: Localizer.UserProfiling.StepTwo.OptionThree.content.localized,
                       checkedImage: ImageLayout.SUICommon.checkedImage,
                       uncheckedImage: ImageLayout.SUICommon.uncheckedImage,
                       image: Image("img_fae"),
                       isSelected: selectedUserType == .engineerOrSale),
                Option(title: Localizer.UserProfiling.StepTwo.OptionFour.title.localized,
                       subtitle: Localizer.UserProfiling.StepTwo.OptionFour.subtitle.localized,
                       content: Localizer.UserProfiling.StepTwo.OptionFour.content.localized,
                       checkedImage: ImageLayout.SUICommon.checkedImage,
                       uncheckedImage: ImageLayout.SUICommon.uncheckedImage,
                       image: Image("img_other"),
                       isSelected: selectedUserType == .other)
             ])
    }
}
