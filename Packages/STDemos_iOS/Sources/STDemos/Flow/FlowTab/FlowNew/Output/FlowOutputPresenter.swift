//
//  FlowOutputPresenter.swift
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

final class FlowOutputPresenter: BasePresenter<FlowOutputViewController, FlowAndNodeParam> {
    var director: TableDirector?
    
    var outputs = [Output]()
    
    weak var delegate: NewFlowParametersSelectionDelegate?
}

// MARK: - FlowOutputViewControllerDelegate
extension FlowOutputPresenter: FlowOutputDelegate {

    func load() {
        view.configureView()
        
        loadAvailableOutputs()
        
        if director == nil {
            director = TableDirector(with: view.tableView)
            director?.register(viewModel: FlowOutputViewModel.self,
                               type: .fromClass,
                               bundle: STDemos.bundle)
            director?.register(viewModel: ContainerCellViewModel<any ViewViewModel>.self,
                               type: .fromClass,
                               bundle: STUI.bundle)
            
            let checkedElements = Array(Set(outputs).intersection(param.flow.outputs))
            
            let inputSensorsLabelViewModel = LabelViewModel(
                param: CodeValue<String>(value: "Outputs"),
                layout: .title2
            )
            director?.elements.append(ContainerCellViewModel(childViewModel: inputSensorsLabelViewModel, layout: Layout.standard))
            
            director?.elements.append(contentsOf: outputs.map({ output in
                FlowOutputViewModel(param: output, isSelected: checkedElements.contains(output), completionHandler: { elements in
                    if let elements = elements as? [Output] {
                        self.param.flow.remove(items: self.outputs)
                        self.param.flow.addOrUpdate(items: elements)
                    }
                })
            }))
        }
        
    }
    
    func doneButtonClicked() {
        if outputs.isEmpty {
            self.delegate?.newFlowParametersSelectionCompleted()
            self.view.dismiss(animated: true)
            return
        }
        
        guard !param.flow.outputs.isEmpty else {
            showErrorMessage("To save this App, you need to select one output")
            return
        }
        
        if !param.flow.hasValidOutputs() {
            showErrorMessage("You cannot simultaneously select a physical output (usb, sd, bt) and logical output (as input, exp)")
            return
        }
        
        self.delegate?.newFlowParametersSelectionCompleted()
        self.view.dismiss(animated: true)
    }
    
    func showErrorMessage(_ message: String) {
        self.view.view.makeToast(message, duration: 4.0, position: .center, title: "ERROR")
    }
    
    func cancelButtonClicked() {
        guard !param.flow.outputs.isEmpty else {
            showErrorMessage("To save this App, you need to select one output")
            return
        }
        self.view.dismiss(animated: true)
    }
    
    private func loadAvailableOutputs() {
        outputs = param.flow.availableOutputs(runningNode: param.node)
    }

}
