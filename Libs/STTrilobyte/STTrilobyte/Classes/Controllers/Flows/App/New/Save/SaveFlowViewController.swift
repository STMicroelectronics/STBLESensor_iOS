//
//  SaveFlowViewController.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 25/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class SaveFlowViewController: FooterViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let nameTextField = TextField(frame: .zero)
    let notesTextField = TextField(frame: .zero)
    
    var currentName: String = ""
    
    var flow: Flow?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "new_flow".localized()
        
        nameTextField.delegate = self
        notesTextField.delegate = self
        
        nameTextField.text = flow?.name
        notesTextField.text = flow?.notes
        
        currentName = flow?.name ?? ""
        
        configureView()
    }
    
    override func rightButtonPressed() {
        
        guard let flow = flow, let name = nameTextField.text, !name.sanitazed().isEmpty else {
            ModalService.showWarningMessage(with: "err_flow_name_missing".localized())
            return
        }
        
        flow.name = name
        flow.notes = notesTextField.text ?? ""
        
        if currentName != flowDefaultName, currentName != nameTextField.text {
            flow.identifier = UUID().uuidString
        }
        
        if PersistanceService.shared.exists(flow: flow) {
            ModalService.showConfirm(with: "error_conflicting_flow_names".localized()) { [weak self] success in
                if success {
                    guard let self = self else { return }
                    PersistanceService.shared.save(flow: flow)
                    self.navigationController?.popToController(ExpertViewController.self, animated: true)
                }
            }
        } else {
            PersistanceService.shared.save(flow: flow)
            navigationController?.popToController(ExpertViewController.self, animated: true)
        }
    }
    
    func configure(with flow: Flow) {
        self.flow = flow
    }
}

private extension SaveFlowViewController {
    
    func configureView() {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.font = currentTheme.font.bold.withSize(16.0)
        titleLabel.textColor = currentTheme.color.textDark
        titleLabel.text = "flow_detail".localized()
        let titleView = titleLabel.embedInView(with: UIEdgeInsets(top: 24.0, left: 24.0, bottom: 12.0, right: 24.0))
        stackView.addArrangedSubview(titleView)
        
        let descriptionLabel = UILabel(frame: .zero)
        descriptionLabel.font = currentTheme.font.regular.withSize(16.0)
        descriptionLabel.textColor = currentTheme.color.text
        descriptionLabel.text = "flow_add_name_notes".localized()
        let descriptionView = descriptionLabel.embedInView(with: UIEdgeInsets(top: 12.0, left: 24.0, bottom: 12.0, right: 24.0))
        stackView.addArrangedSubview(descriptionView)
        
        nameTextField.titleText = "flow_name".localized()
        nameTextField.placeholder = ""
        nameTextField.validators = [
            MinCharactersValidator(with: 8)
        ]
        let nameTextFieldView = nameTextField.embedInView(with: UIEdgeInsets(top: 40.0, left: 24.0, bottom: 12.0, right: 24.0))
        stackView.addArrangedSubview(nameTextFieldView)
        
        notesTextField.titleText = "notes".localized()
        notesTextField.placeholder = ""
        let descriptionTextFieldView = notesTextField.embedInView(with: UIEdgeInsets(top: 40.0, left: 24.0, bottom: 12.0, right: 24.0))
        stackView.addArrangedSubview(descriptionTextFieldView)
        
        addFooter(to: scrollView)
        
        leftButton?.isHidden = true
        rightButton?.setTitle("finish".localized().uppercased(), for: .normal)
        rightButton?.setImage(UIImage.named("img_done"), for: .normal)
    }
}

extension SaveFlowViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === nameTextField {
            notesTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        
        return true
    }
}
