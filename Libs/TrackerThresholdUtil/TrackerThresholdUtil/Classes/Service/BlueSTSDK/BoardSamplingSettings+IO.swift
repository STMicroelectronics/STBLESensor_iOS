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
import AssetTrackingDataModel


internal extension BoardSempligSettings{
       
    func toData()->Data{
        var data = Data()
        data.append(UInt8(self.cloudSyncInterval))
        data.append(UInt8(self.samplingInterval))
        data.append(UInt8(self.thresholds.count))
        self.thresholds.forEach{
            data.append($0.toData())
        }
        return data
    }
    
}

internal extension Data{
    
    private static let SAMPLING_INTERVAL_OFFSET = 1
    private static let CLOUD_SYNC_OFFSET = 0
    private static let N_THRESHOLD_OFFSET = 2
    private static let HEADER_SIZE = 3
    private static let SENSOR_THRESHOLD_SIZE = 4
    
    func toBoardSamplingSettings()->BoardSempligSettings?{
        let nThrehsold = Int(self[Self.N_THRESHOLD_OFFSET])
        let samplingInterval = self[Self.SAMPLING_INTERVAL_OFFSET]
        let cloudSyncInterval = self[Self.CLOUD_SYNC_OFFSET]
        
        let expectedSize = getBoardSamplingSettingsLength()
        guard self.count == expectedSize else{
            return nil
        }
        
        var thresholds:[SensorThreshold] = []
        for currentSensor in 0..<nThrehsold {
            let posSensor = Self.HEADER_SIZE+currentSensor*Self.SENSOR_THRESHOLD_SIZE
            let th = self.getSensorTreshold(offset:posSensor)
            if let threshold = th {
                thresholds.append(threshold)
            }else{
                return nil
            }
        }
        return BoardSempligSettings(samplingInterval: samplingInterval,
                                    cloudSyncInterval: cloudSyncInterval,
                                    thresholds: thresholds)
    }
    
    func getBoardSamplingSettingsLength() -> Int{
        let nThrehsold = Int(self[Self.N_THRESHOLD_OFFSET])
        return Self.HEADER_SIZE + nThrehsold*Self.SENSOR_THRESHOLD_SIZE
    }
}
