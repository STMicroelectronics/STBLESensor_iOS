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

class BlueVoiceIFlyTekDescription : BlueVoiceASRDescription{

    /// no authentication key needed
    public let needAuthKey = false;
    /// it support the continuous recongition
    public let hasContinuousRecognizer = true;
    public let name = "iFlyTek";
    public let supportedLanguages = [BlueVoiceLanguage.CHINESE]
    
    func build(withLanguage lang: BlueVoiceLanguage, samplingRateHz: UInt) -> BlueVoiceASREngine? {
        return BlueVoiceIFlyTekEngine(language: lang,samplingRateHz: samplingRateHz);
    }
}

class BlueVoiceIFlyTekEngine: NSObject,  BlueVoiceASREngine,IFlySpeechRecognizerDelegate{
    
    public static let engineDescription = BlueVoiceIFlyTekDescription() as BlueVoiceASRDescription;
    
    private static let APP_ID = "58d1e68b";
    
    /// no authentication key needed
    public let needAuthKey = false;
    
    /// it support the continuous recongition
    public let hasContinuousRecognizer = true;
    
    public let name = "iFlyTek";

    private let mSamplingRateHz:UInt;
    
    private let mEngine:IFlySpeechRecognizer?;
    
    /// user callback
    private var mCallback:BlueVoiceAsrRequestCallback?=nil;
    
    /// true if the user start the speech recognizer
    private var mIsListening:Bool;
    
    /// Serial queue where enqeueue all the interaction with the IFlySpeechRecognizer
    /// to be secure that all the call are serialized
    private let mEngineCommandQueue = DispatchQueue(label: "EngineCommandQueue");
    
    
    init?(language:BlueVoiceLanguage,samplingRateHz:UInt){
        guard samplingRateHz == 8000 || samplingRateHz == 16000 else{
            return nil;
        }
        guard (BlueVoiceIFlyTekEngine.engineDescription.supportLanguage(language)) else{
            return nil;
        }
        /*
        //debug loggin settings
        IFlySetting.setLogFile(.LVL_ALL);
        IFlySetting.showLogcat(true);
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask,true);
        IFlySetting.setLogFilePath(paths.first);
        */
        IFlySetting.showLogcat(false);
        IFlySpeechUtility.createUtility("appid="+BlueVoiceIFlyTekEngine.APP_ID);
        mEngine = IFlySpeechRecognizer.sharedInstance();
        mSamplingRateHz=samplingRateHz
        mIsListening=false;
        
    }
    
    private func setEngineParam(_ engine: IFlySpeechRecognizer!){
        //reset the engine
       // engine.cancel();
        engine.setParameter("", forKey: IFlySpeechConstant.params())
        
        engine.setParameter("iat", forKey: IFlySpeechConstant.ifly_DOMAIN());
        engine.delegate=self;
        //engine.setParameter("30000",forKey: IFlySpeechConstant.speech_TIMEOUT());
        //engine.setParameter("3000", forKey: IFlySpeechConstant.vad_BOS())
        //engine.setParameter("3000", forKey: IFlySpeechConstant.vad_EOS())
        engine.setParameter("json", forKey: IFlySpeechConstant.result_TYPE())
        engine.setParameter(IFlySpeechConstant.language_CHINESE(),
                            forKey: IFlySpeechConstant.language());
        engine.setParameter(IFlySpeechConstant.accent_MANDARIN(),
                            forKey: IFlySpeechConstant.accent());
        engine.setParameter("-1", forKey: IFlySpeechConstant.audio_SOURCE());
        engine.setParameter("\(mSamplingRateHz)", forKey: IFlySpeechConstant.sample_RATE())
    }
    
    
    /// Always return true since no key is needed
    ///
    /// - Returns: true
    func hasLoadedAuthKey() ->Bool{
        return true
    }
    
    
    /// Always return null since no key is needed
    ///
    /// - Returns: nil
    public func getAuthKeyDialog()->UIViewController?{
        return nil
    }
    
    func startListener(onConnect : @escaping (Error?)->Void){
        mEngineCommandQueue.sync {
            if let engine = mEngine{
                setEngineParam(engine);
                engine.startListening();
                mIsListening=true;
                onConnect(nil)
            }
        }
    }
    
    func stopListener(){
        mEngineCommandQueue.sync {
            if let engine = mEngine{
                engine.delegate=nil;
                engine.stopListening();
                mIsListening=false;
            }
        }
    }
    
    func destroyListener(){
        mEngineCommandQueue.sync {
            if let engine = mEngine{
                engine.cancel();
                engine.destroy();
            }
        }
    }

    func sendASRRequest(audio:Data,  callback: BlueVoiceAsrRequestCallback) -> Bool{
        
        guard mEngine != nil else {
            return false
        }
        mCallback=callback;
        
        mEngineCommandQueue.async {
            self.mEngine?.writeAudio(audio);
        }
        
        return true;
    
    }

    /////////////////////////IFlySpeechRecognizerDelegate///////////////////////
    
    public func onError(_ errorCode:IFlySpeechError){
        guard errorCode.errorCode != 0 else { //0 == Success
            return;
        }
        mCallback?.onAsrRequestFail(error: .IO_CONNECTION_ERROR);
        print("IFlySpeechErrorCode: \(errorCode.errorCode)");
        print("IFlySpeechErrorDesc: \(errorCode.description)");
    }
    
    
    /// extrat the text from the json response
    ///
    /// - Parameter result: string with the json response
    /// - Returns: text rappresentation of the voice
    func parseResult( result:String?) ->String?{
        guard result != nil else{
            return nil;
        }
        
        do{
            let data = result!.data(using: .utf8);
            let jsonData = try JSONSerialization.jsonObject(with:data! ) as! [String:Any];
            var str:String="";
            let worldsArray = jsonData["ws"] as! [[String:Any]];
            for valueDesc in worldsArray{
                let cwArray = valueDesc["cw"] as! [[String:Any]];
                for wDict in cwArray {
                    let temp = wDict["w"] as! String;
                    str.append(temp);
                }
            }
            return str;
        }catch let error as NSError{
            print (error.debugDescription)
            print (error.description);
            return nil;
        }

    }
 
    public func onResults(_ results: [Any]!, isLast: Bool) {
        guard results != nil else{
            mCallback?.onAsrRequestFail(error: .NOT_RECOGNIZED);
            return;
        }
        guard results.count != 0 else {
            mCallback?.onAsrRequestFail(error: .NOT_RECOGNIZED);
            return;
        }
        //yes the data are passed as a dictionary key.. a simple string was to easy
        let dictKey = (results.first as! [String:Any]).first?.key;
        let text  = parseResult(result: dictKey);
        
        if(text != nil){
            if(text?.isEmpty)!{
                mCallback?.onAsrRequestFail(error: .LOW_CONFIDENCE);
            }else{
                mCallback?.onAsrRequestSuccess(withText: text!);
            }
        }else{
            mCallback?.onAsrRequestFail(error:.RESPONSE_ERROR);
        }
    }
    
    
    public func onVolumeChanged(_ volume: Int32) {
        print("Volume change:\(volume)");
    }
    
    public func onBeginOfSpeech() {
        print("onBeginOfSpeech");
    }

    
    /// restart the listening if the user doesn't ask to stop it
    public func onEndOfSpeech() {
        if(mIsListening){
            mEngineCommandQueue.sync {
               _ =  mEngine?.startListening();
            }
        }
        print("onEndOfSpeech");
    }
    
    public func onEvent(_ eventType: Int32, arg0: Int32, arg1: Int32, data eventData: Data!) {
        //print("MY onEvent: eventType:\(eventType) arg0:\(arg0) arg1:\(arg1)");
    }
 
    
}
