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

public class BlueMSAudioClassificationViewController: BlueMSDemoTabViewController{
    
    private static let START_MESSAGE:String = {
        return NSLocalizedString("Audio classifier started",
                                 tableName: nil,
                                 bundle:Bundle(for: BlueMSActivityViewController.self),
                                 value: "Audio classifier started",
                                 comment: "")
    }();
    
    private static let MESSAGE_DISPLAY_TIME = TimeInterval(1.0)
    
    @IBOutlet weak var audioSceneClassification : AudioSceneView!
    @IBOutlet weak var babyCrying: BabyCryingView!
    
    private var mCurrentAudioClass:BlueSTSDKFeatureAudioCalssification.AudioClass?;
    private var mFeature:BlueSTSDKFeature?;
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deselectAllImages()
    }
    
    private lazy var algoIdToView : [ UInt8 : BlueMSAudioClassView] = {
        return [
            0 : audioSceneClassification,
            1 : babyCrying,
        ]
    }()
    
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        mFeature = self.node.getFeatureOfType(BlueSTSDKFeatureAudioCalssification.self);
        if let feature = mFeature{
            feature.add(self)
            feature.enableNotification()
            feature.read()
            displayStartMessage();
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
        algoIdToView.values.forEach{
            $0.deselectAll()
        }
    }
    
    private func displayStartMessage(){
        let message = MBProgressHUD.showAdded(to: self.view, animated: true)
        message.mode = .text;
        message.removeFromSuperViewOnHide=true;
        message.label.text = Self.START_MESSAGE;
        message .hide(animated: true,
                    afterDelay: Self.MESSAGE_DISPLAY_TIME)
    }
    
    private func displayAudioClass(on view: BlueMSAudioClassView ,_ newClass: BlueSTSDKFeatureAudioCalssification.AudioClass){
        if let audioClass = mCurrentAudioClass{
            view.deselect(type: audioClass)
        }
        self.mCurrentAudioClass = newClass
        view.select(type: newClass)
    }
    
    private func displayAudioClass(algoID: UInt8, type:BlueSTSDKFeatureAudioCalssification.AudioClass){
        algoIdToView.forEach{ id , view in
            if ( id == algoID){
                view.setVisible()
                displayAudioClass(on: view, type)
            }else{
                view.setHidden()
            }
        } // for each
    }
    
}

extension BlueMSAudioClassificationViewController : BlueSTSDKFeatureDelegate{
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
    
        let newClass = BlueSTSDKFeatureAudioCalssification.getAudioScene(sample);
        let algorithmId = BlueSTSDKFeatureAudioCalssification.getAlgorythmType(sample);
        DispatchQueue.main.async { [weak self] in
            self?.displayAudioClass(algoID: algorithmId, type: newClass)
        }
    
    }
}
