//
//  FlowMoreTabPresenter.swift
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

final class FlowMoreTabPresenter: BasePresenter<FlowMoreTabViewController, Node> {
    var director: TableDirector?
}

// MARK: - FlowMoreViewControllerDelegate
extension FlowMoreTabPresenter: FlowMoreTabDelegate {

    func load() {
        view.configureView()
        
        director = TableDirector(with: view.tableView)
        
        director?.register(viewModel: FlowMoreBoardViewModel.self,
                           type: .fromClass,
                           bundle: .module)
        
        director?.register(viewModel: FlowMoreItemViewModel.self,
                           type: .fromClass,
                           bundle: .module)
        
        director?.elements.append(FlowMoreBoardViewModel(param: param))
        
        loadMoreItems().forEach { flowMoreItem in
            director?.elements.append(FlowMoreItemViewModel(param: flowMoreItem, urlHandler: {
                if let url = URL(string: flowMoreItem.link) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
        }
        director?.reloadData()
    }

    private func loadMoreItems() -> [FlowMoreItem] {
        if(param.type == .sensorTileBoxPro || param.type == .sensorTileBoxProB) {
            return sensorTileBoxProFlowMoreItems
        } else {
            return sensorTileBoxFlowMoreItems
        }
    }
}
