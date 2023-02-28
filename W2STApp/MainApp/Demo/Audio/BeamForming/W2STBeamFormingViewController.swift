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
import CorePlot
import BlueSTSDK

public class W2STBeamFormingViewController: BlueMSDemoTabViewController, BlueSTSDKFeatureDelegate{

    private static let DEFAULT_DIRECTION = BlueSTSDKFeatureBeamFormingDirection.RIGHT;

    private static let AUDIO_BUFFER_SIZE = 100*40;
    private static let AUDIO_SCALE_FACTOR = 1.0/32768.0;

    @IBOutlet weak var mTopButton: UIButton!

    @IBOutlet weak var mTopRightButton: UIButton!

    @IBOutlet weak var mRightButton: UIButton!

    @IBOutlet weak var mBottomRightButton: UIButton!

    @IBOutlet weak var mBottomButton: UIButton!

    @IBOutlet weak var mBottomLeftButton: UIButton!

    @IBOutlet weak var mLeftButton: UIButton!

    @IBOutlet weak var mTopLeftButton: UIButton!

    @IBOutlet weak var mBoardImage: UIImageView!

    @IBOutlet weak var mGraphView: CPTGraphHostingView!

    private var mAudioRecorder:W2STAudioDumpController!;
    private var mAudioPlayback:W2STAudioPlayBackController?;
    private var mPlotController:W2STAudioPlotViewController!;

    private var mFeatureAudio: BlueMSAudioFeatures?
    private var mFeatureBeamForming:BlueSTSDKFeatureBeamForming?=nil;

    private var mButtonToDirectionMap:[UIButton:BlueSTSDKFeatureBeamFormingDirection]!
    private var mLastSelectedDir:BlueSTSDKFeatureBeamFormingDirection = .UNKNOWN;

    private var featureWasEnabled = false
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground),
                                                           name: UIApplication.didEnterBackgroundNotification,
                                                           object: nil)
                    
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActivity),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        mButtonToDirectionMap = [
                mTopButton : .TOP,
                mTopRightButton : .TOP_RIGHT,
                mRightButton : .RIGHT,
                mBottomRightButton : .BOTTOM_RIGHT,
                mBottomButton : .BOTTOM,
                mBottomLeftButton : .BOTTOM_LEFT,
                mLeftButton: .LEFT,
                mTopLeftButton : .TOP_LEFT];

    }
    
    private func displayNucleoDemoSetup(){

        //display only the left and right button
        mTopButton.isHidden=true;
        mTopRightButton.isHidden=true;
        mBottomRightButton.isHidden=true;
        mBottomButton.isHidden=true;
        mBottomLeftButton.isHidden=true;
        mTopLeftButton.isHidden=true;

        mBoardImage.image=self.node.getImage();
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(self.node.type == .nucleo){
            displayNucleoDemoSetup();
        }
    }


    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mPlotController = W2STAudioPlotViewController(view: mGraphView,
                                                      reDrawAfterSample: 3,
        hasDarkTheme: hasDarkTheme());

        startNotification()

    }

    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mAudioRecorder.viewWillDisappear();
        
        stopNotification()
    }
    
    public func startNotification(){
        mFeatureAudio = BlueMSAudioFeatures.extractBestFeatures(from: self.node)
        //if both feature are present enable the audio
        if let featureAudio = mFeatureAudio{
            mAudioPlayback = W2STAudioPlayBackController(featureAudio.audioStream.codecManager);
            featureAudio.audioStream.add(self)
            featureAudio.controlData.add(self)
            featureAudio.controlData.enableNotification()
            featureAudio.audioStream.enableNotification()
            mAudioRecorder = W2STAudioDumpController(audioConf: featureAudio.audioStream.codecManager,parentView: self, menuController: self.menuDelegate);
        }
        
        mFeatureBeamForming = self.node.getFeatureOfType(BlueSTSDKFeatureBeamForming.self) as! BlueSTSDKFeatureBeamForming?
        if let beamForming = mFeatureBeamForming{
            self.node.enableNotification(beamForming);
            beamForming.enablebeamForming(true);
            beamForming.useStrongbeamFormingAlgorithm(true);
            changeDirection(W2STBeamFormingViewController.DEFAULT_DIRECTION);
        }
    }
    
    public func stopNotification(){
        if let featureAudio = mFeatureAudio{
            mAudioPlayback = nil;
            featureAudio.audioStream.remove(self);
            featureAudio.controlData.remove(self);
            featureAudio.audioStream.disableNotification()
            featureAudio.controlData.disableNotification()
        }

        if let beamForming = mFeatureBeamForming{
            self.node.disableNotification(beamForming);
            Thread.sleep(forTimeInterval: 0.1)
            beamForming.enablebeamForming(false);
            
        }
    }

    @IBAction func onDirectionSelected(_ sender: UIButton) {
        if let newDirecition = mButtonToDirectionMap[sender] {
            changeDirection(newDirecition);
        }
    }

    private func changeDirection(_ newDireciton: BlueSTSDKFeatureBeamFormingDirection){
        let prevButton = getButtonForDirection(mLastSelectedDir);
        prevButton?.isSelected=false;
        let nextButton = getButtonForDirection(newDireciton);
        if let button = nextButton, let feature = mFeatureBeamForming{
            button.isSelected=true;
            feature.setDirection(newDireciton);
            mLastSelectedDir = newDireciton;
        }

    }

    private func getButtonForDirection(_ direction:BlueSTSDKFeatureBeamFormingDirection)->UIButton?{
        let dirIndex = mButtonToDirectionMap.firstIndex { $0.value == direction }
        if let index = dirIndex {
            return mButtonToDirectionMap[index].key;
        }else {
            return nil;
        }
    }


    /////////////////////// BlueSTSDKFeatureDelegate ///////////////////////////


    /// call when the BlueSTSDKFeatureAudioADPCM has new data, it will enque the data
    /// to be play by the sistem and send it to the asr service if it is recording the audio
    ///
    /// - Parameters:
    ///   - feature: feature that generate the new data
    ///   - sample: new data
    private func didAudioUpdate(_ feature: BlueSTSDKAudioDecoder, sample: BlueSTSDKFeatureSample){
        if let data = feature.getAudio(from:sample){
            mAudioPlayback?.playSample(sample: data);
            updateAudioPlot(data)
        }//if data!=null
    }

    private func updateAudioPlot(_ sample:Data){
        let value = sample.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> Int16? in
            return ptr.bindMemory(to: Int16.self).first
        }
        if let value = value{
            mPlotController.appendToPlot(value);
        }
    }

    /// call when the BlueSTSDKFeatureAudioADPCMSync has new data, it is used to
    /// correctly decode the data from the the BlueSTSDKFeatureAudioADPCM feature
    ///
    /// - Parameters:
    ///   - feature: feature that generate new data
    ///   - sample: new data
    private func didAudioSyncUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample){
        mFeatureAudio?.audioStream.codecManager.updateParameters(from: sample)
    }

    /// call when a feature gets update
    ///
    /// - Parameters:
    ///   - feature: feature that get update
    ///   - sample: new feature data
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {

        if let decoder = feature as? BlueSTSDKAudioDecoder {
            self.didAudioUpdate(decoder, sample: sample);
        }
        if(feature == mFeatureAudio?.controlData){
            self.didAudioSyncUpdate(feature, sample: sample);
        }
    }
    
    @objc func didEnterForeground() {
        
        mFeatureAudio = BlueMSAudioFeatures.extractBestFeatures(from: self.node)
        
        if !(mFeatureAudio==nil) && node.isEnableNotification((mFeatureAudio?.controlData)!) {
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
