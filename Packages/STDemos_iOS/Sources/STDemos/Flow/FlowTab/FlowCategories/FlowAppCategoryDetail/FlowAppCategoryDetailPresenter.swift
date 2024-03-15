//
//  FlowAppCategoryDetailPresenter.swift
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

final class FlowAppCategoryDetailPresenter: BasePresenter<FlowAppCategoryDetailViewController, FlowsAndNodeParam> {
    var director: TableDirector?
}

// MARK: - FlowAppCategoryDetailViewControllerDelegate
extension FlowAppCategoryDetailPresenter: FlowAppCategoryDetailDelegate {

    func load() {
        view.configureView()
        
        view.title = param.flows.first?.category
        
        director = TableDirector(with: view.tableView)

        director?.register(viewModel: FlowAppsCatagoriesViewModel.self,
                           type: .fromClass,
                           bundle: .module)

        param.flows.forEach { flowAppCategoryDetailItem in
            director?.elements.append(FlowAppsCatagoriesDetailViewModel(param: flowAppCategoryDetailItem, onFlowAppCategoryDetailClicked: { item in
                self.view.navigationController?.pushViewController(
                    FlowOverviewPresenter(
                        param: FlowAndNodeParam(
                            flow: flowAppCategoryDetailItem,
                            node: self.param.node
                        )
                    ).start(),
                    animated: true
                )
            }, onFlowUploadClicked: { flow in
                let flowUploadController = FlowUploadPresenter(param: FlowAndNodeParam(flow: flow, node: self.param.node))
                flowUploadController.configure(with: [flow])
                
                self.view.navigationController?.pushViewController(
                    flowUploadController.start(),
                    animated: true
                )
            }, onFlowDeleteClicked: { flow in }))
        }
        director?.reloadData()
    }

}
