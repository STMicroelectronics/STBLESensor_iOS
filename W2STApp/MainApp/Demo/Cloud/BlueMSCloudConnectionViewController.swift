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

public class BlueMSCloudConnectionViewController : UIViewController{
    
    private static let START_FW_UPGRADE_SEGUE = "cloudStartFwUpgrade"
    private static let SHOW_CLOUD_DATA_SEGUE = "cloudShowCloudData"
    
    private static let MISSING_PARA_DIALOG_TITLE = {
        return  NSLocalizedString("Error",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                  value: "Error",
                                  comment: "Error");
    }();
    
    private static let MISSING_PARA_DIALOG_MSG = {
        return  NSLocalizedString("Invalid connection parameters",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                  value: "Invalid connection parameters",
                                  comment: "Invalid connection parameters");
    }();
    
    private static let DISCONNECT_BUTTON_LABEL = {
        return  NSLocalizedString("Disconnect",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                  value: "Disconnect",
                                  comment: "Disconnect");
    }();
    
    private static let CONNECT_BUTTON_LABEL = {
        return  NSLocalizedString("Connect",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                  value: "Connect",
                                  comment: "Connect");
    }();
    
    private static let CONNECTION_ERROR_TITLE = {
        return  NSLocalizedString("Connection Error",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                  value: "Connection Error",
                                  comment: "Connection Error");
    }();
    
    /// Class to use for create the cloud connection
    var connectionFactoryBuilder:W2STCloudConfigBuildConnectionFactory!
    
    /// Node that will send the data to the cloud
    public var node:BlueSTSDKNode!
    
    /// min interval between two cloud updates
     public var minUpdateInterval:TimeInterval! = 1.0
    
    @IBOutlet weak var mFeatureList: UITableView!
    
    @IBOutlet weak var mConnectButton: UIButton!
    
    @IBOutlet weak var mShowDataButton: UIButton!
    
    @IBAction func onViewDataButtonPressed(_ sender: UIButton) {
        //we esplicity do the segue otherwise the new view controller will not be inserted in the navigation stack
        self.performSegue(withIdentifier: BlueMSCloudConnectionViewController.SHOW_CLOUD_DATA_SEGUE, sender: self)
    }
    
    private var mFeatureListener : BlueSTSDKFeatureDelegate?
    private var mEnabledFeature : [BlueSTSDKFeature] = []
    private var mKeepConnectionOpen: Bool = false
    private var mConnectionFactory:BlueMSCloudIotConnectionFactory?
    private var mSession:BlueMSCloudIotClient?

    public override func viewDidLoad() {
        super.viewDidLoad()
        mFeatureList.dataSource = self;
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let session = mSession, mKeepConnectionOpen == false  {
            if(session.isConnected){
                disableAllNotification()
                session.disconnect(nil)
            }
        }
        //next time close the conneciton
        mKeepConnectionOpen=false;
    }
    
    private func disableAllNotification(){
        guard let featureListener = mFeatureListener else{
            return
        }
        mEnabledFeature.forEach{ f in
            f.remove(featureListener)
            node.disableNotification(f)
        }
    }
    
    private func extractEnabledFeature() -> [BlueSTSDKFeature]{
       return node.getFeatures()
            .filter{ $0.enabled && mConnectionFactory?.isSupportedFeature($0) ?? false}
    }
  
    
    @IBAction func onConnectButtonPressed(_ sender: UIButton) {
        mConnectionFactory = connectionFactoryBuilder.buildConnectionFactory();
        guard let connectionFactory = mConnectionFactory else {
            self.showAllert(title: BlueMSCloudConnectionViewController.MISSING_PARA_DIALOG_TITLE,
                            message: BlueMSCloudConnectionViewController.MISSING_PARA_DIALOG_MSG)
            return
        }
        
        sender.isEnabled = false
        if( mSession?.isConnected ?? false){
            mSession?.disconnect{ [weak self ] error in
                if(error == nil){
                    self?.onDisconnectionDone()
                }else{
                    self?.onConnectionError(error!)
                }
            }//disconnect
        }else{ //no session or disconnect
            mSession = connectionFactory.getSession()
            mSession?.connect{ [weak self] error in
                if( error == nil){
                    self?.onConnectionDone()
                }else{
                    self?.onConnectionError(error!)
                }
            }//connect
        }//if-else
    }
    
    private func onConnectionDone(){
        guard let session = mSession else{
            return;
        }
        mFeatureListener = mConnectionFactory?.getFeatureDelegate(withSession: session, minUpdateInterval: minUpdateInterval)
        mEnabledFeature = extractEnabledFeature()
  
        _ = mConnectionFactory?.enableCloudFwUpgrade(for: node, connection: session){ fwUrl in
            DispatchQueue.main.async {
                self.askForFwUpgrade(fwUrl)
            }
        }
        
        DispatchQueue.main.async {
            self.mConnectButton.setTitle(BlueMSCloudConnectionViewController.DISCONNECT_BUTTON_LABEL, for: .normal)
            self.mConnectButton.isEnabled=true
            self.mFeatureList.reloadData()
            self.mFeatureList.isHidden=false
            self.mShowDataButton.isHidden = self.mConnectionFactory?.getDataUrl() == nil
        }
    }
    private func onDisconnectionDone(){
        disableAllNotification()
        mEnabledFeature.removeAll()
        DispatchQueue.main.async {
            self.mConnectButton.setTitle(BlueMSCloudConnectionViewController.CONNECT_BUTTON_LABEL, for: .normal)
            self.mConnectButton.isEnabled=true
            self.mFeatureList.reloadData()
            self.mFeatureList.isHidden=true
            self.mShowDataButton.isHidden=true
        }
    }
    
    private func onConnectionError(_ error:Error){
        DispatchQueue.main.async {
            self.showAllert(title: BlueMSCloudConnectionViewController.CONNECTION_ERROR_TITLE,
                            message: error.localizedDescription)
        }
    }
    
    private static let NEW_FW_ALERT_TITLE = {
        return  NSLocalizedString("New Firmware",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                  value: "New Firmware",
                                  comment: "New Firmware");
    }();
    
    private static let NEW_FW_ALERT_MESSAGE_FORMAT = {
        return  NSLocalizedString("New firmware available.\nUpgrade to %@?",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                  value: "New firmware available.\nUpgrade to %@?",
                                  comment: "New firmware available.\nUpgrade to %@?");
    }();
    
    private static let NEW_FW_ALERT_YES = {
        return  NSLocalizedString("Yes",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                  value: "Yes",
                                  comment: "Yes");
    }();
    
    private static let NEW_FW_ALERT_NO = {
        return  NSLocalizedString("No",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                  value: "No",
                                  comment: "No");
    }();
    
    private func askForFwUpgrade(_ fwUrl : URL){
        let message = String(format: BlueMSCloudConnectionViewController.NEW_FW_ALERT_MESSAGE_FORMAT,
                             fwUrl.lastPathComponent)
        let question = UIAlertController(title: BlueMSCloudConnectionViewController.NEW_FW_ALERT_TITLE,
                                         message: message, preferredStyle: .alert)
        
        let upgrade = UIAlertAction(title:BlueMSCloudConnectionViewController.NEW_FW_ALERT_YES , style: .default){ _ in
                self.performSegue(withIdentifier: BlueMSCloudConnectionViewController.START_FW_UPGRADE_SEGUE, sender: fwUrl)
        }
        
        question.addAction(upgrade)
        question.addAction(UIAlertAction(title: BlueMSCloudConnectionViewController.NEW_FW_ALERT_NO,
                                         style: .cancel, handler: nil))

        self.present(question, animated: true, completion: nil)
    }
    
    private func prepareForCloudDataViewController(_ vc: BlueMSCloudDataPageViewController){
        vc.cloudPageUrl = mConnectionFactory?.getDataUrl()
        mKeepConnectionOpen=true
    }
    
    private func prepareForFwUpgradeViewController(_ vc: BlueSTSDKFwUpgradeManagerViewController, _ fwUrl:URL){
        vc.node = node;
        vc.fwRemoteUrl = fwUrl
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? BlueMSCloudDataPageViewController{
            prepareForCloudDataViewController(destination)
        }
        
        if let destination = segue.destination as? BlueSTSDKFwUpgradeManagerViewController,
            let fwUrl = sender as? URL{
            prepareForFwUpgradeViewController(destination,fwUrl)
        }
    }
    
 }
 
 extension BlueMSCloudConnectionViewController : UITableViewDataSource{
    private static let cellTableIdentifier = "BlueMSCloudLogTableViewCell"

    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mEnabledFeature.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BlueMSCloudConnectionViewController.cellTableIdentifier) as?
            BlueMSCloudFeatureTableViewCell
        cell?.onFeatureIsSelected = { feature, isSelected in
            guard let listener = self.mFeatureListener else{
                return
            }
            if(isSelected){
                feature.add(listener)
                self.node.enableNotification(feature)
            }else{
                feature.remove(listener)
                self.node.disableNotification(feature)
            }//if-else
        }//onFeatureIsSelected
        
        let feature = mEnabledFeature[indexPath.row]
        let isSelected = node.isEnableNotification(feature)
        cell?.setFeature(feature, isSelected: isSelected)
        
        return cell!
    }
    
 }
