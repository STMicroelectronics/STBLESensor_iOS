//
//  ExecuteFlowViewController.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 19/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class ExecuteFlowViewController: StackViewController {
    
    var completion: (([Flow]) -> Void)?
    
    var counterFlows: [Flow] = PersistanceService.shared.getCounterFlows()
    var customFlows: [Flow] = PersistanceService.shared.getAllCustomFlows().filter { $0.hasPhysicalOutput }

    var singleSelection: Bool = false
    
    var counterSelected: [Flow] = [Flow]()
    var customSelected: [Flow] = [Flow]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "app_select_flows".localized()
    
        configureView()
    }
    
    override func rightButtonPressed() {
        
        defer {
            navigationController?.popViewController(animated: true)
        }
        
        guard let completion = completion else { return }
        completion(counterSelected + customSelected)
    }
    
    func setup(with selected: [Flow], singleSelection: Bool = false) {
        
        self.counterSelected.removeAll()
        self.customSelected.removeAll()
    
        self.counterSelected.append(contentsOf: Set(counterFlows).intersection(selected))
        self.customSelected.append(contentsOf: Set(customFlows).intersection(selected))
        
        self.singleSelection = singleSelection
    }
    
    func configureView() {
        
        if !counterFlows.isEmpty {
            
            let optionView: CheckBoxGroup = CheckBoxGroup.createFromNib()
            optionView.configure(title: "counters".localized().uppercased(),
                                 items: counterFlows,
                                 selectedItems: counterSelected,
                                 singleSelection: singleSelection) { [weak self] options in
                                    guard let self = self, let options = options as? [Flow] else { return }
                                    
                                    self.counterSelected = options
            }
            
            stackView.addArrangedSubview(optionView.embedInView(with: UIEdgeInsets(top: 30.0, left: 24.0, bottom: 10.0, right: -24.0)))
        }
        
        if !customFlows.isEmpty {
            
            let optionView: CheckBoxGroup = CheckBoxGroup.createFromNib()
            optionView.configure(title: "custom_flows".localized().uppercased(),
                                 items: customFlows,
                                 selectedItems: customSelected,
                                 singleSelection: singleSelection) { [weak self] options in
                                    guard let self = self, let options = options as? [Flow] else { return }
                                    
                                    self.customSelected = options
            }
            
            stackView.addArrangedSubview(optionView.embedInView(with: UIEdgeInsets(top: 30.0, left: 24.0, bottom: 10.0, right: -24.0)))
        }
        
        addFooter(to: scrollView)
        leftButton?.isHidden = true
        rightButton?.setTitle("set_input".localized().uppercased(), for: .normal)
        rightButton?.setImage(UIImage.named("img_done"), for: .normal)
        
    }
}
