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

class BlueMSEulerAngleLevelViewController: BlueMSDemoTabViewController {
    
    @IBOutlet weak var mDetailsLabel: UILabel!
    @IBOutlet weak var mOffsetLabel: UILabel!
    
    @IBOutlet weak var mVerticalTarget: UIImageView!
    @IBOutlet weak var mPlanarTarget1: UIImageView!
    @IBOutlet weak var mPlanarTarget2: UIImageView!

    private var mAngleFeature: BlueSTSDKFeature?

    private var featureWasEnabled = false

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
        mAngleFeature = self.node.getFeatureOfType(BlueSTSDKFeatureEulerAngle.self) as? BlueSTSDKFeatureEulerAngle
        if let feature = mAngleFeature{
            feature.add(self)
            feature.enableNotification()
        }
    }

    public func stopNotification(){
        if let feature = mAngleFeature{
            feature.remove(self)
            feature.disableNotification()
        }
    }


    @objc func didEnterForeground() {
        mAngleFeature = self.node.getFeatureOfType(BlueSTSDKFeatureEulerAngle.self) as? BlueSTSDKFeatureEulerAngle
        if !(mAngleFeature==nil) && node.isEnableNotification(mAngleFeature!) {
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

    
}

extension BlueMSEulerAngleLevelViewController : BlueSTSDKFeatureDelegate{
    
    private static let DETAILS_ANGLE_FORMAT = {
        return  NSLocalizedString("Yaw: %3.2f° Roll:%3.2f° Pitch:%3.2f°",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSEulerAngleLevelViewController.self),
                                  value: "Yaw: %.2f° Roll:%.2f° Pitch:%.2f°",
                                  comment: "Yaw: %.2f° Roll:%.2f° Pitch:%.2f°")
    }();
    
    private static let OFFSET_ANGLE_FORMAT = {
        return  NSLocalizedString("Offset:  %3.2f°",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSEulerAngleLevelViewController.self),
                                  value: "Offset:  %3.2f°",
                                  comment: "Offset:  %3.2f°")
    }();
    
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        let yaw = BlueSTSDKFeatureEulerAngle.getYaw(sample)
        let pitch = BlueSTSDKFeatureEulerAngle.getPitch(sample)
        let roll = BlueSTSDKFeatureEulerAngle.getRoll(sample)
        
        let offset = max(abs(pitch),abs(roll))
        if(offset > 50.0){
            if(abs(pitch)>abs(roll)){
                displayVerticalOffset(angle: roll)
            }else{
                displayVerticalOffset(angle: pitch)
            }
        }else{
            displayPlanarOffset(planarOffset: offset, orientationOffset: yaw)
        }
        let detailsValue = String(format: BlueMSEulerAngleLevelViewController.DETAILS_ANGLE_FORMAT, yaw,roll,pitch)
        let offsetValue = String(format: BlueMSEulerAngleLevelViewController.OFFSET_ANGLE_FORMAT, offset)
        DispatchQueue.main.async {
            self.mDetailsLabel.text = detailsValue
            self.mOffsetLabel.text = offsetValue
        }
    }
    
    private func displayVerticalOffset( angle:Float){
        let rotation = CGAffineTransform(rotationAngle: CGFloat(angle.toRad))
        DispatchQueue.main.async {
            self.mPlanarTarget1.isHidden = true
            self.mPlanarTarget2.isHidden = true
            self.mVerticalTarget.transform = rotation
            self.mVerticalTarget.isHidden = false
        }
    }
    private static let DEEP = Float(5.0)
    private func displayPlanarOffset( planarOffset:Float, orientationOffset:Float ){
        let orientationOffsetRad = orientationOffset.toRad
        let deltaX = BlueMSEulerAngleLevelViewController.DEEP * planarOffset * Float(cos(orientationOffsetRad));
        let deltaY = BlueMSEulerAngleLevelViewController.DEEP * planarOffset * Float(sin(orientationOffsetRad));
        let offset1 = CGAffineTransform(translationX: CGFloat(deltaX), y: CGFloat(deltaY))
        let offset2 = CGAffineTransform(translationX: -CGFloat(deltaX), y: -CGFloat(deltaY))
        DispatchQueue.main.async {
            self.mPlanarTarget1.transform = offset1
            self.mPlanarTarget2.transform = offset2
            self.mPlanarTarget1.isHidden = false
            self.mPlanarTarget2.isHidden = false
            self.mVerticalTarget.isHidden = true
        }
    }
    
}

fileprivate extension FloatingPoint {
    var toRad :Self {
        get{
            return self * .pi/180
        }
    }
}
