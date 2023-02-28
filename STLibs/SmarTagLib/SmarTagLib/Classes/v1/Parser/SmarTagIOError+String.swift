/*
* Copyright (c) 2019  STMicroelectronics – All rights reserved
* The STMicroelectronics corporate logo is a trademark of STMicroelectronics
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* - Redistributions of source code must retain the above copyright notice, this list of conditions
* and the following disclaimer.
*
* - Redistributions in binary form must reproduce the above copyright notice, this list of
* conditions and the following disclaimer in the documentation and/or other materials provided
* with the distribution.
*
* - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
* STMicroelectronics company nor the names of its contributors may be used to endorse or
* promote products derived from this software without specific prior written permission.
*
* - All of the icons, pictures, logos and other images that are provided with the source code
* in a directory whose title begins with st_images may only be used for internal purposes and
* shall not be redistributed to any third party or modified in any way.
*
* - Any redistributions in binary form shall not include the capability to display any of the
* icons, pictures, logos and other images that are provided with the source code in a directory
* whose title begins with st_images.
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

public extension SmarTagIOError {
    
    private static let UNKNOW = {
        return  NSLocalizedString("Unknown Error",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagSensorName.self),
                                  value: "Unknown Error",
                                  comment: "Unknown Error");
    }()
    
    private static let LOST_CONNECTION = {
        return  NSLocalizedString("Lost connection with the tag",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagSensorName.self),
                                  value: "Lost connection with the tag",
                                  comment: "Lost connection with the tag");
    }()
    
    private static let WRONG_PROTOCOL = {
        return  NSLocalizedString("Data format not supported",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagSensorName.self),
                                  value: "Data format not supported",
                                  comment: "Data format not supported");
    }()
    
    private static let MALFORMED_VALUE = {
        return  NSLocalizedString("SmarTag Data not found",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagSensorName.self),
                                  value: "SmarTag Data not found",
                                  comment: "SmarTag Data not found");
    }()
    
    private static let TAG_RESPONSE_ERROR = {
        return  NSLocalizedString("SmarTag response: Error",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagSensorName.self),
                                  value: "SmarTag response: Error",
                                  comment: "SmarTag response: Error");
    }()
    
    var localizedDescription: String {
        switch(self){
        case .malformedNDef:
            return SmarTagIOError.MALFORMED_VALUE
        case .wrongProtocolVersion:
            return SmarTagIOError.WRONG_PROTOCOL
        case .lostConnection:
            return SmarTagIOError.LOST_CONNECTION
        case .tagResponseError:
            return SmarTagIOError.TAG_RESPONSE_ERROR
        case .unknown:
            return SmarTagIOError.UNKNOW
        @unknown default:
            return ""
        }
    }
}
