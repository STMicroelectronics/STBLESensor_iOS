/*
 * Copyright (c) 2017  STMicroelectronics – All rights reserved
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

import BlueSTSDK

public class BlueMSBoardBatteryStatusViewController: BlueMSDemoTabViewController,
    BlueSTSDKFeatureDelegate,
    BlueSTSDKFeatureBatteryDelegate{
    
    private static let BATTERY_RANGE_IMAGE = Float(20)
    private static let BATTERY_INFO_SEGUE = "BlueMS_showBatteryInfo";
    
    
    private static let CURRENT_NOT_AVAILABLE:String = {
        let bundle = Bundle(for: BlueMSBoardBatteryStatusViewController.self)
        return NSLocalizedString("Current: not available", tableName: nil, bundle: bundle,
                                 value: "Current: not available", comment: "")
    }();
    
    private static let CURRENT_FORMAT:String = {
        let bundle = Bundle(for: BlueMSBoardBatteryStatusViewController.self)
        return NSLocalizedString("Current: %.2f mA", tableName: nil, bundle: bundle,
                                 value: "Current: %.2f mA", comment: "")
    }();
    
    private static let VOLTAGE_FORMAT:String = {
        let bundle = Bundle(for: BlueMSBoardBatteryStatusViewController.self)
        return NSLocalizedString("Voltage: %.3f V", tableName: nil, bundle: bundle,
                                 value: "Voltage: %.3f V", comment: "")
    }();
    
    private static let CHARGE_FORMAT:String = {
        let bundle = Bundle(for: BlueMSBoardBatteryStatusViewController.self)
        return NSLocalizedString("Charge: %.1f %%", tableName: nil, bundle: bundle,
                                 value: "Charge: %.1f %%", comment: "")
    }();
    
    private static let AUTONOMY_FORMAT:String = {
        let bundle = Bundle(for: BlueMSBoardBatteryStatusViewController.self)
        return NSLocalizedString("Autonomy: %.1f m", tableName: nil, bundle: bundle,
                                 value: "Autonomy: %.1f m", comment: "")
    }();
    
    @IBOutlet weak var batteryImage:UIImageView!;
    @IBOutlet weak var levelLabel:UILabel!;
    @IBOutlet weak var statusLabel:UILabel!;
    @IBOutlet weak var voltageLabel:UILabel!;
    @IBOutlet weak var currentLabel:UILabel!;
    @IBOutlet weak var remainingTimeLabel:UILabel!;
    
    private var featureWasEnabled = false
    
    private var mBatteryCapacity = Float.nan;
    private var mBatteryFeature:BlueSTSDKFeatureBattery?;
    private var mShowBatteryInfo:UIAlertAction!;
    
    
    public override func viewDidLoad() {
        super.viewDidLoad();
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActivity),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        mShowBatteryInfo = UIAlertAction(title: "Battery Info", style: .default, handler: { (menuItem) in
            self.performSegue(withIdentifier:
                BlueMSBoardBatteryStatusViewController.BATTERY_INFO_SEGUE,
                              sender: self);
        })
    }
    
    @objc func didEnterForeground() {
        mBatteryFeature = self.node.getFeatureOfType(BlueSTSDKFeatureBattery.self) as? BlueSTSDKFeatureBattery;
        
        if !(mBatteryFeature==nil) && node.isEnableNotification(mBatteryFeature!)  {
            featureWasEnabled = true
            stopNotification()
        }else {
            featureWasEnabled = false;
        }
        
    }
    
    @objc func didBecomeActivity() {
        if(featureWasEnabled) {
            startNotification()
        }
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        BlueSTSDKDemoViewProtocolUtil.setupDemoProtocol(demo: segue.destination,
                                                  node: self.node,
                                                  menuDelegate: self.menuDelegate);
    }
    
    private func  loadBatteryCapacity(){
        if(mBatteryCapacity.isNaN){
            mBatteryFeature?.readCapacity();
        }
    }
    
    private func loadMaxAssorbedCurrent(){
        mBatteryFeature?.readMaxAbsorbedCurrent();
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        startNotification()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        stopNotification()
    }
    
    public func startNotification(){
        mBatteryFeature = self.node.getFeatureOfType(BlueSTSDKFeatureBattery.self) as? BlueSTSDKFeatureBattery;
        if let feature = mBatteryFeature{
            feature.add(self);
            feature.addBatteryDelegate(self);
            self.menuDelegate?.addMenuAction(mShowBatteryInfo);
            self.node.enableNotification(feature);
            loadBatteryCapacity();
            loadMaxAssorbedCurrent();
        }
    }

    public func stopNotification(){
        if let feature = mBatteryFeature{
            feature.remove(self);
            feature.addBatteryDelegate(self)
            self.menuDelegate?.removeMenuAction(mShowBatteryInfo);
            self.node.disableNotification(feature);
            Thread.sleep(forTimeInterval: 0.1)
        }
    }
    
    private func getBatteryStatusImage( level:Float, status: BlueSTSDKFeatureBatteryStatus)-> UIImage?{
        
        let rangeImage = BlueMSBoardBatteryStatusViewController.BATTERY_RANGE_IMAGE;
        
        let levelIndex = Int((level/rangeImage)+0.5)*Int(rangeImage)
        if(status != .charging){
            return UIImage(named: String(format: "battery_%d", levelIndex));
        }else{
            return UIImage(named: String(format: "battery_%dc", levelIndex));
        }
    }
    
    private func getBatteryRemainingTime(charge:Float)->Float{
        return mBatteryCapacity*(charge/100.0);
    }
    
    private func displayRemainingTime(_ status:BlueSTSDKFeatureBatteryStatus) -> Bool{
        return status == .discharging || status == .lowBattery;
    }
    
    public func didUpdate(_ feature: BlueSTSDKFeature,
                          sample: BlueSTSDKFeatureSample){
        let chargeValue = BlueSTSDKFeatureBattery.getLevel(sample);
        let currentValue = BlueSTSDKFeatureBattery.getCurrent(sample);
        let batteryStatus = BlueSTSDKFeatureBattery.getStatus(sample);
        
        let voltageValue = BlueSTSDKFeatureBattery.getVoltage(sample);
        
        let currentStr:String = {
            if(currentValue.isNaN){
                return BlueMSBoardBatteryStatusViewController.CURRENT_NOT_AVAILABLE;
            }else{
                return String(format: BlueMSBoardBatteryStatusViewController.CURRENT_FORMAT, currentValue);
            }
        }();
        
        let voltageStr = String(format: BlueMSBoardBatteryStatusViewController.VOLTAGE_FORMAT, voltageValue);
        let chargeStr = String(format:BlueMSBoardBatteryStatusViewController.CHARGE_FORMAT, chargeValue);
        let batteryImage = getBatteryStatusImage(level: chargeValue, status: batteryStatus);
        
        let remaingTime = getBatteryRemainingTime(charge: chargeValue);
        let remaingTimeStr = remaingTime.isNaN ? nil :
            String(format: BlueMSBoardBatteryStatusViewController.AUTONOMY_FORMAT, remaingTime);
        
        let statusStr = BlueSTSDKFeatureBattery.getStatusStr(sample);

        
        DispatchQueue.main.async {
            self.levelLabel.text = chargeStr;
            self.currentLabel.text = currentStr;
            self.voltageLabel.text = voltageStr;
            self.statusLabel.text = statusStr;
            self.batteryImage.image = batteryImage;
            if(self.displayRemainingTime(batteryStatus)){
                self.remainingTimeLabel.text=remaingTimeStr;
            }else{
                self.remainingTimeLabel.text=nil;
            }
        }// DispatchQueue
    
    }
    
    public func didCapacityRead(_ feature: BlueSTSDKFeatureBattery!,
                                capacity: UInt16){
        mBatteryCapacity=Float(capacity)
    }
}
