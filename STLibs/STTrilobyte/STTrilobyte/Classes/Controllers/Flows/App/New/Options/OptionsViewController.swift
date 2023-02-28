//
//  OptionsViewController.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 24/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class OptionsViewController<T: FlowItem>: StackViewController {
    var item: T?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "options".localized()

        configureView()
    }

    func configure(with item: T) {
        self.item = item
    }

    override func rightButtonPressed() {
        navigationController?.popViewController(animated: true)
    }

    func configureView() {

        guard let item = item else { return }

        addFooter(to: scrollView)
        leftButton?.isHidden = true
        rightButton?.setTitle("save_configuration".localized().uppercased(), for: .normal)
        rightButton?.setImage(UIImage.named("img_done"), for: .normal)

        stackView.axis = .vertical
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0.0, left: 24.0, bottom: 0.0, right: 24.0)
        stackView.spacing = 10.0

        stackView.addArrangedSubview(createTitleLabel(with: item.descr))

        configureView(with: item)
    }

    func configureView(with item: T) {

    }
}
