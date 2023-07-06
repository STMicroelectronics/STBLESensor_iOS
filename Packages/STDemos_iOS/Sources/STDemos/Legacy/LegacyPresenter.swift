//
//  LegacyPresenter.swift
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

final class LegacyPresenter: DemoBasePresenter<LegacyViewController, String> {

}

// MARK: - LegacyDelegate
extension LegacyPresenter: LegacyDelegate {

    func load() {

        let demoTitle = param.param ?? "Legacy"
        
        view.title = demoTitle
        
        view.configureView()
    }

}
