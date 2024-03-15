//
//  NewFlowPresenter.swift
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

final class NewFlowPresenter: BasePresenter<NewFlowViewController, FlowAndNodeParam> {
    var director: TableDirector?
}

extension NewFlowPresenter: NewFlowParametersSelectionDelegate {
    func newFlowParametersSelectionCompleted() {
        self.director?.elements.removeAll()
        self.view.tableView.removeFromSuperview()
        self.load()
    }
}

// MARK: - NewFlowViewControllerDelegate
extension NewFlowPresenter: NewFlowDelegate {

    func load() {
        view.configureView()
        
        if !param.flow.inputs.isEmpty {
            view.title = "Edit App"
        } else {
            view.title = "New App"
        }
        
        if director == nil {
            director = TableDirector(with: view.tableView)
            director?.register(viewModel: FlowItemViewModel.self,
                               type: .fromClass,
                               bundle: STDemos.bundle)
            director?.register(viewModel: ContainerCellViewModel<any ViewViewModel>.self,
                               type: .fromClass,
                               bundle: STUI.bundle)
        }
        
        /// INPUT
        let inputLabelViewModel = ImageLabelViewModel(
            param: CodeValue<String>(value: "Input"),
            layout: Layout.title2,
            image: ImageLayout.image(with: "flow_arrow_down", in: .module)?.maskWithColor(color: ColorLayout.primary.auto)
        )
        director?.elements.append(ContainerCellViewModel(childViewModel: inputLabelViewModel, layout: Layout.standard))

        director?.elements.append(contentsOf: param.flow.inputs.map({ input in
            FlowItemViewModel(
                param: input,
                onFlowItemSettingsClicked: { sensorItem in
                    if let sensor = sensorItem as? Sensor {
                        let inputOptionController = FlowInputOptionPresenter(param: SensorAndNodeParam(sensor: sensor, node: self.param.node))
                        let inputOptionVC = inputOptionController.start()
                        
                        self.view.present(
                            inputOptionVC.embeddedInNav(),
                            animated: true
                        )
                    }
                },
                onFlowItemDeleteClicked: { sensorItem in
                    print("ITEM TO DELETE \(sensorItem.descr)")
                }
            )
        }))
        
        let addInputButtonViewModel = ButtonViewModel(
            param: CodeValue<ButtonInput>(value: ButtonInput(title: "Select Input Source", alignment: .left)),
            layout: Layout.standard,
            handleButtonTouched: { _ in
                let inputsFlowController = FlowInputPresenter(param: self.param)
                inputsFlowController.delegate = self
                let inputFlowVC = inputsFlowController.start()
                inputFlowVC.isModalInPresentation = true
                self.view.present(
                    inputFlowVC.embeddedInNav(),
                    animated: true
                )
            }
        )
        addInputButtonViewModel.layout?.buttonLayout = Buttonlayout.standardWithSmallFont
        director?.elements.append(ContainerCellViewModel(childViewModel: addInputButtonViewModel, layout: Layout.standard))
        
        /// FUNCTION
        let functionLabelViewModel = ImageLabelViewModel(
            param: CodeValue<String>(value: "Function"),
            layout: Layout.title2,
            image: ImageLayout.image(with: "flow_arrow_down", in: .module)?.maskWithColor(color: ColorLayout.primary.auto)
        )
        director?.elements.append(ContainerCellViewModel(childViewModel: functionLabelViewModel, layout: Layout.standard))
        
        director?.elements.append(contentsOf: param.flow.functions.map({ fun in
            FlowItemViewModel(
                param: fun,
                onFlowItemSettingsClicked: { functionItem in
                    if let function = functionItem as? Function {
                        let functionOptionController = FlowFunctionOptionPresenter(
                            param: FunctionAndSensorParam(
                                function: function,
                                sensor: self.param.flow.inputSensors().first
                            )
                        )
                        let functionOptionVC = functionOptionController.start()
                        
                        self.view.present(
                            functionOptionVC.embeddedInNav(),
                            animated: true
                        )
                    }
                },
                onFlowItemDeleteClicked: { functionItem in
                    print("ITEM TO DELETE \(functionItem.descr)")
                    ModalService.showConfirm(with: "Are you sure you want to delete the selected function?") { [weak self] success in
                        if success {
                            guard let self = self, let index = self.param.flow.functions.firstIndex (where: { $0.identifier == functionItem.identifier }) else { return }
                            
                            let functionsToRemove = Array(self.param.flow.functions[index...])
                            self.param.flow.remove(items: functionsToRemove)
                            self.param.flow.outputs = [Output]()
                            self.newFlowParametersSelectionCompleted()
                        }
                    }
                }
            )
        }))
        
        let addFunctionButtonViewModel = ButtonViewModel(
            param: CodeValue<ButtonInput>(value: ButtonInput(title: "Select a function", alignment: .left)),
            layout: Layout.standard,
            handleButtonTouched: { _ in
                let functionsFlowController = FlowFunctionsPresenter(param: self.param)
                functionsFlowController.delegate = self
                let functionsFlowVC = functionsFlowController.start()
                functionsFlowVC.isModalInPresentation = true
                self.view.present(
                    functionsFlowVC.embeddedInNav(),
                    animated: true
                )
            }
        )
        addFunctionButtonViewModel.layout?.buttonLayout = Buttonlayout.standardWithSmallFont
        director?.elements.append(ContainerCellViewModel(childViewModel: addFunctionButtonViewModel, layout: Layout.standard))
        
        /// OUTPUT
        let outputLabelViewModel = ImageLabelViewModel(
            param: CodeValue<String>(value: "Output"),
            layout: Layout.title2,
            image: ImageLayout.image(with: "flow_arrow_end", in: .module)?.maskWithColor(color: ColorLayout.primary.auto)
        )
        director?.elements.append(ContainerCellViewModel(childViewModel: outputLabelViewModel, layout: Layout.standard))
        
        director?.elements.append(contentsOf: param.flow.outputs.map({ output in
            FlowItemViewModel(
                param: output,
                onFlowItemSettingsClicked: { outputItem in
                    if let output = outputItem as? Output {
                        let outputOptionController = FlowOutputOptionPresenter(param: output)
                        let outputOptionVC = outputOptionController.start()
                        
                        self.view.present(
                            outputOptionVC.embeddedInNav(),
                            animated: true
                        )
                    }
                },
                onFlowItemDeleteClicked: { outputItem in
                    print("ITEM TO DELETE \(outputItem.descr)")
                }
            )
        }))
        
        let addOutputViewModel = ButtonViewModel(
            param: CodeValue<ButtonInput>(value: ButtonInput(title: "Select an output", alignment: .left)),
            layout: Layout.standard,
            handleButtonTouched: { _ in
                let outputsFlowController = FlowOutputPresenter(param: self.param)
                outputsFlowController.delegate = self
                let outputsFlowVC = outputsFlowController.start()
                outputsFlowVC.isModalInPresentation = true
                self.view.present(
                    outputsFlowVC.embeddedInNav(),
                    animated: true
                )
            }
        )
        addOutputViewModel.layout?.buttonLayout = Buttonlayout.standardWithSmallFont
        director?.elements.append(ContainerCellViewModel(childViewModel: addOutputViewModel, layout: Layout.standard))
        
        director?.reloadData()
    }
    
    func saveAppButtonTapped() {
        guard !param.flow.inputs.isEmpty && !param.flow.outputs.isEmpty else {
            ModalService.showWarningMessage(with: "You need to select the input and the output to save this App.")
            return
        }
        self.view.navigationController?.pushViewController(
            SaveFlowPresenter(param: param).start(),
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
