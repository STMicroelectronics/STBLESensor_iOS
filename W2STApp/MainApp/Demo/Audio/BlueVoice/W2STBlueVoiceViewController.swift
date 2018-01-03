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

public class W2STBlueVoiceViewController: BlueMSDemoTabViewController,
    BlueVoiceSelectEngineDelegate, BlueSTSDKFeatureDelegate, BlueVoiceAsrRequestCallback,
UITableViewDataSource{

    private static let DEFAULT_DIRECTION = BlueSTSDKFeatureBeamFormingDirection.RIGHT;
    private static let ASR_LANG_PREF="W2STBlueVoiceViewController.AsrLangValue"
    private static let DEFAULT_ASR_LANG=BlueVoiceLanguage.ENGLISH_US
    private static let ASR_ENGINE_PREF="W2STBlueVoiceViewController.AsrEngineValue"
    private static let DEFAULT_ASR_ENGINE=BlueVoiceGoogleASREngine.engineDescription
    private static let CODEC="ADPCM"

    private static let PLOT_AUDIO_BUFFER_SIZE = 100*40;
    private static let PLOT_AUDIO_SCALE_FACTOR = 1.0/32768.0;

    private static let AVAILABLE_ENGINE_DESC = [
        BlueVoiceGoogleASREngine.engineDescription,
        BlueVoiceIBMWatsonASREngine.engineDescription
    ]

    /** object used to check if the use has an internet connection */
    private var mInternetReachability: Reachability?;
    
    private var mBundle:Bundle!;

    //////////////////// GUI reference ////////////////////////////////////////
    
    @IBOutlet weak var mCodecLabel: UILabel!
    @IBOutlet weak var mAddAsrKeyButton: UIButton!
    @IBOutlet weak var mSampligFreqLabel: UILabel!
    
    @IBOutlet weak var mAsrStatusLabel: UILabel!
    @IBOutlet weak var mSelectLanguageButton: UIButton!
    
    @IBOutlet weak var mRecordButton: UIButton!
    @IBOutlet weak var mAsrResultsTableView: UITableView!
    @IBOutlet weak var mAsrRequestStatusLabel: UILabel!
    
    @IBOutlet weak var mEnableBeamFormingSwitch: UISwitch!

    @IBOutlet weak var mAudioPlot: CPTGraphHostingView!
    private var mAudioGraph: W2STAudioPlotViewController!
    
    private var mRecordController:W2STAudioDumpController!;
    private var engine:BlueVoiceASREngine?;
    
    private var mFeatureAudio:BlueSTSDKFeatureAudioADPCM?;
    private var mFeatureAudioSync:BlueSTSDKFeatureAudioADPCMSync?;
    private var mFeatureBeamForming:BlueSTSDKFeatureBeamForming?;
    private var mAsrResults:[String] = [];
    
    private var waitingDialog:MBProgressHUD?;


    /////////////////// AUDIO //////////////////////////////////////////////////

    //variable where store the audio before send to an speech to text service
    private let mAudioConf = W2STAudioStreamConfig.blueVoiceConf;
    private var mRecordData:Data?;
    private var mAudioPlayBack:W2STAudioPlayBackController?;

    /////////CONTROLLER STATUS////////////

    private var mMuteState:Bool=false;
    private var mIsRecording:Bool=false;
    
    override public func viewDidLoad(){
        super.viewDidLoad()
        mBundle = Bundle(for: type(of: self));

        //set the constant string
        mCodecLabel.text = mCodecLabel.text!+W2STBlueVoiceViewController.CODEC
        mSampligFreqLabel.text = mSampligFreqLabel.text!+String(mAudioConf.sampleRate/1000)+" kHz"
        mAsrResultsTableView.dataSource=self;

        onEngineSelected(engine: getDefaultEngine(), language: getDefaultLanguage())
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

            initRecability();
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
            beamForming.enableBeanForming(false);
        }
    }
    
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        engine?.destroyListener();
    }

    /// function called when the net state change
    ///
    /// - Parameter notifier: object where read the net state
    private func onReachabilityChange(_ notifier:Reachability?){
        let netStatus = notifier?.currentReachabilityStatus();
        
        if let status = netStatus{
            if(status == NotReachable){

                let text = NSLocalizedString("Disabled", tableName: nil,
                                  bundle: mBundle,
                                  value: "Disabled", comment: "Disabled");
                mAsrStatusLabel.text = text;
                mRecordButton.isEnabled=false;
            }else{
                mRecordButton.isEnabled=true;
                loadAsrEngine(getDefaultEngine(),getDefaultLanguage());
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
    /// - Returns:
    public func getDefaultLanguage()->BlueVoiceLanguage{
        let lang = loadAsrLanguage();
        return lang ?? W2STBlueVoiceViewController.DEFAULT_ASR_LANG;
    }

    private func loadAsrEngineDesc()->BlueVoiceASRDescription?{
        let userPref = UserDefaults.standard;
        let engineName = userPref.string(forKey: W2STBlueVoiceViewController.ASR_ENGINE_PREF);
        if let str = engineName{
            return W2STBlueVoiceViewController.AVAILABLE_ENGINE_DESC.filter({desc in desc.name==str}).first;
        }
        return nil;
    }
    
    private func storeAsrEngine(engineDesc:BlueVoiceASRDescription){
        let userPref = UserDefaults.standard;
        userPref.setValue(engineDesc.name,forKey:W2STBlueVoiceViewController.ASR_ENGINE_PREF);
    }

    private func getDefaultEngine()->BlueVoiceASRDescription{
        let desc = loadAsrEngineDesc();
        return desc ?? W2STBlueVoiceViewController.DEFAULT_ASR_ENGINE;
    }
    
    
    /// load the langiage from the user preference
    ///
    /// - Returns: language stored in the preference or the default one
    private func loadAsrLanguage()->BlueVoiceLanguage?{
        let userPref = UserDefaults.standard;
        let langString = userPref.string(forKey: W2STBlueVoiceViewController.ASR_LANG_PREF);
        if let str = langString{
            return BlueVoiceLanguage(rawValue: str);
        }
        return nil;
    }
    
    
    /// store in the preference the selected language
    ///
    /// - Parameter language: language to store
    private func storeAsrLanguage(_ language:BlueVoiceLanguage){
        let userPref = UserDefaults.standard;
        userPref.setValue(language.rawValue, forKey:W2STBlueVoiceViewController.ASR_LANG_PREF);
    }
    
    
    /// register this class as a delegate of the BlueVoiceSelectLanguageViewController
    ///
    /// - Parameters:
    ///   - segue: segue to prepare
    ///   - sender: object that start the segue
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as? BlueVoiceSelectEngineViewController;
        if let dialog = dest{
            dialog.delegate=self;
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
            feature.enableBeanForming(sender.isOn);
            if(sender.isOn){
                feature.setDirection(W2STBlueVoiceViewController.DEFAULT_DIRECTION);
                feature.useStrongBeanFormingAlgorithm(true);
            }
        }
    }
    
    /// check that the audio engine has a valid service key
    ///
    /// - Returns: true if the service has a valid service key or it does not need a key, 
    /// false otherwise
    private func checkAsrKey() -> Bool{
        if let engine = engine{
            if(engine.engineDesc.needAuthKey && !engine.hasLoadedAuthKey()){
                let msg = NSLocalizedString("Please add the engine key",
                                            tableName: nil,
                                            bundle: mBundle,
                                            value: "Please add the engine key",
                                            comment: "Please add the engine key");
                let title = NSLocalizedString("Engine Fail",
                                              tableName: nil,
                                              bundle: mBundle,
                                              value: "Engine Fail",
                                              comment: "Engine Fail");

                showErrorMsg( msg, title:title, closeController: false);
                return false;
            }else{
                return true;
            }
        }
        return false;
        
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
    
    
    /// Start the voice to text, if the engine can manage the continuos recognition
    private func onContinuousRecognizerStart(){
        guard checkAsrKey() else{
            return;
        }

        mutePlaybackIfNeeded();
        waitingDialog = MBProgressHUD.showAdded(to: self.view, animated: false)
        engine?.startListener(onConnect: self.onConnectionDone);
    }
    
    private func onConnectionDone( _ error:Error?){
        mIsRecording=error==nil;
        DispatchQueue.main.async {
            if error != nil{
                self.showErrorMsg("ASR Engine Error", title: error!.localizedDescription, closeController: false)
            }
            self.waitingDialog?.hide(animated: true);
            self.setRecordButtonTitle(self.engine); //reset the button name
        }
    }

    /// Stop a continuos recognition
    private func onContinuousRecognizerStop(){
        mIsRecording=false;
        unMutePlaybackIfNeeded();
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
        mutePlaybackIfNeeded();
        mRecordData = Data();
        engine?.startListener(onConnect: self.onConnectionDone);
    }
    
    /// Stop a non continuos voice to text service, and send the recorded data 
    /// to the service
    private func onRecognizerStop(){
        mIsRecording=false;
        unMutePlaybackIfNeeded();
        
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
        if(mIsRecording){
            let title =  NSLocalizedString("Stop recongition",
                                       tableName: nil,
                                       bundle: mBundle,
                                       value: "Stop recongition",
                                       comment: "Stop recongition");

            mRecordButton.setTitle(title, for: .normal);
        }else{
            let startRec = NSLocalizedString("Start recongition",
                                         tableName: nil,
                                         bundle: mBundle,
                                         value: "Start recongition",
                                         comment: "Start recongition");
            let keepPress = NSLocalizedString("Keep press to record",
                                          tableName: nil,
                                          bundle: mBundle,
                                          value: "Keep press to record",
                                          comment: "Keep press to record");
            let recorTitle = asrEngine.engineDesc.hasContinuousRecognizer ? startRec : keepPress;
            mRecordButton.setTitle(recorTitle, for: .normal);
        }
    }
    
    
    /// call when the user release the record button, it stop a non contiuos
    /// voice to text
    ///
    /// - Parameter sender: button released
    @IBAction func onRecordButtonRelease(_ sender: UIButton) {
        if (engine?.engineDesc.hasContinuousRecognizer == false){
            onRecognizerStop();
        }
    }
    
    
    /// call when the user press the record buttom, it start the voice to text
    /// service
    ///
    /// - Parameter sender: button pressed
    @IBAction func onRecordButtonPressed(_ sender: UIButton) {
        if let hasContinuousRecognizer = engine?.engineDesc.hasContinuousRecognizer{
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
    private func loadAsrEngine(_ engineDesc:BlueVoiceASRDescription ,_ language:BlueVoiceLanguage){
        if(engine != nil){
            engine!.destroyListener();
        }
        let samplingRateHz = UInt(mAudioConf.sampleRate)
        engine = engineDesc.build(withLanguage: language, samplingRateHz: samplingRateHz);
        if let asrEngine = engine{
            mAddAsrKeyButton.isHidden = !asrEngine.engineDesc.needAuthKey;

            let changeService = NSLocalizedString("Change Service Key",
                                                  tableName: nil,
                                                  bundle: mBundle,
                                                  value: "Change Service Key",
                                                  comment: "Change Service Key");
            let addServiceKey = NSLocalizedString("Add Service Key",
                                                  tableName: nil,
                                                  bundle: mBundle,
                                                  value: "Add Service Key",
                                                  comment: "Add Service Key");

            let asrTitle = asrEngine.hasLoadedAuthKey() ? changeService : addServiceKey;

            mAddAsrKeyButton.setTitle(asrTitle, for:UIControlState.normal)
            setRecordButtonTitle(asrEngine);
        }
    }
    
    /////////////////////// BlueVoiceSelectEngineViewController //////////////////////////
    func onEngineSelected(engine: BlueVoiceASRDescription, language: BlueVoiceLanguage) {
        storeAsrLanguage(language)
        storeAsrEngine(engineDesc: engine);
        loadAsrEngine(engine, language);
        mAsrStatusLabel.text = String(format:"%@ - %@",engine.name,language.rawValue);
    }

    func getAvailableEngine() -> [BlueVoiceASRDescription] {
        return W2STBlueVoiceViewController.AVAILABLE_ENGINE_DESC;
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
            if(mIsRecording){
                if(engine!.engineDesc.hasContinuousRecognizer){
                    _ = engine!.sendASRRequest(audio: data, callback: self);
                }else{
                    if(mRecordData != nil){
                        objc_sync_enter(mRecordData!);
                            mRecordData?.append(data);
                        objc_sync_exit(mRecordData!);
                    }// mRecordData!=null
                }
            }//if is Recording

            updateAudioPlot(data);

        }//if data!=null
    }


    private func updateAudioPlot(_ sample:Data){

        let value = sample.withUnsafeBytes { (ptr: UnsafePointer<Int16>) -> Int16 in
            return ptr.pointee;
        }

        mAudioGraph.appendToPlot(value);

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
    
    
    private func getErrorDescription(_ error:BlueVoiceAsrRequestError )->String{
        switch error {
            case .NO_ERROR:
                return NSLocalizedString("Success",
                                         tableName: nil,
                                         bundle: mBundle,
                                         value: "Success",
                                         comment: "Success");
            case .IO_CONNECTION_ERROR:
                return NSLocalizedString("I/O Error",
                              tableName: nil,
                              bundle: mBundle,
                              value: "I/O Error",
                              comment: "I/O Error");
            case .RESPONSE_ERROR:
                return  NSLocalizedString("Invalid Response",
                                      tableName: nil,
                                      bundle: mBundle,
                                      value: "Invalid Response",
                                      comment: "Invalid Response");
            case .REQUEST_FAILED:
                return  NSLocalizedString("Invalid Request",
                                      tableName: nil,
                                      bundle: mBundle,
                                      value: "Invalid Request",
                                      comment: "Invalid Request");
            case .LOW_CONFIDENCE:
                return  NSLocalizedString("Low Confidence Response",
                                      tableName: nil,
                                      bundle: mBundle,
                                      value: "Low Confidence Response",
                                      comment: "Low Confidence Response");
            case .NOT_RECOGNIZED:
                return  NSLocalizedString("Not Recognizer",
                                      tableName: nil,
                                      bundle: mBundle,
                                      value: "Not Recognizer",
                                      comment: "Not Recognizer");
            case .NETWORK_PROBLEM:
                return  NSLocalizedString("Network Error",
                                      tableName: nil,
                                      bundle: mBundle,
                                      value: "Network Error",
                                      comment: "Network Error");

        }
    }

    /// callback when some error happen during the voice to text translation
    ///
    /// - Parameter error: error during the voice to text translation
    func onAsrRequestFail(error:BlueVoiceAsrRequestError){
        let errorDesc = getErrorDescription(error);
        print("ASR Fail:"+errorDesc);
        DispatchQueue.main.async {
            self.mAsrRequestStatusLabel.text = errorDesc;
            self.mAsrRequestStatusLabel.isHidden=false;
            if(self.mIsRecording){ //if an error happen during the recording, stop it
                if(self.engine!.engineDesc.hasContinuousRecognizer){
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
