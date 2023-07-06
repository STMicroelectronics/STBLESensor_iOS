//
//  BoardListViewController.swift
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

public final class BoardListViewController: TableNoViewController<BoardListDelegate> {

    public override func configure() {
        super.configure()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = Localizer.Catalog.Text.title.localized

        presenter.load()

        stTabBarView?.removeAllTabs()

        stTabBarView?.actionButton.setImage(ImageLayout.Common.filter?.template, for: .normal)
        stTabBarView?.setMainAction { [weak self] _ in
            self?.presenter.showFilters()
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        showTabBar()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        hideTabBar()
    }

    public override func configureView() {
        super.configureView()
    }

}
