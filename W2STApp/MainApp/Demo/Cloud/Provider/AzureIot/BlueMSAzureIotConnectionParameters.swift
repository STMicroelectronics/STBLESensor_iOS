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
public class BlueMSAzureIotConnectionParameters{
    
    public let hostName:String;
    public let deviceId:String;
    public let sharedAccessKey:String;
    
    public init(hostName:String, deviceId:String,sharedAccessKey:String){
        self.hostName=hostName;
        self.deviceId=deviceId;
        self.sharedAccessKey=sharedAccessKey;
    }
    
    public static func parse(_ connectionString:String) -> BlueMSAzureIotConnectionParameters?{
        let regExp = try? NSRegularExpression(pattern: "HostName=(.*);DeviceId=(.*);SharedAccessKey=(.*)", options: .caseInsensitive)
        
        guard regExp != nil else{
            return nil;
        }
    
        let matches = regExp?.matches(in: connectionString,
                        options: [],
                        range: NSRange(location: 0, length: connectionString.count))
        guard (matches?.count == 1) else{
            return nil;
        }
        if let match = matches?[0] {
            guard match.numberOfRanges == 4 else{
                return nil;
            }
            let hostRange = Range(match.range(at: 1), in: connectionString);
            let deviceIdRange = Range(match.range(at: 2), in: connectionString);
            let shareKeyRange = Range(match.range(at: 3), in: connectionString);
        
            if let hostRange = hostRange,
               let deviceIdRange = deviceIdRange,
               let shareKeyRange = shareKeyRange{
                return BlueMSAzureIotConnectionParameters(
                    hostName: String(connectionString[hostRange]),
                    deviceId: String(connectionString[deviceIdRange]),
                    sharedAccessKey: String(connectionString[shareKeyRange]));
            }//if ranges !=nil
        }//if matches !=nil
        return nil;
    }
    
}
