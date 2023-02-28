//
//  ConditionalFlowInputViewController.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 18/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class ConditionalFlowInputViewController: StackViewController {
    
    var completion: (([Flow]) -> Void)?
    var flows: [Flow] = [Flow]()
    var singleSelection: Bool = false
    
    var selected: [Flow] = [Flow]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "if_title".localized()

        configureView()
    }
    
    override func rightButtonPressed() {
        
        defer {
            navigationController?.popViewController(animated: true)
        }
        
        guard let completion = completion else { return }
        completion(selected)
    }
    
    func setup(with flows: [Flow], selected: [Flow], singleSelection: Bool = false) {
        
        self.selected.removeAll()
        self.flows.removeAll()
        
        self.singleSelection = singleSelection
        self.selected.append(contentsOf: selected)
        self.flows.append(contentsOf: flows)
    }
    
    func configureView() {
        
        if !flows.isEmpty {
            
            let optionView: CheckBoxGroup = CheckBoxGroup.createFromNib()
            optionView.configure(title: "exp".localized().uppercased(),
                                 items: flows,
                                 selectedItems: selected,
                                 singleSelection: singleSelection) { [weak self] options in
                                    guard let self = self, let options = options as? [Flow] else { return }
                                    
                                    self.selected = options
            }
            
            stackView.addArrangedSubview(optionView.embedInView(with: UIEdgeInsets(top: 30.0, left: 24.0, bottom: 10.0, right: -24.0)))
        }
        
        addFooter(to: scrollView)
        leftButton?.isHidden = true
        rightButton?.setTitle("set_input".localized().uppercased(), for: .normal)
        rightButton?.setImage(UIImage.named("img_done"), for: .normal)
        
    }
    
}
