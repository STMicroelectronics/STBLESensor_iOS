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


/// List of possible error during the voice to text convertion
enum BlueVoiceAsrRequestError:Int8,CustomStringConvertible {
    case NO_ERROR = 0;
    ///error diring the cominication
    case IO_CONNECTION_ERROR = 1;
    ///response parsing fail
    case RESPONSE_ERROR = 2;
    ///imposible send the request
    case REQUEST_FAILED = 3;
    /// valid respose but with a low confidence
    case LOW_CONFIDENCE=4
    /// valid response but empyt
    case NOT_RECOGNIZED = 5;
    /// impossible to use the network
    case NETWORK_PROBLEM = 6;
    
    var description : String {
        switch self {
            case .NO_ERROR: return "Success";
            case .IO_CONNECTION_ERROR: return "I/O Error";
            case .RESPONSE_ERROR: return "Invalid Response";
            case .REQUEST_FAILED: return "Invalid Request";
            case .LOW_CONFIDENCE: return "Low Confidence Response";
            case .NOT_RECOGNIZED: return "Not Recognizer";
            case .NETWORK_PROBLEM: return "Network Error";
        }
    }
    
}


/// Interface used to comunicate the voice to text results
protocol BlueVoiceAsrRequestCallback{
    
    
    /// call when the ASREngine has a valid response
    ///
    /// - Parameter withText: text extract from the last asr request
    func onAsrRequestSuccess(withText:String );
    
    /// call when the ASREngine has a invalid reposse
    ///
    /// - Parameter error: error happen during the last asr request
    func onAsrRequestFail(error:BlueVoiceAsrRequestError);
    
}

protocol BlueVoiceASREngine{
    
    /// It reveals if this engine needs an authentication key or not.
    var needAuthKey:Bool{get};
    
    /// It reveals if this engine has a continuous recognizer or not.
    var hasContinuousRecognizer:Bool{get};

    
    /// Engine name
    var name:String{get}
    
   
    /**
     *
     * @return
     */
    
    /// It provide a dialog for ASR key insertion.
    ///
    /// - Returns: a UIViewController which allows the insertion of the 
    /// ASR service activation key. It return null if the service doesn't need any key.
    func getAuthKeyDialog()->UIViewController?;
    
    /// Start the recognizer listener
    func startListener();
    
    /// Stop the recognizer listener
    func stopListener();
    
    /// Destroy the recognizer listener
    func destroyListener();
    
    
    /// tell if the engine has a valid key inserted
    ///
    /// - Returns: if the engine has a valid key, or if it doesn't need one
    func hasLoadedAuthKey() ->Bool;

    /// send and audio voice sample to convert it to text
    ///
    /// - Parameters:
    ///   - audio: audio sample to convert
    ///   - callback: object where notify the operation results
    /// - Returns: true if the reuqest is correctly send
    func sendASRRequest(audio:Data,  callback: BlueVoiceAsrRequestCallback) -> Bool;
    
}

/// utility object wuse to build an ASR Engine
public class BlueVoiceASREngineUtil{
    
    /// build the best ASR engine availbe for that language and sampling rate
    ///
    /// - Parameters:
    ///   - samplingRateHz: audio sampling rate, in Hz
    ///   - language: voice language
    /// - Returns: best available ASR engine for that languaga and sampling rate
    static func getEngine(samplingRateHz:UInt , language: BlueVoiceLangauge)->BlueVoiceASREngine{
        return BlueVoiceGoogleASREngine(language:language,samplingRateHz:samplingRateHz);
        
    }
}
