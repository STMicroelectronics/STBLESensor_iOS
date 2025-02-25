//
//  BoardPresenter.swift
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
import STDemos
import STCore

public struct BoardConf {
    let board: Board
    let firmwareNamesFilter: [String]?
    let firmwareSupportedVersions: [String]?

    let isDemoListVisible: Bool

    public init(board: Board, firmwareNamesFilter: [String]?, firmwareSupportedVersions: [String]?, isDemoListVisible: Bool) {
        self.board = board
        self.firmwareNamesFilter = firmwareNamesFilter
        self.firmwareSupportedVersions = firmwareSupportedVersions
        self.isDemoListVisible = isDemoListVisible
    }
}

final class BoardPresenter: BasePresenter<BoardViewController, BoardConf> {
    var director: TableDirector?
}

// MARK: - BoardDelegate
extension BoardPresenter: BoardDelegate {
    
    func load() {
        view.configureView()
        
        if let analytics: AnalyticsServiceAIoTCraftProtocol = Resolver.shared.resolve() {
            analytics.trackCatalogFlow(withBoardName: param.board.friendlyName ?? param.board.name)
        }
        
        if director == nil {
            director = TableDirector(with: view.tableView)
            director?.register(viewModel: BoardHeaderViewModel.self,
                               type: .fromClass,
                               bundle: .main)
            director?.register(viewModel: DemoViewModel.self,
                               type: .fromClass,
                               bundle: STDemos.bundle)
            director?.register(viewModel: ContainerCellViewModel
                               <any ViewViewModel>.self,
                               type: .fromClass,
                               bundle: STUI.bundle)
            director?.register(viewModel: YoutubeViewModel.self,
                               type: .fromClass,
                               bundle: STUI.bundle)
        }
        
        director?.elements.append(BoardHeaderViewModel(param: param.board, firmwareHandler: { [weak self] in
            guard let self else { return }
            self.view.navigationController?.show(FirmwareListPresenter(param: FirmwareFilter(board: self.param.board,
                                                                                             firmwareNamesFilter: self.param.firmwareNamesFilter,
                                                                                             firmwareSupportedVersions: self.param.firmwareSupportedVersions)).start(), sender: nil)
        }, datasheetsHandler: { [weak self] in
            guard let self else { return }
            self.view.open(url: self.param.board.datasheetsUrl ?? "https://www.st.com/")
        }))
        
        if param.isDemoListVisible {
            if let availableDemos = param.board.availableDemos {
                if !availableDemos.isEmpty {
                    let labelViewModel = LabelViewModel(param: CodeValue<String>(value: Localizer.CatalogDetail.Text.availableDemos.localized),
                                                        layout: Layout.standard)
                    
                    director?.elements.append(ContainerCellViewModel(childViewModel: labelViewModel, layout: Layout.standard))
                    
                    //if let availableDemos = param.board.availableDemos {
                    director?.elements.append(contentsOf: availableDemos.enumerated().map({ index, demo in
                        DemoViewModel(param: demo, index: index, isLockedCheckEnabled: false)
                    }))
                }
            }
        }
        
        if param.board.videoId != nil {
            let labelViewModel = LabelViewModel(param: CodeValue<String>(value: Localizer.CatalogDetail.Text.exampleVideo.localized),
                                                layout: Layout.standard)
            director?.elements.append(ContainerCellViewModel(childViewModel: labelViewModel, layout: Layout.standard))
            director?.elements.append(YoutubeViewModel(param: param.board))
        }
        
        if param.board.url == nil {
            view.bottomView?.isUserInteractionEnabled = false
            view.bottomView?.layer.opacity = 0.4
        }
        
        director?.reloadData()
    }
    
    func showDetail() {
        view.open(url: param.board.url ?? "https://www.st.com/")
    }
    
}
