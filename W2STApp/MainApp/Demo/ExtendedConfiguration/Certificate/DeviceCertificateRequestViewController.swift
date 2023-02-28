//
//  DeviceCertificateRequestViewController.swift
//  W2STApp
//
//  Created by Dimitri Giani on 06/05/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import AssetTrackingCloudDashboard
import AssetTrackingDataModel
import BlueSTSDK
import BlueSTSDK_Gui
import UIKit
import Toast_Swift

class DeviceCertificateRequestViewController: UIViewController {
    private let deviceIDTitleLabel = UILabel()
    private let deviceIDTextField = UITextField()
    private let registerButton = UIButton()
    private let showCertificateButton = UIButton()
    private let certificateTextView = UITextView()
    private let loadingView = UIActivityIndicatorView(style: .gray)
    private var mainView: UIStackView!
    
    private let loginManager = CloudConfig.atrLoginManager
    private let certificateManager = CertificateManager()
    private var isCertificatePreGenerated: Bool = false
    
    private var device: AssetTrackingDevice {
        var deviceId: String = uid
        if let text = deviceIDTextField.text, !text.isEmpty {
            deviceId = text
        }
        
        let baseDevice = AssetTrackingDevice(id: deviceId, type: .BLE, label: nil, lastSyncTimestamp: nil)
        
        if isCertificatePreGenerated {
            guard let certificate = certificate else { return baseDevice }
            
            var device = AssetTrackingDevice(id: deviceId, type: .WIFI, label: nil, lastSyncTimestamp: nil)
            device.certificate = certificate
            return device
        }
        
        return baseDevice
    }
    
    var uid: String!
    var didReceivedCertificate: (String) -> Void = { _ in }
    var certificate: String? {
        didSet {
            if let certificate = certificate {
                certificateTextView.text = certificate
            } else {
                certificateTextView.text = "device.certificate.no.certificate.text".localizedFromGUI
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if certificate != nil {
            isCertificatePreGenerated = true
        }
        
        title = "device.certificate.title".localizedFromGUI
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissModal))
        
        view.backgroundColor = currentTheme.color.background
        
        view.addSubviewAndCenter(loadingView)
        loadingView.hidesWhenStopped = true
        
        showCertificateButton.isHidden = !isCertificatePreGenerated
        
        deviceIDTextField.text = uid
        deviceIDTextField.textColor = currentTheme.color.text
        deviceIDTextField.font = UIFont.systemFont(ofSize: 15)
        deviceIDTextField.borderStyle = .roundedRect
        
        deviceIDTitleLabel.text = "device.certificate.deviceid.title".localizedFromGUI
        deviceIDTitleLabel.textColor = currentTheme.color.text
        deviceIDTitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        
        certificateTextView.isEditable = false
        certificateTextView.font = UIFont.systemFont(ofSize: 15)
        certificateTextView.textColor = currentTheme.color.secondaryText
        certificateTextView.backgroundColor = currentTheme.color.background
        
        registerButton.setTitle("device.certificate.register.title".localizedFromGUI.uppercased(), for: .normal)
        registerButton.setTitleColor(currentTheme.color.primary, for: .normal)
        showCertificateButton.setTitleColor(currentTheme.color.primary, for: .normal)
        certificateTextView.isHidden = true
        
        registerButton.addTarget(self, action: #selector(register), for: .touchUpInside)
        showCertificateButton.addTarget(self, action: #selector(showCertificate), for: .touchUpInside)
        
        let labelsStack = UIStackView.getVerticalStackView(withSpacing: 4, views: [deviceIDTitleLabel, deviceIDTextField])
        let buttonsView = UIStackView.getVerticalStackView(withSpacing: 4, views: [registerButton, showCertificateButton])
        buttonsView.alignment = .leading
        
        mainView = UIStackView.getVerticalStackView(withSpacing: 4, views: [labelsStack, buttonsView])
        
        deviceIDTextField.setDimensionContraints(width: nil, height: 44)
        registerButton.setDimensionContraints(width: nil, height: 44)
        showCertificateButton.setDimensionContraints(width: nil, height: 44)
        
        view.addSubview(mainView, constraints: [
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(certificateTextView, constraints: [
            equal(\.topAnchor, toView: mainView, withAnchor: \.bottomAnchor, constant: 16),
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16)
        ])
        
        certificateTextView.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor, constant: 16).isActive = true
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        updateUI()
    }
    
    @objc
    internal func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc
    private func register() {
        setLoadingUIVisible(true)
        registerDevice()
    }
    
    @objc
    private func showCertificate() {
        certificateTextView.isHidden.toggle()
        updateUI()
    }
    
    @objc
    private func dismissModal() {
        dismiss(animated: true)
    }
    
    private func setLoadingUIVisible(_ visible: Bool) {
        visible ? loadingView.startAnimating() : loadingView.stopAnimating()
        mainView.isHidden = visible
        certificateTextView.isHidden = visible
    }
    
    private func updateUI() {
        if certificateTextView.isHidden {
            showCertificateButton.setTitle("device.certificate.show.certificate.title".localizedFromGUI.uppercased(), for: .normal)
        } else {
            showCertificateButton.setTitle("device.certificate.hide.certificate.title".localizedFromGUI.uppercased(), for: .normal)
        }
    }
    
    private func registerDevice() {
        if loginManager.isAuthenticated {
            sendRegisterDevice()
        } else {
            doLogin { [weak self] error in
                if let error = error {
                    self?.setLoadingUIVisible(false)
                    self?.showErrorAlert(error)
                } else {
                    self?.sendRegisterDevice()
                }
            }
        }
    }
    
    private func doLogin(_ completion: @escaping (Error?) -> Void) {
        loginManager.authenticate(from: self) { error in
            DispatchQueue.main.async {
                completion(error)
            }
        }
    }
    
    private func sendRegisterDevice() {
        certificateManager.registerDevice(device: device, certificate: certificate, from: self) { [weak self] result in
            DispatchQueue.main.async {
                self?.setLoadingUIVisible(false)
                
                switch result {
                    case .success(let device):
                        self?.manageRegisterdCertificate(device.certificate)
                        
                    case .failure(let error):
                        self?.showErrorAlert(error)
                }
            }
        }
    }
    
    private func showErrorAlert(_ error: Error) {
        UIAlertController.presentAlert(from: self, title: "Error".localizedFromGUI, message: error.localizedDescription, actions: [UIAlertAction.genericButton()])
    }
    
    private func manageRegisterdCertificate(_ certificate: String?) {
        if device.isWifi {
            view.makeToast("device.certificate.registered.ok.title".localizedFromGUI)
            
            dismiss(animated: true, completion: nil)
        } else {
            view.makeToast("device.certificate.received.ok.title".localizedFromGUI)
            
            guard let certificate = certificate else { return }
            
            didReceivedCertificate(certificate)
        }
    }
}
