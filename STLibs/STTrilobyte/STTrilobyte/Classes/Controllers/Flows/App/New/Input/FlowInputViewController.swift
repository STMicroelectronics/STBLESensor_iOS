//
//  FlowInputViewController.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 18/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

protocol FlowInputDelegate: class {
    
    func didCompleteInputSelection()
}

class FlowInputViewController: StackViewController {
    
    weak var delegate: FlowInputDelegate?
    
    var flow: Flow = Flow()
    
    var sensors = [Sensor]()
    var logicFlows = [Flow]()
    var flows = [Flow]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "input_sources".localized()
        
        sensors = PersistanceService.shared.getAllSensors()
        
        flows = PersistanceService.shared.getAllCustomFlows().filter { flow -> Bool in
            flow.hasOutputAsInput
        }

        logicFlows = PersistanceService.shared.getLogicAsInputFlows()
        
        configureView()
    }

    override func backButtonPressed() {
        rightButtonPressed()
    }

    override func rightButtonPressed() {
        guard !(flow.sensors.isEmpty && flow.flows.isEmpty) else {
            ModalService.showWarningMessage(with: "err_flow_input_missing".localized())
            return
        }
        
        let MLCSelected = flow.sensors.contains { $0.identifier == "S12" }
        let FSMSelected = flow.sensors.contains { $0.identifier == "S13" }
        
        if (MLCSelected && FSMSelected) {
            ModalService.showWarningMessage(with: "err_flow_mlc_fsm_input".localized())
            return
        }
        let nAccSensor = flow.sensors.filter { $0.identifier == "S5" }.count
        if(nAccSensor>1){
            ModalService.showWarningMessage(with: "err_flow_multiple_acc_input".localized())
            return
        }
        
        guard let delegate = delegate else { return }
        
        delegate.didCompleteInputSelection()
        
        navigationController?.popViewController(animated: true)
    }
    
    func configure(with flow: Flow) {
        self.flow = flow
    }
}

extension FlowInputViewController {
    
    @objc
    func configureView() {
        if !sensors.isEmpty {
            let checkedElements = Array(Set(sensors).intersection(flow.sensors))
            
            let optionView: CheckBoxGroup = CheckBoxGroup.createFromNib()
            optionView.configure(title: "sensors".localized().uppercased(),
                                 items: sensors,
                                 selectedItems: checkedElements) { [weak self] options in
                                    guard let self = self, let options = options as? [FlowItem] else { return }
                                    
                                    self.flow.remove(items: self.sensors)
                                    self.flow.addOrUpdate(items: options)
            }
            
            stackView.addArrangedSubview(optionView.embedInView(with: UIEdgeInsets(top: 30.0, left: 24.0, bottom: 10.0, right: 24.0)))
        }

        if !logicFlows.isEmpty {
            
            let checkedElements = Array(Set(logicFlows).intersection(flow.flows))
            
            let optionView: CheckBoxGroup = CheckBoxGroup.createFromNib()
            optionView.configure(title: "exp".localized().uppercased(),
                                 items: logicFlows,
                                 selectedItems: checkedElements) { [weak self] options in
                                    guard let self = self, let options = options as? [FlowItem] else { return }
                                    
                                    self.flow.remove(items: self.logicFlows)
                                    self.flow.addOrUpdate(items: options)
            }
            
            stackView.addArrangedSubview(optionView.embedInView(with: UIEdgeInsets(top: 10.0, left: 24.0, bottom: 10.0, right: 24.0)))
        }
        
        if !flows.isEmpty {
            
            let checkedElements = Array(Set(flows).intersection(flow.flows))
            
            let optionView: CheckBoxGroup = CheckBoxGroup.createFromNib()
            optionView.configure(title: "flow_as_input".localized().uppercased(),
                                 items: flows,
                                 selectedItems: checkedElements) { [weak self] options in
                                    guard let self = self, let options = options as? [FlowItem] else { return }
                                    
                                    self.flow.remove(items: self.flows)
                                    self.flow.addOrUpdate(items: options)
            }
            
            stackView.addArrangedSubview(optionView.embedInView(with: UIEdgeInsets(top: 10.0, left: 24.0, bottom: 10.0, right: 24.0)))
        }
        
        stackView.addArrangedSubview(UIView())
        
        addFooter(to: scrollView)
        leftButton?.isHidden = true
        rightButton?.setTitle("set_input".localized().uppercased(), for: .normal)
        rightButton?.setImage(UIImage.named("img_done"), for: .normal)
    }
}
