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

/// View Controller to switch on and off a led in a specific node
public class STM32WBLedButtonViewController : STM32WBRSSIUpdateViewController{
    
    fileprivate typealias DeviceID = STM32WBPeer2PeerDemoConfiguration.DeviceID
    
    private static let DEVICE_TITLE_FORMAT = {
        return  NSLocalizedString("Device Server %d",
                                  tableName: nil,
                                  bundle: Bundle(for: STM32WBLedButtonViewController.self),
                                  value: "Device Server %d",
                                  comment: "Device Server %d");
    }();
    
    private static let LED_ON_IMAGE = {
        return UIImage(named: "stm32wb_led_on",
                       in: Bundle(for: STM32WBLedButtonViewController.self),
                       compatibleWith: nil)
    }();
    
    private static let LED_OFF_IMAGE = {
        return UIImage(named: "stm32wb_led_off",
                       in: Bundle(for: STM32WBLedButtonViewController.self),
                       compatibleWith: nil)
    }();
    
    private static let RADIO_REBOOT_MENU_ITEM = {
        return  NSLocalizedString("Switch Protocol Radio",
                                  tableName: nil,
                                  bundle: Bundle(for: STM32WBLedButtonViewController.self),
                                  value: "Switch Protocol Radio",
                                  comment: "Switch Protocol Radio");
    }();
    
    @IBOutlet weak var mAllarmLablel: UILabel!
    @IBOutlet weak var mLedButton: UIButton!
    @IBOutlet weak var mDeviceControlView: UIView!
    @IBOutlet weak var mInstructionLabel: UILabel!
    @IBOutlet weak var mDeviceLabel: UILabel!
    @IBOutlet weak var mBellImage: UIImageView!
    
    private var mLedControl:STM32WBControlLedFeature?
    
    private var mButtonStatusFeature:STM32WBSwitchStatusFeature?
    
    private var mRebootActionMenu:UIAlertAction!
    
    private var mLedStatus = false;
    
    fileprivate var mCurrentDevice:DeviceID?
    
    fileprivate let mPulseAnimation:CAKeyframeAnimation = {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale.xy")
        animation.values = [1.0,0.8,1.2,1.0]
        animation.keyTimes = [0.0,0.25,0.75,1.0]
        animation.duration = 0.3
        return animation
    }();
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mCurrentDevice = DeviceID.fromBoardId(node.typeId)
        if let device = mCurrentDevice{
            self.showLedController(deviceId: device)
        }

        enableNotification()
        addShowThreadMenuItem()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disableNotifiation()
        removeShowThreadMenuItem();
    }
    
    private func enableNotification(){
        mLedControl = self.node.getFeatureOfType(STM32WBControlLedFeature.self) as? STM32WBControlLedFeature
        mButtonStatusFeature = self.node.getFeatureOfType(STM32WBSwitchStatusFeature.self) as? STM32WBSwitchStatusFeature
        if let feature = mButtonStatusFeature{
            feature.add(self)
            self.node.enableNotification(feature)
        }
    }
    
    private func disableNotifiation(){
        if let feature = mButtonStatusFeature{
            feature.remove(self)
            self.node.disableNotification(feature)
            Thread.sleep(forTimeInterval: 0.1)
        }
    }
 
    private func addShowThreadMenuItem(){
        guard node.hasThreadRadio() else {
            return
        }
        
        mRebootActionMenu = UIAlertAction(title: STM32WBLedButtonViewController.RADIO_REBOOT_MENU_ITEM,
                                          style: .default){ action in
            if let rebootFeature = self.node.getFeatureOfType(STM32WBProtocolRadioRebootFeature.self) as? STM32WBProtocolRadioRebootFeature,
                let deviceId = self.mCurrentDevice{
                rebootFeature.rebootToNewProtocolRadio(device: deviceId)
            }//if
        }
        
        menuDelegate?.addMenuAction(mRebootActionMenu)
    }
    
    private func removeShowThreadMenuItem(){
        if let menuItem = mRebootActionMenu{
            menuDelegate?.removeMenuAction(menuItem);
        }
    }

    
    fileprivate func showLedController(deviceId:DeviceID){
        let deviceName = String(format:STM32WBLedButtonViewController.DEVICE_TITLE_FORMAT,
                                deviceId.rawValue)//mCurrentDevice is != nil
        self.mInstructionLabel.isHidden=true
        self.mDeviceControlView.isHidden=false
        //deviceId is alwayse != null
        self.mDeviceLabel.text = deviceName
    }
    
    /// call when the led image is cliecked, will send the command to change the led
    /// status
    /// - Parameter sender: button pressed
    @IBAction func onLedClicked(_ sender: UIButton) {
        if let device = mCurrentDevice{
            if(mLedStatus){
                mLedControl?.switchOffLed(device: device);
                sender.setBackgroundImage(
                    STM32WBLedButtonViewController.LED_OFF_IMAGE,
                    for: .normal)
            }else{
                mLedControl?.switchOnLed(device: device);
                sender.setBackgroundImage(STM32WBLedButtonViewController.LED_ON_IMAGE,
                                          for: .normal)
            }//if - else
            mLedStatus = !mLedStatus
        }//if
    }//onLedClicked
    
}


// MARK: - BlueSTSDKFeatureDelegate
extension STM32WBLedButtonViewController : BlueSTSDKFeatureDelegate{
    
    private static let BELL_ANIMATION_KEY = "STM32WBLedButtonViewController.BELL_ANIMATION_KEY"
    
    private static let BUTTON_EVENT_FORMAT = {
        return  NSLocalizedString("Button pressed: %@ { %d }",
                                  tableName: nil,
                                  bundle: Bundle(for: STM32WBLedButtonViewController.self),
                                  value: "Button pressed: %@ { %d }",
                                  comment: "Button pressed: %@ { %d }");
    }();
    

    
    /// Call when the button is pressed in the board
    ///
    /// - Parameters:
    ///   - feature: feature that trigger the event
    ///   - sample: feature data
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        let deviceId = STM32WBSwitchStatusFeature.getDeviceSelection(sample: sample)
        if(mCurrentDevice == nil && deviceId != nil){ // if is the first time
            mCurrentDevice = deviceId
            DispatchQueue.main.async {
                self.showLedController(deviceId: deviceId!)   
            }
        }
        let status = STM32WBSwitchStatusFeature.getButtonPushed(sample: sample) ? 1 : 0
        let eventTime = DateFormatter.localizedString(from: sample.notificaitonTime, dateStyle: .none, timeStyle: .medium)
        let eventString = String(format:STM32WBLedButtonViewController.BUTTON_EVENT_FORMAT , eventTime,status)
        DispatchQueue.main.async {
            self.mAllarmLablel.text = eventString
            self.mBellImage.layer.add(self.mPulseAnimation, forKey:      STM32WBLedButtonViewController.BELL_ANIMATION_KEY)
        }
    }
}

fileprivate extension BlueSTSDKNode{
    static private let ENABLE_REBOOT_THREAD_ADVERTISE_MASK = UInt32(0x00004000);
        
    func hasThreadRadio() -> Bool {
        return advertiseBitMask & BlueSTSDKNode.ENABLE_REBOOT_THREAD_ADVERTISE_MASK != 0
    }
}

