//
//  CallbackAlertViewController.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class CallbackAlertViewController: BaseViewController<CallBackAlertDelegate, CallbackAlertView> {

    public override func makeView() -> CallbackAlertView {
        CallbackAlertView.make(with: Bundle.module) as? CallbackAlertView ?? CallbackAlertView()
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

extension CallbackAlertViewController {
    func configureView(with alertConfiguration: CallbackAlertConfiguration)  {
        mainView.imageView.image = alertConfiguration.image
        mainView.textLabel.text = alertConfiguration.text
        
        mainView.actionButton.setTitle(alertConfiguration.callback.title, for: .normal)
        mainView.actionButton.addAction(for: .touchUpInside) { [weak self] bool in
            guard let self = self else { return }
            alertConfiguration.callback.completion(true)
            self.dismiss(animated: true)
        }
    }
}
