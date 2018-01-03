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
import BlueSTSDK;

public class BlueMSPedometerViewController:
    BlueMSDemoTabViewController,BlueSTSDKFeatureDelegate{
    @IBOutlet weak var mPedometerIcon: UIImageView!
    
    @IBOutlet weak var mNStepsLabel: UILabel!
    @IBOutlet weak var mFrequencyLabel: UILabel!
    
    private var mFrequencyUnit:String?;
    private static let FEQUENCY_FORMAT:String = {
        let bundle = Bundle(for: BlueMSPedometerViewController.self)
        return NSLocalizedString("Frequency: %d %@", tableName: nil, bundle: bundle,
                                             value: "Frequency: %d %@", comment: "")
    }();
    
    private static let STEPS_FORMAT:String = {
        let bundle = Bundle(for: BlueMSPedometerViewController.self)
        return NSLocalizedString("Steps: %d", tableName: nil, bundle: bundle,
                                         value: "Steps: %d", comment: "")
    }();
    
    private var mPedometerFeature:BlueSTSDKFeature?;
    
    private var mImageIsFlip=false;
    private let mFlipImage = CGAffineTransform(
        a: -1, b: 0,
        c: 0,  d: 1,
        tx: 0, ty: 0)
    
    private let mUnFlipImage = CGAffineTransform.identity;
    
    private func extactFrequencyUnit(_ feature:BlueSTSDKFeature) -> String?{
        return feature.getFieldsDesc()[1].unit;
    }
    
    
    public override func viewDidLoad() {
        self.mNStepsLabel.text =
            String(format: BlueMSPedometerViewController.STEPS_FORMAT,0,"");

    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        mPedometerFeature = self.node.getFeatureOfType(BlueSTSDKFeaturePedometer.self);
        
        if let feature = mPedometerFeature{
            mFrequencyUnit = extactFrequencyUnit(feature);
            feature.add(self);
            self.node.enableNotification(feature);
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        
        if let feature = mPedometerFeature{
            feature.remove(self);
            self.node.disableNotification(feature);
            mPedometerFeature=nil;
        }
        
    }
    
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        
        let nStep = BlueSTSDKFeaturePedometer.getSteps(sample);
        let freq = BlueSTSDKFeaturePedometer.getFrequency(sample);

        let nStepString =
            String(format: BlueMSPedometerViewController.STEPS_FORMAT,nStep);
        let freqString =
            String(format: BlueMSPedometerViewController.FEQUENCY_FORMAT,
                   freq,mFrequencyUnit ?? "");
        
        DispatchQueue.main.async {
            self.mNStepsLabel.text = nStepString;
            self.mFrequencyLabel.text = freqString;
            self.animateIcon();
        }
    }
    
    private func animateIcon(){
        if((mPedometerIcon.layer.animationKeys()?.isEmpty) ?? true){
            if(mImageIsFlip){
                mPedometerIcon.layer.setAffineTransform(mUnFlipImage);
            }else{
                mPedometerIcon.layer.setAffineTransform(mFlipImage);
            }
            mImageIsFlip = !mImageIsFlip;
        }
    }
    
    
}
