//
//  IoTDeviceFormViewController.swift
//  W2STApp
//
//  Created by Dimitri Giani on 27/05/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import BlueSTSDK_Gui

class IoTDeviceFormViewController: UIViewController {
    private let loadingView = UIActivityIndicatorView(style: .gray)
    private let scrollView = UIScrollView()
    private let topLabel = UILabel()
    private let deviceNameLabel = UILabel()
    private let deviceNameField = UITextField()
    private let deviceIDLabel = UILabel()
    private let deviceIDField = UITextField()
    private let templateLabel = UILabel()
    private let templateField = SelectCellView()
    private let saveButton = UIButton()
    private var mainStack: UIStackView!
    
    private var templates: [IoTTemplate] = []
    private var device = IoTDeviceTemporary(id: IoTAppsController.shared.deviceID, displayName: IoTAppsController.shared.deviceName, template: "")
    
    var central: IoTCentralApp!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "iot.device.form.title".localizedFromGUI
        view.backgroundColor = currentTheme.color.background
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(dismissModal))
        
        loadingView.hidesWhenStopped = true
        view.addSubviewAndCenter(loadingView)
        
        mainStack = UIStackView.getVerticalStackView(withSpacing: 12, views: [
            UIStackView.getVerticalStackView(withSpacing: 2, views: [
                deviceNameLabel, deviceNameField
            ]),
            UIStackView.getVerticalStackView(withSpacing: 2, views: [
                deviceIDLabel, deviceIDField
            ]),
            UIStackView.getVerticalStackView(withSpacing: 2, views: [
                templateLabel, templateField
            ]),
        ])
        
        let containerView = UIView()
        
        scrollView.addSubview(containerView, constraints: [
            equal(\.topAnchor),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ])
        
        containerView.addSubview(mainStack, constraints: [
            equal(\.topAnchor, constant: 16),
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.bottomAnchor, constant: -16)
        ])
        
        view.addSubview(topLabel, constraints: [
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
        ])
        
        view.addSubview(saveButton, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            equalDimension(\.heightAnchor, to: 44)
        ])
        
        view.addSubview(scrollView, constraints: [
            equal(\.topAnchor, toView: topLabel, withAnchor: \.bottomAnchor, constant: 16),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor, toView: saveButton, withAnchor: \.topAnchor, constant: -16)
        ])
        
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        
        [deviceNameField, deviceIDField].forEach { view in
            view.cornerRadius = 12
            view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
            view.setDimensionContraints(width: nil, height: 40)
            
            view.leftViewMode = .always
            let spacer = UIView()
            spacer.setDimensionContraints(width: 16, height: nil)
            view.leftView = spacer
        }
        
        [deviceNameLabel, deviceIDLabel, templateLabel].forEach { view in
            view.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        }
        deviceNameLabel.text = "iot.device.form.name.title".localizedFromGUI.uppercased()
        deviceIDLabel.text = "iot.device.form.id.title".localizedFromGUI.uppercased()
        templateLabel.text = "iot.device.form.template.title".localizedFromGUI.uppercased()
        topLabel.text = "iot.device.form.text".localizedFromGUI
        templateField.text = "iot.device.form.template.not.assigned.title".localizedFromGUI
        deviceNameField.text = device.displayName
        deviceIDField.text = device.id
        deviceIDField.isEnabled = false
        topLabel.numberOfLines = 0
        
        saveButton.backgroundColor = currentTheme.color.primary
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitle("iot.device.form.button.title".localizedFromGUI, for: .normal)
        
        saveButton.onTap { [weak self] _ in
            self?.saveApp()
        }
        
        deviceNameField.onKeyPress { [weak self] value in
            self?.device.displayName = value
            self?.updateUI()
            return true
        }
        
        deviceIDField.onKeyPress { [weak self] value in
            self?.device.id = value
            self?.updateUI()
            return true
        }
        
        templateField.onTap { [weak self] _ in
            self?.showTemplatesChoice()
        }
        
        manageKeyboard()
        updateUI()
        reloadModel()
    }
    
    @objc
    private func dismissModal() {
        dismiss(animated: true)
    }
    
    private func saveApp() {
        guard device.isValid else { return }
        
        setLoadingUIVisible(true)
        
        IoTNetwork.shared.createDevice(device: device, central: central) { [weak self] device, error in
            if device != nil {
                self?.dismissModal()
            } else {
                let message = error?.localizedDescription ?? "iot.device.form.create.error.message".localizedFromGUI
                self?.presentErrorAlert(message)
            }
            
            self?.setLoadingUIVisible(false)
        }
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func updateUI() {
        saveButton.isEnabled = device.isValid
        saveButton.alpha = saveButton.isEnabled ? 1 : 0.5
    }
    
    private func manageKeyboard() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] notification in
            let height = KeyboardUtilities.getKeyboardHeight(notification)
            self?.saveButton.constraint(withAttribute: .bottom)?.constant = -height
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] notification in
            self?.saveButton.constraint(withAttribute: .bottom)?.constant = -16
        }
    }
    
    private func showTemplatesChoice() {
        var actions: [UIAlertAction] = templates.map { template in
            UIAlertAction.genericButton(template.displayName) { [weak self] _ in
                self?.device.template = template.id
                self?.templateField.text = template.displayName
                self?.updateUI()
            }
        }
        actions.append(UIAlertAction.cancelButton())
        
        UIAlertController.presentActionSheet(from: self, title: "iot.device.form.device.template.choice.title".localizedFromGUI, message: nil, actions: actions)
    }
    
    private func setLoadingUIVisible(_ visible: Bool) {
        mainStack.isHidden = visible
        topLabel.isHidden = visible
        saveButton.isHidden = visible
        navigationItem.leftBarButtonItem?.isEnabled = !visible
        visible ? loadingView.startAnimating() : loadingView.stopAnimating()
    }
    
    private func reloadModel() {
        setLoadingUIVisible(true)
        
        IoTNetwork.shared.getTemplates(central: central) { [weak self] templates, error in
            self?.templates = templates
            self?.setLoadingUIVisible(false)
        }
    }
    
    private func presentErrorAlert(_ message: String) {
        UIAlertController.presentAlert(from: self, title: "Error".localizedFromGUI, message: message, confirmButton: UIAlertAction.genericButton())
    }
}

class SelectCellView: BaseView {
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    
    var text: String = "" {
        didSet {
            titleLabel.text = text
        }
    }
    
    override func configureView() {
        super.configureView()
        
        let line = UIView()
        line.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        addSubview(line, constraints: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor),
            equalDimension(\.heightAnchor, to: 1 / UIScreen.main.scale)
        ])
        
        let stack = UIStackView.getHorizontalStackView(withSpacing: 4, views: [
            titleLabel,
            imageView
        ])
        stack.alignment = .center
        
        imageView.image = UIImage.namedFromGUI("icon_arrow_down")
        imageView.setDimensionContraints(width: 16, height: 16)
        
        addSubviewAndFit(stack, top: 0, trailing: 0, bottom: 16, leading: 0)
    }
}
