//
//  FlowConditionalPresenter.swift
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

final class FlowConditionalPresenter: BasePresenter<FlowConditionalViewController, FlowAndNodeParam> {
    var director: TableDirector?
    
    var condition: Condition = Condition()
}

// MARK: - FlowConditionalViewControllerDelegate
extension FlowConditionalPresenter: FlowConditionalDelegate {

    func load() {
        view.configureView()
        
        if director == nil {
            director = TableDirector(with: view.tableView)
            director?.register(viewModel: FlowItemViewModel.self,
                               type: .fromClass,
                               bundle: STDemos.bundle)
            director?.register(viewModel: ContainerCellViewModel<any ViewViewModel>.self,
                               type: .fromClass,
                               bundle: STUI.bundle)
        }
        
        /// IF
        let inputLabelViewModel = LabelViewModel(
            param: CodeValue<String>(value: "IF"),
            layout: Layout.title2
        )
        director?.elements.append(ContainerCellViewModel(childViewModel: inputLabelViewModel, layout: Layout.standard))

        var items = [Flow]()
        
        if let exp = condition.expression {
            items = [exp]
        }
        
        director?.elements.append(contentsOf: items.map({ input in
            FlowItemViewModel(
                param: input,
                onFlowItemSettingsClicked: { item in },
                onFlowItemDeleteClicked: { item in }
            )
        }))
        
        let addIfButtonViewModel = ButtonViewModel(
            param: CodeValue<ButtonInput>(value: ButtonInput(title: "Choose an expression", alignment: .left)),
            layout: Layout.standard,
            handleButtonTouched: { _ in
                
                let ifInputController = FlowConditionalInputPresenter(param: self.param)
                ifInputController.setup(
                    with: PersistanceService.shared.getAllCustomFlows().filter { $0.hasOutputAsExp },
                    selected: items,
                    singleSelection: true
                )
                
                let ifInputVC = ifInputController.start()
                ifInputVC.isModalInPresentation = true
                
                ifInputController.completion = { [weak self] flows in
                    guard let self = self, let exp = flows.first else { return }
                    
                    self.condition.expression = exp
                    self.director?.elements.removeAll()
                    self.view.tableView.removeFromSuperview()
                    self.load()
                }
                
                self.view.present(
                    ifInputVC.embeddedInNav(),
                    animated: true
                )
            }
        )
        addIfButtonViewModel.layout?.buttonLayout = Buttonlayout.standardWithSmallFont
        director?.elements.append(ContainerCellViewModel(childViewModel: addIfButtonViewModel, layout: Layout.standard))
        
        /// EXECUTE
        let executeLabelViewModel = LabelViewModel(
            param: CodeValue<String>(value: "EXECUTE"),
            layout: Layout.title2
        )
        director?.elements.append(ContainerCellViewModel(childViewModel: executeLabelViewModel, layout: Layout.standard))

        director?.elements.append(contentsOf: condition.executes.map({ exec in
            FlowItemViewModel(
                param: exec,
                onFlowItemSettingsClicked: { item in },
                onFlowItemDeleteClicked: { item in }
            )
        }))
        
        let addExecuteButtonViewModel = ButtonViewModel(
            param: CodeValue<ButtonInput>(value: ButtonInput(title: "Choose an app to upload", alignment: .left)),
            layout: Layout.standard,
            handleButtonTouched: { _ in
                
                let execInputController = FlowExecuteInputPresenter(param: self.param)
                execInputController.setup(
                    with: self.condition.executes,
                    singleSelection: false
                )
                let execInputVC = execInputController.start()
                execInputVC.isModalInPresentation = true
                
                execInputController.completion = { [weak self] flows in
                    guard let self = self else { return }
                    
                    self.condition.executes = flows
                    
                    self.director?.elements.removeAll()
                    self.view.tableView.removeFromSuperview()
                    self.load()
                }
                
                self.view.present(
                    execInputVC.embeddedInNav(),
                    animated: true
                )
            }
        )
        addExecuteButtonViewModel.layout?.buttonLayout = Buttonlayout.standardWithSmallFont
        director?.elements.append(ContainerCellViewModel(childViewModel: addExecuteButtonViewModel, layout: Layout.standard))
        
        director?.reloadData()
    }
    
    func playAppButtonTapped() {
        guard !condition.executes.isEmpty else {
            
            let message = condition.expression == nil ? "Select a IF condition before play" : "Select at least one app to play"
            ModalService.showWarningMessage(with: message)
            
            return
        }
        
        let flowUploadController = FlowUploadPresenter(param: FlowAndNodeParam(flow: self.param.flow, node: self.param.node))
        flowUploadController.configure(with: condition)
        
        self.view.navigationController?.pushViewController(
            flowUploadController.start(),
            animated: true
        )
    }
    
    func terminateButtonTapped() {
        ModalService.showConfirm(with: "Losing all changes. Do you want to continue?") { (close: Bool) in
            if close {
                self.view.navigationController?.popViewController(animated: true)
            }
        }
    }

}
