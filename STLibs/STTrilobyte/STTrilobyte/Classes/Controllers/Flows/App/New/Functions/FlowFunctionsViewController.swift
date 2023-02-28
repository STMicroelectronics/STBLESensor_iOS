//
//  FlowFunctionsViewController.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 21/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

protocol FlowFunctionsDelegate: class {
    
    func didCompleteFunctionSelection()
}

class FlowFunctionsViewController: FooterViewController {
    
    weak var delegate: FlowFunctionsDelegate?
    
    var flow: Flow = Flow()
    
    var filteredFunctions = [FlowItem & Checkable]()
    var selectedFunctions = [FlowItem & Checkable]()
    
    lazy var scrollView: UIScrollView = UIScrollView()
    lazy var stackView: UIStackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "functions".localized()
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.autoAnchorToSuperViewSafeArea()
        stackView.autoAnchorToSuperView()
        
        stackView.axis = .vertical
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        
        configureView()
    }

    override func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    override func rightButtonPressed() {
        guard let function = selectedFunctions.last as? Function else {
            ModalService.showWarningMessage(with: "err_flow_function_missing".localized())
            return
        }
        
        let matchings = flowParameters(with: function)
        
        if matchings.count > function.parametersCount {
            
            let errorMessage = String(format: "err_flow_function_input".localized(), matchings.reduce("") { text, flowItem in "\(text)\n- \(flowItem.descr)" })
            
            ModalService.showWarningMessage(with: errorMessage)
            return
        }
        
        delegate?.didCompleteFunctionSelection()
        
        navigationController?.popViewController(animated: true)
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
    
    func configure(with flow: Flow) {
        self.flow = flow
        
        var allFunctions = PersistanceService.shared.getAllFunctions()
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
    }
}

private extension FlowFunctionsViewController {
    func configureView() {
    
        let optionView: CheckBoxGroup = CheckBoxGroup.createFromNib()
        optionView.configure(title: "available_functions".localized().uppercased(),
                             items: filteredFunctions,
                             selectedItems: selectedFunctions,
                             singleSelection: true) { [weak self] options in
                                guard let self = self, let options = options as? [FlowItem & Checkable] else { return }
                                
                                self.flow.remove(items: self.selectedFunctions)
                                self.selectedFunctions = options
                                self.flow.addOrUpdate(items: options)
        }
        
        stackView.addArrangedSubview(optionView.embedInView(with: UIEdgeInsets(top: 30.0, left: 20.0, bottom: 10.0, right: 20.0)))
        
        stackView.addArrangedSubview(UIView())
        
        addFooter(to: scrollView)
        
        leftButton?.isHidden = true
        rightButton?.setTitle("continue".localized().uppercased(), for: .normal)
        rightButton?.setImage(UIImage.named("img_done"), for: .normal)
    }
    
    func flowParameters(with function: Function) -> [FlowItem] {
        let sensors = flow.inputSensors()
        let functions = flow.inputFunctions()
    
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
