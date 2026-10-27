//
//  AppDelegate+Welcome.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STWelcome
import STUserProfiling
import STCore
import STBlueSDK

extension AppDelegate {

    func goToWelcome() {

        let pages = [
            OldWelcomePage.oldPageOne,
            OldWelcomePage.oldPageTwo,
            OldWelcomePage.oldPageThree,
            OldWelcomePage.oldPageFour
//            OldWelcomePage.oldPageFive,
//            OldWelcomePage.oldPageSix,
//            OldWelcomePage.oldPageSeven
        ]

        let url = Bundle.main.url(forResource: "License", withExtension: "md")

        let welcome = OldWelcome(pages: pages, licenseUrl: url) { [weak self] in
            self?.goToUserProfiling()
        }

        window?.rootViewController = WelcomePresenter(param: welcome).start().embeddedInNav()
    }

    func goToUserProfiling() {

        guard let nav = window?.rootViewController as? UINavigationController else { return }

        let profile = OldProfile(steps: [
            OldStep.oldStepOne,
            OldStep.oldStepTwo
        ]) { [weak self] profile in
            if let sessionService: SessionService = Resolver.shared.resolve() {

                let appMode: AppMode = profile.steps[0].options[0].isSelected ? .beginner : .expert
                let userTypeIndex = profile.steps[1].options.firstIndex(where: { $0.isSelected }) ?? 0

                let userType: UserType = UserType(rawValue: userTypeIndex) ?? .none

                sessionService.update(appMode: appMode, userType: userType)
            }
            self?.goToMain()
        }

        nav.setViewControllers([
            UserProfilingPresenter(param: profile).start()
        ], animated: true)
    }

    func goToMain() {
        window?.rootViewController = MainPresenter().start()
    }

}

extension OldWelcomePage {

    static var oldPageOne: OldWelcomePage {
        OldWelcomePage(image: UIImage(named: "img_welcome1"),
                    title: Localizer.Welcome.PageOne.title.localized,
                    content: Localizer.Welcome.PageOne.content.localized,
                    next: Localizer.Welcome.PageOne.next.localized,
                    isNextHidden: true)
    }

    static var oldPageTwo: OldWelcomePage {
        OldWelcomePage(image: UIImage(named: "img_welcome2"),
                    title: Localizer.Welcome.PageTwo.title.localized,
                    content: Localizer.Welcome.PageTwo.content.localized,
                    next: Localizer.Welcome.PageTwo.next.localized,
                    isNextHidden: true)
    }

    static var oldPageThree: OldWelcomePage {
        OldWelcomePage(image: UIImage(named: "img_welcome3"),
                    title: Localizer.Welcome.PageThree.title.localized,
                    content: Localizer.Welcome.PageThree.content.localized,
                    next: Localizer.Welcome.PageThree.next.localized,
                    isNextHidden: true)
    }

    static var oldPageFour: OldWelcomePage {
        OldWelcomePage(image: UIImage(named: "img_welcome4"),
                    title: Localizer.Welcome.PageFour.title.localized,
                    content: Localizer.Welcome.PageFour.content.localized,
                    next: Localizer.Welcome.PageFour.next.localized,
                    isNextHidden: false)
    }
//
//    static var oldPageFive: OldWelcomePage {
//        OldWelcomePage(image: UIImage(named: "img_welcome5"),
//                    title: Localizer.Welcome.PageFive.title.localized,
//                    content: Localizer.Welcome.PageFive.content.localized,
//                    next: Localizer.Welcome.PageFive.next.localized,
//                    isNextHidden: true)
//    }
//
//    static var oldPageSix: OldWelcomePage {
//        OldWelcomePage(image: UIImage(named: "img_welcome6"),
//                    title: Localizer.Welcome.PageSix.title.localized,
//                    content: Localizer.Welcome.PageSix.content.localized,
//                    next: Localizer.Welcome.PageSix.next.localized,
//                    isNextHidden: true)
//    }
//
//    static var oldPageSeven: OldWelcomePage {
//        OldWelcomePage(image: UIImage(named: "img_welcome7"),
//                    title: Localizer.Welcome.PageSeven.title.localized,
//                    content: Localizer.Welcome.PageSeven.content.localized,
//                    next: Localizer.Welcome.PageSeven.next.localized,
//                    isNextHidden: false)
//    }

}

extension OldStep {
    static var oldStepOne: OldStep {
        OldStep(navigationTitle: Localizer.UserProfiling.StepOne.Text.navigationTitle.localized,
             title: "What is your proficiency level?",
             titleLabel: Localizer.UserProfiling.StepOne.Text.title.localized,
             next: Localizer.UserProfiling.StepOne.Text.next.localized,
             options: [
                OldOption(title: Localizer.UserProfiling.StepOne.OptionOne.title.localized,
                       subtitle: Localizer.UserProfiling.StepOne.OptionOne.subtitle.localized,
                       content: Localizer.UserProfiling.StepOne.OptionOne.content.localized,
                       checkedImage: ImageLayout.Common.checkedImage,
                       uncheckedImage: ImageLayout.Common.uncheckedImage,
                       image: nil,
                       isSelected: true),
                OldOption(title: Localizer.UserProfiling.StepOne.OptionTwo.title.localized,
                       subtitle: Localizer.UserProfiling.StepOne.OptionTwo.subtitle.localized,
                       content: Localizer.UserProfiling.StepOne.OptionTwo.content.localized,
                       checkedImage: ImageLayout.Common.checkedImage,
                       uncheckedImage: ImageLayout.Common.uncheckedImage,
                       image: nil)
             ])
    }

    static var oldStepTwo: OldStep {
        OldStep(navigationTitle: Localizer.UserProfiling.StepTwo.Text.navigationTitle.localized,
             title: "What is your profile?",
             titleLabel: Localizer.UserProfiling.StepTwo.Text.title.localized,
             next: Localizer.UserProfiling.StepTwo.Text.next.localized,
             options: [
                OldOption(title: Localizer.UserProfiling.StepTwo.OptionOne.title.localized,
                       subtitle: Localizer.UserProfiling.StepTwo.OptionOne.subtitle.localized,
                       content: Localizer.UserProfiling.StepTwo.OptionOne.content.localized,
                       checkedImage: ImageLayout.Common.checkedImage,
                       uncheckedImage: ImageLayout.Common.uncheckedImage,
                       image: UIImage(named: "img_developer"),
                       isSelected: true),
                OldOption(title: Localizer.UserProfiling.StepTwo.OptionTwo.title.localized,
                       subtitle: Localizer.UserProfiling.StepTwo.OptionTwo.subtitle.localized,
                       content: Localizer.UserProfiling.StepTwo.OptionTwo.content.localized,
                       checkedImage: ImageLayout.Common.checkedImage,
                       uncheckedImage: ImageLayout.Common.uncheckedImage,
                       image: UIImage(named: "img_university")),
                OldOption(title: Localizer.UserProfiling.StepTwo.OptionThree.title.localized,
                       subtitle: Localizer.UserProfiling.StepTwo.OptionThree.subtitle.localized,
                       content: Localizer.UserProfiling.StepTwo.OptionThree.content.localized,
                       checkedImage: ImageLayout.Common.checkedImage,
                       uncheckedImage: ImageLayout.Common.uncheckedImage,
                       image: UIImage(named: "img_fae")),
                OldOption(title: Localizer.UserProfiling.StepTwo.OptionFour.title.localized,
                       subtitle: Localizer.UserProfiling.StepTwo.OptionFour.subtitle.localized,
                       content: Localizer.UserProfiling.StepTwo.OptionFour.content.localized,
                       checkedImage: ImageLayout.Common.checkedImage,
                       uncheckedImage: ImageLayout.Common.uncheckedImage,
                       image: UIImage(named: "img_other"))
             ])
    }
}
