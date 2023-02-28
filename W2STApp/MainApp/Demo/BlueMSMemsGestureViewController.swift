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

class BlueMSMemsGestureViewController : BlueMSDemoTabViewController{
    
    private static let DEFAULT_ALPHA = CGFloat(0.3)
    private static let SELECTED_ALPHA = CGFloat(1.0)
    private static let AUTOMATIC_DESELECT_TIMEOUT_SEC = TimeInterval(3.0)
    private static let ANIMATION_LENGTH = TimeInterval(1.0/3.0)
    
    
    @IBOutlet weak var glanceIcon: UIImageView!
    @IBOutlet weak var pickUpIcon: UIImageView!
    @IBOutlet weak var wakeUpIcon: UIImageView!
    
    private var mGestureFeature : BlueSTSDKFeature?
    private var mGestureToImage: [BlueSTSDKFeatureMemsGestureType : UIImageView]!
    private var mCurrenctSlected:BlueSTSDKFeatureMemsGestureType?
    private var mLastUpdate:Date?
    
    private var featureWasEnabled = false
    
    private func initGestureImageMap(){
        mGestureToImage = [
            .glance : glanceIcon,
            .pickUp : pickUpIcon,
            .wakeUp : wakeUpIcon
        ]
    }
    
    private func disableAllImages(){
        mGestureToImage.values.forEach{$0.alpha = BlueMSMemsGestureViewController.DEFAULT_ALPHA}
        mCurrenctSlected=nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
                
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActivity),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        initGestureImageMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        disableAllImages()
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
        mGestureFeature = node.getFeatureOfType(BlueSTSDKFeatureMemsGesture.self)
        if let feature = mGestureFeature {
            feature.add(self)
            node.enableNotification(feature)
            node.read(feature)
        }
    }

    public func stopNotification(){
        if let feature = mGestureFeature{
            feature.remove(self)
            node.disableNotification(feature)
            Thread.sleep(forTimeInterval: 0.1)
        }
    }


    @objc func didEnterForeground() {
        mGestureFeature = node.getFeatureOfType(BlueSTSDKFeatureMemsGesture.self)
        if !(mGestureFeature==nil) && node.isEnableNotification(mGestureFeature!) {
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
    
    fileprivate func selectGesture(_ gesture:BlueSTSDKFeatureMemsGestureType){
        //if we have an image to update
        guard let newImage = mGestureToImage[gesture] else{
            return;
        }
        //deselect the prevous one
        if let  current = mCurrenctSlected{
            mGestureToImage[current]?.alpha = BlueMSMemsGestureViewController.DEFAULT_ALPHA
        }
        mCurrenctSlected=gesture
        newImage.alpha = BlueMSMemsGestureViewController.SELECTED_ALPHA
        newImage.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: BlueMSMemsGestureViewController.ANIMATION_LENGTH){
            newImage.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        let now = Date() //save the current time for the closure
        mLastUpdate = now
        //deselect the current image after AUTOMATIC_DESELECT_TIMEOUT_SEC seconds
        DispatchQueue.main.asyncAfter(
            deadline: .now()+BlueMSMemsGestureViewController.AUTOMATIC_DESELECT_TIMEOUT_SEC){
                [weak self, weak newImage] in
                if(self?.mLastUpdate == now){ //if no other update were done
                    newImage?.alpha = BlueMSMemsGestureViewController.DEFAULT_ALPHA
                }//if
        }//asyncAfter
    }
}

extension BlueMSMemsGestureViewController : BlueSTSDKFeatureDelegate{
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        let gesture = BlueSTSDKFeatureMemsGesture.getType(sample)
        DispatchQueue.main.async { [weak self] in
            self?.selectGesture(gesture)
        }
    }
}
