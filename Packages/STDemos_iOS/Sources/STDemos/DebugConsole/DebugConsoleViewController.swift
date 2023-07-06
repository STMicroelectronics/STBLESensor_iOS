//
//  DebugConsoleViewController.swift
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

final class DebugConsoleViewController: DemoNodeNoViewController<DebugConsoleDelegate> {

    let commandTextField = UITextField()
    let sendButton = UIButton()
    let logTextView = UITextView()
    
    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Debug Console"

        presenter.load()
    }

    override func configureView() {
        super.configureView()

        logTextView.isEditable = false
        
        setupCommandTextField()
        
        Buttonlayout.standardWithSmallFont.apply(to: sendButton, text: "SEND")

        let horizontalSV = UIStackView.getHorizontalStackView(withSpacing: 16, views: [
            commandTextField,
            sendButton
        ])
        horizontalSV.distribution = .fill

        let mainStackView = UIStackView.getVerticalStackView(withSpacing: 16, views: [
            horizontalSV,
            logTextView
        ])
        mainStackView.distribution = .fill
        
        view.addSubview(mainStackView, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])

        let sendBtnTap = UITapGestureRecognizer(target: self, action: #selector(sendBtnTapped(_:)))
        sendButton.addGestureRecognizer(sendBtnTap)
    }

}

extension DebugConsoleViewController {
    private func setupCommandTextField() {
        commandTextField.setDimensionContraints(width: nil, height: 44)
        commandTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        commandTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: commandTextField.frame.height))
        commandTextField.leftViewMode = .always
        commandTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: commandTextField.frame.height))
        commandTextField.rightViewMode = .always
        commandTextField.placeholder = "Insert command"
        commandTextField.layer.borderWidth = 1
        commandTextField.layer.cornerRadius = 5
        commandTextField.layer.borderColor = ColorLayout.stGray5.light.cgColor
        commandTextField.returnKeyType = .done
        commandTextField.delegate = self
    }
    
    @objc
    func sendBtnTapped(_ sender: UITapGestureRecognizer) {
        if let commandTxt = commandTextField.text {
            presenter.sendCommand(commandTxt)
        }
    }
}

extension DebugConsoleViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commandTextField.resignFirstResponder()
        return true
    }
}
