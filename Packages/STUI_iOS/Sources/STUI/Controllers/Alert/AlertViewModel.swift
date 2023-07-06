//
//  AlertPresenter.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public struct AlertConfiguration {
    public let image: UIImage?
    public let text: String
    public let callback: AlertActionClosure

    public init(image: UIImage?, text: String, callback: AlertActionClosure) {
        self.image = image
        self.text = text
        self.callback = callback
    }
}

public class AlertPresenter: BasePresenter<AlertViewController, AlertConfiguration> {

}

// MARK: - AlertDelegate
extension AlertPresenter: AlertDelegate {

    public func load() {
        view.configureView()

        view.configureView(with: param)
    }

}
