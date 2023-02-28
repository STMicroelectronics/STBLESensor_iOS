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

fileprivate typealias DeviceID = STM32WBPeer2PeerDemoConfiguration.DeviceID

/// class containg the node status
fileprivate class DeviceStatus{
    
    let deviceId:DeviceID
    var ledStatus:Bool
    var buttonPressed:Bool
    
    init(deviceId:DeviceID,buttonPressed:Bool=false,ledStatus:Bool=false) {
        self.deviceId = deviceId
        self.buttonPressed = buttonPressed
        self.ledStatus = ledStatus
    }
}

public class STM32WBLedNetworkViewController : STM32WBRSSIUpdateViewController{
    
    fileprivate var mLedControlFeature : STM32WBControlLedFeature?
    private var mNetworkStatusFeature : STM32WBNetworkStatusFeature?
    private var mButtonStatusFeature : STM32WBSwitchStatusFeature?
    
    @IBOutlet weak var mControlAllLedSwitch: UISwitch!
    @IBOutlet weak var mInstrucitonLabel: UILabel!
    @IBOutlet weak var mDeviceStatusTableView: UITableView!
    fileprivate var mDeviceStatusList:[DeviceStatus] = []
    
    /// utility function that add this class as listener and enable the notification
    ///
    /// - Parameter feature: feature to enable
    private func enableNotification(_ feature:BlueSTSDKFeature?){
        if let feature = feature{
            feature.add(self)
            self.node.enableNotification(feature)
        }
    }

    private func enableNotifications(){
        mLedControlFeature = self.node.getFeatureOfType(STM32WBControlLedFeature.self) as? STM32WBControlLedFeature
        
        mButtonStatusFeature = self.node.getFeatureOfType(STM32WBSwitchStatusFeature.self) as?
        STM32WBSwitchStatusFeature
        enableNotification(mButtonStatusFeature)

        mNetworkStatusFeature = self.node.getFeatureOfType(STM32WBNetworkStatusFeature.self) as? STM32WBNetworkStatusFeature
        enableNotification(mNetworkStatusFeature)
        if let feature = mNetworkStatusFeature{
            self.node.read(feature)
        }
    }
    
    /// utility function that remote this class as listener and disable the notification
    ///
    /// - Parameter feature: feature to disable
    private func disableNotification(_ feature: BlueSTSDKFeature?){
        if let feature = feature{
            feature.remove(self)
            self.node.disableNotification(feature)
            Thread.sleep(forTimeInterval: 0.1)
        }
    }
    
    private func disableNotifications(){
        disableNotification(mNetworkStatusFeature)
        disableNotification(mButtonStatusFeature)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        mDeviceStatusTableView.dataSource = self;
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableNotifications()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disableNotifications()
    }
    
    /// function used to switch on and off all the leds in the connected nodes
    ///
    /// - Parameter sender: switch that trigger the event
    @IBAction func onChangeAllLedStatusChanged(_ sender: UISwitch) {
        if(sender.isOn){
            mLedControlFeature?.switchOnLed(device: .ALL)
        }else{
            mLedControlFeature?.switchOffLed(device: .ALL)
        }
        setAllLedStatusTo(newStatus: sender.isOn)
    }
    
    /// set a new led status for all the connected nodes
    ///
    /// - Parameter newStatus: new led status
    private func setAllLedStatusTo(newStatus:Bool){
        mDeviceStatusList.forEach{ $0.ledStatus = newStatus}
        mDeviceStatusTableView.reloadData()
    }

}

// MARK: - BlueSTSDKFeatureDelegate
extension STM32WBLedNetworkViewController : BlueSTSDKFeatureDelegate{

    
    /// called when a button is pressed in a remote node, change the buttom state and reload
    /// the table view
    ///
    /// - Parameters:
    ///   - feature:
    ///   - sample: data containing the new switch state
    private func didButtonStatusUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample){
        let deviceId = STM32WBSwitchStatusFeature.getDeviceSelection(sample: sample)
        let buttonStatus = STM32WBSwitchStatusFeature.getButtonPushed(sample: sample)
        if let device = deviceId{
           if let status = mDeviceStatusList.getStatusFor(device){
                status.buttonPressed = buttonStatus
           }else{
                mDeviceStatusList.append (DeviceStatus(deviceId: device,buttonPressed: buttonStatus));
           }
           DispatchQueue.main.async {
                self.mDeviceStatusTableView.reloadData()
           }
        }//if device
    }
    
    private func showInstruction(show:Bool){
        self.mInstrucitonLabel.isHidden = !show
        self.mDeviceStatusTableView.isHidden = show
        self.mControlAllLedSwitch.isEnabled = !show
    }
    
    /// called when a new node is detected from the central node
    ///
    /// - Parameters:
    ///   - feature:
    ///   - sample: data containing the status of the node in the network
    private func didNetworkStatusUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample){
        //test all the possible devices
        DeviceID.allCases.forEach{ deviceId in
            let isConnected = STM32WBNetworkStatusFeature.isDeviceConnected(sample: sample, device: deviceId)
            if(isConnected){
                if(!mDeviceStatusList.contains(deviceId:deviceId)){
                    mDeviceStatusList.append(DeviceStatus(deviceId: deviceId))
                }
            }else{
                _ = mDeviceStatusList.removeStatusFor(deviceId)
            }
        }
        DispatchQueue.main.async {
            if(!self.mDeviceStatusList.isEmpty){
                self.showInstruction(show: false)
                self.mDeviceStatusTableView.reloadData()
            }else{
                self.showInstruction(show: true)
            }
        }
    }
    
    
    /// called when a ble notification arrive, this method will call the proper method
    ///
    /// - Parameters:
    ///   - feature: <#feature description#>
    ///   - sample: <#sample description#>
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        if feature.isKind(of: STM32WBSwitchStatusFeature.self){
            return didButtonStatusUpdate(feature,sample:sample)
        }
        if feature.isKind(of: STM32WBNetworkStatusFeature.self){
            return didNetworkStatusUpdate(feature,sample:sample)
        }
        
    }
    
}


/// utilitiy function to query an array of device status using a device id
extension Array where Element:DeviceStatus{
    
    
    /// utility funcution tha return a lamda that is true when the device status
    /// has a specific device id
    ///
    /// - Parameter deviceId: device id to search
    /// - Returns: labmda returing true when the device status has the specific deviceId
    private func hasDeviceId(_ deviceId:DeviceID) -> ((DeviceStatus)->Bool){
        return { (_ status:DeviceStatus) in status.deviceId == deviceId}
    }
    
    
    /// tell if in the array there is a DeviceStatus with a specific device id
    ///
    /// - Parameter deviceId: device id to search
    /// - Returns: true if the array has a structure
    fileprivate func contains(deviceId:DeviceID)->Bool{
        return self.contains(where:hasDeviceId(deviceId))
    }
    
    
    /// get the status for a specific device id, nil if the device id is not in the array
    ///
    /// - Parameter deviceId: device id to search
    /// - Returns: status of the device with the specific device id
    fileprivate func getStatusFor(_ deviceId:DeviceID)->DeviceStatus?{
        return self.first(where: hasDeviceId(deviceId))
    }
    
    /// Remote the device status with a specific device id
    ///
    /// - Parameter deviceId: device id to remove
    /// - Returns: device status removed or nil if the deviceId doesn't exist
    fileprivate mutating func removeStatusFor(_ deviceId:DeviceID) -> DeviceStatus?{
        let deviceIndex = self.firstIndex(where:hasDeviceId(deviceId))
        if let idx = deviceIndex{
            return remove(at: idx)
        }
        return nil;
    }
}


// MARK: - UITableViewDataSource
extension STM32WBLedNetworkViewController :UITableViewDataSource{
    
    private static let CELL_ID = "STM32WBLedNodeTableViewCell"
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mDeviceStatusList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let status = mDeviceStatusList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: STM32WBLedNetworkViewController.CELL_ID)
            as? STM32WBLedNodeTableViewCell
        
        cell?.setStatus(status: status, onLedStatusChange: { newState in
            if(newState){
                self.mLedControlFeature?.switchOnLed(device: status.deviceId)
            }else{
                self.mLedControlFeature?.switchOffLed(device: status.deviceId)
            }
        })
        
        return cell!
    }
}


/// class used to manage the cell rappresenting a remote device
class STM32WBLedNodeTableViewCell : UITableViewCell{
    
    private static let DEVICE_NAME_FORMAT = {
        return  NSLocalizedString("Device Server %d",
                                  tableName: nil,
                                  bundle: Bundle(for: STM32WBLedNodeTableViewCell.self),
                                  value: "Device Server %d",
                                  comment: "Device Server %d");
    }();
    
    private static let LED_ON_IMAGE = {
        return UIImage(named: "stm32wb_led_on",
                       in: Bundle(for: STM32WBLedNodeTableViewCell.self),
                       compatibleWith: nil)
    }();
    
    private static let LED_OFF_IMAGE = {
        return UIImage(named: "stm32wb_led_off",
                       in: Bundle(for: STM32WBLedNodeTableViewCell.self),
                       compatibleWith: nil)
    }();
    
    @IBOutlet weak var mDeviceNameLabel: UILabel!
    @IBOutlet weak var mAllarmImage: UIImageView!
    @IBOutlet weak var mEnableLedSwitch: UISwitch!
    @IBOutlet weak var mLedImage: UIImageView!
    
    /// function to call when the led switch change
    private var mOnLedStatusChange: ((Bool)->())?
    
    @IBAction func onLedSwitchChange(_ sender: UISwitch) {
        mOnLedStatusChange?(sender.isOn)
        setLedImage(newState: sender.isOn)
    }
    
    /// change the led image
    ///
    /// - Parameter newState: new led status
    private func setLedImage(newState:Bool){
        if(newState){
            mLedImage.image = STM32WBLedNodeTableViewCell.LED_ON_IMAGE
        }else{
            mLedImage.image = STM32WBLedNodeTableViewCell.LED_OFF_IMAGE
        }
    }
    
    
    /// set the cell to display a specific status
    ///
    /// - Parameters:
    ///   - status: statu to display
    ///   - onLedStatusChange: function to call when the switch change its status
    fileprivate func setStatus(status:DeviceStatus, onLedStatusChange: @escaping (Bool)->() ){
        mAllarmImage.isHidden = !status.buttonPressed
        mEnableLedSwitch.isOn = status.ledStatus
        setLedImage(newState: status.ledStatus)
        mDeviceNameLabel.text = String(format: STM32WBLedNodeTableViewCell.DEVICE_NAME_FORMAT, status.deviceId.rawValue)
        mOnLedStatusChange = onLedStatusChange
    }
    
}
