/*
 * Copyright (c) 2018  STMicroelectronics – All rights reserved
 * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list of conditions
 *   and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice, this list of
 *   conditions and the following disclaimer in the documentation and/or other materials provided
 *   with the distribution.
 *
 * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
 *   STMicroelectronics company nor the names of its contributors may be used to endorse or
 *   promote products derived from this software without specific prior written permission.
 *
 * - All of the icons, pictures, logos and other images that are provided with the source code
 *   in a directory whose title begins with st_images may only be used for internal purposes and
 *   shall not be redistributed to any third party or modified in any way.
 *
 * - Any redistributions in binary form shall not include the capability to display any of the
 *   icons, pictures, logos and other images that are provided with the source code in a directory
 *   whose title begins with st_images.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 */

import Foundation
import BlueSTSDK
import BlueSTSDK_Gui
import MBProgressHUD

/// View controller with a progress bar while searching the ota node,
/// when the node is found we connect and move to the fw upgrade view controller
public class BlueSTSDKSeachOtaNodeViewController : UIViewController{
    
    
    /// instantiate the view controller
    ///
    /// - Parameters:
    ///   - nodeAddress: mac address of the node where load the firmware, if not present the first ota node will be selected
    ///   - addressWhereFlash: address where the firmware will be loaded
    /// - Returns: <#return value description#>
    public static func instanziate(nodeAddress:String?=nil,
                                   addressWhereFlash:UInt32?=nil,
                                   fwType:BlueSTSDKFwUpgradeType = .applicationFirmware)
        ->BlueSTSDKSeachOtaNodeViewController{
        
            let storyBoard = UIStoryboard(name: "STM32WBOta", bundle: BlueSTSDK_Gui.bundle())
        
        let seachOtaController = storyBoard.instantiateViewController(withIdentifier: "BlueSTSDKSeachOtaNodeViewController") as! BlueSTSDKSeachOtaNodeViewController
        
        seachOtaController.addressWhereFlash = addressWhereFlash
        seachOtaController.nodeAddressToSearch = nodeAddress
        seachOtaController.fwType = fwType
        
        return seachOtaController;
    }
    
    private static let BLE_SCAN_TIMEOUT_MS = 10*1000
    
    private static let SEARCH_MESSAGE:String = {
        let bundle = Bundle(for: BlueSTSDKStartOtaConfigViewController.self);
        return NSLocalizedString("Searching for OTA Node...", tableName: nil,
                                 bundle: bundle,
                                 value: "Searching for OTA Node...",
                                 comment: "Searching for OTA Node...");
    }();
    
    private static let ERROR_TITLE:String = {
        let bundle = Bundle(for: BlueSTSDKStartOtaConfigViewController.self);
        return NSLocalizedString("Error", tableName: nil,
                                 bundle: bundle,
                                 value: "Error",
                                 comment: "Error");
    }();
    
    private static let ERROR_CONNECTING:String = {
        let bundle = Bundle(for: BlueSTSDKStartOtaConfigViewController.self);
        return NSLocalizedString("Error during the connection", tableName: nil,
                                 bundle: bundle,
                                 value: "Error during the connection",
                                 comment: "Error during the connection");
    }();
    
    private static let CONNECTING:String = {
        let bundle = Bundle(for: BlueSTSDKStartOtaConfigViewController.self);
        return NSLocalizedString("Connecting...", tableName: nil,
                                 bundle: bundle,
                                 value: "Connecting...",
                                 comment: "Connecting...");
    }();
    
    private static let NODE_NOT_FOUND:String = {
        let bundle = Bundle(for: BlueSTSDKStartOtaConfigViewController.self);
        return NSLocalizedString("OTA node not found", tableName: nil,
                                 bundle: bundle,
                                 value: "OTA node not found",
                                 comment: "OTA node not found");
    }();
    
    
    private var mProgressDialog:MBProgressHUD?
    public var addressWhereFlash:UInt32?
    public var nodeAddressToSearch:String?
    public var fwType:BlueSTSDKFwUpgradeType!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        mProgressDialog = MBProgressHUD.showAdded(to: self.view, animated: true);
        mProgressDialog?.mode = .indeterminate;
        mProgressDialog?.removeFromSuperViewOnHide=true;
        mProgressDialog?.label.text = BlueSTSDKSeachOtaNodeViewController.SEARCH_MESSAGE;
    }
    
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let bleManager = BlueSTSDKManager.sharedInstance
        bleManager.addDelegate(self)
        bleManager.resetDiscovery()
        bleManager.discoveryStart(BlueSTSDKSeachOtaNodeViewController.BLE_SCAN_TIMEOUT_MS)
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let bleManager = BlueSTSDKManager.sharedInstance
        bleManager.removeDelegate(self)
        bleManager.discoveryStop()
    }
    
    fileprivate func moveToFwUpgrade(node:BlueSTSDKNode){
        DispatchQueue.main.async {
            let vc = BlueSTSDKFwUpgradeManagerViewController.instaziate(forNode: node,
                                                               requireAddress: true,
                                                               defaultAddress: self.addressWhereFlash,
                                                               requireFwType:true,
                                                               defaultFwType:self.fwType)
            self.replaceViewController(vc,animated: false)
            
        }
    }
    
}


// MARK: -BlueSTSDKManagerDelegate
/// manager delegate, used to filter out the 
extension BlueSTSDKSeachOtaNodeViewController : BlueSTSDKManagerDelegate{
    
    public func manager(_ manager: BlueSTSDKManager, didDiscoverNode node: BlueSTSDKNode) {
        if(BlueSTSDKSTM32WBOTAUtils.isOTANode(node)){
            if nodeAddressToSearch == nil ||
                nodeAddressToSearch! == node.address{
                manager.removeDelegate(self)
                node.addExternalCharacteristics(BlueSTSDKSTM32WBOTAUtils.getOtaCharacteristics())
                node.addStatusDelegate(self)
                DispatchQueue.main.async {
                    self.mProgressDialog?.label.text = BlueSTSDKSeachOtaNodeViewController.CONNECTING
                }
                node.connect()
            }
        }
    }
    
    public func manager(_ manager: BlueSTSDKManager, didChangeDiscovery enable: Bool) {
        if(enable==false){
            DispatchQueue.main.async {
                self.mProgressDialog?.isHidden=true
                self.showAllert(title: BlueSTSDKSeachOtaNodeViewController.ERROR_TITLE,
                                message: BlueSTSDKSeachOtaNodeViewController.NODE_NOT_FOUND,
                                closeController: true)
            }
        }
    }
}


extension BlueSTSDKSeachOtaNodeViewController : BlueSTSDKNodeStateDelegate{
    public func node(_ node: BlueSTSDKNode, didChange newState: BlueSTSDKNodeState,
                     prevState: BlueSTSDKNodeState) {
        if(newState == .connected){
            node.removeStatusDelegate(self)
            DispatchQueue.main.async {
                self.moveToFwUpgrade(node: node)
            }
        }
        if(newState == .dead || newState == .unreachable){
            DispatchQueue.main.async {
                self.mProgressDialog?.isHidden=true
                self.showAllert(title: BlueSTSDKSeachOtaNodeViewController.ERROR_TITLE,
                                message: BlueSTSDKSeachOtaNodeViewController.ERROR_CONNECTING,
                                closeController: true)
            }
        }
    }
}
