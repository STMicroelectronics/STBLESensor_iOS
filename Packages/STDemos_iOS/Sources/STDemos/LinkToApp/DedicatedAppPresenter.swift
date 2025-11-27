//
//  DedicatedAppPresenter.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK

final class DedicatedAppPresenter: DemoBasePresenter<DedicatedAppViewController, DedicatedAppInfo> {
    public override init(param: DemoParam<DedicatedAppInfo>) {
        super.init(param: param)
    }
}

// MARK: - LinkToAppDelegate
extension DedicatedAppPresenter: DedicatedAppDelegate {

    func load() {

        let demoTitle = param.param?.name ?? ""
        
        view.title = demoTitle
        
        view.configureView()
        
        if let dedicatedAppInfo = param.param {
            view.presentSwiftUIView(DedicatedAppView(dedicatedAppInfo: dedicatedAppInfo))
        }
    }
}
