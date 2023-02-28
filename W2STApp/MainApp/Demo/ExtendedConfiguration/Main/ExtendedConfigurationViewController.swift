//
//  ExtendedConfigurationViewController.swift
//  W2STApp
//
//  Created by Dimitri Giani on 27/04/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import BlueSTSDK
import BlueSTSDK_Gui
import AssetTrackingCloudDashboard

extension UserDefaults {
    static let ExtendedCommandWelcome = "ExtendedCommandWelcome"
}

class ExtendedConfigurationViewController: BlueMSDemoTabViewController, DeviceManagerDelegate {
    internal var isConfigured: Bool = false
    internal var feature: BlueSTSDKFeatureExtendedConfiguration? {
        node.getFeatureOfType(BlueSTSDKFeatureExtendedConfiguration.self) as? BlueSTSDKFeatureExtendedConfiguration
    }
    internal let loadingView = LoadingView()
    internal let tableView = UITableView(frame: .zero)
    internal var model: [ECCommandSection] = []
    internal var expandedSections: Set<ECCommandSection> = [.boardReport, .boardSecurity, .boardControl, .boardSettings, .customCommands]
    internal var availableCommands: [ECCommandType] = []
    internal var customCommands: [ECCustomCommand] = []
    internal var uid: String = ""
    
    /** Used to open Predictive Maintenance Dashboard (Request Certificate possible choices [Asset Tracking, Predictive Maintenance] */
    func controller(_ controller: UIViewController, didCompleteDeviceManager deviceManager: DeviceManager) {
        let predmntDeviceListController : PredictiveCloudDeviceListViewController = PredictiveCloudDeviceListViewController(node: self.node)
        
        var viewControllers = controller.navigationController?.viewControllers
        if(viewControllers != nil){
            viewControllers!.remove(at: viewControllers!.count - 1)
            viewControllers!.append(predmntDeviceListController)
            controller.navigationController?.setViewControllers(viewControllers!, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareModel()
        
        view.addSubviewAndCenter(loadingView)
        view.addSubviewAndFit(tableView)
        tableView.separatorStyle = .none
        tableView.register(BaseSubtitleCell.classForCoder(), forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        feature?.debug = true
        
        reloadModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        enableNotifications()
        configureDemo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        disableNotifications()
    }
    
    internal func setLoadingUIVisible(_ visible: Bool, text: String = "") {
        loadingView.setVisible(true, text: text)
        tableView.isHidden = visible
    }
}

extension ExtendedConfigurationViewController {
    private func enableNotifications() {
        feature?.add(self)
        feature?.enableNotification()
    }
    
    private func disableNotifications() {
        feature?.remove(self)
        feature?.disableNotification()
    }
    
    private func configureDemo() {
        guard !isConfigured else { return }
        
        let ud = UserDefaults.standard
        if !ud.bool(forKey: UserDefaults.ExtendedCommandWelcome) {
            UIAlertController.presentAlert(from: self, title: "extconf.main.alert.title".localizedFromGUI, actions: [UIAlertAction.genericButton()])
        }
        
        ud.setValue(true, forKey: UserDefaults.ExtendedCommandWelcome)
        ud.synchronize()
        
        setLoadingUIVisible(true)
        
        DispatchQueue.main.async {
            self.feature?.sendCommand(.readCommand)
        }
    }
    
    private func prepareModel() {
        model = [.boardReport, .boardSecurity, .boardControl, .boardSettings]
        
        if !customCommands.isEmpty {
            model.append(.customCommands)
        }
    }
    
    private func reloadModel() {
        prepareModel()
        tableView.reloadData()
    }
    
    private func commandListUpdated(_ sectionsAvailable: [ECCommandType]) {
        availableCommands = sectionsAvailable
        
        reloadModel()
        
        if uid.isEmpty {
            feature?.sendCommand(.UID)
        }
    }
    
    private func manageResponse(response: ECResponse) {
        guard let type = response.type else { return }
        let alertTitle = type.title.localizedFromGUI
        
        switch type {
            case .readCommand:
                self.commandListUpdated(response.availableCommands)
                
            case .UID:
                let newUID = response.UID ?? ""
                if uid.isEmpty {
                    uid = newUID
                } else {
                    showAlert(title: alertTitle, message: newUID)
                }
                
            case .versionFw, .info, .help, .powerStatus:
                showAlert(title: alertTitle, message: response.stringValue ?? "")
                
            case .readCustomCommand:
                customCommands = response.customCommands ?? []
                reloadModel()
                
            case .readCert:
                showCertificate(response.stringValue)

            case .bankStatus:
                showFlashBankStatus(response.bankStatus ?? nil)
            
            default:
                break
        }
    }
    
    private func showAlert(title: String, message: String) {
        UIAlertController.presentAlert(from: self, title: title, message: message, actions: [UIAlertAction.genericButton()])
    }
}

extension ExtendedConfigurationViewController: BlueSTSDKFeatureDelegate {
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        DispatchQueue.main.async {
            if let sample = sample as? ECFeatureSample {
                self.manageResponse(response: sample.response)
            }
            
            self.setLoadingUIVisible(false)
        }
    }
}
