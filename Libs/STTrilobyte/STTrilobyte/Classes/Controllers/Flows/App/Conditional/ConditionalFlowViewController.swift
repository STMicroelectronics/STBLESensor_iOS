//
//  ConditionalFlowViewController.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 18/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class ConditionalFlowViewController: FooterViewController {
    
    lazy var scrollView: UIScrollView = UIScrollView()
    lazy var stackView: UIStackView = UIStackView()
    
    var condition: Condition = Condition()
    
    let conditionalFlowItemView: FlowItemView = FlowItemView.createFromNib()
    let executeFlowItemView: FlowItemView = FlowItemView.createFromNib()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "if_title".localized()
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.autoAnchorToSuperViewSafeArea()
        stackView.autoAnchorToSuperView()
        
        configureViews()
        updateFlowItemViews()
        
        addFooter(to: scrollView)
        
        leftButton?.isHidden = true
        rightButton?.setTitle("device_upload".localized().uppercased(), for: .normal)
        rightButton?.setImage(UIImage.named("img_done"), for: .normal)
    }
}

extension ConditionalFlowViewController {
    
    override func rightButtonPressed() {
        
        guard !condition.executes.isEmpty else {
            
            let message = condition.expression == nil ? "if_condition_error_message" : "error_select_flows_before_play"
            ModalService.showWarningMessage(with: message.localized())
            
            return
        }
        
        let controller: DeviceListViewController = DeviceListViewController.makeViewControllerFromNib()
        controller.configure(with: condition)
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

private extension ConditionalFlowViewController {
    
    func configureViews() {
        
        scrollView.contentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        stackView.axis = .vertical
        stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        
        conditionalFlowItemView.delegate = self
        conditionalFlowItemView.isSwipeEnabled = false
        stackView.addArrangedSubview(conditionalFlowItemView)
        
        executeFlowItemView.delegate = self
        executeFlowItemView.isSwipeEnabled = false
        stackView.addArrangedSubview(executeFlowItemView)
    }
    
    func updateFlowItemViews() {
        
        var items = [Flow]()
        
        if let exp = condition.expression {
            items = [exp]
        }
        
        conditionalFlowItemView.configure(title: "if".localized().uppercased(),
                                          placeholder: "if_empty_message".localized(),
                                          items: items,
                                          showLine: false)
        
        executeFlowItemView.configure(title: "execute".localized().uppercased(),
                                      placeholder: "if_execute_empty_message".localized(),
                                      items: condition.executes,
                                      showLine: false)
    }
    
}

extension ConditionalFlowViewController: FlowItemViewDelegate {
    func didPressDeleteButton(flowItem: FlowItem) {
        
    }
    
    func didPressFlowItem(view: FlowItemView) {
        
        if view === conditionalFlowItemView {
            
            let controller: ConditionalFlowInputViewController = ConditionalFlowInputViewController()
            var items = [Flow]()
            
            if let exp = condition.expression {
                items = [exp]
            }
            controller.setup(with: PersistanceService.shared.getAllCustomFlows().filter { $0.hasOutputAsExp },
                             selected: items,
                             singleSelection: true)
            
            controller.completion = { [weak self] flows in
                guard let self = self, let exp = flows.first else { return }
                
                self.condition.expression = exp
                self.updateFlowItemViews()
            }
            
            navigationController?.pushViewController(controller, animated: true)
        } else if view === executeFlowItemView {
            let controller: ExecuteFlowViewController = ExecuteFlowViewController()
            
            controller.setup(with: condition.executes,
                             singleSelection: false)
            
            controller.completion = { [weak self] flows in
                guard let self = self else { return }
                
                self.condition.executes = flows
                self.updateFlowItemViews()
            }
            
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func didPressSettingsButton(flowItem: FlowItem) {
        
    }
    
}

extension ConditionalFlowViewController: FlowInputDelegate {
    func didCompleteInputSelection() {
        updateFlowItemViews()
    }
}
