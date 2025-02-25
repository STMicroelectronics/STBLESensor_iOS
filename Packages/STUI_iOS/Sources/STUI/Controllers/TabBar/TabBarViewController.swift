//
//  TabBarViewController.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

open class TabBarViewController: BaseViewController<TabBarDelegate, MainView> {

    public static let mainViewOffset = 25.0

    open override func makeView() -> MainView {
        MainView.make(with: Bundle.module) as? MainView ?? MainView()
    }

    open override func configure() {
        super.configure()
    }

    open override func viewDidLoad() {

        super.viewDidLoad()

        presenter.load()

    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    open override func configureView() {
        let mainView = makeView()
        view.addSubview(mainView,
                        constraints: [
                            equal(\.topAnchor),
                            equal(\.safeAreaLayoutGuide.leftAnchor),
                            equal(\.safeAreaLayoutGuide.rightAnchor),
                            equal(\.safeAreaLayoutGuide.bottomAnchor)
                        ])
        self.mainView = mainView

        view.backgroundColor = ColorLayout.primary.auto
        self.mainView.backgroundColor = view.backgroundColor
    }
}

public extension UIViewController {

    func selectTabItem(for side: TabBarSide) {
        guard let controller = self as? TabBarViewController else {
            guard let parent = parent else { return }
            parent.selectTabItem(for: side)
            return
        }

        controller.mainView.tabBarView.selectTabItem(for: side)
    }

    func showTabBar() {

        guard let controller = self as? TabBarViewController else {
            guard let parent = parent else { return }
            parent.showTabBar()
            return
        }

        controller.mainView.tabBarViewBottomConstraint.constant = 0
        controller.mainView.mainViewOffsetConstraint.constant = -TabBarViewController.mainViewOffset

        UIView.animate(withDuration: 0.3) {
            controller.view.layoutIfNeeded()
        }
    }

    func hideTabBar() {

        guard let controller = self as? TabBarViewController else {
            guard let parent = parent else { return }
            parent.hideTabBar()
            return
        }

        controller.mainView.tabBarViewBottomConstraint.constant = -(controller.mainView.tabBarViewHeighConstraint.constant + UIDevice.current.safeAreaEdgeInsets.bottom)
        controller.mainView.mainViewOffsetConstraint.constant = 0.0

        UIView.animate(withDuration: 0.3) {
            controller.view.layoutIfNeeded()
        }
    }
}
