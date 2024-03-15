//
//  FlowExecuteInputPresenter.swift
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

final class FlowExecuteInputPresenter: BasePresenter<FlowExecuteInputViewController, FlowAndNodeParam> {
    var director: TableDirector?
    
    var counterFlows: [Flow] = [Flow]()
    var customFlows: [Flow] = [Flow]()
    
    var singleSelection: Bool = false

    var counterSelected: [Flow] = [Flow]()
    var customSelected: [Flow] = [Flow]()
    
    var completion: (([Flow]) -> Void)?
}

// MARK: - FlowExecuteInputViewControllerDelegate
extension FlowExecuteInputPresenter: FlowExecuteInputDelegate {

    func load() {
        view.configureView()
        
        if director == nil {
            director = TableDirector(with: view.tableView)
            director?.register(viewModel: FlowInputViewModel.self,
                               type: .fromClass,
                               bundle: STDemos.bundle)
            director?.register(viewModel: ContainerCellViewModel<any ViewViewModel>.self,
                               type: .fromClass,
                               bundle: STUI.bundle)

            counterFlows = PersistanceService.shared.getCounterFlows(runningNode: param.node)
            customFlows = PersistanceService.shared.getAllCustomFlows().filter { $0.hasPhysicalOutput }
            
            if !counterFlows.isEmpty {
                let counterFlowsLabelViewModel = LabelViewModel(
                    param: CodeValue<String>(value: "COUNTERS"),
                    layout: Layout.title2
                )
                director?.elements.append(ContainerCellViewModel(childViewModel: counterFlowsLabelViewModel, layout: Layout.standard))
                
                director?.elements.append(contentsOf: counterFlows.map({ flow in
                    FlowInputViewModel(param: flow, isSelected: counterSelected.contains(flow), completionHandler: { element in
                        if let element = element.checkable as? Flow  {
                            self.counterSelected.append(element)
                        }
                    })
                }))
            }
            
            if !counterFlows.isEmpty {
                let counterFlowsLabelViewModel = LabelViewModel(
                    param: CodeValue<String>(value: "CUSTOM APPS"),
                    layout: Layout.title2
                )
                director?.elements.append(ContainerCellViewModel(childViewModel: counterFlowsLabelViewModel, layout: Layout.standard))
                
                director?.elements.append(contentsOf: customFlows.map({ flow in
                    FlowInputViewModel(param: flow, isSelected: customSelected.contains(flow), completionHandler: { element in
                        if let element = element.checkable as? Flow  {
                            self.customSelected.append(element)
                        }
                    })
                }))
            }
            
        }
        
    }
    
    func doneButtonClicked() {
        guard let completion = completion else { return }
        completion(counterSelected + customSelected)
        self.view.dismiss(animated: true)
    }
    
    func cancelButtonClicked() {
        self.view.dismiss(animated: true)
    }
    
    func setup(with selected: [Flow], singleSelection: Bool = false) {
        
        self.counterSelected.removeAll()
        self.customSelected.removeAll()
    
        counterFlows.removeAll()
        customFlows.removeAll()
        
        counterFlows = PersistanceService.shared.getCounterFlows(runningNode: param.node)
        customFlows = PersistanceService.shared.getAllCustomFlows().filter { $0.hasPhysicalOutput }

        
        self.counterSelected.append(contentsOf: Set(counterFlows).intersection(selected))
        self.customSelected.append(contentsOf: Set(customFlows).intersection(selected))
        
        self.singleSelection = singleSelection
    }

}
