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

public class SmarTagSensorName{
    public static let PRESSURE = {
        return  NSLocalizedString("Pressure",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagSensorName.self),
                                  value: "Pressure",
                                  comment: "Pressure");
    }()
    
    public static let PRESSURE_UNIT = {
        return  NSLocalizedString("mbar",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagSensorName.self),
                                  value: "mbar",
                                  comment: "mbar");
    }()
    
    public static let PRESSURE_DATA_FORMAT = "%.1f"
    public static let PRESSURE_FORMAT = PRESSURE_DATA_FORMAT + " " + PRESSURE_UNIT
    
    public static let HUMIDITY = {
        return  NSLocalizedString("Humidity",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagSensorName.self),
                                  value: "Humidity",
                                  comment: "Humidity");
    }()
    
    public static let HUMIDITY_UNIT = "%"
    public static let HUMIDITY_DATA_FORMAT = "%.0f"
    public static let HUMIDITY_FORMAT = HUMIDITY_DATA_FORMAT + " %%" // the double % is needed to use the string as format
    
    public static let TEMPERATURE = {
        return  NSLocalizedString("Temperature",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagSensorName.self),
                                  value: "Temperature",
                                  comment: "Temperature");
    }()
    
    public static let TEMPERATURE_UNIT = {
        return  NSLocalizedString("\u{2103}",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagSensorName.self),
                                  value: "\u{2103}",
                                  comment: "temperature degree");
    }()
    
    public static let TEMPERATURE_DATA_FORMAT = "%.0f"
    public static let TEMPERATURE_FORMAT = TEMPERATURE_DATA_FORMAT + " " + TEMPERATURE_UNIT
    
    public static let ACCELERATION = {
        return  NSLocalizedString("Acceleration",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagSensorName.self),
                                  value: "Acceleration",
                                  comment: "Acceleration");
    }()
    
    public static let ACCELERATION_UNIT = {
        return  NSLocalizedString("mg",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagSensorName.self),
                                  value: "mg",
                                  comment: "mg");
    }()
    
    public static let ACCELERATION_DATA_FORMAT = "%.0f"
    public static let ACCELERATION_FORMAT = ACCELERATION_DATA_FORMAT + " " + ACCELERATION_UNIT
    
    public static let ORIENTATION = {
        return  NSLocalizedString("6D Orientation",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagSensorName.self),
                                  value: "6D Orientation",
                                  comment: "6D Orientation");
    }()
    
    public static let WAKE_UP = {
        return  NSLocalizedString("Wake Up Event",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagSensorName.self),
                                  value: "Wake Up Event",
                                  comment: "Wake Up Event");
    }()
    
}
