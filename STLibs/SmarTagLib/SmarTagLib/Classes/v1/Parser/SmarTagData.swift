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
import AssetTrackingDataModel

 public func tagIdentifierToString(id:Data)->String{
    let MAX_ID_LENGTH = 8
    return id.reversed()
            .prefix(MAX_ID_LENGTH)
            .map{ String(format: "%02X", $0)}
            .joined()

 }
 
 public struct SmarTagData{
    
    public let id:Data?
    public let version:Version
    public let configuration: Configuration
    public let samples: [DataSample]
    public let dataExtreme:TagExtreme
    
    public var idStr:String?{
        get {
            if let id = id {
                return tagIdentifierToString(id: id)
            }else{
                return nil
            }
        }
    }
    
 }
 
 public func generateFakeSmartTagData() -> SmarTagData{
    let configuration = Configuration(samplingInteval: 1, mode: .SamplingWithThreshold,
                                    temperatureConf: SensorConfiguration(isEnable: true, threshold: Threshold(max: 30,min: 20)),
                                    humidityConf: SensorConfiguration(isEnable: true, threshold: Threshold(max: 50,min: 40)),
                                    pressureConf: SensorConfiguration(isEnable: true, threshold: Threshold(max: 1010.0,min: 1000.0)),
                                    accelerometerConf: SensorConfiguration(isEnable: true, threshold: Threshold(max: 1024,min: nil)),
                                    orientationConf: SensorConfiguration(isEnable: true, threshold: Threshold(max: nil,min: nil)),
                                    wakeUpConf: SensorConfiguration(isEnable: true, threshold: Threshold(max: 1024,min: nil)))
    let samples:[DataSample] = (1...10).map{ index in
        let timeOffset = TimeInterval(index)
        let valueOffset = Float(index)
         return DataSample.sensor(data: SensorDataSample(date: Date(timeIntervalSinceNow: timeOffset),
                                                 temperature: 20+valueOffset,
                                                 humidity: 50+valueOffset,
                                                 pressure: 1000+valueOffset,
                                                 acceleration: 1000+valueOffset*10))
    }
    let extreme = TagExtreme(acquisitionStart: Date(),
            temperature: DataExtreme(maxDate: Date(), maxValue: 50, minDate: Date(), minValue: 40),
            pressure: DataExtreme(maxDate: Date(), maxValue: 1100, minDate: Date(), minValue: 900),
            humidity: DataExtreme(maxDate: Date(), maxValue: 90, minDate: Date(), minValue: 80),
            acceleration: DataExtreme(maxDate: Date(), maxValue: 10000, minDate: nil, minValue: nil))
    return SmarTagData( id: nil,
                        version: Version (majour: 1,minor: 2,patch: 3),
                        configuration: configuration,
                        samples: samples,
                        dataExtreme: extreme)

 }
