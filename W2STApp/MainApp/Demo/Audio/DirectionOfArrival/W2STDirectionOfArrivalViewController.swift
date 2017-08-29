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
import BlueSTSDK

class W2STDirectionOfArrivalViewController: BlueMSDemoTabViewController,BlueSTSDKFeatureDelegate{
    
    @IBOutlet weak var mNeedleImage: UIImageView!
    @IBOutlet weak var mBoardImage: UIImageView!
    @IBOutlet weak var mDirectionLabel: UILabel!
    private var mDirectionFeature:BlueSTSDKFeatureDirectionOfArrival?

    @IBAction func onHighSensitivitySwitchChange(_ sender: UISwitch) {
        mDirectionFeature?.enableLowSensitivity(!sender.isOn);
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mBoardImage.image = self.node.getImage();
        if(self.node.type == .nucleo){
            //rotate right 90 degree
            mBoardImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2);
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        mDirectionFeature = self.node.getFeatureOfType(BlueSTSDKFeatureDirectionOfArrival.self) as! BlueSTSDKFeatureDirectionOfArrival?;
        
        if let feature = mDirectionFeature{
            feature.add(self);
            self.node.enableNotification(feature);
            feature.enableLowSensitivity(false);
        }

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let feature = mDirectionFeature {
            feature.remove(self);
            feature.enableLowSensitivity(false);
            node.disableNotification(feature);
        }
    }

    private static func degreeToRad(_ angle:Float) -> Float{
        return angle * Float.pi/180.0
    }

    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        let angle = BlueSTSDKFeatureDirectionOfArrival.getAudioSourceAngle(sample);
       // NSLog("Angle: \(angle)");
        if(angle>0) {
            DispatchQueue.main.async {
                self.mNeedleImage.transform = CGAffineTransform(rotationAngle: CGFloat(W2STDirectionOfArrivalViewController.degreeToRad(Float(angle))))
                self.mDirectionLabel.text = "\(angle)"
            }
        }
    }

}
