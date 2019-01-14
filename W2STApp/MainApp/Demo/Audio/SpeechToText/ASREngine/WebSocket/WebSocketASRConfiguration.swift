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

public class BlueVoiceWebSocketASRKey{
    
    private static let ENDPOINT_KEY = "BlueVoiceWebSocketASRKey.endpoint"
    private static let USERNAME_KEY = "BlueVoiceWebSocketASRKey.username"
    private static let PASSWORD_KEY = "BlueVoiceWebSocketASRKey.password"
    
    public let endpoint:String;
    public let userName:String?;
    public let password:String?;
    
    init(endpoint:String,user:String? , password:String?) {
        self.endpoint = endpoint;
        userName = user;
        self.password = password;
    }
    
    public func store(){
        let userPref = UserDefaults.standard;
        userPref.setValue(endpoint, forKey: BlueVoiceWebSocketASRKey.ENDPOINT_KEY);
        userPref.setValue(userName, forKey: BlueVoiceWebSocketASRKey.USERNAME_KEY);
        userPref.setValue(password, forKey: BlueVoiceWebSocketASRKey.PASSWORD_KEY);
    }
    
    public static func load()->BlueVoiceWebSocketASRKey?{
        let userPref = UserDefaults.standard;
        let endpont = userPref.string(forKey: BlueVoiceWebSocketASRKey.ENDPOINT_KEY);
        let username = userPref.string(forKey: BlueVoiceWebSocketASRKey.USERNAME_KEY);
        let password = userPref.string(forKey: BlueVoiceWebSocketASRKey.PASSWORD_KEY);
        if let url = endpont{
            return BlueVoiceWebSocketASRKey(endpoint:url,user: username,password: password);
        }
        return nil;
        
    }
    
}

