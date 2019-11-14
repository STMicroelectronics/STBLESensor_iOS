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

class BlueMSMotionAlgorithmViewController:
    BlueMSDemoTabViewController {
    
    @IBOutlet weak var algorithmTilte: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    
    private var mMotionAlgoFeature:BlueSTSDKFeatureMotionAlogrithm?;
    private var mCurrentAlgo:BlueSTSDKFeatureMotionAlogrithm.Algorithm = .poseEstimation
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mMotionAlgoFeature = self.node.getFeatureOfType(BlueSTSDKFeatureMotionAlogrithm.self) as? BlueSTSDKFeatureMotionAlogrithm
        if let feature = mMotionAlgoFeature{
            feature.add(self)
            feature.enableNotification()
            feature.enableAlgorithm(mCurrentAlgo)
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        if let feature = mMotionAlgoFeature{
            feature.remove(self)
            feature.disableNotification()
        }
    }
    
    @IBAction func onChangeAlgorithmClicked(_ sender: UIButton) {
        
        let popOverContent = BlueMSMotionAlogorithmSelectorViewController.instantiate(onSelection: { newAlgo in

            self.mCurrentAlgo = newAlgo
            self.mMotionAlgoFeature?.enableAlgorithm(newAlgo)
        })
        
        popOverContent.modalPresentationStyle = .popover
        let popOverVC = popOverContent.popoverPresentationController
        popOverVC?.delegate = self
        popOverVC?.sourceView=sender
        popOverVC?.sourceRect = CGRect(x: sender.bounds.midX, y: sender.bounds.minY, width: 0, height: 0)
        //popOverContent.preferredContentSize = CGSize(width: 250, height: 250)

        present(popOverContent, animated: true, completion: nil)
    }
    
}

// This is we need to make it looks as a popup window on iPhone
extension BlueMSMotionAlgorithmViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension BlueMSMotionAlgorithmViewController : BlueSTSDKFeatureDelegate{
    
    private func getEventImage(_ sample:BlueSTSDKFeatureSample)->UIImage?{
        if let poseEvent = BlueSTSDKFeatureMotionAlogrithm.getPoseEstimation(sample){
            return poseEvent.icon
        }else if let desktopEvent = BlueSTSDKFeatureMotionAlogrithm.getDetectedDeskType(sample){
            return desktopEvent.icon
        }else if let verticalEvent = BlueSTSDKFeatureMotionAlogrithm.getVerticalContext(sample){
            return verticalEvent.icon
        }
        //else
        return nil
    }
    
    
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        
        let currentAlgo = BlueSTSDKFeatureMotionAlogrithm.getAlgorithmType(sample)
        let image = getEventImage(sample)
        DispatchQueue.main.async { [weak self] in
            self?.algorithmTilte.text = currentAlgo?.description
            self?.eventImage.image = image
        }
    }
}
