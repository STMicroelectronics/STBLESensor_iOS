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
import UIKit
import MBProgressHUD

class BlueMSCarryPositionViewController : BlueMSDemoTabViewController {

    private static let DEFAULT_ALPHA = CGFloat(0.3)
    private static let SELECTED_ALPHA = CGFloat(1.0)
    private static let START_MESSAGE_DISPLAY_TIME = TimeInterval(1.0)
    
    private var featureWasEnabled = false
    
    private static let START_MESSAGE:String = {
        return  NSLocalizedString("Carry detection started",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCarryPositionViewController.self),
                                  value: "Carry detection started",
                                  comment: "Carry detection started");
    }();
    
    private static let LICENSE_NOT_VALID_MSG:String = {
        return  NSLocalizedString("Check the license",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCarryPositionViewController.self),
                                  value: "Check the license",
                                  comment: "Check the license");
    }();
    
    
    
    @IBOutlet weak var handImage: UIImageView!
    @IBOutlet weak var headImage: UIImageView!
    @IBOutlet weak var shirtImage: UIImageView!
    @IBOutlet weak var trouserImage: UIImageView!
    @IBOutlet weak var deskImage: UIImageView!
    @IBOutlet weak var armImage: UIImageView!
    
    private var mPositionToImage:[BlueSTSDKFeatureCarryPositionType : UIImageView]!
    
    private var mPositionFeature : BlueSTSDKFeature?
    private var mCurrentPosition: BlueSTSDKFeatureCarryPositionType?
    
    private func initPositionToImageMap(){
        mPositionToImage = [
            .inHand : handImage,
            .nearHead : headImage,
            .shirtPocket : shirtImage,
            .trousersPocket : trouserImage,
            .onDesk : deskImage,
            .armSwing : armImage
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
                
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActivity),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        initPositionToImageMap()
    }
    
    private func switchOffAllImages(){
        mPositionToImage.values.forEach{ $0.alpha = BlueMSCarryPositionViewController.DEFAULT_ALPHA}
        mCurrentPosition = nil
    }
    
    private func displayStartMessage(){
        let message = MBProgressHUD.showAdded(to: self.view, animated: true)
        message.mode = .text
        message.removeFromSuperViewOnHide = true
        message.label.text = BlueMSCarryPositionViewController.START_MESSAGE
        message.hide(animated: true, afterDelay: BlueMSCarryPositionViewController.START_MESSAGE_DISPLAY_TIME)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switchOffAllImages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopNotification()
    }
    
    public func startNotification(){
        mPositionFeature = node.getFeatureOfType(BlueSTSDKFeatureCarryPosition.self)
        if let feature = mPositionFeature{
            feature.add(self)
            node.enableNotification(feature)
            node.read(feature)
            displayStartMessage()
            if(node.type == .STEVAL_WESU1){
                checkLicense(fromRegister: .REGISTER_NAME_MOTION_CP_VALUE_LIC_STATUS,
                             errorString: BlueMSCarryPositionViewController.LICENSE_NOT_VALID_MSG)
            }
        }
    }

    public func stopNotification(){
        if let feature = mPositionFeature{
            feature.remove(self)
            node.disableNotification(feature)
            Thread.sleep(forTimeInterval: 0.1)
        }
    }


    @objc func didEnterForeground() {
        mPositionFeature = node.getFeatureOfType(BlueSTSDKFeatureCarryPosition.self)
        if !(mPositionFeature==nil) && node.isEnableNotification(mPositionFeature!) {
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
    
    fileprivate func updatePosition(_ position:BlueSTSDKFeatureCarryPositionType){
        if let current = mCurrentPosition{
            mPositionToImage[current]?.alpha = BlueMSCarryPositionViewController.DEFAULT_ALPHA
        }
        mPositionToImage[position]?.alpha = BlueMSCarryPositionViewController.SELECTED_ALPHA
        mCurrentPosition = position
    }
    
}

extension BlueMSCarryPositionViewController : BlueSTSDKFeatureDelegate{
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        let position = BlueSTSDKFeatureCarryPosition.getType(sample)
        DispatchQueue.main.async { [weak self] in
            self?.updatePosition(position);
        }
    }
}
