 /*
  * Copyright (c) 2018  STMicroelectronics – All rights reserved
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
import SmarTagLib
import SwiftyJSON
 
extension DataExtreme {
    private static let MINDATE = "minDate"
    private static let MIN = "min"
    private static let MAXDATE = "maxDate"
    private static let MAX = "max"
    
    public var toJson:JSON{
        var obj = JSON()
        
        if let min = self.minValue{
            obj[DataExtreme.MIN].floatValue = min
            obj[DataExtreme.MINDATE].intValue = Int(self.minDate?.timeIntervalSince1970 ?? 0)
        }
        
        if let max = self.maxValue{
            obj[DataExtreme.MAX].floatValue = max
            obj[DataExtreme.MAXDATE].intValue = Int(self.maxDate?.timeIntervalSince1970 ?? 0)
        }
        
        return obj
    }
 }

 extension TagExtreme {
    private static let START_ACQUISITION = "started"
    private static let ACCELERATION = "acc"
    private static let PRESSURE = "pres"
    private static let TEMPERATURE = "temp"
    private static let HUMIDITY = "hum"
    
    public var toJson:JSON{
        var obj = JSON()
        obj[TagExtreme.START_ACQUISITION].intValue = Int(self.acquisitionStart.timeIntervalSince1970)
        
        if let humidity = self.humidity{
            obj[TagExtreme.HUMIDITY] = humidity.toJson
        }
        
        if let temperature = self.temperature{
            obj[TagExtreme.TEMPERATURE] = temperature.toJson
        }
        
        if let pressure = self.pressure{
            obj[TagExtreme.PRESSURE] = pressure.toJson
        }
        
        if let acc = self.acceleration{
            obj[TagExtreme.ACCELERATION] = acc.toJson
        }
        
        return obj
    }
 }
