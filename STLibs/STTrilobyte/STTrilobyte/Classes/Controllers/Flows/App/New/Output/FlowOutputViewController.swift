//
//  FlowOutputViewController.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 24/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

protocol FlowOutputDelegate: class {
    
    func didCompleteOutputSelection()
}

class FlowOutputViewController: StackViewController {
    
    weak var delegate: FlowOutputDelegate?
    
    var flow: Flow = Flow()
    
    var outputs = [Output]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "output".localized()
        
        outputs = flow.availableOutputs()
        
        configureView()
    }

    override func backButtonPressed() {
        rightButtonPressed()
    }
    
    override func rightButtonPressed() {
        
        if outputs.isEmpty {
            delegate?.didCompleteOutputSelection()
            navigationController?.popViewController(animated: true)
            return
        }
        
        guard !flow.outputs.isEmpty else {
            ModalService.showWarningMessage(with: "err_flow_output_missing".localized())
            return
        }
        
        if !flow.hasValidOutputs() {
            ModalService.showWarningMessage(with: "outputs_error_message".localized())
            return
        }

        guard let delegate = delegate else { return }
        delegate.didCompleteOutputSelection()
        navigationController?.popViewController(animated: true)
    }
    
    func configure(with flow: Flow) {
        self.flow = flow
    }
}

private extension FlowOutputViewController {
    func configureView() {
        let checkedElements = Array(Set(outputs).intersection(flow.outputs))
        
        let optionView: CheckBoxGroup = CheckBoxGroup.createFromNib()
        optionView.configure(title: "available_output_methods".localized().uppercased(),
                             items: outputs,
                             selectedItems: checkedElements) { [weak self] options in
                                guard let self = self, let options = options as? [FlowItem] else { return }
                                
                                self.flow.remove(items: self.outputs)
                                self.flow.addOrUpdate(items: options)
        }
        
        stackView.addArrangedSubview(optionView.embedInView(with: UIEdgeInsets(top: 30.0, left: 20.0, bottom: 10.0, right: 20.0)))
        
        stackView.addArrangedSubview(UIView())
        
        addFooter(to: scrollView)
        
        leftButton?.isHidden = true
        rightButton?.setTitle("continue".localized().uppercased(), for: .normal)
        rightButton?.setImage(UIImage.named("img_done"), for: .normal)
    }
}
