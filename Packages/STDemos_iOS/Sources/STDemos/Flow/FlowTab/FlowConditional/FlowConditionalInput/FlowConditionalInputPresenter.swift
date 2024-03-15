//
//  FlowConditionalInputPresenter.swift
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

final class FlowConditionalInputPresenter: BasePresenter<FlowConditionalInputViewController, FlowAndNodeParam> {
    var director: TableDirector?
    
    var singleSelection: Bool = false
    var flows: [Flow] = [Flow]()
    var selected: [Flow] = [Flow]()
    
    var completion: (([Flow]) -> Void)?
}

// MARK: - FlowConditionalInputViewControllerDelegate
extension FlowConditionalInputPresenter: FlowConditionalInputDelegate {

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

            if !flows.isEmpty {
                let inputIfLabelViewModel = LabelViewModel(
                    param: CodeValue<String>(value: "EXP"),
                    layout: Layout.title2
                )
                director?.elements.append(ContainerCellViewModel(childViewModel: inputIfLabelViewModel, layout: Layout.standard))
                
                director?.elements.append(contentsOf: self.flows.map({ flow in
                    FlowInputViewModel(param: flow, isSelected: selected.contains(flow), completionHandler: { element in
                        if let element = element.checkable as? Flow  {
                            self.selected.append(element)
                        }
                    })
                }))
            }
        }
    }

    func doneButtonClicked() {
        guard let completion = completion else { return }
        completion(selected)
        self.view.dismiss(animated: true)
    }
    
    func cancelButtonClicked() {
        self.view.dismiss(animated: true)
    }
    
    public func setup(with flows: [Flow], selected: [Flow], singleSelection: Bool = false) {
        
        self.selected.removeAll()
        self.flows.removeAll()
        
        self.singleSelection = singleSelection
        self.selected.append(contentsOf: selected)
        self.flows.append(contentsOf: flows)
    }
}
