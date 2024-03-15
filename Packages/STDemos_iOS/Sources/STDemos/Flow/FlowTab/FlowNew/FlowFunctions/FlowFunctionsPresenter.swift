//
//  FlowFunctionsPresenter.swift
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

final class FlowFunctionsPresenter: BasePresenter<FlowFunctionsViewController, FlowAndNodeParam> {
    var director: TableDirector?
    
    var filteredFunctions = [FlowItem & Checkable]()
    var selectedFunctions = [FlowItem & Checkable]()
    
    weak var delegate: NewFlowParametersSelectionDelegate?
}

// MARK: - FlowFunctionsViewControllerDelegate
extension FlowFunctionsPresenter: FlowFunctionsDelegate {

    func load() {
        view.configureView()
        
        loadAvailableFunctions()
        
        if director == nil {
            director = TableDirector(with: view.tableView)
            director?.register(viewModel: FlowFunctionViewModel.self,
                               type: .fromClass,
                               bundle: STDemos.bundle)
            director?.register(viewModel: ContainerCellViewModel<any ViewViewModel>.self,
                               type: .fromClass,
                               bundle: STUI.bundle)
            
            let functionsLabelViewModel = LabelViewModel(
                param: CodeValue<String>(value: "Functions"),
                layout: Layout.title2
            )
            director?.elements.append(ContainerCellViewModel(childViewModel: functionsLabelViewModel, layout: Layout.standard))
            
            director?.elements.append(contentsOf: filteredFunctions.map({ function in
                FlowFunctionViewModel(param: function, isSelected: self.param.flow.functions.contains(where: { $0 == function as? Function }), completionHandler: { element in
                    if element.isChedked {
                        if let element = element.checkable as? FlowItem & Checkable {
                            self.selectedFunctions.append(element)
                        }
                    } else {
                        self.selectedFunctions.removeAll {
                            if let selectedItem = $0 as? Function,
                               let currentItem = element.checkable as? Function {
                                return selectedItem == currentItem
                            }else{
                                return $0.identifier == element.checkable.identifier
                            }
                        }
                    }
                })
            }))
        }
    }

    func doneButtonClicked() {
        guard let function = selectedFunctions.last as? Function else {
            showErrorMessage("To move on, you need to select one function")
            return
        }
        
        let matchings = flowParameters(with: function)
        
        if matchings.count > function.parametersCount {
            let errorMessage = String(format: "The selected function is compatible with multiple chosen inputs. Recheck the App input section.\n\nConflicting inputs:\n%@", matchings.reduce("") { text, flowItem in "\(text)\n- \(flowItem.descr)" })
            showErrorMessage(errorMessage)
            return
        }
        
        self.param.flow.remove(items: filteredFunctions)
        self.param.flow.addOrUpdate(items: selectedFunctions)
        
        self.delegate?.newFlowParametersSelectionCompleted()
        self.view.dismiss(animated: true)
    }
    
    func showErrorMessage(_ message: String) {
        self.view.view.makeToast(message, duration: 4.0, position: .center, title: "ERROR")
    }
    
    func cancelButtonClicked() {
        self.view.dismiss(animated: true)
    }
    
    private func loadAvailableFunctions() {
        
        let node = param.node
        let flow = param.flow
        
        var allFunctions = PersistanceService.shared.getAllFunctions(runningNode: node)
        var sensorIds = [String]()
        var functionsId = [String]()
        
        // Carico tutti i sensori e le funzioni utilizzate nel flow
        if(flow.functions.isEmpty){
            sensorIds.append(contentsOf: flow.inputSensors().map { $0.identifier })
            functionsId.append(contentsOf: flow.inputFunctions().map { $0.identifier })
        }else{
            functionsId.append(flow.functions.last!.identifier)
        }

        let allInput = sensorIds + functionsId
        // Filtra functions rimuovendo quelle già utilizzate
        allFunctions = allFunctions.filter { function in
            hasAllMandatoryInput(fun: function, currentInput: allInput) &&
            hasCommonInput(fun: function, currentInput: allInput) &&
            flow.countInvocation(of: function) < function.maxRepeatCount ?? 1_000
        }

        // Carico ultima funzione utizzata
        if let last = flow.functions.last {
            allFunctions = allFunctions.filter { $0.inputs.contains(last.identifier) }
        }

        // Filtra functions per MANDATORY INPUT ID sensors e ID flows
        // Filtra functions per INPUT ID sensors e ID flows
        
        filteredFunctions.append(contentsOf: allFunctions)

        filteredFunctions.forEach { function in
            if self.param.flow.functions.contains(where: { $0 == function as? Function }) {
                self.selectedFunctions.append(function)
            }
        }
    }
    
    private func hasAllMandatoryInput(fun:Function, currentInput:[String]) -> Bool{
        if fun.mandatoryInputs.isEmpty{
            return true
        }
        return fun.mandatoryInputs.map{ funMandatoryInput in
                currentInput.containsAll(funMandatoryInput)
            }.reduce(false){ $0 || $1 }
    }
    
    private func hasCommonInput(fun:Function, currentInput:[String])->Bool{
        return fun.inputs.map{ currentInput.contains($0)}.reduce(false){ $0 || $1 }
    }
}

extension FlowFunctionsPresenter {
    
    func flowParameters(with function: Function) -> [FlowItem] {
        let sensors = param.flow.inputSensors()
        let functions = param.flow.inputFunctions()
    
        let matchingSensorsIds = Set(function.inputs).intersection(sensors.map { $0.identifier })
        
        var items: [FlowItem] = [FlowItem]()
        
        for identifier in matchingSensorsIds {
            if let sensor = sensors.first(where: { $0.identifier == identifier }) {
                items.append(sensor)
            }
        }
        
        let matchingFunctionsIds = Set(function.inputs).intersection(functions.map { $0.identifier })
        
        for identifier in matchingFunctionsIds {
            if let function = functions.first(where: { $0.identifier == identifier }) {
                items.append(function)
            }
        }
        
        return items
    }
}

fileprivate extension Array where Array.Element : Equatable {
    
    func containsAll(_ values:Array)->Bool{
        for value in values{
            if(!self.contains(value)){
                return false
            }
        }
        return true
    }
    
}
