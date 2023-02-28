//
//  STATCloudLoggingViewController.swift
//  W2STApp
//
//  Created by Dimitri Giani on 24/03/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//
//  Test devices on: https://dsh-assetracking.st.com/#/devices
//

import AssetTrackingCloudDashboard
import AssetTrackingDataModel
import UIKit
import Toast_Swift

class STATCloudLoggingViewController: W2STCloudConfigViewController, DeviceManagerDelegate {
    enum State {
        case connected
        case disconnected
    }
    
    private let loadingView = UIActivityIndicatorView(style: .gray)
    private let deviceTitleLabel = UILabel()
    private let deviceIDLabel = UILabel()
    private let featureListContainerView = UIView()
    private let connectionController = STATFeatureListViewController()
    private let connectButton = UIButton()
    private let samplesButton = UIButton()
    private let loginManager = CloudConfig.atrLoginManager
    private var cloudExporter: CloudExporter? = nil
    private var device: AssetTrackingDevice {
        AssetTrackingDevice(id: deviceID, type: .BLE, label: nil, lastSyncTimestamp: nil)
    }
    private var state: State = .disconnected {
        didSet {
            if state == .connected {
                connectionController.connect()
            } else {
                connectionController.disconnect()
            }
        }
    }
    private var deviceID: String = "" {
        didSet {
            deviceIDLabel.text = deviceID
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "ST Asset Tracking"
        
        view.addSubviewAndCenter(loadingView)
        loadingView.hidesWhenStopped = true
        
        setupController(connectionController)
        
        view.backgroundColor = currentTheme.color.viewControllerBackground
        deviceTitleLabel.text = "Device Id".localizedFromGUI
        deviceTitleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        deviceIDLabel.textAlignment = .right
        
        connectButton.backgroundColor = currentTheme.color.secondary
        connectButton.tintColor = .white
        connectButton.setDimensionContraints(width: 50, height: 50)
        connectButton.cornerRadius = 25
        connectButton.addTarget(self, action: #selector(toggleConnection), for: .touchUpInside)
        
        samplesButton.setDimensionContraints(width: nil, height: 50)
        samplesButton.cornerRadius = 25
        samplesButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 16)
        samplesButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        samplesButton.backgroundColor = currentTheme.color.primary
        samplesButton.tintColor = .white
        samplesButton.setTitleColor(.white, for: .normal)
        samplesButton.addTarget(self, action: #selector(sendSamplesAction), for: .touchUpInside)
        samplesButton.setImage(UIImage.namedFromGUI("icon_cloud_up"), for: .normal)
        samplesButton.isHidden = true
        
        let stackView = UIStackView.getHorizontalStackView(withSpacing: 4, views: [deviceTitleLabel, deviceIDLabel])
        view.addSubview(stackView, constraints: [
            equal(\.safeAreaLayoutGuide.topAnchor, constant: 16),
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16)
        ])
        
        view.addSubview(featureListContainerView, constraints: [
            equal(\.topAnchor, toView: stackView, withAnchor: \.bottomAnchor, constant: 16),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ])
        
        view.addSubview(connectButton, constraints: [
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        view.addSubview(samplesButton, constraints: [
            equal(\.trailingAnchor, toView: connectButton, withAnchor: \.leadingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        add(child: connectionController, appendTo: featureListContainerView, atIndex: 0, constraints: UIView.fitToSuperViewConstraints)
        
        setLoadingUIVisible(false)
        updateUI()
    }
    
    override func buildConnectionFactory() -> BlueMSCloudIotConnectionFactory? {
        return STATConnectionFactory()
    }
    
    override func setupController(_ controller: BlueMSCloudConnectionViewController) {
        super.setupController(controller)
        
        connectionController.didUpdateSamples = { [weak self] in
            self?.updateSamplesDependentUI()
        }
    }
    
    private func updateUI() {
        deviceID = W2STCloudConfigViewController.getDeviceId(for: node)
        
        updateConnectionDependentUI()
    }
    
    private func updateSamplesDependentUI() {
        samplesButton.setTitle("Samples: ".localizedFromGUI + String(connectionController.samples.count), for: .normal)
    }
    
    private func updateConnectionDependentUI() {
        updateSamplesDependentUI()
        
        if state == .connected {
            connectButton.setImage(UIImage.namedFromGUI("icon_cross"), for: .normal)
            samplesButton.isHidden = false
        } else {
            connectButton.setImage(UIImage.namedFromGUI("icon_cloud_up"), for: .normal)
            samplesButton.isHidden = true
        }
    }
    
    private func setLoadingUIVisible(_ visible: Bool) {
        visible ? loadingView.startAnimating() : loadingView.stopAnimating()
        
        connectionController.canAddSamples = !visible
        
        deviceTitleLabel.isHidden = visible
        deviceIDLabel.isHidden = visible
        featureListContainerView.isHidden = visible
        connectButton.isHidden = visible
        samplesButton.isHidden = visible
    }
    
    private func showErrorAlert(_ error: Error) {
        UIAlertController.presentAlert(from: self, title: "Error".localizedFromGUI, message: error.localizedDescription, actions: [UIAlertAction.genericButton()])
    }
    
    @objc
    private func toggleConnection() {
        if state == .connected {
            state = .disconnected
        } else {
            state = .connected
        }
        
        updateConnectionDependentUI()
    }
    
    func controller(_ controller: UIViewController, didCompleteDeviceManager deviceManager: DeviceManager) {
        controller.removeCurrentViewController()
        cloudExporter = CloudExporter(controller: self, deviceManager: deviceManager)
        self.sendSamples()
    }
    
    private func loadLoginViewController() {
        let cloudVc = AssetTrackingCloudBundle.buildATRLoginViewController(loginManager: CloudConfig.atrLoginManager)
        cloudVc.delegate = self
        self.navigationController?.pushViewController(cloudVc, animated: true)
    }
    
    @objc
    private func sendSamplesAction() {
        guard !connectionController.samples.isEmpty else { return }
        loadLoginViewController()
    }
    
    private func sendSamples() {
        setLoadingUIVisible(true)
        cloudExporter?.exportData(device: device, data: connectionController.samples, from: self) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.finishSend()
                    
                case .failure(let error):
                    debugPrint("Error: \(error)")
                    
                    self?.setLoadingUIVisible(false)
                    self?.showErrorAlert(error)
                }
            }
        }
    }
    
    private func finishSend() {
        setLoadingUIVisible(false)
        connectionController.removeAllSamples()
        
        view.makeToast("Cloud sync completed")
    }
}
