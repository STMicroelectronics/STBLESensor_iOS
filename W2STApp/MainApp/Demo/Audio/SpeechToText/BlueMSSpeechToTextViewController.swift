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
import BlueSTSDK
import BlueSTSDK_Gui

public class BlueMSSpeechToTextViewController: BlueMSDemoTabViewController,
    BlueVoiceSelectEngineDelegate, BlueSTSDKFeatureDelegate,
    BlueVoiceAsrRequestCallback, UITableViewDataSource{

    private static let DEFAULT_DIRECTION = BlueSTSDKFeatureBeamFormingDirection.RIGHT;
    private static let ASR_LANG_PREF="W2STBlueVoiceViewController.AsrLangValue"
    private static let DEFAULT_ASR_LANG=BlueVoiceLanguage.ENGLISH_US
    private static let ASR_ENGINE_PREF="W2STBlueVoiceViewController.AsrEngineValue"
    private static let DEFAULT_ASR_ENGINE=BlueVoiceGoogleASREngine.engineDescription

    private static let DISABLED_STR = {
       return  NSLocalizedString("Disabled",
                                 tableName: nil,
                                 bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                                 value: "Disabled",
                                 comment: "Disabled");
    }();
    
    private static let CONNECTED = {
        return  NSLocalizedString("Connected",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                                  value: "Connected",
                                  comment: "Connected");
    }();
    
    private static let CONNECTING = {
        return  NSLocalizedString("Connecting",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                                  value: "Connecting",
                                  comment: "Connecting");
    }();
    
    private static let DISCONNECTED = {
        return  NSLocalizedString("Disconnected",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                                  value: "Disconnected",
                                  comment: "Disconnected");
    }();
    
    private static let SENDING_DATA = {
        return  NSLocalizedString("Sending data",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                                  value: "Sending data",
                                  comment: "Sending data");
    }();
    
    private static let RECORDING = {
        return  NSLocalizedString("Recording",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                                  value: "Recording",
                                  comment: "Recording");
    }();
    
    private static let ENGINE_FAIL_DIALOG_TITLE = {
       return NSLocalizedString("Engine Fail",
                          tableName: nil,
                          bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                          value: "Engine Fail",
                          comment: "Engine Fail");
    }()
    
    private static let ENGINE_KEY_REQUIRED = {
        return NSLocalizedString("Please add the engine key",
                          tableName: nil,
                          bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                          value: "Please add the engine key",
                          comment: "Please add the engine key");
    }()
    
    private static let STOP_RECOGNITION = {
        return NSLocalizedString("Stop recongition",
                          tableName: nil,
                          bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                          value: "Stop recongition",
                          comment: "Stop recongition");
    }()

    private static let START_RECOGNITION = {
        return NSLocalizedString("Start recongition",
                                 tableName: nil,
                                 bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                                 value: "Start recongition",
                                 comment: "Start recongition");
    }()

    private static let KEEP_PRESS = {
        return NSLocalizedString("Keep press to record",
                          tableName: nil,
                          bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                          value: "Keep press to record",
                          comment: "Keep press to record");
    }()
    
    private static let CHANGE_SERVICE_KEY = {
        return NSLocalizedString("Change Key",
                          tableName: nil,
                          bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                          value: "Change Key",
                          comment: "Change Key");
    }()
    
    private static let ADD_SERVICE_KEY = {
        return NSLocalizedString("Add Key",
                                 tableName: nil,
                                 bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                                 value: "Add Key",
                                 comment: "Add Key");
    }()
    
    private static let ERRROR_NO_ERROR = {
        return NSLocalizedString("Success",
                                 tableName: nil,
                                 bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                                 value: "Success",
                                 comment: "Success");
    }()

    private static let ERRROR_CONNECTION_ERROR = {
        return NSLocalizedString("I/O Error",
                                 tableName: nil,
                                 bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                                 value: "I/O Error",
                                 comment: "I/O Error");
    }()
    
    private static let ERRROR_RESPONSE_ERROR = {
        return  NSLocalizedString("Invalid Response",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                                  value: "Invalid Response",
                                  comment: "Invalid Response");
    }()
    
    private static let ERRROR_REQUEST_FAILED = {
        return  NSLocalizedString("Invalid Request",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                                  value: "Invalid Request",
                                  comment: "Invalid Request");
    }()
    
    private static let ERRROR_LOW_CONFIDENCE = {
        return  NSLocalizedString("Low Confidence Response",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                                  value: "Low Confidence Response",
                                  comment: "Low Confidence Response");
    }()
    
    private static let ERRROR_NOT_RECOGNIZED = {
        return  NSLocalizedString("Not Recognizer",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                                  value: "Not Recognizer",
                                  comment: "Not Recognizer");
    }()
    
    private static let ERRROR_NETWORK_PROBLEM = {
        return  NSLocalizedString("Network Error",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                                  value: "Network Error",
                                  comment: "Network Error");
    }()

    private static let CONNECTION_ERROR_DIALOG_TITLE = {
        return  NSLocalizedString("Engine Error",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSSpeechToTextViewController.self),
                                  value: "Engine Error",
                                  comment: "Engine Error");
    }();
    
    private static let AVAILABLE_ENGINE_DESC = [
        BlueVoiceGoogleASREngine.engineDescription,
        BlueVoiceIBMWatsonASREngine.engineDescription,
        BlueVoiceWebSocketASREngine.engineDescription
    ]
    
    /** object used to check if the use has an internet connection */
    private var mInternetReachability: Reachability?;
    
    //////////////////// GUI reference ////////////////////////////////////////
    
    @IBOutlet weak var mAddAsrKeyButton: UIButton!
    
    @IBOutlet weak var mAsrEngineName: UILabel!
    @IBOutlet weak var mSelectLanguageButton: UIButton!
    
    @IBOutlet weak var mRecordButton: UIButton!
    @IBOutlet weak var mAsrResultsTableView: UITableView!
    @IBOutlet weak var mAsrEngineStatusLabel: UILabel!
    
    @IBOutlet weak var mEnableBeamFormingSwitch: UISwitch!
    
    private var mRecordController:W2STAudioDumpController!;
    private var engine:BlueVoiceASREngine?;
    
    private var mFeatureAudio:BlueSTSDKFeatureAudioADPCM?;
    private var mFeatureAudioSync:BlueSTSDKFeatureAudioADPCMSync?;
    private var mFeatureBeamForming:BlueSTSDKFeatureBeamForming?;
    private var mFeatureAccEvents:BlueSTSDKFeatureAccelerometerEvent?;
    
    private var mAsrResults:[String] = [];
    
    private var waitingDialog:MBProgressHUD?;

    
    /////////////////// AUDIO //////////////////////////////////////////////////

    //variable where store the audio before send to an speech to text service
    private let mAudioConf = W2STAudioStreamConfig.blueVoiceConf;
    private var mRecordData:Data?;

    /////////CONTROLLER STATUS////////////

    private var mMuteState:Bool=false;
    private var mIsRecording:Bool=false;
    
    override public func viewDidLoad(){
        super.viewDidLoad()
        mAsrResultsTableView.dataSource=self;
        onEngineSelected(engine: getDefaultEngine(), language: getDefaultLanguage())
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mRecordController = W2STAudioDumpController(audioConf: mAudioConf, parentView: self, menuController: self.menuDelegate);
    }

    private func enableAudioStream(){
        mFeatureAudio = self.node.getFeatureOfType(BlueSTSDKFeatureAudioADPCM.self) as! BlueSTSDKFeatureAudioADPCM?;
        mFeatureAudioSync = self.node.getFeatureOfType(BlueSTSDKFeatureAudioADPCMSync.self) as!
            BlueSTSDKFeatureAudioADPCMSync?;
    
        //if both feature are present enable the audio
        if let audio = mFeatureAudio,
            let audioSync = mFeatureAudioSync,
            !self.node.isEnableNotification(audio),
            !self.node.isEnableNotification(audioSync) {
            audio.add(self);
            audioSync.add(self);
            self.node.enableNotification(audio);
            self.node.enableNotification(audioSync);
        }
    
        mFeatureBeamForming = self.node.getFeatureOfType(BlueSTSDKFeatureBeamForming.self) as? BlueSTSDKFeatureBeamForming
        if let beamForming = mFeatureBeamForming,
            !self.node.isEnableNotification(beamForming){
            self.node.enableNotification(beamForming)
            beamForming.enablebeamForming(mEnableBeamFormingSwitch.isOn)
        }
    
    }
    
    private func disableAudioStream(){
        if let audio = mFeatureAudio,
           let audioSync = mFeatureAudioSync,
           self.node.isEnableNotification(audio),
           self.node.isEnableNotification(audioSync) {
            audio.remove(self);
            audioSync.remove(self);
            self.node.disableNotification(audio);
            self.node.disableNotification(audioSync);
        }
        if let beamForming = mFeatureBeamForming,
            self.node.isEnableNotification(beamForming){
            self.node.disableNotification(beamForming);
            beamForming.enablebeamForming(false);
        }
    }
    
    private func initBeamformingGui(){
        if(node.getFeatureOfType(BlueSTSDKFeatureBeamForming.self) != nil){
            mEnableBeamFormingSwitch.isEnabled=true;
            mEnableBeamFormingSwitch.isOn=false;
        }
    }
    
    /*
     * enable the ble audio stremaing and initialize the audio queue
     */
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        initRecability();
        initBeamformingGui();
        
        mFeatureAccEvents = node.getFeatureOfType(BlueSTSDKFeatureAccelerometerEvent.self) as? BlueSTSDKFeatureAccelerometerEvent
        if let accEvent = mFeatureAccEvents{
            accEvent.add(self)
            accEvent.enable(accEvent.DEFAULT_ENABLED_EVENT, enable: false)
            accEvent.enable(.eventTypeDoubleTap, enable: true)
            node.enableNotification(accEvent)
        }else{
            enableAudioStream()
        }
        
    }
    
    /**
     * stop the ble audio streaming and the audio queue
     */
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        mRecordController.viewWillDisappear();
        disableAudioStream()
        deInitRecability()
        
        if let accEvent = mFeatureAccEvents{
            accEvent.remove(self)
            node.disableNotification(accEvent)
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
                mAsrEngineName.text = BlueMSSpeechToTextViewController.DISABLED_STR;
                mAsrEngineStatusLabel.text = BlueMSSpeechToTextViewController.DISABLED_STR;
                mRecordButton.isEnabled=false;
            }else{
                mRecordButton.isEnabled=true;
                loadAsrEngine(getDefaultEngine(),getDefaultLanguage());
                mAsrEngineStatusLabel.text = BlueMSSpeechToTextViewController.DISCONNECTED;
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
        return lang ?? BlueMSSpeechToTextViewController.DEFAULT_ASR_LANG;
    }
    
    private func loadAsrEngineDesc()->BlueVoiceASRDescription?{
        let userPref = UserDefaults.standard;
        let engineName = userPref.string(forKey: BlueMSSpeechToTextViewController.ASR_ENGINE_PREF);
        if let str = engineName{
            return BlueMSSpeechToTextViewController.AVAILABLE_ENGINE_DESC.filter({desc in desc.name==str}).first;
        }
        return nil;
    }
    
    private func storeAsrEngine(engineDesc:BlueVoiceASRDescription){
        let userPref = UserDefaults.standard;
        userPref.setValue(engineDesc.name,forKey:BlueMSSpeechToTextViewController.ASR_ENGINE_PREF);
    }
    
    private func getDefaultEngine()->BlueVoiceASRDescription{
        let desc = loadAsrEngineDesc();
        return desc ?? BlueMSSpeechToTextViewController.DEFAULT_ASR_ENGINE;
    }
    
    
    /// load the langiage from the user preference
    ///
    /// - Returns: language stored in the preference or the default one
    private func loadAsrLanguage()->BlueVoiceLanguage?{
        let userPref = UserDefaults.standard;
        let langString = userPref.string(forKey: BlueMSSpeechToTextViewController.ASR_LANG_PREF);
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
        userPref.setValue(language.rawValue, forKey:BlueMSSpeechToTextViewController.ASR_LANG_PREF);
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
    
    
    @IBAction func onBeamFormingStateChange(_ sender: UISwitch) {
        if let feature = mFeatureBeamForming{
            feature.enablebeamForming(sender.isOn);
            if(sender.isOn){
                feature.setDirection(BlueMSSpeechToTextViewController.DEFAULT_DIRECTION);
                feature.useStrongbeamFormingAlgorithm(true);
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
                showAllert(title: BlueMSSpeechToTextViewController.ENGINE_FAIL_DIALOG_TITLE,
                           message: BlueMSSpeechToTextViewController.ENGINE_KEY_REQUIRED)
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
    
        waitingDialog = MBProgressHUD.showAdded(to: self.view, animated: false)
        self.mAsrEngineStatusLabel.text = BlueMSSpeechToTextViewController.CONNECTING;
        engine?.startListener(onConnect: self.onConnectionDone);
    }
    
    private func onConnectionDone( _ error:Error?){
        mIsRecording = error==nil;
        if(mIsRecording){
            enableAudioStream()
        }
        DispatchQueue.main.async {
            if (error != nil){
                self.showAllert(title: BlueMSSpeechToTextViewController.CONNECTION_ERROR_DIALOG_TITLE,
                           message: error!.localizedDescription)
                self.mAsrEngineStatusLabel.text = BlueMSSpeechToTextViewController.DISCONNECTED;
            }else{
                if(self.engine!.engineDesc.hasContinuousRecognizer){
                    self.mAsrEngineStatusLabel.text = BlueMSSpeechToTextViewController.CONNECTED;
                }else{
                    self.mAsrEngineStatusLabel.text = BlueMSSpeechToTextViewController.RECORDING;
                }
            }
            self.waitingDialog?.hide(animated: true);
            self.setRecordButtonTitle(self.engine); //reset the button name
        }
    }
    
    /// Stop a continuos recognition
    private func onContinuousRecognizerStop(){
        mIsRecording=false;
        disableAudioStream()
        if let engine = engine{
            engine.stopListener();
            setRecordButtonTitle(engine);
            self.mAsrEngineStatusLabel.text = BlueMSSpeechToTextViewController.DISCONNECTED;
        }
    }
    
    
    /// Start a non continuos voice to text service
    private func onRecognizerStart(){
        guard checkAsrKey() else{
            return;
        }
        mRecordData = Data();
        engine?.startListener(onConnect: self.onConnectionDone);
    }
    
    /// Stop a non continuos voice to text service, and send the recorded data 
    /// to the service
    private func onRecognizerStop(){
        mIsRecording=false;
        disableAudioStream()
        if let engine = engine{
            if(mRecordData != nil){
                self.mAsrEngineStatusLabel.text = BlueMSSpeechToTextViewController.SENDING_DATA;
                _ = engine.sendASRRequest(audio: mRecordData!, callback: self);
                mRecordData=nil;
                self.mAsrEngineStatusLabel.text = BlueMSSpeechToTextViewController.DISCONNECTED;
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
            mRecordButton.setTitle(BlueMSSpeechToTextViewController.STOP_RECOGNITION, for: .normal);
        }else{
            let recorTitle = asrEngine.engineDesc.hasContinuousRecognizer ?
                BlueMSSpeechToTextViewController.START_RECOGNITION :
                BlueMSSpeechToTextViewController.KEEP_PRESS;
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

            let asrTitle = asrEngine.hasLoadedAuthKey() ?
                BlueMSSpeechToTextViewController.CHANGE_SERVICE_KEY :
                BlueMSSpeechToTextViewController.ADD_SERVICE_KEY;

            mAddAsrKeyButton.setTitle(asrTitle, for:UIControl.State.normal)
            setRecordButtonTitle(asrEngine);
            displayEngineName(engineDesc.name, language: language.rawValue)
        }
    }
    
    /////////////////////// BlueVoiceSelectEngineViewController //////////////////////////
    func onEngineSelected(engine: BlueVoiceASRDescription, language: BlueVoiceLanguage) {
        storeAsrLanguage(language)
        storeAsrEngine(engineDesc: engine);
        loadAsrEngine(engine, language);
    }
    
    private func displayEngineName(_ name:String,language:String){
        mAsrEngineName.text = String(format:"%@ - %@",name,language)
    }
    
    func getAvailableEngine() -> [BlueVoiceASRDescription] {
        return BlueMSSpeechToTextViewController.AVAILABLE_ENGINE_DESC;
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
    private static let IGNORE_DOUBLE_TAP_INTERVAL:TimeInterval=1.0
    
    private var mLastEvent:TimeInterval=0.0;
    private func didAccEventUpdate(_ feature:BlueSTSDKFeature, sample:BlueSTSDKFeatureSample){
        
        if(BlueSTSDKFeatureAccelerometerEvent.getAccelerationEvent(sample) == .doubleTap){
            let now = Date.timeIntervalSinceReferenceDate
            //ignore events to close
            if(now-mLastEvent>=BlueMSSpeechToTextViewController.IGNORE_DOUBLE_TAP_INTERVAL){
                mLastEvent = now;
                DispatchQueue.main.async {
                    self.onRecordButtonPressed(self.mRecordButton)
                }
            }
            
        }
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
        if(feature .isKind(of: BlueSTSDKFeatureAccelerometerEvent.self)){
            self.didAccEventUpdate(feature, sample: sample);
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
            if(!(self.engine?.engineDesc.hasContinuousRecognizer ?? true)){
                self.mAsrEngineStatusLabel.text = BlueMSSpeechToTextViewController.DISCONNECTED
            }
        }
    }
    
    
    private func getErrorDescription(_ error:BlueVoiceAsrRequestError )->String{
        switch error {
            case .NO_ERROR:
                return BlueMSSpeechToTextViewController.ERRROR_NO_ERROR;
            case .IO_CONNECTION_ERROR:
                return BlueMSSpeechToTextViewController.ERRROR_CONNECTION_ERROR;
            case .RESPONSE_ERROR:
                return BlueMSSpeechToTextViewController.ERRROR_RESPONSE_ERROR;
            case .REQUEST_FAILED:
                return BlueMSSpeechToTextViewController.ERRROR_REQUEST_FAILED;
            case .LOW_CONFIDENCE:
                return BlueMSSpeechToTextViewController.ERRROR_LOW_CONFIDENCE;
            case .NOT_RECOGNIZED:
                return BlueMSSpeechToTextViewController.ERRROR_NOT_RECOGNIZED;
            case .NETWORK_PROBLEM:
                return BlueMSSpeechToTextViewController.ERRROR_NETWORK_PROBLEM;
        }
    }

    /// callback when some error happen during the voice to text translation
    ///
    /// - Parameter error: error during the voice to text translation
    func onAsrRequestFail(error:BlueVoiceAsrRequestError){
        let errorDesc = getErrorDescription(error);
        print("ASR Fail:"+errorDesc);
        DispatchQueue.main.async {
            self.mAsrEngineStatusLabel.text = errorDesc;
            self.mAsrEngineStatusLabel.isHidden=false;
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
    
        var cell = tableView.dequeueReusableCell(withIdentifier: "BlueVoiceAsrResultCell");
    
        if (cell == nil){
            cell = UITableViewCell(style: .default, reuseIdentifier: "BlueVoiceAsrResultCell");
            cell?.selectionStyle = .none;
        }
     
        cell?.textLabel?.text=mAsrResults[indexPath.row];
        
        return cell!;
    
    }

    

}
