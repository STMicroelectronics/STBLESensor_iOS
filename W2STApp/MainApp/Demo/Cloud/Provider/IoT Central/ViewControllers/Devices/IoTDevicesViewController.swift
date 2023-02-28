//
//  IoTDevicesViewController.swift
//  W2STApp
//
//  Created by Dimitri Giani on 27/05/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import BlueSTSDK
import BlueSTSDK_Gui

class IoTDevicesViewController: UIViewController {
    private let loadingView = UIActivityIndicatorView(style: .gray)
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let noDataLabel = UILabel()
    
    private var devices: [IoTDevice] = []
    private var myDeviceIsListed: Bool {
        devices.first { $0.id == IoTAppsController.shared.deviceID } != nil
    }
    
    var node: BlueSTSDKNode!
    var minUpdateInterval: TimeInterval!
    var central: IoTCentralApp!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "iot.device.title".localizedFromGUI
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDevice))
        view.backgroundColor = currentTheme.color.background
        noDataLabel.text = "iot.device.nodata.text".localizedFromGUI
        noDataLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        noDataLabel.numberOfLines = 0
        noDataLabel.textAlignment = .center
        tableView.register(BaseSubtitleCell.self, forCellReuseIdentifier: "BaseSubtitleCell")
        tableView.delegate = self
        tableView.dataSource = self
        noDataLabel.isHidden = true
        
        loadingView.hidesWhenStopped = true
        view.addSubviewAndCenter(loadingView)
        view.addSubviewAndFit(noDataLabel, top: 16, trailing: 16, bottom: 16, leading: 16)
        view.addSubviewAndFit(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIButton.appearance().setTitleColor(.white, for: .normal)
        reloadModel()
    }
    
    private func setLoadingUIVisible(_ visible: Bool) {
        tableView.isHidden = visible
        noDataLabel.isHidden = true
        visible ? loadingView.startAnimating() : loadingView.stopAnimating()
        navigationItem.rightBarButtonItem?.isEnabled = !visible
    }
    
    private func reloadModel() {
        setLoadingUIVisible(true)
        
        IoTNetwork.shared.getDevices(central: central) { [weak self] devices, error in
            guard let self = self else { return }
            
            self.devices = devices
            
            IoTNetwork.shared.getTemplates(central: self.central) { [weak self] templates, error in
                self?.updateDevicesWithTemplates(templates)
                self?.setLoadingUIVisible(false)
                self?.updateUI()
            }
        }
    }
    
    private func updateDevicesWithTemplates(_ templates: [IoTTemplate]) {
        devices.forEach { device in
            device.ioTtemplate = templates.first { $0.id == device.template }
        }
    }
    
    @objc
    private func addDevice() {
        let controller = IoTDeviceFormViewController()
        controller.central = central
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true)
    }
    
    private func updateUI() {
        tableView.reloadData()
        
        tableView.isHidden = devices.isEmpty
        noDataLabel.isHidden = !devices.isEmpty
        navigationItem.rightBarButtonItem?.isEnabled = !myDeviceIsListed
    }
    
    private func showErrorAlert(_ error: Error) {
        UIAlertController.presentAlert(from: self, title: "Error".localizedFromGUI, message: error.localizedDescription, actions: [UIAlertAction.genericButton()])
    }
    
    private func deleteDevice(_ device: IoTDevice) {
        func deleteDevice() {
            setLoadingUIVisible(true)
            
            IoTNetwork.shared.deleteDevice(device: device, central: central) { [weak self] error in
                if let error = error {
                    self?.setLoadingUIVisible(false)
                    self?.showErrorAlert(error)
                } else {
                    self?.reloadModel()
                }
            }
        }
        
        UIAlertController.presentAlert(from: self, title: "iot.device.delete.alert.title".localizedFromGUI, message: nil, actions: [
            UIAlertAction.destructiveButton("generic.yes".localizedFromGUI, { _ in
                deleteDevice()
            }),
            UIAlertAction.cancelButton()
        ])
    }
}

extension IoTDevicesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BaseSubtitleCell", for: indexPath)
        let device = devices[indexPath.row]
        let isMyDevice = device.id == IoTAppsController.shared.deviceID
        cell.textLabel?.text = device.displayName
        cell.detailTextLabel?.text = device.id
        cell.accessoryType = isMyDevice ? .disclosureIndicator : .none
        cell.textLabel?.alpha = isMyDevice ? 1 : 0.5
        cell.detailTextLabel?.alpha = isMyDevice ? 1 : 0.5
        cell.selectionStyle = isMyDevice ? .default : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let device = devices[indexPath.row]
        guard device.id == IoTAppsController.shared.deviceID else { return }
        
        let controller = IoTDeviceDetailViewController()
        controller.node = node
        controller.minUpdateInterval = minUpdateInterval
        controller.device = device
        controller.central = central
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .destructive, title: "iot.device.delete.title".localizedFromGUI, handler: { [unowned self] _, indexPath in
                self.deleteDevice(devices[indexPath.row])
            })
        ]
    }
}
