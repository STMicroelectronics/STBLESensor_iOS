//
//  BoardViewController.swift
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
import STBlueSDK

final class BoardViewController: TableNoViewController<BoardDelegate> {

    var bottomView: UIStackView?

    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizer.CatalogDetail.Text.title.localized

        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 50.0, right: 0.0)

        let emptyView = UIView()
        let secondEmptyView = UIView()

        let actionButton = UIButton(type: .custom)
        Buttonlayout.standard.apply(to: actionButton, text: "     ORDER & BUY     ")
        actionButton.on(.touchUpInside) { [weak self] _ in
            self?.presenter.showDetail()
        }

        let buttonStackView = UIStackView.getHorizontalStackView(withSpacing: 10.0,
                                                           views: [
                                                            emptyView,
                                                            actionButton.embedInView(with: .standardTopBottom),
                                                            secondEmptyView
                                                           ])

        var bottomViews = [UIView]()
        bottomViews.append(buttonStackView)

        if UIDevice.current.hasNotch {
            bottomViews.append(UIView.empty(height: 40.0))
        }

        let bottomStackView = UIStackView.getVerticalStackView(withSpacing: 0.0,
                                                               views: bottomViews)

        buttonStackView.backgroundColor = .white
        bottomStackView.backgroundColor = .white

//        emptyView.activate(constraints: [
//            equal(\.widthAnchor, toView: secondEmptyView, withAnchor: \.widthAnchor)
//        ])
        emptyView.setDimensionContraints(width: 10)
        secondEmptyView.setDimensionContraints(width: 10)
        
        view.addSubview(bottomStackView)
        bottomStackView.activate(constraints: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ])


        bottomView = bottomStackView

        presenter.load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let bottomView = bottomView else { return }

        view.bringSubviewToFront(bottomView)
        bottomView.applyShadow()
    }

    override func configureView() {
        super.configureView()
    }

    override func configureTableView() {

        tableView.separatorStyle = .none

        guard let bottomView = bottomView else { return }

        view.addSubview(tableView, constraints: [
            equal(\.topAnchor),
            equal(\.leftAnchor),
            equal(\.rightAnchor)
        ])

        tableView.activate(constraints: [
            equal(\.bottomAnchor, toView: bottomView, withAnchor: \.topAnchor)
        ])

        tableView.backgroundColor = view.backgroundColor
    }

}
