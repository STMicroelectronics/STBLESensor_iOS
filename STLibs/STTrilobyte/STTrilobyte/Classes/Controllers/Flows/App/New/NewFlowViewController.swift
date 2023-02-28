//
//  NewFlowViewController.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 18/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class NewFlowViewController: FooterViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    var flow: Flow = Flow()
    
    let inputFlowItemView: FlowItemView = FlowItemView.createFromNib()
    let functionFlowItemView: FlowItemView = FlowItemView.createFromNib()
    let addFunctionButton: AddFunctionButtonView = AddFunctionButtonView.createFromNib()
    let outputFlowItemView: FlowItemView = FlowItemView.createFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "new_flow".localized()
        
        configureView()
    }
    
    override func backButtonPressed() {
        leftButtonPressed()
    }
    
    override func leftButtonPressed() {
        ModalService.showConfirm(with: "warn_abort_flow_wizard".localized()) { (close: Bool) in
            if close {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    override func rightButtonPressed() {
        guard !flow.inputs.isEmpty && !flow.outputs.isEmpty else {
            ModalService.showWarningMessage(with: "err_flow_mandatory_on_save".localized())
            return
        }
        
        let controller: SaveFlowViewController = SaveFlowViewController.makeViewControllerFromNib()
        controller.configure(with: flow)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension NewFlowViewController {
    
    func configure(with flow: Flow) {
        self.flow = flow
    }
}

private extension NewFlowViewController {
    func configureView() {
        addFooter(to: scrollView)
        
        leftButton?.setTitle("terminate".localized().uppercased(), for: .normal)
        leftButton?.setImage(UIImage.named("img_close"), for: .normal)
        rightButton?.setTitle("save_flow".localized().uppercased(), for: .normal)
        rightButton?.setImage(UIImage.named("img_done"), for: .normal)
        
        inputFlowItemView.delegate = self
        inputFlowItemView.isSwipeEnabled = false
        stackView.addArrangedSubview(inputFlowItemView)
        
        functionFlowItemView.delegate = self
        functionFlowItemView.isHidden = flow.inputs.isEmpty
        functionFlowItemView.isSwipeEnabled = true
        stackView.addArrangedSubview(functionFlowItemView)

        addFunctionButton.delegate = self
        addFunctionButton.isHidden = flow.inputs.isEmpty
        stackView.addArrangedSubview(addFunctionButton)

        outputFlowItemView.delegate = self
        outputFlowItemView.isHidden = flow.inputs.isEmpty
        outputFlowItemView.isSwipeEnabled = false
        stackView.addArrangedSubview(outputFlowItemView)
        
        updateFlowItemViews()
    }
    
    func updateFlowItemViews() {
        inputFlowItemView.configure(title: "input".localized().uppercased(),
                                    placeholder: "input_empty_message".localized(),
                                    items: flow.inputs,
                                    showLine: flow.inputs.isEmpty ? false : true)
        
        functionFlowItemView.configure(title: "functions".localized().uppercased(),
                                       placeholder: "function_empty_message".localized(),
                                       items: flow.functions)

        addFunctionButton.isHidden = flow.functions.isEmpty

        outputFlowItemView.configure(title: "output".localized().uppercased(),
                                     placeholder: "output_empty_message".localized(),
                                     items: flow.outputs, showLine: false)
    }
}

extension NewFlowViewController: FlowInputDelegate {
    func didCompleteInputSelection() {
        
        // Reset functions and output
        flow.functions = [Function]()
        flow.outputs = [Output]()
        
        updateFlowItemViews()
        
        functionFlowItemView.isHidden = flow.inputs.isEmpty
        outputFlowItemView.isHidden = flow.inputs.isEmpty
    }
    
}

extension NewFlowViewController: FlowFunctionsDelegate {
    func didCompleteFunctionSelection() {
        
        updateFlowItemViews()
    }
    
}

extension NewFlowViewController: FlowOutputDelegate {
    func didCompleteOutputSelection() {
        
        updateFlowItemViews()
    }
    
}

extension NewFlowViewController: FlowItemViewDelegate {
    func didPressDeleteButton(flowItem: FlowItem) {
        ModalService.showConfirm(with: "expert_flow_delete_function_message".localized()) { [weak self] success in
            if success {
                guard let self = self, let index = self.flow.functions.firstIndex (where: { $0.identifier == flowItem.identifier }) else { return }

                let functionsToRemove = Array(self.flow.functions[index...])
                self.flow.remove(items: functionsToRemove)
                self.flow.outputs = [Output]()
                self.updateFlowItemViews()
            }
        }
    }
    
    func didPressFlowItem(view: FlowItemView) {
        if view === inputFlowItemView {
            let controller: FlowInputViewController = FlowInputViewController()
            controller.configure(with: flow)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        } else if view === functionFlowItemView && flow.functions.isEmpty {
            let controller: FlowFunctionsViewController = FlowFunctionsViewController()
            controller.configure(with: flow)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        } else if view === outputFlowItemView {
            let controller: FlowOutputViewController = FlowOutputViewController()
            controller.configure(with: flow)
            controller.delegate = self
            navigationController?.pushViewController(controller, animated: true)
        }
    }

    func didPressSettingsButton(flowItem: FlowItem) {
        if let sensor = flowItem as? Sensor {
            let controller: SensorOptionsViewController = SensorOptionsViewController()
            controller.configure(with: sensor)
            navigationController?.pushViewController(controller, animated: true)
        } else if let function = flowItem as? Function {
                let controller: FunctionOptionsViewController = FunctionOptionsViewController()
                controller.configure(with: function, applayTo: flow.inputSensors().first)
                navigationController?.pushViewController(controller, animated: true)
        } else if let output = flowItem as? Output {
            let controller: OutputOptionsViewController = OutputOptionsViewController()
            controller.configure(with: output)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}

extension NewFlowViewController: AddFunctionButtonDelegate {
    func didPressAddFunctionButton() {
        let controller: FlowFunctionsViewController = FlowFunctionsViewController()
        controller.configure(with: flow)
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
}
