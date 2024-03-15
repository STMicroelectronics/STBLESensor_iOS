//
//  FlowExpertPresenter.swift
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

final class FlowExpertPresenter: BasePresenter<FlowExpertViewController, Node> {
    var director: TableDirector?
    var flows = [Flow?]()
}

// MARK: - FlowExpertViewControllerDelegate
extension FlowExpertPresenter: FlowExpertDelegate {

    func load() {
        view.configureView()

        flows = PersistanceService.shared.getAllCustomFlows()
        
        director = TableDirector(with: view.tableView)

        director?.register(viewModel: FlowAppsCatagoriesViewModel.self,
                           type: .fromClass,
                           bundle: .module)
        director?.register(viewModel: FlowExpertHeaderViewModel.self,
                           type: .fromClass,
                           bundle: .module)
        
        director?.elements.append(FlowExpertHeaderViewModel(param: self.param, newAppHandler: { [weak self] in
            guard let self else { return }
            let newFlowController = NewFlowPresenter(param: FlowAndNodeParam(flow: Flow(), node: self.param))
            self.view.navigationController?.pushViewController(newFlowController.start(), animated: true)
            
        },ifHandler: { [weak self] in
            guard let self else { return }
            let ifFlowController = FlowConditionalPresenter(param: FlowAndNodeParam(flow: Flow(), node: self.param))
            self.view.navigationController?.pushViewController(ifFlowController.start(), animated: true)
        }))
        
        flows.forEach { customFlow in
            if let customFlow = customFlow {
                director?.elements.append(FlowAppsCatagoriesDetailViewModel(param: customFlow, onFlowAppCategoryDetailClicked: { item in
                    self.view.navigationController?.pushViewController(
                        FlowOverviewPresenter(
                            param: FlowAndNodeParam(
                                flow: customFlow,
                                node: self.param
                            )
                        ).start(),
                        animated: true
                    )
                }, onFlowUploadClicked: { flow in
                    let flowUploadController = FlowUploadPresenter(param: FlowAndNodeParam(flow: flow, node: self.param))
                    flowUploadController.configure(with: [flow])
                    
                    self.view.navigationController?.pushViewController(
                        flowUploadController.start(),
                        animated: true
                    )
                }, onFlowDeleteClicked: { flow in
                    ModalService.showConfirm(with: "Are you sure you want to delete the app?") { [weak self] success in
                        if success {
                            PersistanceService.shared.delete(flow: flow)
                            guard let self = self else { return }
                            self.director?.elements.removeAll()
                            self.view.tableView.removeFromSuperview()
                            self.load()
                        }
                    }
                }, isDeleteButtonVisible: true))
            }
        }
        director?.reloadData()
    }

}
