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


internal extension SensorThreshold{
    
    private func encodeThreshold()->Data{
        switch self.sensor {
        case .Temperature:
            var intValue = Int16(self.value*10.0)
            return Data(bytes: &intValue,count: 2)
        case .Pressure:
            var intValue = UInt16(self.value*10.0)
            return Data(bytes: &intValue,count: 2)
        case .Humidity:
            var intValue = UInt16(self.value*10.0)
            return Data(bytes: &intValue,count: 2)
        case .WakeUp:
            var intValue = UInt16(self.value)
            return Data(bytes: &intValue,count: 2)
        case .Tilt:
            var intValue = UInt16(self.value)
            return Data(bytes: &intValue,count: 2)
        case .Orietation:
            var intValue = UInt16(self.orientation?.toByte ?? 0)
            return Data(bytes: &intValue,count: 2)
        }
    }
    
    func toData() -> Data{
        var data = Data(capacity: 4)
        data.append(self.sensor.toByte)
        data.append(self.comparison.toByte)
        data.append(encodeThreshold())
        return data
    }
}

internal extension Data {
    
    func getSensorTreshold(offset:Int) -> SensorThreshold?{
        guard let sensor = self[offset].toSensorType else{
            return nil
        }
        
        guard let comparison = self[offset+1].toThresholdType else{
            return nil
        }
        
        let thesholValueData = Data(self[(offset+2)...(offset+3)])

        var orientation: SensorOrientation?
        var value: Double?
        
        switch sensor {
        case .Temperature:
            value = Double(thesholValueData.getLeInt16())/10.0
        case .Pressure:
            value = Double(thesholValueData.getLeUInt16())/10.0
        case .Humidity:
            value = Double(thesholValueData.getLeUInt16())/10.0
        case .WakeUp:
            value = Double(thesholValueData.getLeUInt16())
        case .Tilt:
            value = 1.0
        case .Orietation:
            orientation = UInt8(thesholValueData.getLeUInt16()).toOrientation
        }
        
        if(orientation == nil){
            return SensorThreshold(sensor: sensor, comparison: comparison, value: value!)
        }else{
            return SensorThreshold(orientation: orientation!)
        }
        
    }

    private func getLeUInt16(offset: Index = 0) -> UInt16 {
        var value = UInt16(0)
        value = UInt16(self[self.startIndex+offset]) | UInt16(self[self.startIndex+offset+1])<<8
        return value
    }

    private func getLeInt16(offset: Index = 0) -> Int16 {
        var value = Int16(0)
        value = Int16(self[self.startIndex+offset]) | Int16(self[self.startIndex+offset+1])<<8
        return value
    }

    private func getLeUInt32(offset: Index) -> UInt32 {
        return  UInt32(self[offset])       | (UInt32(self[offset+1])<<8) |
            (UInt32(self[offset+2])<<16) | (UInt32(self[offset+3])<<24)
    }
}
