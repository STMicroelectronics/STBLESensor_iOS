/*
 * Copyright (c) 2018  STMicroelectronics – All rights reserved
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

class SelectableFeature{
    let name:String
    let mask:UInt32
    var isSelected = false
    
    init(name:String, mask:UInt32){
        self.name = name
        self.mask = mask
    }
}

struct AIDataParameterConfiguration{
    let minValue:Float
    let maxValue:Float
    let defaultValue:Float
    let values:[Float]
    
    init(minVal:Float, maxVal:Float,stepVal:Float,defaultVal:Float){
        self.minValue = minVal
        self.maxValue = maxVal
        self.defaultValue = defaultVal
        
        let size = Int(((maxValue-minValue)/stepVal).rounded())+1
        var tempValue = minValue
        var values = [Float]()
        for _ in 0..<size {
            values.append(tempValue)
            tempValue += stepVal
        }
        self.values = values
    }
    
    init(values:[Float], defaultVal:Float) {
        self.values = values
        self.defaultValue = defaultVal
        self.minValue = values.max() ?? Float.nan
        self.maxValue = values.min() ?? Float.nan
    }
    
}

class AIDataLogParametersViewModel{
    
    public static let ENVIROMENTAL_FREQUENCY_CONF = AIDataParameterConfiguration(
        minVal: 0.1, maxVal: 1.0, stepVal: 0.1, defaultVal: 1.0
    )
    
    public static let INERTIAL_FREQUENCY_CONF = AIDataParameterConfiguration(
        values: [13.0,26.0,52.0,104.0], defaultVal: 104.0
    )
    
    public static let AUDIO_VOLUME_CONF = AIDataParameterConfiguration(
        values: [0.5,1.0,1.5,2.0], defaultVal: 1.0
    )
    
    public let availableFeatures = [
        SelectableFeature(name:"Temperature (HTS221)", mask:UInt32(0x00010000)),
        SelectableFeature(name:"Temperature (LPS22HB)",  mask:UInt32(0x00040000)),
        SelectableFeature(name:"Pressure",  mask:UInt32(0x00100000)),
        SelectableFeature(name:"Humidity",  mask:UInt32(0x00080000)),
        SelectableFeature(name:"Accelerometer",  mask:UInt32(0x00800000)),
        SelectableFeature(name:"Gyroscope",  mask:UInt32(0x00400000)),
        SelectableFeature(name:"Magnetometer",  mask:UInt32(0x00200000)),
        SelectableFeature(name:"Audio", mask:UInt32(0x08000000)),
    ]
    
    public var inertialFrequencyHz = INERTIAL_FREQUENCY_CONF.defaultValue
    public var environmentalFrequencyHz = ENVIROMENTAL_FREQUENCY_CONF.defaultValue
    public var audioVolume = AUDIO_VOLUME_CONF.defaultValue
    
    public func getSelectedFeatureMask()->UInt32{
        return availableFeatures
            .filter{ $0.isSelected }
            //make the or of all the selected feture
            .reduce(UInt32(0)){ mergeMask, current in
                return mergeMask | current.mask
            }
    }
    
    var parameters: BlueSTSDKFeatureAILogging.Parameters {
        get {
            return BlueSTSDKFeatureAILogging.Parameters(featureMask:getSelectedFeatureMask(),
                                                        environmentalFrequencyHz: environmentalFrequencyHz,
                                                        inertialFrequencyHz:inertialFrequencyHz,
                                                        audioVolume:audioVolume)
        }
    }
    
}
