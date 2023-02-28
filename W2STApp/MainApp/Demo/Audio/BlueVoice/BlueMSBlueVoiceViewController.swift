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
import MediaPlayer
import CorePlot
import BlueSTSDK
import BlueSTSDK_Gui

public class BlueMSBlueVoiceViewController: BlueMSDemoTabViewController,
    BlueSTSDKFeatureDelegate{

    private static let DEFAULT_DIRECTION = BlueSTSDKFeatureBeamFormingDirection.RIGHT;
    
    private var mBundle:Bundle!;

    //////////////////// GUI reference ////////////////////////////////////////
    
    @IBOutlet weak var mCodecLabel: UILabel!
    @IBOutlet weak var mSampligFreqLabel: UILabel!
    
    @IBOutlet weak var mEnableBeamFormingSwitch: UISwitch!

    @IBOutlet weak var mAudioPlot: CPTGraphHostingView!
    private var mAudioGraph: W2STAudioPlotViewController!
    
    private var mRecordController:W2STAudioDumpController?;
    
    private var mAudioFeature : BlueMSAudioFeatures?
    private var mFeatureBeamForming:BlueSTSDKFeatureBeamForming?;
    
    private var featureWasEnabled = false
    
    /////////////////// AUDIO //////////////////////////////////////////////////

    //variable where store the audio before send to an speech to text service
    private var mRecordData:Data?;
    private var mAudioPlayBack:W2STAudioPlayBackController?;

    /////////CONTROLLER STATUS////////////

    private var mMuteState:Bool=false;
    
    override public func viewDidLoad(){
        super.viewDidLoad()
        mBundle = Bundle(for: type(of: self));
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground),
                                                           name: UIApplication.didEnterBackgroundNotification,
                                                           object: nil)
                    
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActivity),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    @objc func didEnterForeground() {
        mAudioFeature = BlueMSAudioFeatures.extractBestFeatures(from: self.node)
        
        if !(mAudioFeature==nil) && node.isEnableNotification((mAudioFeature?.controlData)!) {
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
    
    private func displayCodecSettings(_ settings:BlueSTSDKAudioCodecSettings){
        mCodecLabel.text = mCodecLabel.text!+settings.codecName
        mSampligFreqLabel.text = mSampligFreqLabel.text!+String(settings.samplingFequency/1000)+" kHz"
    }

    /*
     * enable the ble audio stremaing and initialize the audio queue
     */
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);

        mAudioGraph = W2STAudioPlotViewController(view: mAudioPlot,
                                                  reDrawAfterSample: 3,
                                                  hasDarkTheme: hasDarkTheme());

        mAudioFeature = BlueMSAudioFeatures.extractBestFeatures(from: self.node)

        startNotification()
        
    }
    
    /**
     * stop the ble audio streaming and the audio queue
     */
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        mRecordController?.viewWillDisappear()
        stopNotification()
    }
    
    public func startNotification(){
        //if both feature are present enable the audio
        if let audioFeature = mAudioFeature{
            mRecordController = W2STAudioDumpController(audioConf: audioFeature.audioStream.codecManager, parentView: self, menuController: self.menuDelegate);
            mAudioPlayBack = W2STAudioPlayBackController(audioFeature.audioStream.codecManager);
            displayCodecSettings(audioFeature.audioStream.codecManager)
            audioFeature.audioStream.add(self);
            audioFeature.controlData.add(self);
            audioFeature.controlData.enableNotification()
            audioFeature.audioStream.enableNotification()
        }

        mFeatureBeamForming = self.node.getFeatureOfType(BlueSTSDKFeatureBeamForming.self) as! BlueSTSDKFeatureBeamForming?
        if let beamForming = mFeatureBeamForming{
            self.node.enableNotification(beamForming)
            mEnableBeamFormingSwitch.isEnabled=true;
            mEnableBeamFormingSwitch.isOn=false;
        }
    }
    
    public func stopNotification(){
        if let audioFeature = mAudioFeature{
            mAudioPlayBack = nil;
            audioFeature.audioStream.remove(self);
            audioFeature.controlData.remove(self);
            audioFeature.audioStream.disableNotification()
            audioFeature.controlData.disableNotification()
        }
        if let beamForming = mFeatureBeamForming{
            self.node.disableNotification(beamForming);
            Thread.sleep(forTimeInterval: 0.1)
            beamForming.enablebeamForming(false);
        }
    }
    
    /// call when the user press the mute button, it mute/unmute the audio
    ///
    /// - Parameter sender: button where the user click
    @IBAction func onMuteButtonClick(_ sender: UIButton) {
        if let playback = mAudioPlayBack{
            var img:UIImage?;
            if(playback.mute){
                img = UIImage(named:"volume_on");
            }else{
                img = UIImage(named:"volume_off");
            }
            playback.mute = !playback.mute
            sender.setImage(img, for:.normal);
        }
    }


    @IBAction func onBeamFormingStateChange(_ sender: UISwitch) {
        if let feature = mFeatureBeamForming{
            feature.enablebeamForming(sender.isOn);
            if(sender.isOn){
                feature.setDirection(BlueMSBlueVoiceViewController.DEFAULT_DIRECTION);
                feature.useStrongbeamFormingAlgorithm(true);
            }
        }
    }
    
    private func mutePlaybackIfNeeded(){
        if let playBack = mAudioPlayBack{
            mMuteState = playBack.mute;
            if(!mMuteState){
                playBack.mute=true;
            }
        }
    }

    private func unMutePlaybackIfNeeded(){
        if let playback = mAudioPlayBack{
            playback.mute=mMuteState;
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
        let sampleData = feature.getAudio(from: sample);
        if let data = sampleData{
            mAudioPlayBack?.playSample(sample: data);
            mRecordController?.dumpAudioSample(sample: data);
            updateAudioPlot(data);
        }//if data!=null
    }


    private func updateAudioPlot(_ sample:Data){
        let value = sample.withUnsafeBytes { (ptr: UnsafeRawBufferPointer) -> Int16? in
            return ptr.bindMemory(to: Int16.self).first
        }
        if let value = value{
            mAudioGraph.appendToPlot(value);
        }
    }
    
    /// call when the BlueSTSDKFeatureAudioADPCMSync has new data, it is used to 
    /// correclty decode the data from the the BlueSTSDKFeatureAudioADPCM feature
    ///
    /// - Parameters:
    ///   - feature: feature that generate new data
    ///   - sample: new data
    private func didAudioSyncUpdate(_ feature: BlueSTSDKFeature,
                                    sample: BlueSTSDKFeatureSample){
        mAudioFeature?.audioStream.codecManager.updateParameters(from: sample)
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
        if(feature == mAudioFeature?.controlData){
            self.didAudioSyncUpdate(feature, sample: sample);
        }
    }
    
}
