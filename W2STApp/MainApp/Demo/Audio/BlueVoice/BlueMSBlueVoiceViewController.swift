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

    private static let CODEC="ADPCM"
    private static let DEFAULT_DIRECTION = BlueSTSDKFeatureBeamFormingDirection.RIGHT;

    private static let PLOT_AUDIO_BUFFER_SIZE = 100*40;
    private static let PLOT_AUDIO_SCALE_FACTOR = 1.0/32768.0;
    
    private var mBundle:Bundle!;

    //////////////////// GUI reference ////////////////////////////////////////
    
    @IBOutlet weak var mCodecLabel: UILabel!
    @IBOutlet weak var mSampligFreqLabel: UILabel!
    
    @IBOutlet weak var mEnableBeamFormingSwitch: UISwitch!

    @IBOutlet weak var mAudioPlot: CPTGraphHostingView!
    private var mAudioGraph: W2STAudioPlotViewController!
    
    private var mRecordController:W2STAudioDumpController!;
    
    private var mFeatureAudio:BlueSTSDKFeatureAudioADPCM?;
    private var mFeatureAudioSync:BlueSTSDKFeatureAudioADPCMSync?;
    private var mFeatureBeamForming:BlueSTSDKFeatureBeamForming?;
    
    /////////////////// AUDIO //////////////////////////////////////////////////

    //variable where store the audio before send to an speech to text service
    private let mAudioConf = W2STAudioStreamConfig.blueVoiceConf;
    private var mRecordData:Data?;
    private var mAudioPlayBack:W2STAudioPlayBackController?;

    /////////CONTROLLER STATUS////////////

    private var mMuteState:Bool=false;
    
    override public func viewDidLoad(){
        super.viewDidLoad()
        mBundle = Bundle(for: type(of: self));

        //set the constant string
        mCodecLabel.text = mCodecLabel.text!+BlueMSBlueVoiceViewController.CODEC
        mSampligFreqLabel.text = mSampligFreqLabel.text!+String(mAudioConf.sampleRate/1000)+" kHz"
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mRecordController = W2STAudioDumpController(audioConf: mAudioConf, parentView: self, menuController: self.menuDelegate);
    }

    /*
     * enable the ble audio stremaing and initialize the audio queue
     */
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);

        mAudioGraph = W2STAudioPlotViewController(view: mAudioPlot, reDrawAfterSample: 3);

        mFeatureAudio = self.node.getFeatureOfType(BlueSTSDKFeatureAudioADPCM.self) as! BlueSTSDKFeatureAudioADPCM?;
        mFeatureAudioSync = self.node.getFeatureOfType(BlueSTSDKFeatureAudioADPCMSync.self) as!
            BlueSTSDKFeatureAudioADPCMSync?;


        //if both feature are present enable the audio
        if let audio = mFeatureAudio, let audioSync = mFeatureAudioSync{
            mAudioPlayBack = W2STAudioPlayBackController(W2STAudioStreamConfig.blueVoiceConf);
            audio.add(self);
            audioSync.add(self);
            self.node.enableNotification(audio);
            self.node.enableNotification(audioSync);

        }

        mFeatureBeamForming = self.node.getFeatureOfType(BlueSTSDKFeatureBeamForming.self) as! BlueSTSDKFeatureBeamForming?
        if let beamForming = mFeatureBeamForming{
            self.node.enableNotification(beamForming)
            mEnableBeamFormingSwitch.isEnabled=true;
            mEnableBeamFormingSwitch.isOn=false;
        }
        
    }
    
    /**
     * stop the ble audio streaming and the audio queue
     */
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        mRecordController.viewWillDisappear();
        if let audio = mFeatureAudio, let audioSync = mFeatureAudioSync{
            mAudioPlayBack = nil;
            audio.remove(self);
            audioSync.remove(self);
            self.node.disableNotification(audio);
            self.node.disableNotification(audioSync);
        }
        if let beamForming = mFeatureBeamForming{
            self.node.disableNotification(beamForming);
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
    private func didAudioUpdate(_ feature: BlueSTSDKFeatureAudioADPCM, sample: BlueSTSDKFeatureSample){
        let sampleData = BlueSTSDKFeatureAudioADPCM.getLinearPCMAudio(sample);
        if let data = sampleData{
            mAudioPlayBack?.playSample(sample: data);
            mRecordController.dumpAudioSample(sample: data);
            
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
    private func didAudioSyncUpdate(_ feature: BlueSTSDKFeatureAudioADPCMSync, sample: BlueSTSDKFeatureSample){
        mFeatureAudio?.audioManager.setSyncParam(sample);
    }
    
    
    /// call when a feature gets update
    ///
    /// - Parameters:
    ///   - feature: feature that get update
    ///   - sample: new feature data
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        if(feature .isKind(of: BlueSTSDKFeatureAudioADPCM.self)){
            self.didAudioUpdate(feature as! BlueSTSDKFeatureAudioADPCM, sample: sample);
        }
        if(feature .isKind(of: BlueSTSDKFeatureAudioADPCMSync.self)){
            self.didAudioSyncUpdate(feature as! BlueSTSDKFeatureAudioADPCMSync, sample: sample);
        }
    }
    
}
