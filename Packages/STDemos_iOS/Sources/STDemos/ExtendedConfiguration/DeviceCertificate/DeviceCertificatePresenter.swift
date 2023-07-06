//
//  DeviceCertificatePresenter.swift
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

final class DeviceCertificatePresenter: BasePresenter<DeviceCertificateViewController, Void> {

}

// MARK: - DeviceCertificateDelegate
extension DeviceCertificatePresenter: DeviceCertificateDelegate {

    func load() {
        view.configureView()
    }

    func register() {

    }

    func showCertificate() {
        
    }
}
