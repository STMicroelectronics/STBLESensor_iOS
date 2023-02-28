//
//  IoTDeviceDetailViewController.swift
//  W2STApp
//
//  Created by Dimitri Giani on 27/05/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import BlueSTSDK
import BlueSTSDK_Gui
import SafariServices

class IoTDeviceDetailViewController: W2STCloudConfigViewController {
    enum State {
        case ready
        case configuring
    }
    private let loadingView = UIActivityIndicatorView(style: .gray)
    private let deviceNameLabel = UILabel()
    private let deviceIdLabel = UILabel()
    //private let sendLabel = UILabel()
    private let sendingFeatureStatus = UILabel()
    private let sendingFeatureValue = UILabel()
    private let featureListContainerView = UIView()
    private let connectionController = IoTDeviceDetailFeatureListViewController()
    private var mainStack: UIStackView!
    private var credentials: IoTDeviceCredentials!
    private var state = State.configuring

    private var goingForwards = false
    
    var enabledFeatures = Array<BlueSTSDKFeature>()
    
    private var dashboardURL: URL {
        return central.baseURL.appendingPathComponent("devices/details/\(device.id)/")
    }
    
    var central: IoTCentralApp!
    var device: IoTDevice!
    
    deinit {
        connectionController.disconnect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(goingForeground),
                                                   name: UIApplication.didEnterBackgroundNotification,
                                                   object: nil)
                    
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActivity),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        minUpdateInterval = 1
        
        title = "iot.device.detail.title".localizedFromGUI
        view.backgroundColor = currentTheme.color.background
        
        loadingView.hidesWhenStopped = true
        view.addSubviewAndCenter(loadingView)
        
        let editButton = UIButton()
        let deviceInfoView = UIStackView.getHorizontalStackView(withSpacing: 6, views: [
            UIStackView.getVerticalStackView(withSpacing: 2, views: [deviceNameLabel, deviceIdLabel]),
            editButton
        ])
        deviceInfoView.distribution = .equalCentering
        
        let dashboardButton = UIButton()
        let buttonsStack = UIStackView.getHorizontalStackView(withSpacing: 12, views: [dashboardButton])
        
        mainStack = UIStackView.getVerticalStackView(withSpacing: 12, views: [
            deviceInfoView,
            buttonsStack,
            //sendLabel,
            sendingFeatureStatus,
            sendingFeatureValue
        ])
        
        view.addSubview(mainStack, constraints: [
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(featureListContainerView, constraints: [
            equal(\.topAnchor, toView: mainStack, withAnchor: \.bottomAnchor, constant: 1),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ])
        
        editButton.setDimensionContraints(width: 44, height: nil)
        //sendLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        sendingFeatureStatus.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        sendingFeatureValue.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        sendingFeatureValue.numberOfLines = 2
        deviceNameLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        deviceIdLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        deviceNameLabel.numberOfLines = 0
        //sendLabel.textColor = currentTheme.color.text
        sendingFeatureStatus.textColor = currentTheme.color.text
        sendingFeatureValue.textColor = currentTheme.color.secondaryText
        deviceNameLabel.textColor = currentTheme.color.text
        deviceIdLabel.textColor = currentTheme.color.secondaryText
        //sendLabel.text = "iot.device.detail.start.telemetry.title".localizedFromGUI
        sendingFeatureStatus.text = "Sending: None"
        sendingFeatureValue.text = "- - -"
        //sendLabel.textAlignment = .center
        sendingFeatureStatus.textAlignment = .left
        sendingFeatureValue.textAlignment = .left
        dashboardButton.setTitle("iot.device.detail.show.dashboard.title".localizedFromGUI, for: .normal)
        dashboardButton.backgroundColor = currentTheme.color.secondary
        dashboardButton.setTitleColor(.white, for: .normal)
        dashboardButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
        dashboardButton.addTarget(self, action: #selector(showDashboard), for: .touchUpInside)
        dashboardButton.setDimensionContraints(height: 44)
        
        editButton.setImage(UIImage.namedFromGUI("ic_edit_on"), for: .normal)
        editButton.onTap { [weak self] _ in
            self?.editDeviceName()
        }
        
        updateUI()
        
        getCredentials()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        goingForwards = false
        setupController(connectionController)
        
        connectionController.telemetryValueHandler = { featureName, featureValue in
            DispatchQueue.main.async {
                self.sendingFeatureStatus.text = "Sending: \(featureName)"
                self.sendingFeatureValue.text = featureValue
            }
        }
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        if(!goingForwards){
            super.viewDidDisappear(animated)
        
            connectionController.disconnect()
            
            connectionController.node = nil
            connectionController.connectionFactoryBuilder = nil
        }
    }
    
    override func buildConnectionFactory() -> BlueMSCloudIotConnectionFactory? {
        return IotCentralConnectionFactory(device: device, central: central, credentials: credentials, node: node)
    }
    
    private func updateUI() {
        deviceNameLabel.text = device.displayName
        deviceIdLabel.text = device.id
    }
    
    private func editDeviceName() {
        var aTextField: UITextField?
        UIAlertController.presentTextFieldAlert(from: self,
                                                title: "iot.device.detail.edit.name.title".localizedFromGUI,
                                                message: nil,
                                                confirmButton: UIAlertAction.genericButton("iot.device.detail.edit.name.button.title".localizedFromGUI, { [weak self] _ in
                                                    
                                                    if let text = aTextField?.text, !text.isEmpty {
                                                        self?.updateDeviceName(text)
                                                    }
                                                    
                                                }),
                                                cancelButton: UIAlertAction.cancelButton()) { textField, controller in
            aTextField = textField
            textField.text = self.device.displayName
        }
    }
    
    private func setLoadingUIVisible(_ visible: Bool) {
        mainStack.isHidden = visible
        
        if state == .ready {
            connectionController.view.isHidden = visible
        }
        
        visible ? loadingView.startAnimating() : loadingView.stopAnimating()
    }
    
    private func showErrorAlert(_ error: Error) {
        UIAlertController.presentAlert(from: self, title: "Error".localizedFromGUI, message: error.localizedDescription, actions: [UIAlertAction.genericButton()])
    }
    
    private func updateDeviceName(_ name: String) {
        setLoadingUIVisible(true)
        
        IoTNetwork.shared.updateDeviceName(device: device, name: name, central: central) { [weak self] error in
            self?.setLoadingUIVisible(false)
            if let error = error {
                self?.showErrorAlert(error)
            } else {
                self?.device.displayName = name
                self?.deviceNameLabel.text = name
            }
        }
    }
    
    private func showConnectionErrorAlert() {
        
        let controller = UIAlertController(title: "Error", message: "iot.device.detail.connection.alert.message".localizedFromGUI, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }))
        present(controller, animated: true)
    }
    
    @objc
    private func showDashboard() {
        goingForwards = true
        present(SFSafariViewController(url: dashboardURL), animated: true, completion: nil)
    }
    
    private func connect() {
        state = .ready
        
        setupController(connectionController)
        add(child: connectionController, appendTo: featureListContainerView, atIndex: 0, constraints: UIView.fitToSuperViewConstraints)
        connectionController.connect { [weak self] success in
            self?.setLoadingUIVisible(false)
            if !success {
                self?.showConnectionErrorAlert()
            }
        }
    }
    
    private func getCredentials() {
        setLoadingUIVisible(true)
        IoTNetwork.shared.getDeviceCredentials(device: device, central: central) { [weak self] credentials, error in
            if let credentials = credentials {
                self?.credentials = credentials
                self?.connect()
            } else {
                self?.showConnectionErrorAlert()
            }
        }
    }
    
    @objc func goingForeground() {
        IotCentralConnectionFactory.supportedFeatures.forEach { f in
            //let feature = self.node.getFeatureOfType(f)
            if !(f==nil) {
               if(node.isEnableNotification(f)) {
                    enabledFeatures.append(f)
                    node.disableNotification(f)
                    Thread.sleep(forTimeInterval: 0.1)
                }
            }
        }
    }
        
    @objc func didBecomeActivity() {
        enabledFeatures.forEach { f in
            node.enableNotification(f)
            Thread.sleep(forTimeInterval: 0.1)
        }
        enabledFeatures.removeAll()
    }

}
