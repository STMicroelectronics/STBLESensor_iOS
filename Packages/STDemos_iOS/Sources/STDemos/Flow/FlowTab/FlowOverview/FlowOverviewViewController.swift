//
//  FlowOverviewViewController.swift
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

final class FlowOverviewViewController: TableNodeNoViewController<FlowOverviewDelegate> {
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Overview"
        
        tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 50.0, right: 0.0)
        
        presenter.load()
    }
    
    private func createCardStyle(_ view: UIView) {
        view.layer.cornerRadius = 8.0
        view.backgroundColor = .white
        view.applyShadow()
    }

    override func configureView() {
        super.configureView()
    }

    override func configureTableView() {
        
        tableView.separatorStyle = .none
        
        view.addSubview(tableView, constraints: [
            equal(\.topAnchor),
            equal(\.leftAnchor),
            equal(\.rightAnchor),
            equal(\.bottomAnchor)
        ])

        tableView.backgroundColor = view.backgroundColor
    }
}
