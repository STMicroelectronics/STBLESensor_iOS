//
//  IoTCentralAppsAvailableViewController.swift
//  
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import Foundation
import BlueSTSDK
import BlueSTSDK_Gui

struct PnPApps{
    let name: String
    let description: String
}

class IoTCentralAppsAvailableViewController: UIViewController {
    
    private let noDataLabel = UILabel()
    
    var node: BlueSTSDKNode!
    
    var availablePnPapps: [CloudApp] = []
    
    private var completeDebugMsgOutput = ""

    /** Local DB firmwares */
    public var catalogFw: Catalog?
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadModel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**Retrieve Blue STSDK v2 firmware informations */
        catalogFw = CatalogService().currentCatalog()
        loadPnPApps()
        
        title = "Select Pnp Application"
        view.backgroundColor = currentTheme.color.background
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(dismissModal))
        
        noDataLabel.text = "No IoT Central Applications Available for this board.".localizedFromGUI
        noDataLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        noDataLabel.numberOfLines = 0
        noDataLabel.textAlignment = .center
        
        tableView.register(BaseSubtitleCell.self, forCellReuseIdentifier: "BaseSubtitleCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubviewAndFit(noDataLabel, top: 16, trailing: 16, bottom: 16, leading: 16)
        view.addSubviewAndFit(tableView)
    }
    
    @objc
    private func dismissModal() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is IoTCentralAppsViewController {
                self.navigationController!.popToViewController(aViewController, animated: true)
            }
        }
    }
    
    private func reloadModel() {
        tableView.reloadData()
        
        noDataLabel.isHidden = !availablePnPapps.isEmpty
        tableView.isHidden = availablePnPapps.isEmpty
    }
    
    /**
     *  Function that load firmware informations from Local DB
     */
    func loadPnPApps() {

        /**1. Retrieve Option Bytes*/
        let optBytes = withUnsafeBytes(of: node.advertiseInfo.featureMap.bigEndian, Array.init)
        print("optBytes0 -> \(optBytes[0]) and optBytes1 \(optBytes[1])")
        
        /**1. Retrieve Firmware Id*/
        var bleFwId: Int = 0
        if(optBytes[0]==0x00){
            bleFwId = Int(optBytes[1]) + 256
        }else if(optBytes[0]==0xFF){
            bleFwId = 255
        }else{
            bleFwId = Int(optBytes[0])
        }
        
        print("Board Type Id \(node.typeId)")
        print("Board Protocol Version \(node.advertiseInfo.protocolVersion)")
        print("Ble Fw Id \(bleFwId)")
        
        catalogFw?.blueStSdkV2.forEach{ fw in
            if (node.typeId == __uint8_t(fw.deviceId.dropFirst(2), radix: 16) &&  __uint8_t(fw.bleVersionIdHex.dropFirst(2), radix: 16)! == bleFwId) {
                fw.cloudApps?.forEach{ cloudApp in
                    availablePnPapps.append(cloudApp)
                }
            }
        }
        
        if(node.protocolVersion == 1){
            if !(node.debugConsole==nil){
                node.debugConsole?.add(self)
                node.debugConsole?.writeMessage("versionFw\n")
            }
        }

        /** Reload model -> if there aren't available apps an information label will appear*/
        reloadModel()

    }
    
}

extension IoTCentralAppsAvailableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        availablePnPapps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BaseSubtitleCell", for: indexPath)
        
        let app = availablePnPapps[indexPath.row]
        cell.textLabel?.text = app.name
        cell.detailTextLabel?.text = app.description
        cell.detailTextLabel?.numberOfLines = 5
        
        //cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let controller = IoTCentralAppFormViewController()
        controller.node = node
        controller.cloudAppSelected = availablePnPapps[indexPath.row]
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension IoTCentralAppsAvailableViewController: BlueSTSDKDebugOutputDelegate {
    func debug(_ debug: BlueSTSDKDebug, didStdOutReceived msg: String) {
        debugPrint("didStdOutReceived: \(msg)")
        
        if(!(msg.hasSuffix("\n"))){
            completeDebugMsgOutput = completeDebugMsgOutput + msg
        }else{
            completeDebugMsgOutput = completeDebugMsgOutput + msg
            debugPrint("completeDebugMsgOutput: \(completeDebugMsgOutput)")
            let parts = completeDebugMsgOutput.split(separator: "\r\n")
            if let boardResponse = parts.first {
                catalogFw?.blueStSdkV1.forEach{ fw in
                    if(node.typeId == __uint8_t(fw.deviceId.dropFirst(2), radix: 16)) {
                        if(boardResponse == fw.bleVersionIdHex){
                            fw.cloudApps?.forEach{ pnpApp in
                                availablePnPapps.append(pnpApp)
                            }
                        }
                    }
                }
            }
            
            DispatchQueue.main.async(execute: {
                self.reloadModel()
            })
        }
        
        
    }
    
    func debug(_ debug: BlueSTSDKDebug, didStdErrReceived msg: String) {
        debugPrint("didStdErrReceived: \(msg)")
    }
    
    func debug(_ debug: BlueSTSDKDebug, didStdInSend msg: String, error: Error?) {
        debugPrint("didStdInSend: \(msg)")
    }
    
    
}
