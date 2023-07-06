//
//  AlertViewController.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public class AlertViewController: BaseViewController<AlertDelegate, AlertView> {

    public override func makeView() -> AlertView {
        AlertView.make(with: Bundle.module) as? AlertView ?? AlertView()
    }

    public override func configure() {
        super.configure()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = "Alert_title"

        presenter.load()
    }

    public override func configureView() {
        super.configureView()

        view.backgroundColor = .clear
        mainView.backgroundColor = .clear
    }

}

extension AlertViewController {
    func configureView(with alertConfiguration: AlertConfiguration)  {
        mainView.imageView.image = alertConfiguration.image
        mainView.textLabel.text = alertConfiguration.text

        mainView.actionButton.setTitle(alertConfiguration.callback.title, for: .normal)
        mainView.actionButton.addAction(for: .touchUpInside) { [weak self] _ in
            guard let self = self else { return }

            self.dismiss(animated: true)
        }
    }
}
