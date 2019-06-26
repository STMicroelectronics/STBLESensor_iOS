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

public class BlueMSSwitchViewController: BlueMSDemoTabViewController,BlueSTSDKFeatureDelegate{

    private static let SWITCH_DESCRIPTION:String = {
        let bundle = Bundle(for: BlueMSPedometerViewController.self)
        return NSLocalizedString("Click the image to change the status", tableName: nil, bundle: bundle,
                                 value: "Click the image to change the status", comment: "")
    }();
    
    private static let EVENT_DESCRIPTION:String = {
        let bundle = Bundle(for: BlueMSPedometerViewController.self)
        return NSLocalizedString("The led is swithing on when an event is detected", tableName: nil, bundle: bundle,
                                 value: "The led is swithing on when an event is detected", comment: "")
    }();
    
    private static let SWITCH_ON:UInt8 = 0x01;
    private static let SWITCH_OFF:UInt8 = 0x00;
    
    @IBOutlet weak var mLedImage: UIImageView!
    @IBOutlet weak var mLedDescription: UILabel!

    private var mFeature:BlueSTSDKFeatureSwitch?;
    private static let STATUS_ON_IMG = #imageLiteral(resourceName: "led_on")
    private static let STATUS_OFF_IMG = #imageLiteral(resourceName: "led_off")

    private func enableOnImageClickEvent(){
        let singleTapDetector = UITapGestureRecognizer(target: self,
                action: #selector(self.onImageClick(sender:)))
        singleTapDetector.numberOfTapsRequired=1;
        mLedImage.isUserInteractionEnabled=true;
        mLedImage.addGestureRecognizer(singleTapDetector);
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        enableOnImageClickEvent();
    }

    private func setDescriptionString(_ nodeType:BlueSTSDKNodeType){
        if(nodeType == .sensor_Tile_Box){
            mLedDescription.text = BlueMSSwitchViewController.EVENT_DESCRIPTION
        }else{
            mLedDescription.text = BlueMSSwitchViewController.SWITCH_DESCRIPTION
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setDescriptionString(node.type)
        mFeature = self.node.getFeatureOfType(BlueSTSDKFeatureSwitch.self) as! BlueSTSDKFeatureSwitch?
        if let feature = mFeature {
            feature.add(self);
            self.node.enableNotification(feature);
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let feature = mFeature {
            feature.remove(self);
            self.node.disableNotification(feature);
            mFeature=nil;
        }
    }

    //send the new status to the node
    @objc func onImageClick(sender: UITapGestureRecognizer) {
        guard mFeature != nil else {
            return
        }
        let currentStatus = BlueSTSDKFeatureSwitch.getStatus(mFeature?.lastSample);
        if(currentStatus == BlueMSSwitchViewController.SWITCH_ON){
            mFeature?.setSwitchStatus(BlueMSSwitchViewController.SWITCH_OFF);
        }else{
            mFeature?.setSwitchStatus(BlueMSSwitchViewController.SWITCH_ON);
        }
    }
    
    private func getSwitchImage( status:UInt8)->UIImage?{
        switch(status){
            case BlueMSSwitchViewController.SWITCH_ON:
                return  BlueMSSwitchViewController.STATUS_ON_IMG;
            case BlueMSSwitchViewController.SWITCH_OFF:
                return  BlueMSSwitchViewController.STATUS_OFF_IMG;
            default:
                return nil;
        }
    }
    
    //update the switch image with the new status
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        let status = BlueSTSDKFeatureSwitch.getStatus(sample);
        
        let newImg = getSwitchImage(status: status);
        DispatchQueue.main.async {
            self.mLedImage.image = newImg;
        }
        
    }
}
