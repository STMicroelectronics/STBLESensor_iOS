//
//  SUIDebugConsoleViewModel.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STBlueSDK
import STCore

@MainActor
public final class SUIDebugConsoleViewModel: ObservableObject {

    let node: Node

    @Published private(set) var log: String = ""

    public init(node: Node) {
        self.node = node
    }

    func sendCommand(_ commandText: String) {
        BlueManager.shared.sendMessage(
            commandText,
            to: node,
            completion: DebugConsoleCallback(
                timeOut: 1.0,
                onCommandResponds: { [weak self] text in
                    Task { @MainActor in
                        guard let self else { return }
                        self.log = text + "\n\n" + self.log
                    }
                }, onCommandError: {
                    Logger.debug(text: "!!! DEBUG CONSOLE ERROR !!!")
                }
            )
        )
    }
}
