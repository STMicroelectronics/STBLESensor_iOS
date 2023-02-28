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
import UIKit
import SpeechToText

class IBMWatsonDescription : BlueVoiceASRDescription{
    
    public let needAuthKey = true;
    public let hasContinuousRecognizer = true;
    public let name = "IBM Watson";
    public let supportedLanguages = [ BlueVoiceLanguage.ENGLISH_UK,BlueVoiceLanguage.ENGLISH_US]
    
    func build(withLanguage lang: BlueVoiceLanguage, samplingRateHz: UInt) -> BlueVoiceASREngine? {
        return BlueVoiceIBMWatsonASREngine(lang,samplingRateHz);
    }
}

/// Use the Google speech API to translate the voice to text
class BlueVoiceIBMWatsonASREngine: BlueVoiceASREngine, IBMWatsonKeyDelegate{
    
    public static let engineDescription = IBMWatsonDescription() as BlueVoiceASRDescription;

    private static let LANGUAGE_MODEL = "en-US_BroadbandModel"
    private static let ASR_KEY_PREFERENCE = "BlueVoiceGoogleASREngine.ASR_KEY";
    
    public let needAuthKey = true;
    public let hasContinuousRecognizer = true;
    public let name = "IBM Watson";
    
    private let mAudioNeedUpsampling:Bool;
    
    /// string key to use during the google request
    private var mAsrKey:BlueVoiceIBMWatsonASRKey?;
    private var mSpeechToText:SpeechToTextSession?;
    private var mSpeechServiceConnected:Bool = false;
    private var mSpeechTextCallback:BlueVoiceAsrRequestCallback?;
    private let mAsrVoiceModel:String;
    
    private static func getVoiceModel(lang:BlueVoiceLanguage)->String{
        switch lang {
        case BlueVoiceLanguage.ENGLISH_UK:
            return "en-US_BroadbandModel"
        case BlueVoiceLanguage.ENGLISH_US:
            return "en-UK_BroadbandModel"
        default:
            return BlueVoiceIBMWatsonASREngine.ASR_KEY_PREFERENCE;
        }
    }
    
    
    /// create an object to use the IBM Speech to text api the supported sampling rate are 8k or 16k
    ///
    /// - Parameter samplingRateHz: audio sampling rate
    init?(_ lang:BlueVoiceLanguage,_ samplingRateHz:UInt){
        guard samplingRateHz == 8000 || samplingRateHz == 16000 else{
            return nil;
        }
        guard (BlueVoiceIBMWatsonASREngine.engineDescription.supportLanguage(lang)) else{
            return nil;
        }
        mAudioNeedUpsampling = samplingRateHz == 8000;
        mAsrVoiceModel = BlueVoiceIBMWatsonASREngine.getVoiceModel(lang: lang);
    }
    
    func hasLoadedAuthKey() ->Bool{
        mAsrKey = BlueVoiceIBMWatsonASRKey.load();
        return mAsrKey != nil;
    }
    
    public func getAuthKeyDialog()->UIViewController?{
        let storyBoard = UIStoryboard(name: "SpeechToText", bundle: Bundle(for: Self.self) )
        let viewController = storyBoard.instantiateViewController(withIdentifier: "IBMWatsonASRKeyViewController") as! BlueVoiceIBMWatsonASRKeyViewController;
        viewController.delegate=self;
        return viewController;
    }
    
    
    /// update the sampling frequency from 8k to 16k.
    /// it duplicate the values
    ///
    /// - Parameter audio: buffer to convert
    /// - Returns: buffer with the same content but with a double sampling rate
    private func upsamplingAudioBuffer(_ audio:Data)->Data{
        // allocate the new buffer
        var upsampligAudio = Data(capacity: 2*audio.count)
        audio.withUnsafeBytes{ (ptr : UnsafeRawBufferPointer) in
            let audioSample = ptr.bindMemory(to: UInt16.self)
            audioSample.forEach{ sample in
                let bytes = [UInt8(truncatingIfNeeded: sample >> 8),
                             UInt8(truncatingIfNeeded: sample)]
                upsampligAudio.append(contentsOf: bytes)
                upsampligAudio.append(contentsOf: bytes)
            }
        }
        /*
        audio.withUnsafeBytes{(audioSamples: UnsafePointer<UInt16>) in
            //for each audio sample
            for i in 0..<audio.count/2{
                //get the pointer
                let value = audioSamples.advanced(by: i);
                //eavluate as uint8
                value.withMemoryRebound(to: UInt8.self, capacity: 2, { (bytes) in
                    //copy the value in the output buffer 2 times
                    upsampligAudio.append(bytes, count: 2)
                    upsampligAudio.append(bytes, count: 2)
                })
            }
        }*/
        return upsampligAudio;
    }

    private func buildWebSocketEndpint(serviceUrl:String)->String{
        return serviceUrl.replacePrefix(prefix: "https", replacement: "wss") + "/v1/recognize"
    }
    
    func startListener(onConnect : @escaping (Error?)->Void){
        guard let asrKey = BlueVoiceIBMWatsonASRKey.load() else{
            onConnect(NSError(domain: "BlueVoiceIBMWatsonASREngine", code: 1,
                              userInfo: [NSLocalizedDescriptionKey:"Invalid service key"]))
            return;
        }
        var watsonSettings =
            RecognitionSettings(contentType:"audio/l16;rate=16000;channels=1")
        watsonSettings.interimResults=true;
        let autenticator = WatsonIAMAuthenticator(apiKey: asrKey.apiKey ?? "")
        mSpeechToText = SpeechToTextSession(authenticator: autenticator,
                                            model: mAsrVoiceModel,
                                            acousticCustomizationID: nil)
        mSpeechToText?.websocketsURL = buildWebSocketEndpint(serviceUrl: asrKey.endpoint)
        mSpeechToText?.onConnect = {
            onConnect(nil)
            self.mSpeechServiceConnected=true;
            self.mSpeechToText?.startRequest(settings: watsonSettings);
        }
        mSpeechToText?.onResults = self.notifyResults;
        mSpeechToText?.onError={ (error) in
            onConnect(error)
            print(error)
        }
        
        mSpeechToText?.connect()
    }
    
    func stopListener(){
        mSpeechServiceConnected=false;
        mSpeechToText?.stopRequest()
        mSpeechToText?.disconnect()
        mSpeechToText=nil;
    }
    
    func destroyListener(){}
    
    
    /// conver the audio to text
    ///
    /// - Parameters:
    ///   - audio: audio to send
    ///   - callback: object to notify when the answer is ready
    /// - Returns: true if the request is send correctly
    func sendASRRequest(audio:Data,  callback: BlueVoiceAsrRequestCallback) -> Bool{
        guard mSpeechServiceConnected else{
            return false;
        }
        mSpeechTextCallback = callback;
        let dataToSend = mAudioNeedUpsampling ? upsamplingAudioBuffer(audio) : audio;
        mSpeechToText?.recognize(audio:dataToSend)
        
        return true;
    }
    
    private func notifyResults(results:SpeechRecognitionResults){
        guard let res = results.results, res.count>=1 else{ //if no result don't do anything
            return;
        }
                
        if let lastResult = results.results?.last, lastResult.final{
            let transcript = lastResult.alternatives.first?.transcript;
            if let str = transcript{
              self.mSpeechTextCallback?.onAsrRequestSuccess(withText: str)
            }
        }
    
    }
    
    //////////////////BlueVoiceGoogleKeyDelegate///////////////////////////////
    
    public func loadAsrKey() -> BlueVoiceIBMWatsonASRKey? {
        return BlueVoiceIBMWatsonASRKey.load()
    }
    
    public func storeAsrKey(_ key: BlueVoiceIBMWatsonASRKey) {
        key.store();
    }
    
}

extension String {
    fileprivate func replacePrefix(prefix: String, replacement: String) -> String {
        if hasPrefix(prefix) {
            return replacement + self[prefix.endIndex...]
        }
        else {
            return self
        }
    }
}



