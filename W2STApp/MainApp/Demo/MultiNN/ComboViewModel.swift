/*
 * Copyright (c) 2019  STMicroelectronics – All rights reserved
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


class ComboModelView : NSObject{
    
    private var mActivityState: BlueSTSDKFeatureActivity.ActivityType = .noActivity
    private var mActivityAlgo: UInt8 = 0
    private var mAudioState: BlueSTSDKFeatureAudioCalssification.AudioClass = .Unknown
    private var mAudioAlgo: UInt8 = 0
    
    var onStateChange:((UIImage,String)->())?
    var onSetVisibiltiy:((Bool)->())?
        
    func attachListener(featureActivity: BlueSTSDKFeatureActivity?, featureAudio: BlueSTSDKFeatureAudioCalssification?) {
        guard let f1 = featureActivity else{
            DispatchQueue.main.async { [weak self] in
                self?.onSetVisibiltiy?(false)
            }
            return
        }
        f1.add(self)
        
        guard let f2 = featureAudio else{
            DispatchQueue.main.async { [weak self] in
                self?.onSetVisibiltiy?(false)
            }
            return
        }
        f2.add(self)
    }
    
    func removeListener(featureActivity: BlueSTSDKFeatureActivity?, featureAudio: BlueSTSDKFeatureAudioCalssification?){
        guard let f1 = featureActivity else{
            return
        }
        f1.remove(self)
        
        guard let f2 = featureAudio else{
            return
        }
        f2.remove(self)
    }
}

extension ComboModelView : BlueSTSDKFeatureDelegate{
    
    private static let COMBO_STRING_WARNING = {
        return  NSLocalizedString("Warning!!!",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSMultiNetworkViewController.self),
                                  value: "Warning!!!",
                                  comment: "Warning!!!")
    }();
    
    private static let COMBO_STRING_QUIET = {
        return  NSLocalizedString("Quiet...",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSMultiNetworkViewController.self),
                                  value: "Quiet...",
                                  comment: "Quiet...")
    }();
    
    private static let COMBO_IMAGE_WARNING_ENABLED = UIImage(imageLiteralResourceName: "ic_warning_accent")
    
    private static let COMBO_IMAGE_WARNING_DISABLED = UIImage(imageLiteralResourceName: "ic_warning_light_grey")
    
    func showComboActivity() {
        
        var comboImage: UIImage
        var comboString: String
        
        if (mAudioAlgo == 1 && mActivityAlgo == 4) {
            if (mActivityState != .adultInCar && mAudioState == .BabyIsCrying) {
                comboImage = ComboModelView.COMBO_IMAGE_WARNING_ENABLED
                comboString = ComboModelView.COMBO_STRING_WARNING
            } else {
                comboImage = ComboModelView.COMBO_IMAGE_WARNING_DISABLED
                comboString = ComboModelView.COMBO_STRING_QUIET
            } // if - else
            
            DispatchQueue.main.async { [weak self] in
                self?.onSetVisibiltiy?(true)
                self?.onStateChange?(comboImage, comboString)
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.onSetVisibiltiy?(false)
            }
        }//if-else algo
    }
    
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        switch feature {
            case is BlueSTSDKFeatureActivity:
                mActivityState = BlueSTSDKFeatureActivity.getType(sample)
                mActivityAlgo = BlueSTSDKFeatureActivity.getAlgorithmId(sample)
            case is BlueSTSDKFeatureAudioCalssification:
                mAudioState = BlueSTSDKFeatureAudioCalssification.getAudioScene(sample)
                mAudioAlgo = BlueSTSDKFeatureAudioCalssification.getAlgorythmType(sample)
            default:
                return
        }
        showComboActivity();
    }
}
