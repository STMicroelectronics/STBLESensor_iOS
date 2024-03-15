//
//  StandardHUD.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import ProgressHUD

public protocol HUD {

    func configure()

    func show(with text: String?)
    func show(with text: String?, notDismissable: Bool)
    func dismiss()
    func dismiss(force: Bool)
    func showProgress(with text: String?, progress: Float)
}

public class StandardHUD: HUD {

    public static let shared = StandardHUD()
    private(set) var isNotDismissable: Bool = false

    public func configure() {
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.colorHUD = .systemGray
        ProgressHUD.colorBackground = .clear
        ProgressHUD.colorAnimation = ColorLayout.primary.light
        ProgressHUD.colorProgress = ColorLayout.primary.light
        ProgressHUD.colorStatus = .label
        ProgressHUD.fontStatus = .boldSystemFont(ofSize: 24)
//        ProgressHUD.imageSuccess = UIImage(named: "success.png")
//        ProgressHUD.imageError = UIImage(named: "error.png")
    }

    public func show(with text: String? = nil) {
        show(with: text, notDismissable: false)
    }

    public func show(with text: String? = nil, notDismissable: Bool) {
        if isNotDismissable {
            return
        }

        isNotDismissable = notDismissable
        ProgressHUD.show(text, interaction: false)
    }

    public func dismiss(force: Bool) {
        if force {
            isNotDismissable = false
        }

        dismiss()
    }

    public func dismiss() {
        if isNotDismissable {
            return
        }

        ProgressHUD.dismiss()
    }

    public func showProgress(with text: String? = nil, progress: Float) {
        ProgressHUD.showProgress(text, CGFloat(progress), interaction: false)
    }


}

