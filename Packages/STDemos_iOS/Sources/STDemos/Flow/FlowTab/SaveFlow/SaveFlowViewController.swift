//
//  SaveFlowViewController.swift
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

final class SaveFlowViewController: BaseNoViewController<SaveFlowDelegate> {

    var bottomView: UIStackView?
    
    var nameTextField = UITextField()
    var descriptionTextField = UITextField()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Save App"
        
        presenter.load()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let bottomView = bottomView else { return }

        view.bringSubviewToFront(bottomView)
        bottomView.applyShadow()
    }
    
    override func configureView() {
        super.configureView()
        
        let appDetailsTitle = UILabel()
        let appDetailsDescription = UILabel()
        let nameTextFieldLabel = UILabel()
        let descriptionTextFieldLabel = UILabel()
        
        TextLayout.title.apply(to: appDetailsTitle)
        appDetailsTitle.numberOfLines = 0
        appDetailsTitle.text = "App Details"

        TextLayout.infoBold.apply(to: appDetailsDescription)
        appDetailsDescription.numberOfLines = 0
        appDetailsDescription.text = "Add a name and notes to your Application.\nThe Application Name will be also the File Name."
        
        TextLayout.text.apply(to: nameTextFieldLabel)
        nameTextFieldLabel.numberOfLines = 0
        nameTextFieldLabel.text = "Name"
        
        TextLayout.text.apply(to: descriptionTextFieldLabel)
        descriptionTextFieldLabel.numberOfLines = 0
        descriptionTextFieldLabel.text = "Description"
        
        setupTextFields()
        
        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            appDetailsTitle,
            appDetailsDescription,
            nameTextFieldLabel,
            nameTextField,
            descriptionTextFieldLabel,
            descriptionTextField
        ])
        mainStackView.distribution = .fill
        
        let doneButton = UIButton(type: .custom)
        let cancelButton = UIButton(type: .custom)
        Buttonlayout.textColorWithIamge(color: ColorLayout.systemWhite.light, image: ImageLayout.Common.done?.withTintColor(ColorLayout.systemWhite.light, renderingMode: .alwaysTemplate)).apply(to: doneButton, text: "FINISH")
        Buttonlayout.textColorWithIamge(color: ColorLayout.systemWhite.light, image: ImageLayout.Common.close?.withTintColor(ColorLayout.systemWhite.light, renderingMode: .alwaysTemplate)).apply(to: cancelButton, text: "CANCEL")
        
        doneButton.on(.touchUpInside) { [weak self] _ in
            self?.presenter.doneButtonTapped()
        }
        
        cancelButton.on(.touchUpInside) { [weak self] _ in
            self?.presenter.cancelButtonTapped()
        }
        
        let buttonStackView = UIStackView.getHorizontalStackView(
            withSpacing: 10.0,
            views: [
                cancelButton.embedInView(with: .standardEmbed),
                doneButton.embedInView(with: .standardEmbed)
            ]
        )
        buttonStackView.distribution = .fillEqually
        
        var bottomViews = [UIView]()
        bottomViews.append(buttonStackView)

        if UIDevice.current.hasNotch {
            bottomViews.append(UIView.empty(height: 40.0))
        }

        let bottomStackView = UIStackView.getVerticalStackView(withSpacing: 0.0,
                                                               views: bottomViews)

        bottomViews.forEach { view in
            view.backgroundColor = ColorLayout.primary.light
        }
        
        view.addSubview(bottomStackView)
        bottomStackView.activate(constraints: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ])
        
        bottomView = bottomStackView
        
        view.backgroundColor = .systemBackground
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView, constraints: [
            equal(\.leadingAnchor, constant: 0),
            equal(\.trailingAnchor, constant: 0),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 0),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
        scrollView.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.topAnchor, constant: 16),
            equal(\.bottomAnchor, constant: -16),
            equal(\.widthAnchor, constant: -32)
        ])
    }

}

extension SaveFlowViewController {
    private func setupTextFields() {
        nameTextField.setDimensionContraints(width: nil, height: 44)
        nameTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: nameTextField.frame.height))
        nameTextField.leftViewMode = .always
        nameTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: nameTextField.frame.height))
        nameTextField.rightViewMode = .always
        nameTextField.placeholder = "Insert name"
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.cornerRadius = 5
        nameTextField.layer.borderColor = ColorLayout.stGray5.light.cgColor
        nameTextField.returnKeyType = .done
        nameTextField.delegate = self
        
        descriptionTextField.setDimensionContraints(width: nil, height: 44)
        descriptionTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        descriptionTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: descriptionTextField.frame.height))
        descriptionTextField.leftViewMode = .always
        descriptionTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: descriptionTextField.frame.height))
        descriptionTextField.rightViewMode = .always
        descriptionTextField.placeholder = "Insert description"
        descriptionTextField.layer.borderWidth = 1
        descriptionTextField.layer.cornerRadius = 5
        descriptionTextField.layer.borderColor = ColorLayout.stGray5.light.cgColor
        descriptionTextField.returnKeyType = .done
        descriptionTextField.delegate = self
    }
}

extension SaveFlowViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === nameTextField {
            descriptionTextField.becomeFirstResponder()
        } else {
            view.endEditing(true)
        }
        
        return true
    }
}
