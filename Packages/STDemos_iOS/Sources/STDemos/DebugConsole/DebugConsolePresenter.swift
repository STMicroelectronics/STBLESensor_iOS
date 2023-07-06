//
//  DebugConsolePresenter.swift
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
import STCore
import STBlueSDK

final class DebugConsolePresenter: DemoPresenter<DebugConsoleViewController> {

}

// MARK: - DebugConsoleViewControllerDelegate
extension DebugConsolePresenter: DebugConsoleDelegate {

    func load() {
        view.configureView()
    }
    
    func sendCommand(_ commandText: String) {
        BlueManager.shared.sendMessage(
            commandText,
            to: param.node,
            completion: DebugConsoleCallback(
                timeOut: 1.0,
                onCommandResponds: { [weak self] text in
                    guard let self = self else { return }
                    self.view.logTextView.text = text + "\n\n" + self.view.logTextView.text
                }, onCommandError: {
                    Logger.debug(text: "!!! DEBUG CONSOLE ERROR !!!")
                }
            )
        )
    }

}
