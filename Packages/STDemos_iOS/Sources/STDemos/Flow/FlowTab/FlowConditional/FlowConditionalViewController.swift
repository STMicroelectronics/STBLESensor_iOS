//
//  FlowConditionalViewController.swift
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

final class FlowConditionalViewController: TableNodeNoViewController<FlowConditionalDelegate> {

    var bottomView: UIStackView?

    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "IF Condition"
        
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 50.0, right: 0.0)

        let saveButton = UIButton(type: .custom)
        let terminateButton = UIButton(type: .custom)
        Buttonlayout.textColorWithIamge(color: ColorLayout.systemWhite.light, image: ImageLayout.Common.save?.withTintColor(ColorLayout.systemWhite.light, renderingMode: .alwaysTemplate)).apply(to: saveButton, text: "  PLAY  ")
        Buttonlayout.textColorWithIamge(color: ColorLayout.systemWhite.light, image: ImageLayout.Common.close?.withTintColor(ColorLayout.systemWhite.light, renderingMode: .alwaysTemplate)).apply(to: terminateButton, text: "TERMINATE")
        
        saveButton.on(.touchUpInside) { [weak self] _ in
            self?.presenter.playAppButtonTapped()
        }
        
        terminateButton.on(.touchUpInside) { [weak self] _ in
            self?.presenter.terminateButtonTapped()
        }
        
        let buttonStackView = UIStackView.getHorizontalStackView(
            withSpacing: 10.0,
            views: [
                terminateButton.embedInView(with: .standardEmbed),
                saveButton.embedInView(with: .standardEmbed)
            ]
        )
        
        var bottomViews = [UIView]()
        bottomViews.append(buttonStackView)

        if UIDevice.current.hasNotch {
            bottomViews.append(UIView.empty(height: 40.0))
        }

        let bottomStackView = UIStackView.getVerticalStackView(withSpacing: 0.0,
                                                               views: bottomViews)

        bottomViews.forEach { view in
            view.backgroundColor = ColorLayout.primary.light
        }
        
        view.addSubview(bottomStackView)
        bottomStackView.activate(constraints: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ])
        
        bottomView = bottomStackView

        presenter.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItems?.removeAll()
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
