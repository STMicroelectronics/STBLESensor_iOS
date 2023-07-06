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

public final class TabBarViewController: BaseViewController<TabBarDelegate, MainView> {

    public static let mainViewOffset = 25.0

    public override func makeView() -> MainView {
        MainView.make(with: Bundle.module) as? MainView ?? MainView()
    }

    public override func configure() {
        super.configure()
    }

    public override func viewDidLoad() {

        super.viewDidLoad()

        presenter.load()

    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    public override func configureView() {
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

public extension BaseViewController {
    func showTabBar() {
        guard let controller = parent?.parent as? TabBarViewController else { return }

        controller.mainView.tabBarViewBottomConstraint.constant = 0
        controller.mainView.mainViewOffsetConstraint.constant = -TabBarViewController.mainViewOffset

        UIView.animate(withDuration: 0.3) {
            controller.view.layoutIfNeeded()
        }
    }

    func hideTabBar() {
        guard let controller = parent?.parent as? TabBarViewController else { return }

        controller.mainView.tabBarViewBottomConstraint.constant = -(controller.mainView.tabBarViewHeighConstraint.constant + UIDevice.current.safeAreaEdgeInsets.bottom)

        controller.mainView.mainViewOffsetConstraint.constant = 0.0

        UIView.animate(withDuration: 0.3) {
            controller.view.layoutIfNeeded()
        }
    }
}
