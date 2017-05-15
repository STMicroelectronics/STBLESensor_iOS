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


/// Use the Google speech API to translate the voice to text
public class BlueVoiceGoogleASREngine: BlueVoiceASREngine,
    BlueVoiceGoogleKeyDelegate{
    
    private static let ASR_KEY_PREFERENCE = "BlueVoiceGoogleASREngine.ASR_KEY";
    private static let ASR_KEY_LENGHT = 39;
    
    /// result with a confidence lower that this value will be discarded
    private static let MIN_CONFIDENCE = Float(0.75);
    
    public let needAuthKey = true;
    public let hasContinuousRecognizer = false;
    public let name = "Google™";
    
    private let mSamplingRateHz:UInt;
    
    /// string key to use during the google request
    private var mAsrKey:String?;
    
    /// voice language
    private let mLanguage:BlueVoiceLangauge;
    
    
    /// Check that the string has a valid format to be an api key,
    /// it return the valid key string or nil if the string is not a valid key
    ///
    /// - Parameter asrKey: key to test
    /// - Returns: nil if is not a valid key, otherwise the valid key
    private static func synitizeAsrKey(_ asrKey:String?) -> String?{
        if(asrKey?.characters.count==ASR_KEY_LENGHT){
            return asrKey;
        }else{
            return nil;
        }//if let
    }
    
    
    /// convert the language in the url string parameter, if the language is
    /// unknow the english will be used
    ///
    /// - Parameter lang: voice language
    /// - Returns: string to use in the request url
    private static func getLanguageParamiter(lang: BlueVoiceLangauge)-> String{
        switch lang {
        case .ENGLISH:
            return "en-US";
        case .ITALIAN:
            return "it-IT";
        case .FRENCH:
            return "fr-FR"
        case .SPANISH:
            return "es-ES";
        case .GERMAN:
            return "de-DE";
        case .PORTUGUESE:
            return "pr-PR";
        default:
            return "en-EN"
        }
    }
    
    
    /// build the request url
    ///
    /// - Parameters:
    ///   - language: voice language
    ///   - key: user key
    /// - Returns: url where send the audio data
    private static func getRequestUrl(_ language:BlueVoiceLangauge, _ key:String)->URL?{
        let langStr = getLanguageParamiter(lang: language);
        return URL(string:"https://www.google.com/speech-api/v2/recognize?xjerr=1&client=chromium&lang="+langStr+"&key="+key);
    }
    
    init(language:BlueVoiceLangauge, samplingRateHz:UInt){
        mLanguage=language;
        mSamplingRateHz=samplingRateHz;
        mAsrKey=loadAsrKey()
    }
    
    func hasLoadedAuthKey() ->Bool{
        if(mAsrKey==nil){
            mAsrKey = loadAsrKey();
        }
        return mAsrKey != nil;
    }
    
    public func getAuthKeyDialog()->UIViewController?{
        let storyBoard = UIStoryboard(name: "BlueVoice", bundle:nil )
        let viewController = storyBoard.instantiateViewController(withIdentifier: "GoogleAsrKeyViewController") as! BlueVoiceGoogleASRKeyViewController;
        viewController.delegate=self;
        return viewController;
    }
    
    func startListener(){}
    
    func stopListener(){}
    
    func destroyListener(){}
    
    
    /// conver the audio to text
    ///
    /// - Parameters:
    ///   - audio: audio to send
    ///   - callback: object to notify when the answer is ready
    /// - Returns: true if the request is send correctly
    func sendASRRequest(audio:Data,  callback: BlueVoiceAsrRequestCallback) -> Bool{
        guard mAsrKey != nil else{
            return false;
        }
        
        let url = BlueVoiceGoogleASREngine.getRequestUrl(mLanguage,mAsrKey!);
        
        if(url == nil){
            return false;
        }
        
        var request = URLRequest(url: url!,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 10.0);
        
        request.httpMethod="POST";
        request.setValue("audio/l16; rate=\(mSamplingRateHz)", forHTTPHeaderField: "Content-Type");
        
        let session = URLSession(configuration: URLSessionConfiguration.default);
        //start the request and call parseResponseData when it is ready
        let task = session.uploadTask(with: request, from: audio, completionHandler:
            {(responseData:Data?,response:URLResponse?,error:Error?) in
                self.parseResponseData(responseData: responseData, respose: response, error: error, callback: callback);
            })
        task.resume();
        return true;
    }

    
    /// function call when the http response is ready
    ///
    /// - Parameters:
    ///   - responseData: response data
    ///   - respose: response header
    ///   - error: response error
    ///   - callback: object where notify the response results
    private func parseResponseData(responseData:Data?,respose:URLResponse?,error:Error?,callback: BlueVoiceAsrRequestCallback){
        guard error==nil else{
            print(error!.localizedDescription);
            callback.onAsrRequestFail(error: .NETWORK_PROBLEM);
            return;
        }
        
        if let resp = (respose as! HTTPURLResponse?){
            if(resp.statusCode != 200){
                callback.onAsrRequestFail(error: .REQUEST_FAILED);
                return;
            }
        }
        
        guard responseData != nil else{
            callback.onAsrRequestFail(error: .REQUEST_FAILED);
            return;
        }
        
        let results = extractResults(data: responseData);
        let bestResults = getBestConfidenceResults(results);
        if let (confidence,text) = bestResults{
            print("BestResult: \(text) conf: \(confidence)")
            if(confidence>=BlueVoiceGoogleASREngine.MIN_CONFIDENCE){
                callback.onAsrRequestSuccess(withText: text);
            }else{
                callback.onAsrRequestFail(error: .LOW_CONFIDENCE)
            }
        }else{
            callback.onAsrRequestFail(error: .NOT_RECOGNIZED)
        }
        
    }
    
    /// function that parse the json response and extract a list of confidence and strings
    ///
    /// - Parameter data: json response
    /// - Returns: list of confidence and string or nil if the parse fail
    private func extractResults(data:Data?)->[(Float,String)]?{
        var retValue:[(Float,String)] = Array();
        do{
            
            var respStr = String(data: data!, encoding: .utf8);
            //the fist line of the response is an empty json.. remove it to parse
            //the real response
            respStr = respStr?.replacingOccurrences(of: "{\"result\":[]}", with:"")
            respStr = respStr?.trimmingCharacters(in: .controlCharacters);
            print(respStr!)
            let respStrData = respStr?.data(using: .utf8);
            
            if(respStr == nil){
                return nil;
            }
            
            let json = try JSONSerialization.jsonObject(with: respStrData!) as? [String: Any];
            let retult = json?["result"] as? [[String:Any]];
            let alternative = retult?.first?["alternative"] as? [[String:Any]];
            if(alternative == nil){
                return nil;
            }
            for transcript in alternative!{
                let text = transcript["transcript"] as! String;
                let confidence = transcript["confidence"] as! Float;
                retValue.append((confidence,text));
            }
            
        }catch let error as NSError{
            print (error.debugDescription)
            print (error.description);
            return nil;
        }
        return retValue;
    }
    
    
    /// sort the result in decreasing order using the float component ->
    /// in first position the value with the best confidence
    ///
    /// - Parameter results: list to sort
    /// - Returns: sorted list, with the best confidece value as the first paramiters
    func getBestConfidenceResults(_ results:[(Float,String)]?)->(Float,String)?{
        let sortResults = results?.sorted(by: {$0.0 > $1.0});
        return sortResults?.first;
    }
    
    //////////////////BlueVoiceGoogleKeyDelegate///////////////////////////////
    
    public func loadAsrKey()->String?{
        let userPref = UserDefaults.standard;
        let langString = userPref.string(forKey: BlueVoiceGoogleASREngine.ASR_KEY_PREFERENCE);
        return BlueVoiceGoogleASREngine.synitizeAsrKey(langString);
    }
    
    public func storeAsrKey(_ asrKey:String){
        let userPref = UserDefaults.standard;
        if let checkedKey = BlueVoiceGoogleASREngine.synitizeAsrKey(asrKey){
            mAsrKey=checkedKey;
            userPref.setValue(checkedKey, forKey:BlueVoiceGoogleASREngine.ASR_KEY_PREFERENCE);
        }
    }

    
}

