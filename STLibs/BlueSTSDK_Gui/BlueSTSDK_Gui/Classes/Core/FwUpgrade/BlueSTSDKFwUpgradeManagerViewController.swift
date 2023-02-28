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
import UIKit
import MBProgressHUD
 
public class BlueSTSDKFwUpgradeManagerViewController: UIViewController{
    
    
    /// instanziate a View controller to upload a new fw on the board
    ///
    /// - Parameters:
    ///   - node: node where upload the board
    ///   - requireAddress: true if the use has to insert an address where upload the firmware
    ///   - defaultAddress: default address where load the fw
    ///   - fwRemoteUrl: if present the fw will be dowloaded from this url
    /// - Returns: BlueSTSDKFwUpgradeManagerViewController instance
    public static func instaziate(forNode node:BlueSTSDKNode,
                                  requireAddress:Bool,
                                  defaultAddress:UInt32?=nil,
                                  requireFwType:Bool = false,
                                  defaultFwType:BlueSTSDKFwUpgradeType = .applicationFirmware,
                                  fwRemoteUrl:URL?=nil,
                                  fwLocalUrl:URL?=nil)
            ->BlueSTSDKFwUpgradeManagerViewController{
                
        let storyBoard = UIStoryboard(name: "FwUpgrade", bundle: BlueSTSDK_Gui.bundle())
        
        let fwUpgradeController = storyBoard.instantiateInitialViewController() as! BlueSTSDKFwUpgradeManagerViewController
        
        fwUpgradeController.node=node
        
        fwUpgradeController.requireAddress=requireAddress
        fwUpgradeController.defaultAddress=defaultAddress
  
        fwUpgradeController.requireFwType = requireFwType
        fwUpgradeController.defaultFwType = defaultFwType

        fwUpgradeController.fwRemoteUrl = fwRemoteUrl
        fwUpgradeController.fwLocalUrl = fwLocalUrl

        return fwUpgradeController;
    }
    
    public static func instaziate(forNode node:BlueSTSDKNode,
                                  fwRemoteUrl:URL)
        ->BlueSTSDKFwUpgradeManagerViewController{
            return instaziate(forNode: node, requireAddress: false, defaultAddress: nil, requireFwType: false, defaultFwType: .applicationFirmware, fwRemoteUrl: fwRemoteUrl)
    }
    
    private static let ERROR_TITLE_MSG:String = {
        let bundle = Bundle(for: BlueSTSDKFwUpgradeManagerViewController.self);
        return NSLocalizedString("Error", tableName: nil,
                                 bundle: bundle,
                                 value: "Error",
                                 comment: "Error");
    }();
    
    private static let ERROR_ADDRESS_RANGE_FORMAT:String = {
        let bundle = Bundle(for: BlueSTSDKFwUpgradeManagerViewController.self);
        return NSLocalizedString("The address is not in the range: [0x%x,0x%x]", tableName: nil,
                                 bundle: bundle,
                                 value: "The address is not in the range: [0x%x,0x%x]",
                                 comment: "The address is not in the range: [0x%x,0x%x]");
    }();

    private static let WARNING_TITLE_MSG:String = {
        let bundle = Bundle(for: BlueSTSDKFwUpgradeManagerViewController.self);
        return NSLocalizedString("Warning", tableName: nil,
                                 bundle: bundle,
                                 value: "Warning",
                                 comment: "Warning");
    }();
    
    private static let WARNING_ADDRESS_START_NOT_MULTIPLE:String = {
        let bundle = Bundle(for: BlueSTSDKFwUpgradeManagerViewController.self);
        return NSLocalizedString("The address should be multiple of 0x1000", tableName: nil,
                                 bundle: bundle,
                                 value: "The address should be multiple of 0x1000",
                                 comment: "The address should be multiple of 0x1000");
    }();

    
    private static let FW_UPGRADE_NOT_AVAILABLE_ERR:String = {
        let bundle = Bundle(for: BlueSTSDKFwUpgradeManagerViewController.self);
        return NSLocalizedString("Firmware upgrade not available", tableName: nil,
                                 bundle: bundle,
                                 value: "Firmware upgrade not available",
                                 comment: "Firmware upgrade not available");
    }();
    
    static let FW_UPGRADE_NOT_SUPPORTED_ERR:String = {
        let bundle = Bundle(for: BlueSTSDKFwUpgradeManagerViewController.self);
        return NSLocalizedString("Firmware upgrade not supported, please upgrade the firmware", tableName: nil,
                                 bundle: bundle,
                                 value: "Firmware upgrade not supported, please upgrade the firmware",
                                 comment: "Firmware upgrade not supported, please upgrade the firmware");
    }();
    
    static let FORMATTING_MSG:String = {
        let bundle = Bundle(for: BlueSTSDKFwUpgradeManagerViewController.self);
        return NSLocalizedString("Formatting...", tableName: nil,
                                 bundle: bundle,
                                 value: "Formatting...",
                                 comment: "Formatting...");
    }();
    
    static let MIN_VERSION = [
      BlueSTSDKFwVersion(name: "BLUEMICROSYSTEM2", mcuType: nil, major: 2, minor: 0, patch: 1)
    ];
    
    
    static let READ_VERSION:String = {
        let bundle = Bundle(for: BlueSTSDKFwUpgradeManagerViewController.self);
        return NSLocalizedString("Reading firmware version", tableName: nil,
                                 bundle: bundle,
                                 value: "Reading firmware version",
                                 comment: "Reading firmware version");
    }();
    
    private static func checkOldVersion(version:BlueSTSDKFwVersion)->Bool{
        
        for v in MIN_VERSION {
            if(v.name == version.name){
                if(v.compare(version) == .orderedDescending){
                    return true;
                }
            }
        }
        return false;
    }
    
    @IBOutlet weak var mBoardFwNameLabel: UILabel!
    @IBOutlet weak var mFwVersionLabel: UILabel!
    @IBOutlet weak var mFwTypeLabel: UILabel!

    @IBOutlet weak var mConfigView: UIStackView!
    @IBOutlet weak var mUploadView: UIView!
    @IBOutlet weak var mUploadProgressView: UIProgressView!
    @IBOutlet weak var mUploadProgressLabel: UILabel!
    @IBOutlet weak var mUploadStatusProgress: UILabel!
   
    @IBOutlet weak var mSelectFileButton: UIBarButtonItem!

    @IBOutlet weak var mAddressView: UIStackView!
    @IBOutlet weak var mAddressText: UITextField!
    
    @IBOutlet weak var mFwTypeView: UIStackView!
    @IBOutlet weak var mFwTypeSelector: UISegmentedControl!
    @IBOutlet weak var mBoardTypeSelector: UISegmentedControl!
    
    @IBOutlet weak var selectFileFlashButton: UIButton!
    
    private var boardTypeSelected = 1
    
    @IBAction func mBoardTypeSelected(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            boardTypeSelected = 1
        case 1:
            boardTypeSelected = 2
        default:
            return
        }
    }
    
    
    public var node:BlueSTSDKNode?
    public var fwRemoteUrl:URL?
    public var fwLocalUrl:URL?
    
    public var requireAddress:Bool=false
    public var defaultAddress:UInt32?=nil
    
    public var requireFwType:Bool=false
    public var defaultFwType:BlueSTSDKFwUpgradeType = .applicationFirmware
    
    private var mCurrentFwVersion:BlueSTSDKFwVersion? = nil
    private var mLoadVersionHud:MBProgressHUD? = nil
    private var mFwUpgradeConsole:BlueSTSDKFwUpgradeConsole? = nil
    private var mReadVersionConsole:BlueSTSDKFwReadVersionConsole? = nil
    private var mProgresViewController:BlueSTSDKFwUpgradeProgressViewController!
    private var mDownloadProgressViewController:BlueSTSDKDownloadFileViewController!
    
    //Memory Addreess for WB FwUpdate
    private static let MIN_MEMORY_ADDRESS: [Int] = [0x00, 0x7000, 0x7000] //Undef, WB, WB15
    private static let MAX_MEMORY_ADDRESS: [Int] = [0x00, 0x089000, 0x01C000] //Undef, WB, WB15
    private static let WB_SECTOR_SIZE: [Int] = [0x00, 0x1000, 0x800] //Undef, WB, WB15
    
    private func showHud(){
        mLoadVersionHud = MBProgressHUD.showAdded(to: self.view, animated: true)
        mLoadVersionHud?.mode = .indeterminate
        mLoadVersionHud?.removeFromSuperViewOnHide=true
        mLoadVersionHud?.label.text = BlueSTSDKFwUpgradeManagerViewController.READ_VERSION
    }

    private func setRightBarButton(){
        //we set also in the parent in the case the vc is used inside another view controller
        // like the DemoViewController
        //parent?.navigationItem.rightBarButtonItem = mSelectFileButton
        //navigationItem.rightBarButtonItem = mSelectFileButton
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        setRightBarButton()
        mProgresViewController =
            BlueSTSDKFwUpgradeProgressViewController(progressLabel: mUploadProgressLabel,
                                                     statusLabel: mUploadStatusProgress,
                                                     progressView: mUploadProgressView)
        mProgresViewController.mFwUploadDelegate=self;
        mDownloadProgressViewController =
            BlueSTSDKDownloadFileViewController(progressLabel: mUploadProgressLabel,
                                                 statusLabel: mUploadStatusProgress,
                                                 progressView: mUploadProgressView)
        
        //If ASTRA or PROTEUS or STSYS_SBU06 fix the WB Board Type Selector to first option
        if(node?.type == BlueSTSDKNodeType.POLARIS || node?.type == BlueSTSDKNodeType.PROTEUS || node?.type == BlueSTSDKNodeType.STSYS_SBU06){
            mBoardTypeSelector.isEnabled = false
        }
        
    }
    
    private func loadFwVersion(){
        if(mCurrentFwVersion == nil){
            _ = mReadVersionConsole?.readFwVersion{ [weak self] version in
                guard let self = self else{
                    return
                }
                self.mCurrentFwVersion = version
                self.onFwVersionRead(version)
                self.mFwUpgradeConsole = BlueSTSDKFwConsoleUtil.getFwUploadConsoleForNode(node: self.node, version:version)
            }
        }else{
            onFwVersionRead(mCurrentFwVersion)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        showHud();
        mReadVersionConsole = BlueSTSDKFwConsoleUtil.getFwReadVersionConsoleForNode(node: self.node)
        loadFwVersion()
        
        mAddressView.isHidden = !requireAddress
        if let address = defaultAddress{
            mAddressText.text = String(format:"%X",address)
        }
        
        //If Memory Address stackView is hidden, hidden also BoardTypeSelector
        if(mAddressView.isHidden){
            mBoardTypeSelector.isHidden = true
        }
        
        mFwTypeView.isHidden = !requireFwType
        mFwTypeSelector.selectedFwType = defaultFwType
        //avoid the system to go idle, since we are using the ble to send the data
        //when the system go in idle the ble transfers are suspended
        UIApplication.shared.isIdleTimerDisabled=true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.isIdleTimerDisabled=false
    }
    
    @IBAction func onSelectButtonFilePressed(_ sender: UIButton) {
        guard  hasValidFlashAddress() else {
            let msg = String(format: BlueSTSDKFwUpgradeManagerViewController.ERROR_ADDRESS_RANGE_FORMAT,
                             mFwUpgradeConsole?.validAddressRange.lowerBound ?? UInt32.min,
                             mFwUpgradeConsole?.validAddressRange.upperBound ?? UInt32.max)
            showAllert(title: BlueSTSDKFwUpgradeManagerViewController.ERROR_TITLE_MSG,
                       message: msg)
            return;
        }
        if let userAddress = UInt32(mAddressText.text ?? "", radix: 16){
            defaultAddress = userAddress
        }
        
        
        
        let docPicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
        docPicker.delegate = self
        //docPicker.popoverPresentationController?.barButtonItem=sender
        present(docPicker, animated: true, completion: nil)
    }
    @IBAction func onSelectFileButtonPress(_ sender: UIBarButtonItem) {
        /*guard  hasValidFlashAddress() else {
            let msg = String(format: BlueSTSDKFwUpgradeManagerViewController.ERROR_ADDRESS_RANGE_FORMAT,
                             mFwUpgradeConsole?.validAddressRange.lowerBound ?? UInt32.min,
                             mFwUpgradeConsole?.validAddressRange.upperBound ?? UInt32.max)
            showAllert(title: BlueSTSDKFwUpgradeManagerViewController.ERROR_TITLE_MSG,
                       message: msg)
            return;
        }
        if let userAddress = UInt32(mAddressText.text ?? "", radix: 16){
            defaultAddress = userAddress
        }
        
        
        
        let docPicker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
        docPicker.delegate = self
        docPicker.popoverPresentationController?.barButtonItem=sender
        present(docPicker, animated: true, completion: nil)*/
    }
    
    private func hasValidFlashAddress()->Bool{
        //if address is not required return true
        guard requireAddress == true else {
            return true;
        }
        
        if let text = mAddressText.text,
           let address = UInt32(text, radix: 16){
                if(mAddressView.isHidden){
                    //Conditions for WB Fw Upgrade - Check Range Memory Address
                    if(address >= BlueSTSDKFwUpgradeManagerViewController.MIN_MEMORY_ADDRESS[boardTypeSelected] && address <= BlueSTSDKFwUpgradeManagerViewController.MAX_MEMORY_ADDRESS[boardTypeSelected]){
                                return mFwUpgradeConsole?.validAddressRange.contains(address) ?? false
                            }else{
                                return false
                            }
                }else{
                    //Conditions for Debug Console Fw Upgrade
                    return mFwUpgradeConsole?.validAddressRange.contains(address) ?? false
                }
            }else{
                return false
            }
    }
    
    private func getFwAddress() -> UInt32?{
        let addressStr = mAddressText.text
        let address = UInt32((addressStr ?? "0"), radix: 16)

        if !(address==nil){
            if !(address==0){
                return max(UInt32(BlueSTSDKFwUpgradeManagerViewController.MIN_MEMORY_ADDRESS[boardTypeSelected]), min(address!, UInt32(BlueSTSDKFwUpgradeManagerViewController.MAX_MEMORY_ADDRESS[boardTypeSelected])))
            }
        }

        return nil

    }
    
    fileprivate func startFwUpgrade(firmware: URL){
        if(mAddressView.isHidden){
            //START Debug Console Fw Upgrade
            //onSelectFileButtonPress has check that is a valid address
            DispatchQueue.main.async{
                Thread.sleep(forTimeInterval: 1)
                self.mUploadView.isHidden=false
                self.mUploadStatusProgress.text = BlueSTSDKFwUpgradeManagerViewController.FORMATTING_MSG
                let address = self.defaultAddress != nil ? UInt32(self.defaultAddress!) : nil
                let fwType = self.mFwTypeSelector.selectedFwType
                DispatchQueue.global(qos: .background).async {
                    _ = self.mFwUpgradeConsole?.loadFwFile(type:fwType,
                                                           file:firmware,
                                                           delegate: self.mProgresViewController,
                                                           address: address)
                }
                
            }
        }else{
            //START WB Fw Upgrade
            let address = getFwAddress()
            if !(address==nil){
                //onSelectFileButtonPress has check that is a valid address
                DispatchQueue.main.async{
                    self.mUploadView.isHidden=false
                    self.mUploadStatusProgress.text = BlueSTSDKFwUpgradeManagerViewController.FORMATTING_MSG
                    //let address = self.defaultAddress != nil ? UInt32(self.defaultAddress!) : nil
                    let fwType = self.mFwTypeSelector.selectedFwType
                    DispatchQueue.global(qos: .background).async {
                        _ = self.mFwUpgradeConsole?.loadFwFile(type:fwType,
                                                               file:firmware,
                                                               delegate: self.mProgresViewController,
                                                               address: address!)
                    }

                }
            }
        }
    }
    
    private func onFwVersionRead(_ version: BlueSTSDKFwVersion?){
        DispatchQueue.main.async {
            self.mLoadVersionHud?.hide(animated: true);
            self.mLoadVersionHud=nil
            
            guard version != nil else{
                self.showAllert(title: BlueSTSDKFwUpgradeManagerViewController.ERROR_TITLE_MSG,
                                message: BlueSTSDKFwUpgradeManagerViewController.FW_UPGRADE_NOT_AVAILABLE_ERR,
                                  closeController: true)
                return
            }
            
            self.mBoardFwNameLabel.text = version?.name;
            self.mFwTypeLabel.text = version?.mcuType;
            self.mFwVersionLabel.text = version?.getNumberStr();
            if(BlueSTSDKFwUpgradeManagerViewController.checkOldVersion(version: version!)){
                self.showAllert(title: BlueSTSDKFwUpgradeManagerViewController.ERROR_TITLE_MSG,
                                message: BlueSTSDKFwUpgradeManagerViewController.FW_UPGRADE_NOT_SUPPORTED_ERR,
                                closeController: true)
            }else{
                self.mSelectFileButton.isEnabled=true
            }
            
            if let url = self.fwRemoteUrl{
                self.mUploadView.isHidden=false;
                self.mDownloadProgressViewController.downloadFile(url: url, onComplete: {
                    self.startFwUpgrade(firmware:  $0)
                })
            }
            
            if let url = self.fwLocalUrl{
                self.mUploadView.isHidden=false;
                self.selectFileFlashButton.isHidden = true
                self.startFwUpgrade(firmware: self.fwLocalUrl!)
            }
        }       
    }

}
 
 extension BlueSTSDKFwUpgradeManagerViewController :UIDocumentPickerDelegate{
    public func documentPicker(_ pickController:UIDocumentPickerViewController, didPickDocumentsAt urls:[URL]){
        if let selectedFile = urls.first{
            startFwUpgrade(firmware: selectedFile)
        }
    }
    
    public func documentPicker(_ pickController:UIDocumentPickerViewController, didPickDocumentAt url:URL){
        startFwUpgrade(firmware: url)
    }
    
 }
 
 
 extension BlueSTSDKFwUpgradeManagerViewController : BlueSTSDKFwUpgradeConsoleCallback{
    
    static let UPLOAD_COMPLETE_TITLE:String = {
        let bundle = Bundle(for: BlueSTSDKFwUpgradeManagerViewController.self);
        return NSLocalizedString("Upgrade completed", tableName: nil,
                                 bundle: bundle,
                                 value: "Upgrade completed",
                                 comment: "Upgrade completed");
    }();
    
    static let UPLOAD_COMPLETE_CONTENT:String = {
        let bundle = Bundle(for: BlueSTSDKFwUpgradeManagerViewController.self);
        return NSLocalizedString("The board is resetting", tableName: nil,
                                 bundle: bundle,
                                 value: "The board is resetting",
                                 comment: "The board is resetting");
    }();
    
    public func onLoadComplite(file: URL) {
        DispatchQueue.main.async {
            self.showAllert(title: BlueSTSDKFwUpgradeManagerViewController.UPLOAD_COMPLETE_TITLE,
                            message: BlueSTSDKFwUpgradeManagerViewController.UPLOAD_COMPLETE_CONTENT,
                            closeController: true)
        }
    }
    
    public func onLoadError(file: URL, error: BlueSTSDKFwUpgradeError) {
        
    }
    
    public func onLoadProgres(file: URL, remainingBytes: UInt) {
        
    }
    
    
 
 }

 fileprivate extension UISegmentedControl{
    
    var selectedFwType:BlueSTSDKFwUpgradeType{
        get{
            return self.selectedSegmentIndex == 0 ? .applicationFirmware : .radioFirmware
        }
        set( newValue){
            switch newValue {
                case .applicationFirmware:
                    self.selectedSegmentIndex = 0
                case .radioFirmware:
                    self.selectedSegmentIndex = 1
            }
        }
    }
    
 }
