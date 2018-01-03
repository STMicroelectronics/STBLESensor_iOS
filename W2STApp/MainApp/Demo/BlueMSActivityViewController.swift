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
import BlueSTSDK;

public class BlueMSActivityViewController:
    BlueMSDemoTabViewController,BlueSTSDKFeatureDelegate{
    
    private static let DEFAULT_APHA = CGFloat(0.3)
    private static let SELECTED_ALPHA = CGFloat(1.0)
    private static let MESSAGE_DISPLAY_TIME = TimeInterval(1.0)
    
    @IBOutlet weak var standingImage: UIImageView!
    @IBOutlet weak var walkingImage: UIImageView!
    @IBOutlet weak var fastWalkingImage: UIImageView!
    @IBOutlet weak var joggingImage: UIImageView!
    @IBOutlet weak var bikingImage: UIImageView!
    @IBOutlet weak var drivingImage: UIImageView!

    private var mStartMessage:String!
    private var mCheckLicenseMsg:String!
    
    private var mCurrentActivity:UIImageView?;
    //object to map an activity to an image to select
    private var mActivityToImage:[BlueSTSDKFeatureActivityType:UIImageView]!;
    private var mFeature:BlueSTSDKFeature?;
    
    private func loadLocalizeString(){
        let bundle = Bundle(for: type(of:self))
        
        mStartMessage = NSLocalizedString("Activity detection started", tableName: nil, bundle: bundle,
                                          value: "Activity detection started", comment: "")
        mCheckLicenseMsg = NSLocalizedString("Check the license", tableName: nil, bundle: bundle,
                                             value: "Check the license", comment: "")
    }
    
    private func initActivityToImageMap(){
        mActivityToImage = [
            .standing : standingImage,
            .walking : walkingImage,
            .fastWalking : fastWalkingImage,
            .jogging : joggingImage,
            .biking : bikingImage,
            .driving : drivingImage
        ];
    }
    
    public override func viewDidLoad() {
        loadLocalizeString()
        initActivityToImageMap()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        deselectAllImages();
        mFeature = self.node.getFeatureOfType(BlueSTSDKFeatureActivity.self);
        if let feature = mFeature{
            feature.add(self)
            self.node.enableNotification(feature);
            self.node.read(feature);
            displayStartMessage();
            //if wesu check if the license is present
            if(node.type == .STEVAL_WESU1){
                self.checkLicense(fromRegister: .REGISTER_NAME_MOTION_AR_VALUE_LIC_STATUS,
                                  errorString: mCheckLicenseMsg)
            }
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        if let feature = mFeature{
            feature.remove(self);
            self.node.disableNotification(feature);
            mFeature=nil;
        }
    }
    
    private func deselectAllImages(){
        mActivityToImage.values.forEach{
            $0.alpha=BlueMSActivityViewController.DEFAULT_APHA;
        }
        mCurrentActivity=nil;
    }
    
    private func displayStartMessage(){
        let message = MBProgressHUD.showAdded(to: self.view, animated: true)
        message.mode = .text;
        message.removeFromSuperViewOnHide=true;
        message.label.text = mStartMessage;
        message .hide(animated: true,
                    afterDelay: BlueMSActivityViewController.MESSAGE_DISPLAY_TIME)
    }
    
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
    
        let newActivity = BlueSTSDKFeatureActivity.getType(sample);
        
        DispatchQueue.main.async {
            self.mCurrentActivity?.alpha=BlueMSActivityViewController.DEFAULT_APHA;
            self.mCurrentActivity = self.mActivityToImage[newActivity];
            self.mCurrentActivity?.alpha=BlueMSActivityViewController.SELECTED_ALPHA;
        }
    
    }
}
