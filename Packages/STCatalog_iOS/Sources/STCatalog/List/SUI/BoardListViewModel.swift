//
//  BoardListViewModel.swift
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
import Algorithms

@MainActor
public final class BoardListViewModel: ObservableObject {

    // MARK: - Configuration
    public let nodeTypesFilter: [NodeType]?
    public let firmwareNamesFilter: [String]?
    public let firmwareSupportedVersions: [String]?
    public let isDemoListVisible: Bool
    public let isGrouped: Bool

    // MARK: - Published state
    @Published public private(set) var boards: [Board] = []
    @Published public var currentFilter: [DemoGroup] = []
    @Published public var currentOrderFilter: OrderByGroup = .none
    @Published public var isShowingFilters: Bool = false

    public init(nodeTypesFilter: [NodeType]?,
                firmwareNamesFilter: [String]? = nil,
                firmwareSupportedVersions: [String]? = nil,
                isDemoListVisible: Bool,
                isGrouped: Bool = false) {
        self.nodeTypesFilter = nodeTypesFilter
        self.firmwareNamesFilter = firmwareNamesFilter
        self.firmwareSupportedVersions = firmwareSupportedVersions
        self.isDemoListVisible = isDemoListVisible
        self.isGrouped = isGrouped
    }

    public func load() {
        refresh()
    }

    public func refresh() {
        guard let catalogService: CatalogService = Resolver.shared.resolve(),
              let catalog = catalogService.catalog else {
            boards = []
            return
        }

        let filter: [DemoGroup] = currentFilter.isEmpty ? DemoGroup.allCases : currentFilter

        var filteredDemo = [Demo]()
        filter.forEach { group in
            filteredDemo.append(contentsOf: Demo.allCases.filter { $0.groups.contains(group) })
        }

        var blueStSdkV2Boards = [Firmware]()
        var blueStSdkV1Boards = [Firmware]()

        if let nodeTypesFilter {
            blueStSdkV2Boards.append(contentsOf: catalog.blueStSdkV2.filterWithNodeTypes(nodeTypesFilter))
            if let blueStSdkV1 = catalog.blueStSdkV1 {
                blueStSdkV1Boards.append(contentsOf: blueStSdkV1.filterWithNodeTypes(nodeTypesFilter))
            }
        } else {
            blueStSdkV2Boards.append(contentsOf: catalog.blueStSdkV2)
            if let blueStSdkV1 = catalog.blueStSdkV1 {
                blueStSdkV1Boards.append(contentsOf: blueStSdkV1)
            }
        }

        var collected = [Board]()
        collected.append(contentsOf: blueStSdkV2Boards.filterWithDemos(filteredDemo).boardsWithCharacteristic)
        collected.append(contentsOf: blueStSdkV1Boards.filterWithDemos(filteredDemo).boardsWithCharacteristic)

        if currentFilter.isEmpty, let catalogBoards = catalog.boards?.toBoard {
            collected.append(contentsOf: catalogBoards)
        }

        var merged: [Board] = []
        for board in collected {
            let currentDevId = board.deviceId
            let boardsWithCurrentDevId = collected.filter { $0.deviceId == currentDevId }

            var chars: [BleCharacteristic] = []
            boardsWithCurrentDevId.forEach { $0.characteristics?.forEach { chars.append($0) } }
            chars = chars.uniqued(on: { $0.uuid })

            var boardToAdd = boardsWithCurrentDevId[0]
            boardToAdd.characteristics = chars
            merged.append(boardToAdd)
        }

        merged = merged.uniqued(on: { $0.deviceId })

        if let catalogBoards = catalog.boards {
            for idx in merged.indices {
                for cBoard in catalogBoards {
                    if cBoard.bleDeviceId == merged[idx].deviceId {
                        merged[idx].friendlyName = cBoard.friendlyName
                        merged[idx].status = cBoard.status
                        merged[idx].description = cBoard.description
                        merged[idx].url = cBoard.orderUrl
                        merged[idx].datasheetsUrl = cBoard.documentationUrl
                        merged[idx].videoId = cBoard.videoUrl
                        merged[idx].wikiUrl = cBoard.wikiUrl
                        merged[idx].variant = cBoard.variant
                        merged[idx].boardPart = cBoard.boardPart
                        merged[idx].releaseDate = cBoard.releaseDate
                    }
                }
            }
        }

        if isGrouped {
            merged = merged.uniqued(on: { $0.friendlyName })
        }

        let originalOrder = merged

        switch currentOrderFilter {
        case .alphabetical:
            merged = merged.sorted { $0.name.lowercased() < $1.name.lowercased() }
        case .releaseDate:
            merged = merged.sorted { ($0.releaseDate ?? "") < ($1.releaseDate ?? "") }
        case .none:
            merged = originalOrder
        }

        merged = merged.uniqued(on: { $0.boardPart })

        boards = merged
    }

    public func applyFilters(_ result: FilterParameters) {
        currentFilter = result.demosGroup
        currentOrderFilter = result.orderingBy
        refresh()
    }

    public func boardDetailConf(for board: Board) -> BoardConf {
        BoardConf(board: board,
                  firmwareNamesFilter: firmwareNamesFilter,
                  firmwareSupportedVersions: firmwareSupportedVersions,
                  isDemoListVisible: isDemoListVisible)
    }
}
