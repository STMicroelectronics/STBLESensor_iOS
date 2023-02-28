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

public struct Configuration{
    
    public enum SamplingMode:UInt8{
        case Inactive=0x00
        case Sampling=0x01
        case SingleShot=0x02
        case SamplingWithThreshold = 0x03
        case StoreNextSample = 0x04
    }
    
    public let samplingInterval_s:UInt16
    public let mode:SamplingMode
    public let temperatureConf:SensorConfiguration
    public let humidityConf:SensorConfiguration
    public let pressureConf:SensorConfiguration
    public let accelerometerConf:SensorConfiguration
    public let orientationConf:SensorConfiguration
    public let wakeUpConf:SensorConfiguration
    public let lastConfigurationChange:Date
    
    
    public init(samplingInteval:UInt16,
                mode:SamplingMode,
                temperatureConf:SensorConfiguration,
                humidityConf:SensorConfiguration,
                pressureConf:SensorConfiguration,
                accelerometerConf:SensorConfiguration,
                orientationConf:SensorConfiguration,
                wakeUpConf:SensorConfiguration,
                lastConfChange:Date = Date() ) {
        samplingInterval_s = samplingInteval
        self.mode = mode
        self.temperatureConf = temperatureConf
        self.humidityConf = humidityConf
        self.pressureConf = pressureConf
        self.accelerometerConf = accelerometerConf
        self.orientationConf = orientationConf
        self.wakeUpConf = wakeUpConf
        self.lastConfigurationChange = lastConfChange
    }
}

public struct Threshold{
    public let max:Float?
    public let min:Float?
    
    public init(max:Float?,min:Float?) {
        self.max = max;
        self.min = min;
    }
    
    public init(max:Float?){
        self.init(max:max, min:nil)
    }
}

public struct SensorConfiguration{
    public let isEnable:Bool
    public let threshold:Threshold
    
    public init(isEnable:Bool, threshold:Threshold) {
        self.isEnable=isEnable
        self.threshold = threshold
    }
    
    public init(isEnabled:Bool){
        self.init(isEnable: isEnabled,threshold: Threshold(max: nil,min: nil))
    }
}
