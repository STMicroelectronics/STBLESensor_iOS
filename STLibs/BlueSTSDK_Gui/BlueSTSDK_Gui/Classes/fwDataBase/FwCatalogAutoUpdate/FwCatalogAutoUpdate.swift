//
//  FwCatalogAutoUpdate.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//
 
import Foundation
import BlueSTSDK
import BlueSTSDK_Gui

public class FwCatalogAutoUpdate: UIViewController {
    
    public init(node: BlueSTSDKNode, fwCurrent: Firmware, fwAvailable: Firmware) {
        self.node = node
        self.currentFwUpdate = fwCurrent
        self.availableFwUpdate = fwAvailable
        super.init(nibName: "FwCatalogAutoUpdate", bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    private let DISCONNECT_DELAY = TimeInterval(0.3) //0.3s
    
    var node: BlueSTSDKNode
    var currentFwUpdate: Firmware
    var availableFwUpdate: Firmware
    public var bundle: Bundle? = nil
    private var selectedFileName: String = ""
    private var selectedFileUrl: String = ""
    
    private var dontAskAgain = false
    
    @objc
    private func dismissModal() {
        navigationController?.popViewController(animated: true)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Update Available"
        
        /** Used to load .xib view (tableView cell) in Pod File */
        bundle = Bundle(for: self.classForCoder)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "FwCatalogAutoUpdateCell", bundle: bundle)
        nib.instantiate(withOwner: self, options: nil)
        tableView.register(nib, forCellReuseIdentifier: "fwcatalogautoupdatecell")
        
    }
    
}

@available(iOS 13.0, *)
extension FwCatalogAutoUpdate: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Firmware Update Cell n\(indexPath) tapped")
    }
    
    /** Click on Download And Flash Firmware Button */
    private func onDownloadAndFlashFirmwareTapped() {
        //HUD.show(.progress, onView: self.view)
        let fwDownloadManager = FwDownloadManager(fileName: selectedFileName, url: selectedFileUrl)
        fwDownloadManager.downloadFile() { (downloadedFwPath) -> () in
            print("[CALLBACK] \(downloadedFwPath ?? "Cannot download the firmware")")
            //HUD.hide()
            guard let downloadedFwPath = downloadedFwPath else {
                self.showToast(message: "Cannot download the firmware", seconds: 2.0)
                return
            }

            if(self.node.type == BlueSTSDKNodeType.PROTEUS || self.node.type == BlueSTSDKNodeType.POLARIS || self.node.type == BlueSTSDKNodeType.nucleo || self.node.type == BlueSTSDKNodeType.NUCLEO_L053R8 || self.node.type == BlueSTSDKNodeType.NUCLEO_L476RG || self.node.type == BlueSTSDKNodeType.NUCLEO_F446RE || self.node.type == BlueSTSDKNodeType.NUCLEO_F401RE || self.node.type == BlueSTSDKNodeType.STSYS_SBU06){
                self.catalogFwUpgradeWB(downloadedFwPath: downloadedFwPath) /// WB Catalog Fw Upgrade
            } else {
                self.catalogFwUpgradeDebugConsole(downloadedFwPath: downloadedFwPath) /// Debug Console Catalog Fw Upgrade
            }
            
        }
        
    }
    
    private func catalogFwUpgradeDebugConsole(downloadedFwPath: String?){
        let vc = BlueSTSDKFwUpgradeManagerViewController.instaziate(forNode: self.node, requireAddress: false, fwLocalUrl: URL(string: downloadedFwPath!))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func catalogFwUpgradeWB(downloadedFwPath: String?){
        /// WB Fw Upgrade
        let feature = self.node.getFeatureOfType(BlueSTSDKSTM32WBRebootOtaModeFeature.self) as? BlueSTSDKSTM32WBRebootOtaModeFeature;
        
        feature?.rebootToFlash(sectorOffset: 7,
                               numSector: 40)
        //wait 1/3s to send the message and then disconnect the node
        DispatchQueue.main.asyncAfter(deadline: .now() + DISCONNECT_DELAY){ [node = self.node] in
            node.disconnect()
        }
        
        //create the vc that will search the ota node
        let searchVc = BlueSTSDKSeachOtaNodeViewController.instanziate(
            nodeAddress: BlueSTSDKSTM32WBOTAUtils.getOtaAddressForNode(self.node),
            addressWhereFlash: UInt32(7)*0x1000,
            fileUrl: URL(string: downloadedFwPath!),
            fwType: BlueSTSDKFwUpgradeType.applicationFirmware)
        //replace the current vc with the one for search the node
        replaceViewController(searchVc,animated: false)
    }
}

@available(iOS 13.0, *)
extension FwCatalogAutoUpdate: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fwcatalogautoupdatecell", for: indexPath) as! FwCatalogAutoUpdateCell
        
        /**Cell still be selectable, but you won't see the background colour change**/
        cell.selectionStyle = .none
        
        cell.firmwareCurrentName.text = "\(currentFwUpdate.name) v\(currentFwUpdate.version)"
        cell.firmwareUpdateName.text = "\(availableFwUpdate.name) v\(availableFwUpdate.version)"
        cell.changeLog.text = availableFwUpdate.changelog

        cell.dontAskAgainCheckBox.addTarget(self, action: #selector(checkBoxTapped), for: .touchUpInside)
        
        cell.cancel.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cell.installNow.addTarget(self, action: #selector(installNowButtonTapped), for: .touchUpInside)
        
        return cell
    }
    
    @objc func checkBoxTapped(sender: UIButton!) {
        if(sender.currentImage == UIImage(systemName: "square")){
            sender.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
            dontAskAgain = true
        } else {
            sender.setImage(UIImage(systemName: "square"), for: .normal)
            dontAskAgain = false
        }
    }
    
    @objc func cancelButtonTapped(sender: UIButton!) {
        if(dontAskAgain) {
            let fullCurrentFwInfo = "\(currentFwUpdate.name) v\(currentFwUpdate.version)"
            let DONT_ASK_AGAIN_FW_UPDATE = "propose_fw_update_for_\(fullCurrentFwInfo)_\(node.tag)"
            let preference = UserDefaults.standard
            preference.setValue(true, forKey: DONT_ASK_AGAIN_FW_UPDATE)
        }
        dismissModal()
    }
    
    @objc func installNowButtonTapped(sender: UIButton!) {
        selectedFileName = "\(availableFwUpdate.name)v\(availableFwUpdate.version)"
        selectedFileUrl = "\(availableFwUpdate.fota.url ?? " ")"
        onDownloadAndFlashFirmwareTapped()
    }
}
