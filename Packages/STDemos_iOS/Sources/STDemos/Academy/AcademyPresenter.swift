//
//  AcademyPresenter.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK

final class AcademyPresenter: DemoPresenter<AcademyViewController> {

}

// MARK: - EventCounterViewControllerDelegate
extension AcademyPresenter: AcademyDelegate {

    func load() {
        
        view.configureView()
    }
    
}
