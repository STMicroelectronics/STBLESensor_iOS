//
//  FFTStatsViewModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import UIKit
import STUI

public class FFTStatsPresenter: BasePresenter<FFTStatsViewController, AlertFFTDetails> {

}

// MARK: - AlertDelegate
extension FFTStatsPresenter: FFTStatsDelegate {

    public func load() {
        view.configureView()

        view.configureView(with: param)
    }

}
