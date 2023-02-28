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
import UIKit

import AssetTrackingDataModel

extension SensorOrientation: CustomStringConvertible {
    private static let TOP_LEFT = {
        return  NSLocalizedString("Top Left",
                                  tableName: nil,
                                  bundle: TrackerThresholdUtilBundle.bundle(),
                                  value: "Top Left",
                                  comment: "Top Left")
    }()

    private static let BOTTOM_LEFT = {
        return  NSLocalizedString("Bottom Left",
                                  tableName: nil,
                                  bundle: TrackerThresholdUtilBundle.bundle(),
                                  value: "Bottom Left",
                                  comment: "Bottom Left")
    }()

    private static let BOTTOM_RIGHT = {
        return  NSLocalizedString("Bottom Right",
                                  tableName: nil,
                                  bundle: TrackerThresholdUtilBundle.bundle(),
                                  value: "Bottom Right",
                                  comment: "Bottom Right")
    }()

    private static let TOP_RIGHT = {
        return  NSLocalizedString("Top Right",
                                  tableName: nil,
                                  bundle: TrackerThresholdUtilBundle.bundle(),
                                  value: "Top Right",
                                  comment: "Top Right")
    }()

    private static let UP = {
        return  NSLocalizedString("Up",
                                  tableName: nil,
                                  bundle: TrackerThresholdUtilBundle.bundle(),
                                  value: "Up",
                                  comment: "Up")
    }()

    private static let DOWN = {
        return  NSLocalizedString("Down",
                                  tableName: nil,
                                  bundle: TrackerThresholdUtilBundle.bundle(),
                                  value: "Down",
                                  comment: "Down")
    }()

    private static let UNKNOWN = {
        return  NSLocalizedString("Unknown",
                                  tableName: nil,
                                  bundle: TrackerThresholdUtilBundle.bundle(),
                                  value: "Unknown",
                                  comment: "Unknown")
    }()

    public var description: String {
        switch self {
        case .topLeft:
            return SensorOrientation.TOP_LEFT
        case .bottomLeft:
            return SensorOrientation.BOTTOM_LEFT
        case .bottomRight:
            return SensorOrientation.BOTTOM_RIGHT
        case .topRight:
            return SensorOrientation.TOP_RIGHT
        case .up:
            return SensorOrientation.UP
        case .down:
            return SensorOrientation.DOWN
        case .unknown:
            return SensorOrientation.UNKNOWN            
        }
    }

}
