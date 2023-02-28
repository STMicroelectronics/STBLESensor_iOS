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
import SwiftyJSON

extension SensorDataSample {
    
    enum MappingKeys{
        case acceleration
        case pressure
        case temperature
        case humidity
        
        var decode: String{
            switch self{
            case .acceleration :
                return "acc"
            case .pressure:
                return "pre"
            case .temperature:
                return "tem"
            case .humidity:
                return "hum"
            }
        }
        
        var encode: String{
            switch self{
            case .acceleration :
                return "acc"
            case .pressure:
                return "pre"
            case .temperature:
                return "tem"
            case .humidity:
                return "hum"
            }
        }
    }
    
    var toJson: JSON {
        var obj = JSON()
        try? obj.merge(with: date.toJson)
        //obj["domain"].string = "environmental"
        
        var measure: String = ""
        var value: Float = 0.0
        
        if let acceleration = self.acceleration {
            measure = MappingKeys.acceleration.encode
            value = acceleration
        } else if let pressure = self.pressure {
            measure = MappingKeys.pressure.encode
            value = pressure;
        } else if let temperature = self.temperature {
            measure = MappingKeys.temperature.encode
            value = temperature
        } else if let humidity = self.humidity {
            measure = MappingKeys.humidity.encode
            value = humidity
        }
        
        obj["t"].string = measure
        obj["v"].float = value
        
        return obj
    }
    
    /// The input sample containing multiple sensor readings is transformed into an array of samples, each one with a single sensor reading.
    /// Example: split the inpit sample with both humidity and temperature into an array containing 1 humidity sample and 1 temperature sample.
    var toSplittedJson: [JSON] {
        var splitted: [JSON] = []
        
        if let acceleration = self.acceleration {
            splitted.append(SensorDataSample(date: date, acceleration: acceleration).toJson)
        }
        if let pressure = self.pressure {
            splitted.append(SensorDataSample(date: date, pressure: pressure).toJson)
        }
        if let temperature = self.temperature {
            splitted.append(SensorDataSample(date: date, temperature: temperature).toJson)
        }
        if let humidity = self.humidity {
            splitted.append(SensorDataSample(date: date, humidity: humidity).toJson)
        }
        
        return splitted
    }
}

private extension AccelerationEvent {
    var toJsonString: String{
        switch self {
        case .wakeUp:
            return "WAKE_UP"
        case .orientation:
            return "ORIENTATION"
        case .singleTap:
            return "SINGLE_TAP"
        case .doubleTap:
            return "DOUBLE_TAP"
        case .freeFall:
            return "FREE_FALL"
        case .tilt:
            return "TILT"
        }
    }
}

extension SensorOrientation {
    var toJsonString: String {
        switch self {
        case .unknown:
            return "UNKWNOWN"
        case .topRight:
            return "UP_RIGHT"
        case .up:
            return "TOP"
        case .bottomLeft:
            return "DOWN_LEFT"
        case .down:
            return "BOTTOM"
        case .topLeft:
            return "UP_LEFT"
        case .bottomRight:
            return "DOWN_RIGHT"
        }
    }
    
    static func fromJson(string: String) -> SensorOrientation {
        switch string {
        case "TOP":
            return .up
        case "BOTTOM":
            return .down
        case "TOP.LEFT":
            return .topLeft
        case "TOP.RIGHT":
            return .topRight
        case "BOTTOM.LEFT":
            return .bottomLeft
        case "BOTTOM.RIGHT":
            return .bottomRight
        default:
            return .unknown
        }
    }

}

internal extension EventDataSample {
    private static let ACCELERATION = "acc"
    private static let EVENTS = "evt"
    private static let ORIENTATION = "ori"
    
    var toJson: JSON {
        var obj = JSON()
        try? obj.merge(with: date.toJson)
        var value = JSON()
        
        let fillJson: () -> Void = {
            obj["t"].stringValue = "evt"
            obj["v"].object = value
        }
        
        guard let first = accelerationEvents.first else {
            fillJson()
            return obj
        }
        
        switch first {
        case .wakeUp:
            var objWakeUp = JSON()
            objWakeUp["et"].stringValue = "threshold"
            objWakeUp["m"].stringValue = "wakeup"
            value = objWakeUp
        case .tilt:
            var objTilt = JSON()
            objTilt["et"].stringValue = "threshold"
            objTilt["m"].stringValue = "tilt"
            value = objTilt
        case .orientation:
            var objOrientation = JSON()
            objOrientation["et"].stringValue = "threshold"
            objOrientation["m"].stringValue = "orientation"
            objOrientation["l"].stringValue = (currentOrientation ?? .unknown).toJsonString
            value = objOrientation
        case .singleTap, .doubleTap, .freeFall:
            break
        }
        
        
//        obj[EventDataSample.EVENTS].arrayObject = self.accelerationEvents.map{$0.toJsonString}
//
//        if let acc = self.acceleration {
//            obj[EventDataSample.ACCELERATION].floatValue = acc;
//        }
//
//        if let orientation = self.currentOrientation,
//           orientation != .unknown{
//            obj[EventDataSample.ORIENTATION].stringValue = orientation.toJsonString
//        }
//
        fillJson()
        return obj
    }
}
