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
import MBProgressHUD
import BlueSTSDK

public class BlueMSCloudConnectionViewController: UIViewController {
    private static let START_FW_UPGRADE_SEGUE = "cloudStartFwUpgrade"
    private static let SHOW_CLOUD_DATA_SEGUE = "cloudShowCloudData"
    
    /// Class to use for create the cloud connection
    var connectionFactoryBuilder: W2STCloudConfigBuildConnectionFactory!
    
    /// Node that will send the data to the cloud
    public var node: BlueSTSDKNode!
    
    /// min interval between two cloud updates
    public var minUpdateInterval: TimeInterval = 1.0
    
    @IBOutlet var mFeatureList: UITableView?
    @IBOutlet weak var mConnectButton: UIButton?
    @IBOutlet weak var mShowDataButton: UIButton?
    
    internal var mFeatureListener: BlueSTSDKFeatureDelegate?
    internal var mEnabledFeature: [BlueSTSDKFeature] = []
    internal var mKeepConnectionOpen: Bool = false
    internal var mConnectionFactory: BlueMSCloudIotConnectionFactory?
    internal var mSession: BlueMSCloudIotClient?
    internal var progressBar: MBProgressHUD?
    internal var currentAccFeatureEvent: BlueSTSDKFeatureAccelerationDetectableEventType?
    
    //private var featureWasEnabled = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        mFeatureList?.estimatedRowHeight = 64
        mFeatureList?.rowHeight = UITableView.automaticDimension
        mFeatureList?.dataSource = self
        mFeatureList?.register(UINib(nibName: "BlueMSCloudLogTableViewCell", bundle: Bundle(for: Self.self)), forCellReuseIdentifier: "BlueMSCloudLogTableViewCell")
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        manageViewDisappear()
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
    
    @IBAction
    internal func onConnectButtonPressed(_ sender: UIButton) {
        mConnectionFactory = connectionFactoryBuilder.buildConnectionFactory()
        
        guard let connectionFactory = mConnectionFactory else {
            self.showAllert(title: BlueMSCloudConnectionViewController.MISSING_PARA_DIALOG_TITLE,
                            message: BlueMSCloudConnectionViewController.MISSING_PARA_DIALOG_MSG)
            return
        }
        
        sender.isEnabled = false
        if mSession?.isConnected ?? false {
            mSession?.disconnect{ [weak self ] error in
                if error == nil {
                    self?.onDisconnectionDone()
                } else {
                    self?.onConnectionError(error!)
                }
            }
        } else { //no session or disconnect
            mSession = connectionFactory.getSession()
            progressBar = createConnectiongProgressBar()
            mSession?.connect{ [weak self] error in
                if error == nil {
                    self?.onConnectionDone()
                } else {
                    self?.onConnectionError(error!)
                }
            }
        }
    }
    
    @IBAction
    internal func onViewDataButtonPressed(_ sender: UIButton) {
        //we esplicity do the segue otherwise the new view controller will not be inserted in the navigation stack
        self.performSegue(withIdentifier: BlueMSCloudConnectionViewController.SHOW_CLOUD_DATA_SEGUE, sender: self)
    }
    
    internal func disableAllNotification() {
        guard let featureListener = mFeatureListener else { return }
        
        mEnabledFeature.forEach { f in
            f.remove(featureListener)
            node.disableNotification(f)
            Thread.sleep(forTimeInterval: 0.1)
        }
    }
    
    internal func extractEnabledFeature() -> [BlueSTSDKFeature] {
        return node.getFeatures().filter{ $0.enabled && mConnectionFactory?.isSupportedFeature($0) ?? false}
    }
    
    internal func createConnectiongProgressBar() -> MBProgressHUD {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .indeterminate
        hud.removeFromSuperViewOnHide = true
        hud.label.text = Self.CONNECTING
        return hud
    }
    
    internal func onConnectionDone() {
        guard let session = mSession else{
            return;
        }
        mFeatureListener = mConnectionFactory?.getFeatureDelegate(withSession: session, minUpdateInterval: minUpdateInterval)
        mEnabledFeature = extractEnabledFeature()
        
        _ = mConnectionFactory?.enableCloudFwUpgrade(for: node, connection: session) { fwUrl in
            DispatchQueue.main.async { [weak self] in
                self?.askForFwUpgrade(fwUrl)
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.progressBar?.hide(animated: true)
            self?.mConnectButton?.setTitle(BlueMSCloudConnectionViewController.DISCONNECT_BUTTON_LABEL, for: .normal)
            self?.mConnectButton?.isEnabled = true
            self?.mFeatureList?.reloadData()
            self?.mFeatureList?.isHidden = false
            self?.mShowDataButton?.isHidden = self?.mConnectionFactory?.getDataUrl() == nil
        }
    }
    
    internal func onDisconnectionDone() {
        disableAllNotification()
        mEnabledFeature.removeAll()
        
        DispatchQueue.main.async {
            self.mConnectButton?.setTitle(BlueMSCloudConnectionViewController.CONNECT_BUTTON_LABEL, for: .normal)
            self.mConnectButton?.isEnabled=true
            self.mFeatureList?.reloadData()
            self.mFeatureList?.isHidden=true
            self.mShowDataButton?.isHidden=true
        }
    }
    
    internal func onConnectionError(_ error: Error) {
        DispatchQueue.main.async {
            self.progressBar?.hide(animated: false)
            self.showAllert(title: BlueMSCloudConnectionViewController.CONNECTION_ERROR_TITLE, message: error.localizedDescription)
            self.mConnectButton?.setTitle(BlueMSCloudConnectionViewController.CONNECT_BUTTON_LABEL, for: .normal)
            self.mConnectButton?.isEnabled=true
        }
    }
    
    internal func askForFwUpgrade(_ fwUrl: URL) {
        let message = String(format: BlueMSCloudConnectionViewController.NEW_FW_ALERT_MESSAGE_FORMAT, fwUrl.lastPathComponent)
        let question = UIAlertController(title: BlueMSCloudConnectionViewController.NEW_FW_ALERT_TITLE, message: message, preferredStyle: .alert)
        
        question.addAction(UIAlertAction(title:BlueMSCloudConnectionViewController.NEW_FW_ALERT_YES , style: .default) { _ in
            self.performSegue(withIdentifier: BlueMSCloudConnectionViewController.START_FW_UPGRADE_SEGUE, sender: fwUrl)
        })
        question.addAction(UIAlertAction(title: BlueMSCloudConnectionViewController.NEW_FW_ALERT_NO, style: .cancel, handler: nil))
        
        self.present(question, animated: true, completion: nil)
    }
    
    internal func prepareForCloudDataViewController(_ vc: BlueMSCloudDataPageViewController) {
        vc.cloudPageUrl = mConnectionFactory?.getDataUrl()
        mKeepConnectionOpen=true
    }
    
    internal func prepareForFwUpgradeViewController(_ vc: BlueSTSDKFwUpgradeManagerViewController, _ fwUrl: URL) {
        vc.node = node;
        vc.fwRemoteUrl = fwUrl
    }
    
    internal func showEventSelector(_ feature: BlueSTSDKFeatureAccelerometerEvent) {
        var actions: [UIAlertAction] = feature.supportedTypes.map { event in
            UIAlertAction.genericButton(BlueSTSDKFeatureAccelerometerEvent.detectableEventType(toString: event)) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.toggleFeatureEvent(feature, event: event)
                }
            }
        }
        
        actions.append(UIAlertAction.cancelButton())
        
        UIAlertController.presentActionSheet(from: self, title: nil, message: nil, actions: actions)
    }
    
    internal func toggleFeatureEvent(_ feature: BlueSTSDKFeatureAccelerometerEvent, event: BlueSTSDKFeatureAccelerationDetectableEventType) {
        guard event != currentAccFeatureEvent else { return }
        
        if let currentAccFeatureEvent = currentAccFeatureEvent {
            feature.disableEvent(currentAccFeatureEvent)
        }
        if event != .eventTypeNone {
            feature.enableEvent(event)
        }
        
        currentAccFeatureEvent = event
        
        mFeatureList?.reloadData()
    }
    
    internal func setFeatureEnabled(_ feature: BlueSTSDKFeature, enabled: Bool) {
        guard let listener = mFeatureListener else { return }
        
        if enabled {
            feature.add(listener)
            self.node.enableNotification(feature)
        } else {
            feature.remove(listener)
            self.node.disableNotification(feature)
            Thread.sleep(forTimeInterval: 0.1)
        }
    }
    
    internal func manageViewDisappear() {
        if let session = mSession, mKeepConnectionOpen == false  {
            if(session.isConnected) {
                disableAllNotification()
                session.disconnect(nil)
            }
        }
        
        //next time close the conneciton
        mKeepConnectionOpen=false
    }
}

extension BlueMSCloudConnectionViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mEnabledFeature.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BlueMSCloudFeatureTableViewCell = tableView.dequeueReusableCell(withIdentifier: "BlueMSCloudLogTableViewCell", for: indexPath) as! BlueMSCloudFeatureTableViewCell
        let feature = mEnabledFeature[indexPath.row]
        let isSelected = node.isEnableNotification(feature)
        
        cell.setFeature(feature, isSelected: isSelected)
        cell.onFeatureIsSelected = { [weak self] feature, isSelected in
            self?.setFeatureEnabled(feature, enabled: isSelected)
        }
        
        if let feature = feature as? BlueSTSDKFeatureAccelerometerEvent {
            cell.setEvents(feature.supportedTypes, selectedEvent: currentAccFeatureEvent)
            cell.wantChooseEvent = { [weak self] in
                self?.showEventSelector(feature)
            }
        }
        
        return cell
    }
}
