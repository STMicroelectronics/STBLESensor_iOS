//
//  DashboardCreateViewController.swift
//  AssetTrackingCloudDashboard
//
//  Created by Klaus Lanzarini on 04/11/2020.
//

import UIKit
import AssetTrackingDataModel

class DashboardCreateViewController: UIViewController {
    typealias CreateCallback = (AssetTrackingDevice, String, UIViewController) -> Void
    // init
    private let deviceManager: DeviceManager
    private var device: AssetTrackingDevice
    private let callback: CreateCallback

    private var deviceText: String = "" { didSet { deviceLabel.text = "Device ID: " + deviceText } }
    
    // outlets
    private let deviceLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let nameTextField = UITextField()
    private let createButton = UIButton()
    
    init(deviceManager: DeviceManager, device: AssetTrackingDevice, callback: @escaping CreateCallback) {
        self.deviceManager = deviceManager
        self.device = device
        self.callback = callback
        super.init(nibName: nil, bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "CLOUD SYNC"
        view.backgroundColor = .white
        createButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)
        
        deviceText = device.id
        
        setupViews()
    }
}

private extension DashboardCreateViewController {
    func setupViews() {
        view.addSubview(deviceLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(nameTextField)
        view.addSubview(createButton)
        deviceLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        nameTextField.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        deviceLabel.font = UIFont.systemFont(ofSize: 18)
        descriptionLabel.text = "Unknown device, please register it"
        descriptionLabel.textColor = .lightGray
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        nameTextField.placeholder = "Device name (required)"
        nameTextField.borderStyle = .roundedRect
        createButton.setTitle("ADD DEVICE TO CLOUD", for: .normal)
        createButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        NSLayoutConstraint.activate([deviceLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
                                     deviceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
                                     deviceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
                                     descriptionLabel.topAnchor.constraint(equalTo: deviceLabel.bottomAnchor, constant: 16),
                                     descriptionLabel.leadingAnchor.constraint(equalTo: deviceLabel.leadingAnchor),
                                     descriptionLabel.trailingAnchor.constraint(equalTo: deviceLabel.trailingAnchor),
                                     nameTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 32),
                                     nameTextField.leadingAnchor.constraint(equalTo: deviceLabel.leadingAnchor),
                                     nameTextField.trailingAnchor.constraint(equalTo: deviceLabel.trailingAnchor),
                                     createButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
                                     createButton.leadingAnchor.constraint(equalTo: deviceLabel.leadingAnchor),
                                     createButton.trailingAnchor.constraint(equalTo: deviceLabel.trailingAnchor)])
    }
    
    @objc
    func didTapCreate() {
        guard let name = nameTextField.text else { return }
        callback(device, name, self)
    }
}
