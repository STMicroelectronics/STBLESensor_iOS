//
//  FlowInputPresenter.swift
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
import Toast

final class FlowInputPresenter: BasePresenter<FlowInputViewController, FlowAndNodeParam> {
    var director: TableDirector?
    
    var sensors = [Sensor]()
    var logicFlows = [Flow]()
    var flows = [Flow]()
    
    var selectedItems: [Checkable] = [Checkable]()
    
    weak var delegate: NewFlowParametersSelectionDelegate?
}

// MARK: - FlowInputViewControllerDelegate
extension FlowInputPresenter: FlowInputDelegate {

    func load() {
        view.configureView()
        
        loadAvailableInputs()
        
        if director == nil {
            director = TableDirector(with: view.tableView)
            director?.register(viewModel: FlowInputViewModel.self,
                               type: .fromClass,
                               bundle: STDemos.bundle)
            director?.register(viewModel: ContainerCellViewModel<any ViewViewModel>.self,
                               type: .fromClass,
                               bundle: STUI.bundle)

            if !sensors.isEmpty {
                let checkedElements = Array(Set(sensors).intersection(param.flow.sensors))
                selectedItems.append(contentsOf: checkedElements)

                let inputSensorsLabelViewModel = LabelViewModel(
                    param: CodeValue<String>(value: "Sensors"),
                    layout: Layout.title2
                )
                director?.elements.append(ContainerCellViewModel(childViewModel: inputSensorsLabelViewModel, layout: Layout.standard))
                
                director?.elements.append(contentsOf: sensors.map({ sensor in
                    FlowInputViewModel(param: sensor, isSelected: checkedElements.contains(sensor), completionHandler: { element in
                        if element.isChedked {
                            self.selectedItems.append(element.checkable)
                        } else {
                            self.selectedItems.removeAll {
                                if let selectedItem = $0 as? Sensor,
                                   let currentItem = element.checkable as? Sensor {
                                    return selectedItem == currentItem
                                }else{
                                    return $0.identifier == element.checkable.identifier
                                }
                            }
                        }
                    })
                }))
            }
            
            if !logicFlows.isEmpty {
                let checkedElements = Array(Set(logicFlows).intersection(param.flow.flows))
                selectedItems.append(contentsOf: checkedElements)
                
                let inputExpressionsLabelViewModel = LabelViewModel(
                    param: CodeValue<String>(value: "Expressions"),
                    layout: Layout.title2
                )
                director?.elements.append(ContainerCellViewModel(childViewModel: inputExpressionsLabelViewModel, layout: Layout.standard))
                
                director?.elements.append(contentsOf: logicFlows.map({ flow in
                    FlowInputViewModel(param: flow, isSelected: checkedElements.contains { $0.identifier == flow.identifier }, completionHandler: { element in
                        if element.isChedked {
                            self.selectedItems.append(element.checkable)
                        } else {
                            self.selectedItems.removeAll {
                                $0.identifier == element.checkable.identifier
                            }
                        }
                    })
                }))
            }
            
            if !flows.isEmpty {
                let checkedElements = Array(Set(flows).intersection(param.flow.flows))
                selectedItems.append(contentsOf: checkedElements)
                
                let inputAppLabelViewModel = LabelViewModel(
                    param: CodeValue<String>(value: "App As Input"),
                    layout: Layout.title2
                )
                director?.elements.append(ContainerCellViewModel(childViewModel: inputAppLabelViewModel, layout: Layout.standard))
                
                director?.elements.append(contentsOf: flows.map({ flow in
                    FlowInputViewModel(param: flow, isSelected: checkedElements.contains { $0.identifier == flow.identifier }, completionHandler: { element in
                        if element.isChedked {
                            self.selectedItems.append(element.checkable)
                        } else {
                            self.selectedItems.removeAll {
                                $0.identifier == element.checkable.identifier
                            }
                        }
                    })
                }))
            }
            
            director?.reloadData()
        }
    }
    
    func doneButtonClicked() {
        self.param.flow.remove(items: self.sensors)
        self.param.flow.remove(items: self.logicFlows)
        self.param.flow.remove(items: self.flows)
        
        if let selectedItems = selectedItems as? [FlowItem] {
            self.param.flow.addOrUpdate(items: selectedItems)
        }
        
        guard !(self.param.flow.sensors.isEmpty && self.param.flow.flows.isEmpty) else {
            showErrorMessage("Select at least one input to save")
            return
        }
        
        let MLCSelected = self.param.flow.sensors.contains { $0.identifier == "S12" }
        let FSMSelected = self.param.flow.sensors.contains { $0.identifier == "S13" }
        
        if (MLCSelected && FSMSelected) {
            showErrorMessage("MLC Virtual Sensor and FSM Virtual Sensor cannot be selected together")
            return
        }
        let nAccSensor = self.param.flow.sensors.filter { $0.identifier == "S5" }.count
        if(nAccSensor>1){
            showErrorMessage("Multiple accelerometer sensor selected")
            return
        }

        self.delegate?.newFlowParametersSelectionCompleted()
        self.view.dismiss(animated: true)
    }
    
    func showErrorMessage(_ message: String) {
        self.view.view.makeToast(message, duration: 4.0, position: .center, title: "ERROR")
    }
    
    func cancelButtonClicked() {
        guard !(self.param.flow.sensors.isEmpty && self.param.flow.flows.isEmpty) else {
            showErrorMessage("Select at least one input to save")
            return
        }
        self.view.dismiss(animated: true)
    }
    
    private func loadAvailableInputs() {
        sensors = PersistanceService.shared.getAllSensors(runningNode: param.node)
        
        flows = PersistanceService.shared.getAllCustomFlows().filter { flow -> Bool in
            flow.hasOutputAsInput
        }

        logicFlows = PersistanceService.shared.getLogicAsInputFlows(runningNode: param.node)
    }
}
