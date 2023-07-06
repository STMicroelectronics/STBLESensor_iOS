//
//  LicensePresenter.swift
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

public final class LicensePresenter: BasePresenter<LicenseViewController, URL> {

}

// MARK: - LicenseViewControllerDelegate
extension LicensePresenter: LicenseDelegate {

    public func load() {
        view.configureView()
        
        guard let license = try? String(contentsOf: param) else { return }

        view.licenseLabel.text = license
        view.licenseLabel.font = FontLayout.font(size: 12, weight: .light)
    }

}
