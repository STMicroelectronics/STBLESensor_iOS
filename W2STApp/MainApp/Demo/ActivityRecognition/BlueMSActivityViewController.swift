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
import CoreGraphics
import BlueSTSDK_Gui
import BlueSTSDK
import MBProgressHUD

public class BlueMSActivityViewController:
    BlueMSDemoTabViewController, BlueSTSDKFeatureDelegate{
    
    private static let START_MESSAGE:String = {
        return NSLocalizedString("Activity detection started",
                                 tableName: nil,
                                 bundle:Bundle(for: BlueMSActivityViewController.self),
                                 value: "Activity detection started",
                                 comment: "")
    }();
    
    private static let CHECK_LICENSE:String = {
        return NSLocalizedString("Check the license",tableName: nil,
                                 bundle:Bundle(for: BlueMSActivityViewController.self),
                                 value: "Check the license",
                                 comment: "")
    }();
    
    private static let MESSAGE_DISPLAY_TIME = TimeInterval(1.0)
    
    @IBOutlet weak var mMotionARView : BlueMSMotionARView!
    @IBOutlet weak var mActivityIGNView: ActivityRecognitionIGNView!
    @IBOutlet weak var mActivityGMPView: ActivityRecognitionGMPView!
    @IBOutlet weak var mActivityMLCView: ActivityRecognitionMLCView!
    @IBOutlet weak var mAdultPresenceMLCView: AdultPresenceMLCView!

    private var mCurrentActivity:BlueSTSDKFeatureActivity.ActivityType?;
    private var mFeature:BlueSTSDKFeature?;
    
    private var featureWasEnabled = false
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deselectAllImages()
    }
    
    private lazy var algoIdToView : [ UInt8 : BlueMSActivityView] = {
        return [
            0 : mMotionARView,
            1 : mActivityGMPView,
            2 : mActivityIGNView,
            3 : mActivityMLCView,
            4 : mAdultPresenceMLCView
        ]
    }()
    
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
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
    
    private func deselectAllImages(){
        mMotionARView.deselectAll()
        mActivityGMPView.deselectAll()
        mActivityIGNView.deselectAll()
        mActivityMLCView.deselectAll()
        mAdultPresenceMLCView.deselectAll()
    }
    
    private func displayStartMessage(){
        let message = MBProgressHUD.showAdded(to: self.view, animated: true)
        message.mode = .text;
        message.removeFromSuperViewOnHide=true;
        message.label.text = BlueMSActivityViewController.START_MESSAGE;
        message.hide(animated: true,
                    afterDelay: BlueMSActivityViewController.MESSAGE_DISPLAY_TIME)
    }
    
    private func displayActivityType(on view: BlueMSActivityView ,_ newActivity: BlueSTSDKFeatureActivity.ActivityType){
        if let activity = mCurrentActivity{
            view.deselect(type: activity)
        }
        self.mCurrentActivity = newActivity
        view.select(type: newActivity)
    }
    
    private func displayActivity(algoID: UInt8, type:BlueSTSDKFeatureActivity.ActivityType){
        algoIdToView.forEach{ id , view in
            if ( id == algoID){
                view.setVisible()
                displayActivityType(on: view, type)
            }else{
                view.setHidden()
            }
        } // for each
    }
    
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
    
        let newActivity = BlueSTSDKFeatureActivity.getType(sample);
        let algorithmId = BlueSTSDKFeatureActivity.getAlgorithmId(sample);
        DispatchQueue.main.async { [weak self] in
            self?.displayActivity(algoID: algorithmId, type: newActivity)
        }
    
    }
    
    @objc func didEnterForeground() {
        mFeature = self.node.getFeatureOfType(BlueSTSDKFeatureActivity.self);
        if !(mFeature==nil) && node.isEnableNotification(mFeature!) {
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
    
    public func startNotification(){
        mFeature = self.node.getFeatureOfType(BlueSTSDKFeatureActivity.self);
        if let feature = mFeature{
            feature.add(self)
            self.node.enableNotification(feature);
            self.node.read(feature);
            displayStartMessage();
            //if wesu check if the license is present
            if(node.type == .STEVAL_WESU1){
                self.checkLicense(fromRegister: .REGISTER_NAME_MOTION_AR_VALUE_LIC_STATUS,
                                  errorString: BlueMSActivityViewController.CHECK_LICENSE)
            }
        }
    }
    
    public func stopNotification(){
        if let feature = mFeature{
            feature.remove(self);
            self.node.disableNotification(feature);
            Thread.sleep(forTimeInterval: 0.1)
            mFeature=nil;
        }
    }
    
}
