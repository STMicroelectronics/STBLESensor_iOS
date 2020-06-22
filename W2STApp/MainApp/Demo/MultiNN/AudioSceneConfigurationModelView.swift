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


class AudioSceneClassificaitonModelView : NSObject{
    
    var onStateChange:((UIImage,String)->())?
    var onSetVisibiltiy:((Bool)->())?
    
    func attachListener(feature: BlueSTSDKFeatureAudioCalssification?){
        guard let f = feature else{
            DispatchQueue.main.async { [weak self] in
                self?.onSetVisibiltiy?(false)
            }
            return
        }
        f.add(self)
    }
    
    func removeListener(feature: BlueSTSDKFeatureAudioCalssification?){
        guard let f = feature else{
            return
        }
        f.remove(self)
    }
}

extension AudioSceneClassificaitonModelView : BlueSTSDKFeatureDelegate{
    
    private func showDefaultAudioScene(_ scene:BlueSTSDKFeatureAudioCalssification.AudioClass){
        DispatchQueue.main.async { [weak self] in
            self?.onStateChange?(scene.icon,scene.description)
            if(scene != .Unknown){
                self?.onSetVisibiltiy?(true)
            }
        }
    }
    
    private static let SCENE_BABY_IS_NOT_CRYING_STR = {
        return  NSLocalizedString("Baby is not crying",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSMultiNetworkViewController.self),
                                  value: "Baby is not crying",
                                  comment: "Baby is not crying")
    }();
    
    private func showBabyCryingAudioScene(_ scene:BlueSTSDKFeatureAudioCalssification.AudioClass){
        let sceneImg = scene == .BabyIsCrying ? scene.icon : UIImage(imageLiteralResourceName: "audioScene_babyNotCrying")
        let sceneDesc = scene == .BabyIsCrying ? scene.description : Self.SCENE_BABY_IS_NOT_CRYING_STR
        
        DispatchQueue.main.async { [weak self] in
            self?.onStateChange?(sceneImg,sceneDesc)
            self?.onSetVisibiltiy?(true)
        }
    }
    
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        let scene = BlueSTSDKFeatureAudioCalssification.getAudioScene(sample)
        let algoId = BlueSTSDKFeatureAudioCalssification.getAlgorythmType(sample)
        switch algoId {
        case 1:
            showBabyCryingAudioScene(scene)
        default:
            showDefaultAudioScene(scene)
        }
    }
    
}
