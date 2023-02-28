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
import Foundation
import BlueSTSDK;

/// demo that show the compass data
public class BlueMSCOSensorDemoViewController:
    BlueMSDemosViewController {
    
    private static let SET_SENSITIVYT_MENU = {
        return  NSLocalizedString("Set Sensitivity",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCOSensorDemoViewController.self),
                                  value: "Set Sensitivity",
                                  comment: "Set Sensitivity");
    }();
    
    @IBOutlet weak var mCOValueText: UILabel!
    
    private var mCOSensorFeature:BlueSTSDKFeatureCOSensor?;
    private var mSensitivityMenuItem:UIAlertAction?
    private var mSetSensitivytController:BlueMSCOSensorSetSensitivityController?
    
    private var featureWasEnabled = false
    
    private func addSensitivytMenuItem(sensor: BlueSTSDKFeatureCOSensor){
        mSetSensitivytController = BlueMSCOSensorSetSensitivityController(sensor: sensor);
        mSensitivityMenuItem = UIAlertAction(title: BlueMSCOSensorDemoViewController.SET_SENSITIVYT_MENU,
                                             style: .default){ _ in self.showSetSensitivityDialog() }
        menuDelegate?.addMenuAction(mSensitivityMenuItem!)
    }
    
    private func removeSensitityMenuItem(){
        if let menuItem = mSensitivityMenuItem {
            menuDelegate?.removeMenuAction(menuItem)
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startNotification()
    }

    public override func viewDidLoad() {
        super.viewDidLoad();
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground),
                                                       name: UIApplication.didEnterBackgroundNotification,
                                                       object: nil)
                
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActivity),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        stopNotification()
    }
    
    public func startNotification(){
        mCOSensorFeature = self.node.getFeatureOfType(BlueSTSDKFeatureCOSensor.self) as? BlueSTSDKFeatureCOSensor
        if let feature = mCOSensorFeature{
            feature.add(self)
            self.node.enableNotification(feature)
            addSensitivytMenuItem(sensor: feature)
        }
    }

    public func stopNotification(){
        if let feature = mCOSensorFeature{
            feature.remove(self)
            self.node.disableNotification(feature)
            Thread.sleep(forTimeInterval: 0.1)
            removeSensitityMenuItem()
        }
    }


    @objc func didEnterForeground() {
        mCOSensorFeature = self.node.getFeatureOfType(BlueSTSDKFeatureCOSensor.self) as? BlueSTSDKFeatureCOSensor
        if !(mCOSensorFeature==nil) && node.isEnableNotification(mCOSensorFeature!) {
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
    
    
    private func showSetSensitivityDialog(){
        if let dialog = mSetSensitivytController?.dialog{
            present(dialog, animated: true, completion: nil)
        }
    }
}


extension BlueMSCOSensorDemoViewController : BlueSTSDKFeatureDelegate{
    
    private static let CO_VALUE_FORMAT = {
        return  NSLocalizedString("CO Data: %4.2f ppm",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCOSensorDemoViewController.self),
                                  value: "CO Data: %4.2f ppm",
                                  comment: "CO Data: %4.2f ppm")
    }();
    
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        let value = BlueSTSDKFeatureCOSensor.getGasPresence(sample)
        let stringValue = String(format: BlueMSCOSensorDemoViewController.CO_VALUE_FORMAT, value)
        DispatchQueue.main.async {
            self.mCOValueText.text = stringValue
        }
    }
    
}
