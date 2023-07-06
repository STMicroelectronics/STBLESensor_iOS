//
//  CallbackAlertViewModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public struct CallbackAlertConfiguration {
    public let image: UIImage?
    public let text: String
    public let callback: AlertActionClosureBool

    public init(image: UIImage?, text: String, callback: AlertActionClosureBool) {
        self.image = image
        self.text = text
        self.callback = callback
    }
}

public class CallbackAlertPresenter: BasePresenter<CallbackAlertViewController, CallbackAlertConfiguration> {

}

// MARK: - AlertDelegate
extension CallbackAlertPresenter: CallBackAlertDelegate {

    public func load() {
        view.configureView()

        view.configureView(with: param)
    }

}
