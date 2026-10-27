//
//  BoardDetailViewModel.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import STBlueSDK
import STCore
import STDemos

@MainActor
final class BoardDetailViewModel: ObservableObject {

    let conf: BoardConf

    init(conf: BoardConf) {
        self.conf = conf
    }

    var board: Board {
        conf.board
    }

    var availableDemos: [Demo] {
        board.availableDemos ?? []
    }

    func trackAnalytics() {
        if let analytics: AnalyticsServiceAIoTCraftProtocol = Resolver.shared.resolve() {
            analytics.trackCatalogFlow(
                withBoardName: board.friendlyName ?? board.name
            )
        }
    }
}
