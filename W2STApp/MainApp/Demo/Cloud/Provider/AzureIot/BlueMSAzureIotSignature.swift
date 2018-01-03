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
/*
 * equivalent of:
 https://github.com/Azure/azure-iot-sdk-java/blob/ac28d075b506220a3c92743b5ef9949aa36407fc/device/iot-device-client/src/main/java/com/microsoft/azure/sdk/iot/device/auth/Signature.java
*/
public class BlueMSAzureIotSignature{

    private static let RAW_SIGNATURE_FORMAT="%@\n%lld";
    
    private static func buildRawSignature(uri:String, expireTime:Int64)->Data{
        let mergeStr = String(format:RAW_SIGNATURE_FORMAT,uri,expireTime);
        return mergeStr.data(using: .utf8)!
    }
    
    private static func decodeDeviceKeyBase64(_ deviceKey:String)->Data{
        let deviceUrlStr = String(format:"data:application/octet-stream;base64,%@",deviceKey);
        let deviceUrl = URL(string: deviceUrlStr);
        return try! Data(contentsOf: deviceUrl!);
    }
    
    public static func signature(forUri uri:String,
                                       expireTime:Int64,
                                       deviceKey:String) ->String{
        
        let rawSig = BlueMSAzureIotSignature.buildRawSignature(uri: uri,expireTime: expireTime);
        let decodeDeviceKey = BlueMSAzureIotSignature.decodeDeviceKeyBase64(deviceKey);
        let encryptedBase64 = rawSig.getSHA256HMac(key: decodeDeviceKey).base64EncodedData();
        return String(data: encryptedBase64, encoding: .utf8)!.encodeWebSafe();
    }
}

