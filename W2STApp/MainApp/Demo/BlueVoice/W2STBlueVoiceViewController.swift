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
import MediaPlayer
import BlueSTSDK
import AVFoundation

/**
 * Audio callback called when an audio buffer can be reused
 * userData: pointer to our SyncQueue with the buffer to reproduce
 * queue: audio queue where the buffer will be played
 * buffer: audio buffer that must be filled
 */
fileprivate func audioCallback(usedData:UnsafeMutableRawPointer?,queue:AudioQueueRef, buffer:AudioQueueBufferRef){

    // SampleQueue *ptr = (SampleQueue*) userData
    let sampleQueuePtr = usedData?.assumingMemoryBound(to: BlueVoiceSyncQueue.self)
    //NSData* data = sampleQueuePtr->pop();
    let data = sampleQueuePtr?.pointee.pop();
    //uint8* temp = (uint8*) buffer->mAudioData
    let temp = buffer.pointee.mAudioData.assumingMemoryBound(to: UInt8.self);
    //memcpy(temp,data)
    data?.copyBytes(to: temp, count: Int(buffer.pointee.mAudioDataByteSize));

    AudioQueueEnqueueBuffer(queue, buffer, 0, nil);
}

public class W2STBlueVoiceViewController: BlueMSDemoTabViewController,
    BlueVoiceSelectDelegate, BlueSTSDKFeatureDelegate, BlueVoiceAsrRequestCallback,
    UITableViewDataSource{
    
    private static let ASR_LANG_PREF="W2STBlueVoiceViewController.AsrLangValue"
    private static let DEFAULT_ASR_LANG=BlueVoiceLangauge.ENGLISH
    private static let CODEC="ADPCM"
    private static let SAMPLING_FREQ_kHz = 8;
    private static let NUM_CHANNELS = UInt32(1);
    /*
     * number of byffer that the sysmte will allocate, each buffer will contain
     * a sample recived trought the ble connection
    */
    private static let NUM_BUFFERS=18;
    private static let SAMPLE_TYPE_SIZE = UInt32(2)//UInt32(MemoryLayout<UInt16>.size);
    //each buffer contains 40 audio sample
    private static let BUFFER_SIZE = (40*SAMPLE_TYPE_SIZE);
    
    /** object used to check if the use has an internet connection */
    private var mInternetReachability: Reachability?;
    
    //////////////////// GUI reference ////////////////////////////////////////
    
    @IBOutlet weak var mCodecLabel: UILabel!
    @IBOutlet weak var mAddAsrKeyButton: UIButton!
    @IBOutlet weak var mSampligFreqLabel: UILabel!
    
    @IBOutlet weak var mAsrStatusLabel: UILabel!
    @IBOutlet weak var mSelectLanguageButton: UIButton!
    
    @IBOutlet weak var mRecordButton: UIButton!
    @IBOutlet weak var mAsrResultsTableView: UITableView!
    @IBOutlet weak var mAsrRequestStatusLabel: UILabel!
    
    private var engine:BlueVoiceASREngine?;
    
    private var mFeatureAudio:BlueSTSDKFeatureAudioADPCM?;
    private var mFeatureAudioSync:BlueSTSDKFeatureAudioADPCMSync?;
    private var mAsrResults:[String] = [];
    
    /////////////////// AUDIO //////////////////////////////////////////////////
    
    //https://developer.apple.com/library/mac/documentation/MusicAudio/Reference/CoreAudioDataTypesRef/#//apple_ref/c/tdef/AudioStreamBasicDescription
    private var mAudioFormat = AudioStreamBasicDescription(
            mSampleRate: Float64(W2STBlueVoiceViewController.SAMPLING_FREQ_kHz*1000),
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kLinearPCMFormatFlagIsSignedInteger,
            mBytesPerPacket: W2STBlueVoiceViewController.SAMPLE_TYPE_SIZE * W2STBlueVoiceViewController.NUM_CHANNELS,
            mFramesPerPacket: 1,
            mBytesPerFrame: W2STBlueVoiceViewController.SAMPLE_TYPE_SIZE*W2STBlueVoiceViewController.NUM_CHANNELS,
            mChannelsPerFrame: W2STBlueVoiceViewController.NUM_CHANNELS,
            mBitsPerChannel: UInt32(8) * W2STBlueVoiceViewController.SAMPLE_TYPE_SIZE,
            mReserved: 0);
    
    
    //audio queue where play the sample
    private var queue:AudioQueueRef?;
    //quueue of audio buffer to play
    private var buffers:[AudioQueueBufferRef?] = Array(repeating:nil, count: NUM_BUFFERS)
    //syncronized queue used to store the audio sample from the node
    // when an audio buffer is free it will be filled with sample from this object
    private var mSyncAudioQueue:BlueVoiceSyncQueue?;
    //variable where store the audio before send to an speech to text service
    private var mRecordData:Data?;
    
    /////////CONTROLLER STATUS////////////
    
    private var mIsMute:Bool=false;
    private var mIsRecording:Bool=false;
    
    override public func viewDidLoad(){
        super.viewDidLoad()
        //set the constant string
        mCodecLabel.text = mCodecLabel.text!+W2STBlueVoiceViewController.CODEC
        mSampligFreqLabel.text = mSampligFreqLabel.text!+String(W2STBlueVoiceViewController.SAMPLING_FREQ_kHz)+" kHz"
        
        newLanguageSelected(getDefaultLanguage());
        mAsrResultsTableView.dataSource=self;
    }
    
    /*
     * enable the ble audio stremaing and initialize the audio queue
     */
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        mFeatureAudio = self.node.getFeatureOfType(BlueSTSDKFeatureAudioADPCM.self) as! BlueSTSDKFeatureAudioADPCM?;
        mFeatureAudioSync = self.node.getFeatureOfType(BlueSTSDKFeatureAudioADPCMSync.self) as!
            BlueSTSDKFeatureAudioADPCMSync?;
        
        //if both feature are present enable the audio
        if let audio = mFeatureAudio, let audioSync = mFeatureAudioSync{
            audio.add(self);
            audioSync.add(self);
            self.node.enableNotification(audio);
            self.node.enableNotification(audioSync);
            initAudioQueue();
            initRecability();
        }
        
    }
    
    /**
     * stop the ble audio streaming and the audio queue
     */
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        if let audio = mFeatureAudio, let audioSync = mFeatureAudioSync{
            deInitAudioQueue();
            audio.remove(self);
            audioSync.remove(self);
            self.node.disableNotification(audio);
            self.node.disableNotification(audioSync);
        }
    }
    
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        engine?.destroyListener();
    }
    
    private func initAudioQueue(){
        
        //create the queue where store the sample
        mSyncAudioQueue = BlueVoiceSyncQueue(size: W2STBlueVoiceViewController.NUM_BUFFERS);
        
        //create the audio queue
        AudioQueueNewOutput(&mAudioFormat,audioCallback, &mSyncAudioQueue,nil, nil, 0, &queue);
        //create the system audio buffer that will be filled with the data inside the mSyncAudioQueue
        for i in 0..<W2STBlueVoiceViewController.NUM_BUFFERS{
           AudioQueueAllocateBuffer(queue!,
                                W2STBlueVoiceViewController.BUFFER_SIZE,
                                &buffers[i]);
            
            if let buffer = buffers[i]{
                buffer.pointee.mAudioDataByteSize = W2STBlueVoiceViewController.BUFFER_SIZE;
                memset(buffer.pointee.mAudioData,0,Int(W2STBlueVoiceViewController.BUFFER_SIZE));
                AudioQueueEnqueueBuffer(queue!, buffer, 0, nil);
            }
        }//for
        //start plaing the audio
        AudioQueueStart(queue!, nil);
        mIsMute=false;
    }
    
    
    /// free the audio initialized audio queues
    private func deInitAudioQueue(){
        AudioQueueStop(queue!, true);
        for i in 0..<W2STBlueVoiceViewController.NUM_BUFFERS{
            if let buffer = buffers[i]{
                AudioQueueFreeBuffer(queue!,buffer);
            }
        }
    }
    
    
    /// function called when the net state change
    ///
    /// - Parameter notifier: object where read the net state
    private func onReachabilityChange(_ notifier:Reachability?){
        let netStatus = notifier?.currentReachabilityStatus();
        
        if let status = netStatus{
            if(status == NotReachable){
                mAsrStatusLabel.text="Disabled";
            }else{
                loadAsrEngine(getDefaultLanguage());
            }
        }
        
    }
    
    
    /// register this class as a observer of the net state
    private func initRecability(){
        
        NotificationCenter.default.addObserver(forName:Notification.Name.reachabilityChanged,
                                               object:nil, queue:nil) {
                notification in
                    if(!(notification.object is Reachability)){
                        return;
                    }
                    let notificaitonObj = notification.object as! Reachability?;
                    self.onReachabilityChange(notificaitonObj);
        }

        mInternetReachability = Reachability.forInternetConnection();
        mInternetReachability?.startNotifier();
        
        onReachabilityChange(mInternetReachability);
        
    }
    
    private func deInitRecability(){
        mInternetReachability?.stopNotifier();
    }
    

    
    /// get the selected language for the asr engine
    ///
    /// - Returns: <#return value description#>
    public func getDefaultLanguage()->BlueVoiceLangauge{
        let lang = loadAsrLanguage();
        return lang ?? W2STBlueVoiceViewController.DEFAULT_ASR_LANG;
        
    }
    
    
    /// called when the user select a new language for the asr
    /// it store this information an reload the engine
    ///
    /// - Parameter language: language selected
    public func newLanguageSelected(_ language:BlueVoiceLangauge){
        loadAsrEngine(language);
        storeAsrLanguage(language);
        mSelectLanguageButton.setTitle(language.rawValue, for:UIControlState.normal)
    }
    
    
    /// load the langiage from the user preference
    ///
    /// - Returns: language stored in the preference or the default one
    private func loadAsrLanguage()->BlueVoiceLangauge?{
        let userPref = UserDefaults.standard;
        let langString = userPref.string(forKey: W2STBlueVoiceViewController.ASR_LANG_PREF);
        if let str = langString{
            return BlueVoiceLangauge(rawValue: str);
        }
        return nil;
    }
    
    
    /// store in the preference the selected language
    ///
    /// - Parameter language: language to store
    private func storeAsrLanguage(_ language:BlueVoiceLangauge){
        let userPref = UserDefaults.standard;
        userPref.setValue(language.rawValue, forKey:W2STBlueVoiceViewController.ASR_LANG_PREF);
    }
    
    
    /// register this class as a delegate of the BlueVoiceSelectLanguageViewController
    ///
    /// - Parameters:
    ///   - segue: segue to prepare
    ///   - sender: object that start the segue
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as? BlueVoiceSelectLanguageViewController;
        if let dialog = dest{
            dialog.delegate=self;
        }
    }
    
    
    /// call when the user press the mute button, it mute/unmute the audio
    ///
    /// - Parameter sender: button where the user click
    @IBAction func onMuteButtonClick(_ sender: UIButton) {
        var img:UIImage?;
        if(!mIsMute){
            img = UIImage(named:"volume_off");
            AudioQueueSetParameter(queue!, kAudioQueueParam_Volume,0.0);
            
        }else{
            img = UIImage(named:"volume_on");
            AudioQueueSetParameter(queue!, kAudioQueueParam_Volume,1.0);
        }
        mIsMute = !mIsMute;
        sender.setImage(img, for:.normal);
    }
    
    
    /// check that the audio engine has a valid service key
    ///
    /// - Returns: true if the service has a valid service key or it does not need a key, 
    /// false otherwise
    private func checkAsrKey() -> Bool{
        if let engine = engine{
            if(engine.needAuthKey && !engine.hasLoadedAuthKey()){
                showErrorMsg("Please add the engine key", title: "Engine Fail", closeController: false);
                return false;
            }else{
                return true;
            }
        }
        return false;
        
    }
    
    
    /// Start the voice to text, if the engine can manage the continuos recognition
    private func onContinuousRecognizerStart(){
        guard checkAsrKey() else{
            return;
        }
        mRecordButton.setTitle("Stop recongition", for: .normal);
        if(!mIsMute){
            AudioQueueSetParameter(queue!, kAudioQueueParam_Volume,0.0);
        }
        engine?.startListener();
        mIsRecording=true;
    }
    
    
    /// Stop a continuos recognition
    private func onContinuousRecognizerStop(){
        mIsRecording=false;
        if(!mIsMute){
            AudioQueueSetParameter(queue!, kAudioQueueParam_Volume,1.0);
        }
        if let engine = engine{
            engine.stopListener();
            setRecordButtonTitle(engine);
        }
    }
    
    
    /// Start a non continuos voice to text service
    private func onRecognizerStart(){
        guard checkAsrKey() else{
            return;
        }
        if(!mIsMute){
            AudioQueueSetParameter(queue!, kAudioQueueParam_Volume,0.0);
        }
        mRecordData = Data();
        engine?.startListener();
        mIsRecording=true;
    }
    
    /// Stop a non continuos voice to text service, and send the recorded data 
    /// to the service
    private func onRecognizerStop(){
        mIsRecording=false;
        if(!mIsMute){
            AudioQueueSetParameter(queue!, kAudioQueueParam_Volume,1.0);
        }
        
        if let engine = engine{
            if(mRecordData != nil){
                _ = engine.sendASRRequest(audio: mRecordData!, callback: self);
                mRecordData=nil;
            }
            engine.stopListener();
            setRecordButtonTitle(engine);
        }
    }
    
    
    /// set the starting value for the record button
    ///
    /// - Parameter asrEngine: voice to text engine that will be used
    private func setRecordButtonTitle(_ asrEngine: BlueVoiceASREngine!){
        let recorTitle = asrEngine.hasContinuousRecognizer ? "Start recongition" : "Keep press to record"
        mRecordButton.setTitle(recorTitle, for: .normal);
    }
    
    
    /// call when the user release the record button, it stop a non contiuos
    /// voice to text
    ///
    /// - Parameter sender: button released
    @IBAction func onRecordButtonRelease(_ sender: UIButton) {
        if (engine?.hasContinuousRecognizer == false){
            onRecognizerStop();
        }
        
    }
    
    
    /// call when the user press the record buttom, it start the voice to text
    /// service
    ///
    /// - Parameter sender: button pressed
    @IBAction func onRecordButtonPressed(_ sender: UIButton) {
        if let hasContinuousRecognizer = engine?.hasContinuousRecognizer{
            if (hasContinuousRecognizer){
                if(mIsRecording){
                    onContinuousRecognizerStop();
                }else{
                    onContinuousRecognizerStart();
                }//if isRecording
            }else{
                onRecognizerStart();
            }//if hasContinuos
        }//if let
    }//onRecordButtonPressed
    
    
    
    /// call when the user press the add key button, it show the popup to insert
    /// the key
    ///
    /// - Parameter sender: button pressed
    @IBAction func onAddAsrKeyButtonClick(_ sender: UIButton) {
        
        let insertKeyDialog = engine?.getAuthKeyDialog();
        if let viewContoller = insertKeyDialog {
            viewContoller.modalPresentationStyle = .popover;
            self.present(viewContoller, animated: false, completion: nil);
            
            let presentationController = viewContoller.popoverPresentationController;
            presentationController?.sourceView = sender;
            presentationController?.sourceRect = sender.bounds
        }//if let
    }
    
    
    
    /// create a new voice to text service that works with the selected language
    ///
    /// - Parameter language: voice language
    private func loadAsrEngine(_ language:BlueVoiceLangauge){
        if(engine != nil){
            engine!.destroyListener();
        }
        let samplingRateHz = UInt((W2STBlueVoiceViewController.SAMPLING_FREQ_kHz*1000))
        engine = BlueVoiceASREngineUtil.getEngine(samplingRateHz:samplingRateHz,language: language);
        if let asrEngine = engine{
            mAsrStatusLabel.text = asrEngine.name;
            mAddAsrKeyButton.isHidden = !asrEngine.needAuthKey;
            let asrTitle = asrEngine.hasLoadedAuthKey() ? "Change Service Key" : "Add Service Key";
            mAddAsrKeyButton.setTitle(asrTitle, for:UIControlState.normal)
            setRecordButtonTitle(asrEngine);
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
            mSyncAudioQueue?.push(data: data)
            if(mIsRecording){
                if(engine!.hasContinuousRecognizer){
                    _ = engine!.sendASRRequest(audio: data, callback: self);
                }else{
                    if(mRecordData != nil){
                        objc_sync_enter(mRecordData);
                            mRecordData?.append(data);
                        objc_sync_exit(mRecordData);
                    }// mRecordData!=null
                }
            }//if is Recording
        }//if data!=null
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
    
    
//////////////////////////BlueVoiceAsrRequestCallback///////////////////////////
    
    
    /// callback call when the asr engin has a positive results, the reult table
    /// will be updated wit the new results
    ///
    /// - Parameter text: world say from the user
    func onAsrRequestSuccess(withText text:String ){
        print("ASR Success:"+text);
        mAsrResults.append(text);
        DispatchQueue.main.async {
            self.mAsrResultsTableView.reloadData();
            self.mAsrRequestStatusLabel.isHidden=true;
        }
    }
    
    
    /// callback when some error happen during the voice to text translation
    ///
    /// - Parameter error: error during the voice to text translation
    func onAsrRequestFail(error:BlueVoiceAsrRequestError){
        print("ASR Fail:"+error.rawValue.description);
        DispatchQueue.main.async {
            self.mAsrRequestStatusLabel.text = error.description;
            self.mAsrRequestStatusLabel.isHidden=false;
            if(self.mIsRecording){ //if an error happen during the recording, stop it
                if(self.engine!.hasContinuousRecognizer){
                    self.onContinuousRecognizerStop();
                }else{
                    self.onRecognizerStop();
                }
            }
        }
    }
    
    /////////////////////// TABLE VIEW DATA DELEGATE /////////////////////////
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return mAsrResults.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
    
        var cell = tableView.dequeueReusableCell(withIdentifier: "AsrResult");
    
        if (cell == nil){
            cell = UITableViewCell(style: .default, reuseIdentifier: "AsrResult");
            cell?.selectionStyle = .none;
        }
     
        cell?.textLabel?.text=mAsrResults[indexPath.row];
        
        return cell!;
    
    }

    

}
