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

import BlueSTSDK

class BlueMSAudioSceneClassificationViewController : BlueMSDemoTabViewController{
    fileprivate typealias SceneType = BlueSTSDKFeatureAudioSceneCalssification.Scene
    
    private static let DEFAULT_ALPHA = CGFloat(0.3)
    private static let SELECTED_ALPHA = CGFloat(1.0)
    private static let ANIMATION_LENGTH = TimeInterval(1.0/3.0)
    
    
    @IBOutlet weak var indoorIcon: UIImageView!
    @IBOutlet weak var outdoorIcon: UIImageView!
    @IBOutlet weak var inVehicleIcon: UIImageView!
    
    private var mAudioSceneFeature : BlueSTSDKFeature?
    private var mSceneToImage: [SceneType : UIImageView]!
    private var mCurrenctSlected:SceneType?

    private func initSceneImageMap(){
        mSceneToImage = [
            .Indoor : indoorIcon,
            .Outdoor : outdoorIcon,
            .InVehicle : inVehicleIcon
        ]
    }
    
    private func disableAllImages(){
        mSceneToImage.values.forEach{$0.alpha = BlueMSAudioSceneClassificationViewController.DEFAULT_ALPHA}
        mCurrenctSlected=nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSceneImageMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disableAllImages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mAudioSceneFeature = node.getFeatureOfType(BlueSTSDKFeatureAudioSceneCalssification.self)
        if let feature = mAudioSceneFeature {
            feature.add(self)
            node.enableNotification(feature)
            node.read(feature)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let feature = mAudioSceneFeature{
            feature.remove(self)
            node.disableNotification(feature)
        }
    }
    
    fileprivate func selectScene(_ scene:SceneType){
        //if we have an image to update
        guard let newImage = mSceneToImage[scene] else{
            return;
        }
        //deselect the prevous one
        if let  current = mCurrenctSlected{
            mSceneToImage[current]?.alpha = BlueMSAudioSceneClassificationViewController.DEFAULT_ALPHA
        }
        newImage.alpha = BlueMSAudioSceneClassificationViewController.SELECTED_ALPHA
        mCurrenctSlected=scene
    }
}

extension BlueMSAudioSceneClassificationViewController : BlueSTSDKFeatureDelegate{
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        let gesture = BlueSTSDKFeatureAudioSceneCalssification.getScene(sample)
        DispatchQueue.main.async { [weak self] in
            self?.selectScene(gesture)
        }
    }
}
