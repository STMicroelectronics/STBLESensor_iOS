/*
* Copyright (c) 2020  STMicroelectronics – All rights reserved
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

public extension Notification.Name{
    static let assetTrackingNewData = Notification.Name("AssetTrackingBroadcastEvents.newData")
    static let assetTrackingNewPosition = Notification.Name("AssetTrackingBroadcastEvents.newPosition")
}

public struct AssetTrackingBroadcastEvents{
    
    private static let BOARD_KEY = "Device"
    private static let BOARD_DATA_KEY = "BoradData"
    private static let POSITION_KEY = "Position"
    
    public static func sendNewBoardData(device: AssetTrackingDevice, boardData: [DataSample]) {
        let notification = Notification(name: .assetTrackingNewData,
                                        object: nil,
                                        userInfo: [BOARD_KEY : device,
                                                   BOARD_DATA_KEY : boardData])
        NotificationCenter.default.post(notification)
    }
    
    public static func extractNewBoardData(from notification:Notification) -> (AssetTrackingDevice, [DataSample])? {
        guard notification.name == .assetTrackingNewData,
            let data = notification.userInfo else{
            return nil
        }
        
        guard let device = data[BOARD_KEY] as? AssetTrackingDevice,
            let boardData = data[BOARD_DATA_KEY] as? [DataSample] else{
            return nil
        }
        return (device,boardData)
    }
 
    
    public static func sendNewPosition(_ position:Location){
        let notificaiton = Notification(name: .assetTrackingNewPosition,
                                        object: nil,
                                        userInfo: [POSITION_KEY: position])
        NotificationCenter.default.post(notificaiton)
    }
    
    public static func extractNewPositionData(from notification:Notification)->Location?{
        guard notification.name == .assetTrackingNewPosition,
            let data = notification.userInfo else{
            return nil
        }
        
        return data[POSITION_KEY] as? Location
    }
}
