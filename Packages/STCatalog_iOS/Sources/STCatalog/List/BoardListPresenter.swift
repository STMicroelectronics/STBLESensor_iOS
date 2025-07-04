//
//  BoardListPresenter.swift
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
import STCore
import STDemos
import Algorithms

public struct BoardListConf {
    let nodeTypesFilter: [NodeType]?
    let firmwareNamesFilter: [String]?
    let firmwareSupportedVersions: [String]?
    let isDemoListVisible: Bool
    let isGrouped: Bool

    public init(nodeTypesFilter: [NodeType]?, firmwareNamesFilter: [String]? = nil, firmwareSupportedVersions: [String]? = nil, isDemoListVisible: Bool, isGrouped: Bool = false) {
        self.nodeTypesFilter = nodeTypesFilter
        self.firmwareNamesFilter = firmwareNamesFilter
        self.firmwareSupportedVersions = firmwareSupportedVersions
        self.isDemoListVisible = isDemoListVisible
        self.isGrouped = isGrouped
    }
}

public final class BoardListPresenter: BasePresenter<BoardListViewController, BoardListConf> {
    var director: TableDirector?
    var currentFilter: [DemoGroup] = [DemoGroup]()
    var currentOrderFilter: OrderByGroup = OrderByGroup.none
}

// MARK: - CatalogDelegate
extension BoardListPresenter: BoardListDelegate {
    
    public func load() {
        view.configureView()
        
        if director == nil {
            director = TableDirector(with: view.tableView)
            director?.register(viewModel: BoardViewModel.self,
                               type: .fromClass,
                               bundle: .main)
            
        }
        
        refresh()
    }
    
    public func refresh() {
        if let catalogService: CatalogService = Resolver.shared.resolve(),
           let catalog = catalogService.catalog {
            
            var filteredDemo = [Demo]()
            
            var filter: [DemoGroup] = [DemoGroup]()
            
            if currentFilter.isEmpty {
                filter.append(contentsOf: DemoGroup.allCases)
            } else {
                filter.append(contentsOf: currentFilter)
            }
            
            filter.forEach { group in
                filteredDemo.append(contentsOf: Demo.allCases.filter { $0.groups.contains(group) })
            }
            
            var boards = [BoardViewModel]()
            
            var blueStSdkV2Boards = [Firmware]()
            var blueStSdkV1Boards = [Firmware]()
            
            if let param = param.nodeTypesFilter {
                blueStSdkV2Boards.append(contentsOf: catalog.blueStSdkV2.filterWithNodeTypes(param))
                if let blueStSdkV1 = catalog.blueStSdkV1 {
                    blueStSdkV1Boards.append(contentsOf: blueStSdkV1.filterWithNodeTypes(param))
                }
            } else {
                blueStSdkV2Boards.append(contentsOf: catalog.blueStSdkV2)
                if let blueStSdkV1 = catalog.blueStSdkV1 {
                    blueStSdkV1Boards.append(contentsOf: blueStSdkV1)
                }
            }
            
            boards.append(contentsOf: blueStSdkV2Boards.filterWithDemos(filteredDemo).boardsWithCharacteristic.map { board in
                BoardViewModel(param: board)
            })
            
            boards.append(contentsOf: blueStSdkV1Boards.filterWithDemos(filteredDemo).boardsWithCharacteristic.map { board in
                BoardViewModel(param: board)
            })
            
            //Add the boards even if they have not a fw on catalog (if we have not used any filter on Demo)
            if currentFilter.isEmpty {
                if let catalogBoard = catalog.boards?.toBoard {
                    boards.append(contentsOf: catalogBoard.compactMap { board in
//                        if let type = board.type, let nodeTypesFilter = self.param.nodeTypesFilter, nodeTypesFilter.contains(type) {
                            return BoardViewModel(param: board)
//                        }
//                        return nil
                    })
                }
            }
            
            var boardMerged: [BoardViewModel] = []
            for board in boards {
                let currentDevId = board.param?.deviceId
                let boardsWithCurrentDevId = boards.filter { $0.param?.deviceId == currentDevId }
                
                var chars: [BleCharacteristic] = []
                boardsWithCurrentDevId.forEach { board in
                    board.param?.characteristics?.forEach { char in
                        chars.append(char)
                    }
                }
                
                chars = chars.uniqued(on: { $0.uuid })
                
                let boardToAdd = boardsWithCurrentDevId[0]
                boardToAdd.param?.characteristics = chars
                
                boardMerged.append(boardToAdd)
            }
            
            //            boards = boards.uniqued(on: { $0.param?.deviceId })
            boardMerged = boardMerged.uniqued(on: { $0.param?.deviceId })
            
            for board in boardMerged {
                catalog.boards?.forEach { cBoard in
                    if cBoard.bleDeviceId == board.param?.deviceId {
                        let catalogBoard = cBoard
                        board.param?.friendlyName = catalogBoard.friendlyName
                        board.param?.status = catalogBoard.status
                        board.param?.description = catalogBoard.description
                        board.param?.url = catalogBoard.orderUrl
                        board.param?.datasheetsUrl = catalogBoard.documentationUrl
                        board.param?.videoId = catalogBoard.videoUrl
                        board.param?.wikiUrl = catalogBoard.wikiUrl
                        board.param?.variant = catalogBoard.variant
                        board.param?.boardPart = catalogBoard.boardPart
                        board.param?.releaseDate = catalogBoard.releaseDate
                    }
                }
            }

            if param.isGrouped {
                boardMerged = boardMerged.uniqued(on: { $0.param?.friendlyName })
            }

            director?.elements.removeAll()
            //            director?.elements.append(contentsOf: boards)
            
            let originalBoardOrderList = boardMerged
            
            if currentOrderFilter == .alphabetical {
                boardMerged = boardMerged.sorted { $0.param?.name.lowercased() ?? "" < $1.param?.name.lowercased() ?? "" }
            } else if currentOrderFilter == .releaseDate {
                boardMerged = boardMerged.sorted { $0.param?.releaseDate ?? "" < $1.param?.releaseDate ?? "" }
            } else {
                boardMerged = originalBoardOrderList
            }
            
            boardMerged = boardMerged.uniqued(on: { $0.param?.boardPart })
            
            director?.elements.append(contentsOf: boardMerged)
        }
        
        director?.onSelect({ [weak self] indexpath in
            guard let self, let viewModel = self.director?.elements[indexpath.row] as? BoardViewModel,
            let board = viewModel.param else { return }

            self.view.navigationController?.show(BoardPresenter(param: BoardConf(board: board, 
                                                                                 firmwareNamesFilter: self.param.firmwareNamesFilter,
                                                                                 firmwareSupportedVersions: self.param.firmwareSupportedVersions,
                                                                                 isDemoListVisible: self.param.isDemoListVisible)).start(), sender: nil)
            
        })
        
        
        director?.reloadData()
    }
    
    public func showFilters() {
        view.present(DemoGroupFilterPresenter(param: FilterParameters(orderingBy: currentOrderFilter, demosGroup: currentFilter), completion: { [weak self] groups in
            self?.currentFilter.removeAll()
            self?.currentFilter.append(contentsOf: groups.demosGroup)
            self?.currentOrderFilter = groups.orderingBy
            self?.refresh()
        }).start(), animated: true)
    }
    
}

public extension Array where Element == Firmware {
    func filterWithDemos(_ demos: [ Demo ]) -> [Firmware] {
        let classTypes = Set<String>(demos.map({ $0.features }).joined().map { String(describing: $0)})
        
        return filter { element in
            guard let characteristics = element.characteristics else { return false }
            return !characteristics.featureClasses.isDisjoint(with: classTypes)
        }
    }
    
    func filterWithNodeTypes(_ types: [ NodeType ]) -> [Firmware] {
        return filter { element in
            guard let type = element.boardType else {
                return false
            }
            
            return types.contains(type)
        }
    }
}

public extension Array where Element == BleCharacteristic {
    var featureClasses: Set<String> {
        let test = Set<String>(FeatureType.featureClasses(from: map { $0.uuid.lowercased() } ).map( { String(describing: $0) } ))
        
        return test
    }
}

public extension Board {
    var availableDemos: [Demo]? {
        
        var uuidsString: [String] = []
        self.characteristics?.forEach { characteristic in
            uuidsString.append(characteristic.uuid)
        }
        
        let fTypes = FeatureType.featureClasses(from: uuidsString)
        let demos = Demo.demos(withFeatureTypes: fTypes)
        
        return demos
    }
    
}
