/*
 * BlueMSMainViewController.swift
 *
 * Copyright (c) 2022 STMicroelectronics.
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file in
 * the root directory of this software component.
 * If no LICENSE file comes with this software, it is provided AS-IS.
 */

import Foundation
import BlueSTSDK_Gui
import BlueMSFwUpgradeChecker
import STTrilobyte
import Alamofire
import UIKit

public class BlueMSMainViewController : BlueSTSDKMainViewController {
    
    /** Checksum Structure Response */
    public struct ChecksumResponse: Codable {
        public let checksum: String
        public let date: String
        public let version: String

        enum CodingKeys: String, CodingKey {
            case checksum = "checksum"
            case date = "date"
            case version = "version"
        }

        public init(checksum: String, date: String, version: String) {
            self.checksum = checksum
            self.date = date
            self.version = version
        }
    }
    
    /**
     *  laod the BlueSTSDKMainView and set the delegate for it
     */
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.delegateAbout = self
        self.delegateNodeList = self
        
        
        let defaults = UserDefaults.standard
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        /**Load LOCAL CHECKSUM Field for comparing to REMOTE DB Firmwares CHECKSUM*/
        let checksum = defaults.string(forKey: "Checksum")
        
        /** Check if the checksum field is changed */
        let checkSumUrl = URL(string: "https://raw.githubusercontent.com/STMicroelectronics/appconfig/blesensor_4.18/bluestsdkv2/chksum.json")!
        AF.request(checkSumUrl).responseDecodable(of: ChecksumResponse.self) { response in
            switch response.result {
                case .success(let response):
                    if(checksum != response.checksum){
                        let c = response.checksum
                        self.saveFirmwareInformations(checksum: c, defaults: defaults)
                    } else if (CatalogService().currentCatalog() == nil){
                        self.saveFirmwareInformations(checksum: response.checksum, defaults: defaults)
                    }
                case .failure(_):
                    let alert = UIAlertController(title: "Offline", message: "Please check your connectivity.", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
            }
        }

    }
    
    private func saveFirmwareInformations(checksum: String, defaults: UserDefaults){
        /**1. Store REMOTE Checksum Information*/
        defaults.set(checksum, forKey: "Checksum")
        
        /**2. Make REMOTE DB Firmware request and save to LOCAL DB Firmware*/
        CatalogService().requestDBFirmware()
    }
    
    @IBAction func onCreateAppButtonClick(_ sender: UIButton) {
        let sensorTile101vc = SensorTile101ViewController()
        sensorTile101vc.sensorTile101Delegate = self
        changeViewController(sensorTile101vc)
    }
    
    private func getDemoViewController(with node: BlueSTSDKNode, menuManager: BlueSTSDKViewControllerMenuDelegate)
        -> UIViewController{
            let storyBoard = UIStoryboard(name: "BlueMS", bundle: Bundle(for: Self.self));
            let mainView = storyBoard.instantiateInitialViewController() as? BlueMSDemosViewController
            mainView?.node=node;
            mainView?.menuDelegate = menuManager;
            return mainView!
    }
    
    private func logNodeConnection(node: BlueSTSDKNode, currentVersion:BlueSTSDKFwVersion?){
        
        let fwVersion = STM32WBPeer2PeerDemoConfiguration.isValidNode(node) ?
            BlueSTSDKFwVersion(name: "STM32Cube_FW_WB", mcuType: "STM32WBxx", major: 0, minor: 0, patch: 0) :
            currentVersion
    }
    
    private func checkFw(node:BlueSTSDKNode, currentVersion:BlueSTSDKFwVersion?){
        guard let currentVersion = currentVersion else{
            return
        }
        let checker = BlueMSFwUpgradeChecker()
        checker.checkNewFirmwareAvailabitity(boardType: node.typeId, board: currentVersion){ newFwUrl in
            guard let fwUrl = newFwUrl else{
                return
            }
            DispatchQueue.main.async {
                BlueSTSDKAskFwUpgradeDialog.askToUpgrade(node: node,file: fwUrl,vc: self)
            }
        }
    }
    
    private func retrieveRunningFw(node: BlueSTSDKNode) -> Firmware? {
        let optBytes = withUnsafeBytes(of: node.advertiseInfo.featureMap.bigEndian, Array.init)
        let optBytesData = NSData(bytes: optBytes, length: optBytes.count)
        
        let result0 = (optBytesData as NSData).extractUInt8(fromOffset: UInt(0))
        let result1 = (optBytesData as NSData).extractUInt8(fromOffset: UInt(1))

        let catalogService = CatalogService()
        let catalog = catalogService.currentCatalog()
        
        guard let catalog = catalog else { return nil }

        return catalogService.getFwDetailsNode(catalog: catalog, device_id: Int(node.typeId & 0xFF), opt_byte_0: Int(result0), opt_byte_1: Int(result1))
    }
    
    private func checkCatalogFwUpdate(node: BlueSTSDKNode) -> UIViewController? {
        let catalogService = CatalogService()
        let catalog = catalogService.currentCatalog()
        guard let catalog = catalog else { return nil }
        
        var availableFwsUpdate: Firmware? = nil
        
        let runningFw = retrieveRunningFw(node: node)
        guard let runningFw = runningFw else { return nil }
        if(runningFw.fota.type == .wbReady){ return nil }

        let compatibleFws = catalogService.getCompatibleFirmwaressNode(catalog: catalog, device_id: Int(node.typeId & 0xFF), bleFwId: Int((runningFw.bleVersionIdHex.dropFirst(2)), radix: 16)!)
        
        guard let compatibleFws = compatibleFws else { return nil }

        compatibleFws.forEach{ compatibleFw in
            if(compatibleFw.name == runningFw.name){
                if(compatibleFw.version > runningFw.version){
                    if(compatibleFw.fota.url != nil && compatibleFw.fota.url != ""){
                        availableFwsUpdate = compatibleFw
                    }
                }
            }
        }
        
        guard let availableFwsUpdate = availableFwsUpdate else { return nil }

        /** Check if user selected Dont Ask Again CheckBox */
        let fullCurrentFwInfo = "\(runningFw.name) v\(runningFw.version)"
        let DONT_ASK_AGAIN_FW_UPDATE = "propose_fw_update_for_\(fullCurrentFwInfo)_\(node.tag)"
        let preference = UserDefaults.standard
        
        if !preference.bool(forKey: DONT_ASK_AGAIN_FW_UPDATE) {
            let controller: FwCatalogAutoUpdate = FwCatalogAutoUpdate(node: node, fwCurrent: runningFw, fwAvailable: availableFwsUpdate)
            return controller
        }
        
        return nil
    }

    private func retrieveDtmiUri(fw: Firmware) -> String? {
        guard let dtmi = fw.dtmi else { return nil }
        if(dtmi == "") { return nil }
        
        var dtmiUri = dtmi
        dtmiUri = dtmiUri.replacingOccurrences(of: ":", with: "/")
        dtmiUri = dtmiUri.replacingOccurrences(of: ";", with: "-")
        
        if(dtmi.contains("dtmi:stmicroelectronics")) {
            return "https://devicemodels.azure.com/" + dtmiUri + ".expanded.json"
        } else {
            return "https://raw.githubusercontent.com/STMicroelectronics/appconfig/blesensor_4.18/" + dtmiUri + ".expanded.json"
        }
    }
    
    private func retrieveDtmi(_ dtmiUri: String){
        AF.request(URL(string: dtmiUri)!).responseDecodable(of: PnPLikeDtmiCommands.self) { response in
            switch response.result {
                case .success(let response):
                    if(response.count != 0){
                        PnPLikeService().storePnPLDtmi(response, type: .standard)
                    }
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    /**
     *  when the user select a node show the main view form the DemoView storyboard
     *
     *  @param node node selected
     *
     *  @return controller with the demo to show
     */
    public func demoViewController(with node: BlueSTSDKNode, menuManager: BlueSTSDKViewControllerMenuDelegate) -> UIViewController? {
        let runningFw = retrieveRunningFw(node: node)
        if(runningFw != nil){
            let dtmiUri = retrieveDtmiUri(fw: runningFw!)
            if(dtmiUri != nil){
                retrieveDtmi(dtmiUri!)
            } else if(dtmiUri == nil) {
                let dtmi = PnPLikeService().currentPnPLDtmi()
                if(dtmi == nil){
                    PnPLikeService().storePnPLDtmi(nil, type: .standard)
                }
            }
        } else {
            PnPLikeService().storePnPLDtmi(nil, type: .standard)
        }
                
        let catalogFwUpgrade = checkCatalogFwUpdate(node: node)
        if(catalogFwUpgrade != nil){
            return catalogFwUpgrade
        }
                
        readNodeFwVersion(node: node){ [weak self] version in
            self?.logNodeConnection(node: node, currentVersion: version)
            self?.checkFw(node: node, currentVersion: version)
        }
        if(BlueSTSDKSTM32WBOTAUtils.isOTANode(node)){
            return BlueSTSDKFwUpgradeManagerViewController.instaziate(forNode: node,
                                                                      requireAddress: true,
                                                                      defaultAddress: BlueSTSDKSTM32WBOTAUtils.DEFAULT_FW_ADDRESS,
                                                                       requireFwType: true)
        }else if (BlueNRGOtaUtils.isOTANode(node)){
            return BlueSTSDKFwUpgradeManagerViewController.instaziate(forNode: node,
                                                                      requireAddress: false,
                                                                      defaultAddress:nil)
        }else{
            return getDemoViewController(with: node, menuManager: menuManager)
        }
        
    }

    private func readNodeFwVersion( node:BlueSTSDKNode, onRead:@escaping (BlueSTSDKFwVersion?)->()){
        let readVersionConsole = BlueSTSDKFwConsoleUtil.getFwReadVersionConsoleForNode(node: node)
        if let console = readVersionConsole{
            let sendCmd = console.readFwVersion{ version in
                onRead(version)
            }
            if(!sendCmd){ // if we can't send the command log whotut the fw info
                onRead(nil)
            }
        }else{
            onRead(nil)
        }
    }

}


extension BlueMSMainViewController : BlueSTSDKAboutViewControllerDelegate{
    private static let PRIVACY_URL = URL(string:"http://www.st.com/content/st_com/en/common/privacy-policy.html")
    
    public func abaoutHtmlPagePath() -> String? {
        return Bundle.main.path(forResource: "text", ofType: "html");
    }
    
    public func headImage() -> UIImage? {
        return UIImage(named: "press_contact")
    }
    
    public func privacyInfoUrl() -> URL? {
        return BlueMSMainViewController.PRIVACY_URL
    }
    
    public func libLicenseInfo() -> [BlueSTSDKLibLicense]? {
        let bundle = Bundle.main;
        return [
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "AWSMobileSDK", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "BlueSTSDK", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "BlueSTSDK_Gui", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "CorePlot", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "IBMWatson", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "MBProgressHUD", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "MQTTClient", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "Reachability", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "SwiftyJSON", ofType: "txt")!)
        ]
    }
    
}

extension BlueMSMainViewController : BlueSTSDKNodeListViewControllerDelegate{
    /**
     *  filter the node for show only the ones with remote features
     *
     *  @param node node to filter
     *
     */
    public func display(node: BlueSTSDKNode) -> Bool {
        return true;
    }
    
    public func prepareToConnect(node:BlueSTSDKNode){
        node.addExternalCharacteristics(BlueSTSDKStdCharToFeatureMap.getManageStdCharacteristics())
        node.addExternalCharacteristics(BlueSTSDKSTM32WBOTAUtils.getOtaCharacteristics())
        node.addExternalCharacteristics(BlueNRGOtaUtils.getOtaCharacteristics())
        if(STM32WBPeer2PeerDemoConfiguration.isValidDeviceNode(node)){
            node.addExternalCharacteristics(STM32WBPeer2PeerDemoConfiguration.getCharacteristicMapping())
        }
        if(node.type == .sensor_Tile_Box ){
            showStBoxPinAllert()
        }
        
    }
    
    private static let ST_BOX_PIN_ALLERT_SHOW = "BlueSTSDKNodeListViewControllerDelegate.ST_BOX_PIN_ALLERT_SHOW"
    
    private static let ST_BOX_PIN_ALLERT_TITLE:String = {
        let bundle = Bundle(for: BlueMSMotionIntensityViewController.self)
        return NSLocalizedString("SensorTile.Box Pin",
                                 tableName: nil,
                                 bundle: bundle,
                                 value: "SensorTile.Box Pin",
                                 comment: "")
        
    }();
    
    private static let ST_BOX_PIN_ALLERT_CONTENT:String = {
        let bundle = Bundle(for: BlueMSMotionIntensityViewController.self)
        return NSLocalizedString("If requested the default pin is 123456",
                                 tableName: nil,
                                 bundle: bundle,
                                 value: "If requested the default pin is 123456",
                                 comment: "")
        
    }();
    
    func showStBoxPinAllert(){
        let userSettings = UserDefaults.standard
        if(!userSettings.bool(forKey: Self.ST_BOX_PIN_ALLERT_SHOW )){
            showAllert(title: Self.ST_BOX_PIN_ALLERT_TITLE,
                       message: Self.ST_BOX_PIN_ALLERT_CONTENT)
            userSettings.set(true, forKey: Self.ST_BOX_PIN_ALLERT_SHOW)
        }
    }
    
    public var advertiseFilters: [BlueSTSDKAdvertiseFilter]{
        get{
            //if a board is compatible with multiple advertise, give the precedence to the sdk format
            return  BlueSTSDKManager.DEFAULT_ADVERTISE_FILTER + [ BlueNRGOtaAdvertiseParser() ]
        }
    }
}

extension BlueMSMainViewController : SensorTile101Delegate{
    
    public func didUploadFlowsWithBleStreamOutput(controller: SensorTile101ViewController) {
        //self.onStartDiscoveryClick(self.mNodeListButton)
    }
}
