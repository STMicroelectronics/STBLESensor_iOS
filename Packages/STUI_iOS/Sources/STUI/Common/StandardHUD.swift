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
    func dismiss()
    func showProgress(with text: String?, progress: Float)
}

public struct StandardHUD: HUD {

    public static let shared = StandardHUD()

    public func configure() {
        ProgressHUD.animationType = .circleStrokeSpin
        ProgressHUD.colorHUD = .systemGray
        ProgressHUD.colorBackground = .clear
        ProgressHUD.colorAnimation = ColorLayout.secondary.light
        ProgressHUD.colorProgress = ColorLayout.secondary.light
        ProgressHUD.colorStatus = .label
        ProgressHUD.fontStatus = .boldSystemFont(ofSize: 24)
//        ProgressHUD.imageSuccess = UIImage(named: "success.png")
//        ProgressHUD.imageError = UIImage(named: "error.png")
    }

    public func show(with text: String? = nil) {
        ProgressHUD.show(text, interaction: false)
    }

    public func dismiss() {
        ProgressHUD.dismiss()
    }

    public func showProgress(with text: String? = nil, progress: Float) {
        ProgressHUD.showProgress(text, CGFloat(progress), interaction: false)
    }


}

