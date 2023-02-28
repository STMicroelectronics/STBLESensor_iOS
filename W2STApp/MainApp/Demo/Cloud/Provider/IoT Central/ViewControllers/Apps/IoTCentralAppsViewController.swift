//
//  IoTCentralAppsViewController.swift
//  W2STApp
//
//  Created by Dimitri Giani on 25/05/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import BlueSTSDK
import BlueSTSDK_Gui
import STTheme

class IoTCentralAppsViewController: W2STCloudConfigViewController {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let noDataLabel = UILabel()
    
    private var completeDebugMsgOutput = ""
    
    private var extFeature: BlueSTSDKFeatureExtendedConfiguration? {
        node.getFeatureOfType(BlueSTSDKFeatureExtendedConfiguration.self) as? BlueSTSDKFeatureExtendedConfiguration
    }
    
    private var apps: [IoTCentralApp] {
        IoTAppsController.shared.apps
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDeviceID(W2STCloudConfigViewController.getDeviceId(for: node))
        IoTAppsController.shared.deviceName = W2STCloudConfigViewController.getDeviceId(for: node)
        
        //  Updated Device ID with STM32 UID
        
        if let feature = extFeature {
            feature.add(self)
            feature.enableNotification()
            feature.sendCommand(ECCommandType.UID)
        } else {
            node.debugConsole?.add(self)
            node.debugConsole?.writeMessage("uid\n")
        }
        
        title = "iot.title".localizedFromGUI
        view.backgroundColor = currentTheme.color.background
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCentral))
        noDataLabel.text = "iot.nodata.text".localizedFromGUI
        noDataLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        noDataLabel.numberOfLines = 0
        noDataLabel.textAlignment = .center
        tableView.register(BaseSubtitleCell.self, forCellReuseIdentifier: "BaseSubtitleCell")
        tableView.delegate = self
        tableView.dataSource = self
        noDataLabel.isHidden = true
        
        view.addSubviewAndFit(noDataLabel, top: 16, trailing: 16, bottom: 16, leading: 16)
        view.addSubviewAndFit(tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIButton.appearance().setTitleColor(.white, for: .normal)
        reloadModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //  Reset button styles
        ThemeService.shared.applyToAllViewType()
    }
    
    private func setDeviceID(_ id: String) {
        IoTAppsController.shared.deviceID = id
    }
    
    private func reloadModel() {
        tableView.reloadData()
        
        noDataLabel.isHidden = !apps.isEmpty
        tableView.isHidden = apps.isEmpty
    }
    
    @objc
    private func addCentral() {
        let controller = IoTCentralAppsAvailableViewController()
        controller.node = node
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func deleteApp(_ app: IoTCentralApp) {
        func deleteApp() {
            IoTAppsController.shared.removeApp(app)
            reloadModel()
        }
        
        UIAlertController.presentAlert(from: self, title: "iot.apps.delete.alert.title".localizedFromGUI, message: nil, actions: [
            UIAlertAction.destructiveButton("generic.yes".localizedFromGUI, { _ in
                deleteApp()
            }),
            UIAlertAction.cancelButton()
        ])
    }
}

extension IoTCentralAppsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        apps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BaseSubtitleCell", for: indexPath)
        let central = apps[indexPath.row]
        cell.textLabel?.text = central.subdomain
        cell.detailTextLabel?.text = central.domain
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let controller = IoTDevicesViewController()
        controller.node = node
        controller.minUpdateInterval = minUpdateInterval
        controller.central = apps[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .destructive, title: "iot.apps.delete.title".localizedFromGUI, handler: { [unowned self] _, indexPath in
                self.deleteApp(apps[indexPath.row])
            })
        ]
    }
}

extension IoTCentralAppsViewController: BlueSTSDKFeatureDelegate {
    private func manageResponse(response: ECResponse) {
        guard let type = response.type else { return }
        switch type {
            case .UID:
                if let id = response.UID { setDeviceID(id) }
                
            default:
                break
        }
    }
    
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        DispatchQueue.main.async {
            if let sample = sample as? ECFeatureSample {
                self.manageResponse(response: sample.response)
            }
        }
    }
}

extension IoTCentralAppsViewController: BlueSTSDKDebugOutputDelegate {
    func debug(_ debug: BlueSTSDKDebug, didStdOutReceived msg: String) {
        
        if(!(msg.hasSuffix("\n"))){
            completeDebugMsgOutput = completeDebugMsgOutput + msg
            return
        }else{
            completeDebugMsgOutput = completeDebugMsgOutput + msg
        }
        
        let parts = completeDebugMsgOutput.split(separator: "_")
        
        if let id = parts.first {
            setDeviceID(String(id).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        }
    }
    
    func debug(_ debug: BlueSTSDKDebug, didStdErrReceived msg: String) {
//        debugPrint("didStdErrReceived: \(msg)")
    }
    
    func debug(_ debug: BlueSTSDKDebug, didStdInSend msg: String, error: Error?) {
//        debugPrint("didStdInSend: \(msg)")
    }
    
    
}
