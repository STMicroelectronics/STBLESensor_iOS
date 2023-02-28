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
import AssetTrackingDataModel

internal class SmarTagV1Parser{
    
    static func buildVersion(rawData:Data) -> Version{
        return Version(majour: rawData[SmarTagV1Parser.VERSION_MAJ_OFFEST],
                       minor: rawData[SmarTagV1Parser.VERSION_MIN_OFFEST],
                       patch: rawData[SmarTagV1Parser.VERSION_PATH_OFFEST])
    }
    
    private static let SAMPLING_INTERVAL_OFFEST = 0
    private static let LOG_MODE_OFFEST = 2
    private static let LOG_SEMSOR_OFFSET = 3
    private static let CONFIG_WRITE_TIME_OFFEST = 4
    private static let LOG_TEMPERATURE_MASK = UInt8(0x01)
    private static let LOG_HUMIDITY_MASK = UInt8(0x02)
    private static let LOG_PRESSURE_MASK = UInt8(0x04)
    private static let LOG_ACCELEROMETER_MASK = UInt8(0x08)
    private static let LOG_ORIENTATION_MASK = UInt8(0x10)
    private static let LOG_WAKEUP_MASK = UInt8(0x20)
    private static let LOG_TEMP_MAX_TH_OFFSET = 8
    private static let LOG_TEMP_MIN_TH_OFFSET = 9
    private static let LOG_HUM_MAX_TH_OFFSET = 10
    private static let LOG_HUM_MIN_TH_OFFSET = 11
    private static let LOG_PRES_ACC_TH_OFFSET = 12
    
    static func buildConfig(rawData:Data) -> Configuration{
        let mode = Configuration.SamplingMode(rawValue: rawData[SmarTagV1Parser.LOG_MODE_OFFEST])
        let samplingInterval = rawData.getLeUInt16(offset: SmarTagV1Parser.SAMPLING_INTERVAL_OFFEST)
        let temperatureConf = SmarTagV1Parser.getTemperatureConf(from: rawData);
        let humidityConf = SmarTagV1Parser.getHumidityConf(from: rawData);
        let pressureConf = SmarTagV1Parser.getPressureConf(from: rawData);
        let accelerometerConf = SmarTagV1Parser.getAccelerometerConf(from: rawData)
        let orientationConf = SmarTagV1Parser.getOrientationConf(from: rawData)
        let wakeUpConf = SmarTagV1Parser.getWakeUpConf(from: rawData)
        let confWrite = getDate(from: rawData, offset: SmarTagV1Parser.CONFIG_WRITE_TIME_OFFEST)
        return Configuration(samplingInteval: samplingInterval,
                             mode: mode!,
                             temperatureConf:temperatureConf,
                             humidityConf:humidityConf,
                             pressureConf:pressureConf,
                             accelerometerConf:accelerometerConf,
                             orientationConf:orientationConf,
                             wakeUpConf: wakeUpConf,
                             lastConfChange: confWrite)
    }
    
    struct AcquireSampleInfo{
        let nSample:UInt16
        let nextSampleBlock:UInt16
    }
    
    static func getAcquiredSampleInfo(rawData:Data) -> AcquireSampleInfo{
        return AcquireSampleInfo(nSample: rawData.getLeUInt16(offset: 0),
                                 nextSampleBlock: rawData.getLeUInt16(offset: 2)/4)
    }
    
    static func getNAcquiredSample(rawData:Data) -> UInt16{
        return rawData.getLeUInt16(offset: 0)
    }
    
    static func getNextSampleBlock(rawData:Data) -> UInt16{
        return rawData.getLeUInt16(offset: 0)
    }
    
    private static func getTemperatureConf(from rawData:Data) ->SensorConfiguration{
           let isEnabled = (rawData[LOG_SEMSOR_OFFSET] & LOG_TEMPERATURE_MASK) != 0
           let threshold = Threshold(max: Float(rawData[LOG_TEMP_MAX_TH_OFFSET])+TEMPERATURE_RANGE_C.lowerBound,
                                     min: Float(rawData[LOG_TEMP_MIN_TH_OFFSET])+TEMPERATURE_RANGE_C.lowerBound)
           return SensorConfiguration(isEnable: isEnabled, threshold: threshold)
       }
       
       private static func getHumidityConf(from rawData:Data) ->SensorConfiguration{
           
           let isEnabled = (rawData[LOG_SEMSOR_OFFSET] & LOG_HUMIDITY_MASK) != 0
           let threshold = Threshold(max: Float(rawData[LOG_HUM_MAX_TH_OFFSET])+HUMIDITY_RANGE.lowerBound,
                                     min: Float(rawData[LOG_HUM_MIN_TH_OFFSET])+HUMIDITY_RANGE.lowerBound)
           return SensorConfiguration(isEnable: isEnabled, threshold: threshold)
       }
       
       private static func getPressureConf(from rawData:Data) ->SensorConfiguration{
           
           let isEnabled = (rawData[LOG_SEMSOR_OFFSET] & LOG_PRESSURE_MASK) != 0
           let thValue = rawData.getLeUInt32(offset: LOG_PRES_ACC_TH_OFFSET)
           let max = Float(thValue & 0xFFF)/10.0 + PRESSURE_RANGE_MBAR.lowerBound
           let min = Float((thValue >> 12) & 0xFFF)/10.0 +  PRESSURE_RANGE_MBAR.lowerBound
           let threshold = Threshold(max: max, min: min)
           return SensorConfiguration(isEnable: isEnabled, threshold: threshold)
       }
       
       private static func getAccelerometerConf(from rawData:Data) ->SensorConfiguration{
           
           let isEnabled = (rawData[LOG_SEMSOR_OFFSET] & LOG_ACCELEROMETER_MASK) != 0
           let thValue = rawData.getLeUInt32(offset: LOG_PRES_ACC_TH_OFFSET)
           
           let max = Float(((thValue >> 24) & 0x3F))*ACC_SCALE
           
           let threshold = Threshold(max: max, min: nil)
           return SensorConfiguration(isEnable: isEnabled, threshold: threshold)
       }
       
       private static func getOrientationConf(from rawData:Data) ->SensorConfiguration{
           
           let isEnabled = (rawData[LOG_SEMSOR_OFFSET] & LOG_ORIENTATION_MASK) != 0
           
           let threshold = Threshold(max: nil, min: nil)
           return SensorConfiguration(isEnable: isEnabled, threshold: threshold)
       }
       
       private static func getWakeUpConf(from rawData:Data) ->SensorConfiguration{
           
           let isEnabled = (rawData[LOG_SEMSOR_OFFSET] & LOG_WAKEUP_MASK) != 0
           let thValue = rawData.getLeUInt32(offset: LOG_PRES_ACC_TH_OFFSET)
           
           let max = Float(((thValue >> 24) & 0x3F))*ACC_SCALE
           
           let threshold = Threshold(max: max, min: nil)
           return SensorConfiguration(isEnable: isEnabled, threshold: threshold)
       }
    //24
    private static let EXTREME_TEMP_MAX_OFFSET = 16
    private static let EXTREME_TEMP_MAX_DATE_OFFSET = 0
    private static let EXTREME_TEMP_MIN_OFFSET = 17
    private static let EXTREME_TEMP_MIN_DATE_OFFSET = 4
    private static let EXTREME_HUM_MAX_OFFSET = 18
    private static let EXTREME_HUM_MAX_DATE_OFFSET = 8
    private static let EXTREME_HUM_MIN_OFFSET = 19
    private static let EXTREME_HUM_MIN_DATE_OFFSET = 12
    private static let EXTREME_PRES_MAX_MIN_OFFSET = 32
    private static let EXTREME_PRES_MAX_DATE_OFFSET = 20
    private static let EXTREME_PRES_MIN_DATE_OFFSET = 24
    private static let EXTREME_ACC_MAX_OFFSET = 32
    private static let EXTREME_ACC_MAX_DATE_OFFSET = 28
    private static let INVALID_TEMP = 0x007F
    private static let INVALID_PRESSURE = 0x0FFF
    private static let INVALID_HUM = 0x007F
    private static let INVALID_ACC = 0x003F
    private static let SAMPLE_FIRST_DATA_OFFSET = 64
    private static let YEAR_OFFSET = 2018
    
    static func buildTagExtreme(rawData:Data, configuration:Configuration) -> TagExtreme{
        let temperature = configuration.temperatureConf.isEnable ? SmarTagV1Parser.getTemperatureExtreme(from: rawData) : nil
        let pressure = configuration.pressureConf.isEnable ? SmarTagV1Parser.getPressureExtreme(from: rawData) : nil
        let humidity = configuration.humidityConf.isEnable ? SmarTagV1Parser.getHumidityExtreme(from: rawData) : nil
        let acceleration = configuration.accelerometerConf.isEnable ? SmarTagV1Parser.getAccelerometerExtreme(from: rawData): nil
        return TagExtreme(acquisitionStart: configuration.lastConfigurationChange,
                          temperature: temperature,
                          pressure: pressure,
                          humidity: humidity,
                          acceleration: acceleration)
    }
    
    private static func getTemperatureExtreme(from rawData:Data) ->DataExtreme{
           let max = Float(rawData[EXTREME_TEMP_MAX_OFFSET])+TEMPERATURE_RANGE_C.lowerBound
           let dataMax = getDate(from: rawData, offset: EXTREME_TEMP_MAX_DATE_OFFSET)
           let min = Float(rawData[EXTREME_TEMP_MIN_OFFSET])+TEMPERATURE_RANGE_C.lowerBound
           let dataMin = getDate(from: rawData, offset: EXTREME_TEMP_MIN_DATE_OFFSET)
           return DataExtreme(maxDate: dataMax, maxValue: max, minDate: dataMin, minValue: min)
       }
       
       private static func getHumidityExtreme(from rawData:Data) ->DataExtreme{
           let max = Float(rawData[EXTREME_HUM_MAX_OFFSET])+HUMIDITY_RANGE.lowerBound
           let dataMax = getDate(from: rawData, offset: EXTREME_HUM_MAX_DATE_OFFSET)
           let min = Float(rawData[EXTREME_HUM_MIN_OFFSET])+HUMIDITY_RANGE.lowerBound
           let dataMin = getDate(from: rawData, offset: EXTREME_HUM_MIN_DATE_OFFSET)
           return DataExtreme(maxDate: dataMax, maxValue: max, minDate: dataMin, minValue: min)
       }
       
       
       private static func getPressureExtreme(from rawData:Data) ->DataExtreme{
           
           let pressureValue = rawData.getLeUInt32(offset: EXTREME_PRES_MAX_MIN_OFFSET)
           let max = Float(pressureValue & 0xFFF)/10.0 + PRESSURE_RANGE_MBAR.lowerBound
           let dataMax = getDate(from: rawData, offset: EXTREME_PRES_MAX_DATE_OFFSET)
           let min = Float((pressureValue >> 12) & 0xFFF)/10.0 + PRESSURE_RANGE_MBAR.lowerBound
           let dataMin = getDate(from: rawData, offset: EXTREME_PRES_MIN_DATE_OFFSET)
           return DataExtreme(maxDate: dataMax, maxValue: max, minDate: dataMin, minValue: min)
       }
       
       private static func getAccelerometerExtreme(from rawData:Data) ->DataExtreme{
           
           let thValue = rawData.getLeUInt32(offset: EXTREME_ACC_MAX_OFFSET)
           
           let max = Float(((thValue >> 24) & 0x3F))*ACC_SCALE
           let dataMax = getDate(from: rawData, offset: EXTREME_ACC_MAX_DATE_OFFSET)

           return DataExtreme(maxDate: dataMax, maxValue: max, minDate: nil, minValue: nil)
           
       }
       
       private static func getDate(from rawData:Data, offset:Data.Index)->Date{
           let compactValue = rawData.getLeUInt32(offset: offset) & 0x7FFFFFFF; //set to 0 the msb
           var dateComponents = DateComponents()
           
           dateComponents.year = Int((compactValue >> 26) & 0x3F) + YEAR_OFFSET //6bit
           dateComponents.month = Int((compactValue >> 17) & 0x0F) //4bit
           dateComponents.day = Int((compactValue >> 21)  & 0x1F) //5bit
           
           dateComponents.hour = Int((compactValue >> 12) & 0x1F) //5bit
           dateComponents.minute = Int((compactValue >> 6) & 0x3F)  //6bit
           dateComponents.second = Int(compactValue & 0x3F)  //6bit
           return  Calendar.current.date(from: dateComponents)!
       }
    
    private static let TEMPERATURE_RANGE_C = Float(-40.0)...Float(85.0)
    private static let HUMIDITY_RANGE = Float(0.0)...Float(100.0)
    private static let PRESSURE_RANGE_MBAR = Float(810.0)...Float(1210.0)
    private static let ACCELERATION_RANGE_MG = Float(0.0)...Float(16000.0)
    private static let ACC_SCALE = Float(256)
    
    private static let VERSION_MAJ_OFFEST = 1
    private static let VERSION_MIN_OFFEST = 2
    private static let VERSION_PATH_OFFEST = 3
    
    
    private static func getSensorSampleSample(from rawData:Data)->SensorDataSample{
        let sampleDate = getDate(from: rawData, offset: 0)
        let data = rawData.getLeUInt32(offset: 4)
        var intValue = (data >> 20) & 0xFFF
        let pressure = (intValue != INVALID_PRESSURE) ? Float(intValue)/10.0 + PRESSURE_RANGE_MBAR.lowerBound : nil
        intValue = (data >> 13) & 0x7F
        let temperature = (intValue != INVALID_TEMP) ? Float(intValue)+TEMPERATURE_RANGE_C.lowerBound : nil
        intValue = (data >> 6) & 0x7F
        let humidity = (intValue != INVALID_HUM) ? Float(intValue) + HUMIDITY_RANGE.lowerBound: nil
        intValue = data & 0x3F
        let acc = (intValue != INVALID_ACC) ? Float(intValue)*ACC_SCALE : nil
        return SensorDataSample(date: sampleDate, temperature: temperature,
                                humidity: humidity, pressure: pressure,
                                acceleration: acc)
    }
    
    private static func getEventSampleSample(from rawData: Data) -> EventDataSample {
        let sampleDate = getDate(from: rawData, offset: 0)
        let data = rawData.getLeUInt32(offset: 4)
        
        // orientation = 3 bit
        let orientation = UInt8(data & 0x07).convertToNfcOrientation().sensorOrientation
        let events = UInt8((data >> 3) & 0x3F).toAccelerationEvents()
        let intValue = (data >> 9) & 0x3F
        let acc = (intValue != INVALID_ACC) ? Float(intValue)*ACC_SCALE : nil
        return EventDataSample(date: sampleDate,
                               acceleration: acc,
                               accelerationEvents: events,
                               currentOrientation: orientation)
    }
    
    public static func getDataSample(from rawData:Data, index: Int)->DataSample{
        let sampleData = rawData[index*8..<(index+1)*8]
        let isAsyncSample = (sampleData.getLeUInt32(offset: 0) & 0x80000000) != 0
        if( isAsyncSample){
            return DataSample.event(data: getEventSampleSample(from: sampleData))
        }else{
            return DataSample.sensor(data: getSensorSampleSample(from: sampleData))
        }
        
    }
    
    private static func encodeEnabledSensor(_ conf:Configuration) -> UInt8{
        var flag = UInt8(0)
        if (conf.temperatureConf.isEnable){
            flag |= SmarTagV1Parser.LOG_TEMPERATURE_MASK
        }
        if(conf.humidityConf.isEnable){
            flag |= SmarTagV1Parser.LOG_HUMIDITY_MASK
        }
        if(conf.pressureConf.isEnable){
            flag |= SmarTagV1Parser.LOG_PRESSURE_MASK
        }
        if(conf.accelerometerConf.isEnable){
            flag |= SmarTagV1Parser.LOG_ACCELEROMETER_MASK
        }
        if(conf.orientationConf.isEnable){
            flag |= SmarTagV1Parser.LOG_ORIENTATION_MASK
        }
        if(conf.wakeUpConf.isEnable){
            flag |= SmarTagV1Parser.LOG_WAKEUP_MASK
        }
        return flag
    }
    
    private static  func encodeDate(_ date:Date)->Data{
        let calendar = Calendar(identifier: .gregorian)
        var rawData = UInt32(0)
        rawData |= UInt32(calendar.component(.second, from: date) & 0x3F) // 6bit
        rawData |= UInt32((calendar.component(.minute, from: date) & 0x3F)) << 6
        rawData |= UInt32((calendar.component(.hour, from: date) & 0x1F)) << 12
        rawData |= UInt32((calendar.component(.day, from: date) & 0x1F)) << 21
        rawData |= UInt32((calendar.component(.month, from: date) & 0x0F)) << 17
        rawData |= UInt32(((calendar.component(.year, from: date) -  YEAR_OFFSET) & 0x3F)) << 26
        return Data(bytes: &rawData,count: 4)
    }
    
    
    private static func clampThreshold(th:Threshold, range:ClosedRange<Float>)->Threshold{
        let max = th.max?.clampTo(range)
        let min = th.min?.clampTo(range)
        return Threshold(max: max, min: min)
    }
    
    private static func encodeTemperatureHumidityThreshold(temperature:Threshold, humidity:Threshold) -> Data{
        let  tempOffset = TEMPERATURE_RANGE_C.lowerBound
        let clampTempTh = clampThreshold(th: temperature, range: TEMPERATURE_RANGE_C)
        let maxTemp = (clampTempTh.max ?? TEMPERATURE_RANGE_C.lowerBound) - tempOffset
        let minTemp = (clampTempTh.min ?? TEMPERATURE_RANGE_C.upperBound) - tempOffset
        let clampHumTh = clampThreshold(th: humidity, range: HUMIDITY_RANGE)
        let maxHum = clampHumTh.max ?? HUMIDITY_RANGE.lowerBound
        let minHum = clampHumTh.min ?? HUMIDITY_RANGE.upperBound
        return Data([UInt8(maxTemp),UInt8(minTemp),UInt8(maxHum),UInt8(minHum)])
    }
    
    private static func encodePressureAccThrehsold(pressure:Threshold, acc:Threshold) -> Data{
        let pressureOffset = PRESSURE_RANGE_MBAR.lowerBound
        let clampPressureTh = clampThreshold(th: pressure, range: PRESSURE_RANGE_MBAR)
        let minPres = UInt32(((clampPressureTh.min ?? PRESSURE_RANGE_MBAR.upperBound) - pressureOffset) * 10)
        let maxPres = UInt32(((clampPressureTh.max ?? PRESSURE_RANGE_MBAR.lowerBound) - pressureOffset) * 10)
        let clampAccelerometerTh = clampThreshold(th: acc, range: ACCELERATION_RANGE_MG)
        let acc = UInt32(((clampAccelerometerTh.max ?? ACCELERATION_RANGE_MG.lowerBound) - ACCELERATION_RANGE_MG.lowerBound)/ACC_SCALE)
        
        var packValue:UInt32 = (acc & 0x3F) << 24
        packValue |= (minPres & 0xFFF) << 12
        packValue |= (maxPres & 0xFFF)
        return Data(bytes: &packValue,count: 4)
    }
    
    static func encodeConfiguration(_ conf:Configuration) -> Data{
        
        let date = conf.lastConfigurationChange
        print(date)
        print(getDate(from: encodeDate(date),offset: 0))
        
        var samplingSettings = Data()
        samplingSettings.append(conf.samplingInterval_s.toLEData)
        samplingSettings.append(conf.mode.rawValue)
        samplingSettings.append(encodeEnabledSensor(conf))
        samplingSettings.append(encodeDate(conf.lastConfigurationChange))
        samplingSettings.append(
            encodeTemperatureHumidityThreshold(
                temperature: conf.temperatureConf.threshold,
                humidity: conf.humidityConf.threshold))
        samplingSettings.append(encodePressureAccThrehsold(pressure: conf.pressureConf.threshold, acc: conf.accelerometerConf.threshold))
        let statusCell = SmarTagStatus(newConfigurationAvailable: true, singleShotResponseReady: false)
        samplingSettings.append(encodeTagStatus(statusCell))
        print((samplingSettings as NSData).debugDescription)
        return samplingSettings
    }
    
    static func resetExtremeData() -> Data{
        let zeroBlock = Data(repeating: 0, count: 4)
        var extremeData = Data()
        extremeData.append(zeroBlock) // tempMaxDate
        extremeData.append(zeroBlock) // tempMinDate
        extremeData.append(zeroBlock) // HumMaxDate
        extremeData.append(zeroBlock) // HumpMinDate
        extremeData.append(encodeTemperatureHumidityThreshold(
            temperature: Threshold(max: TEMPERATURE_RANGE_C.lowerBound,min: TEMPERATURE_RANGE_C.upperBound),
            humidity: Threshold(max:HUMIDITY_RANGE.lowerBound,min:HUMIDITY_RANGE.upperBound)))
        extremeData.append(zeroBlock) // pressMaxDate
        extremeData.append(zeroBlock) // pressMinDate
        extremeData.append(zeroBlock) // accMaxDate
        extremeData.append(encodePressureAccThrehsold(
            pressure: Threshold(max: PRESSURE_RANGE_MBAR.lowerBound, min: PRESSURE_RANGE_MBAR.upperBound),
            acc:Threshold(max: ACCELERATION_RANGE_MG.lowerBound, min: nil)))
        
        return extremeData
    }
    
    static func resetSensorSample( firstSampleBlock:UInt16) -> Data{
        let fistSampleBytePosition = firstSampleBlock * 4
        var data = Data(capacity: 4)
        data.append(contentsOf: [0x00,0x00])
        data.append(contentsOf: fistSampleBytePosition.toLEData)
        return data
    }
    
    static func buildTagStatus(from rawData:Data)->SmarTagStatus{
        return SmarTagStatus(newConfigurationAvailable: rawData[0] != 0,
                             singleShotResponseReady: rawData[1] != 0)
    }
    
    static func encodeTagStatus(_ status:SmarTagStatus)->Data{
        return Data([status.newConfigurationAvailable ? 0x01 : 0x00,
            status.singleShotResponseReady ? 0x01:0x00,
            0x00, // not used
            0x00 // not used
        ])
    }    
}

fileprivate extension Data{
    
    func getLeUInt16(offset:Index)->UInt16{
        var value = UInt16(0)
        value = UInt16(self[self.startIndex+offset]) | UInt16(self[self.startIndex+offset+1])<<8
        return value
    }
        
    func getLeUInt32(offset:Index)->UInt32{
        return  UInt32(self[self.startIndex+offset])         | (UInt32(self[self.startIndex+offset+1])<<8) |
                (UInt32(self[self.startIndex+offset+2])<<16) | (UInt32(self[self.startIndex+offset+3])<<24)
    }
}

fileprivate extension UInt16 {
    var toLEData:Data{
        var temp = self
        return Data(bytes: &temp,count: 2)
    }
}

fileprivate extension Float{
    func clampTo( _ range:ClosedRange<Float>)->Float{
        range.lowerBound > self ? range.lowerBound
        : range.upperBound < self ? range.upperBound
        : self
    }
}
