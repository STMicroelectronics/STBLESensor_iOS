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

extension SensorOrientation {
    
    var toImage: UIImage {
        let bundle = TrackerThresholdUtilBundle.bundle()
        switch self {
        case .topLeft:
            return UIImage(named: "orientation_top_left", in: bundle, compatibleWith: nil)!
        case .bottomLeft:
            return UIImage(named: "orientation_bottom_left", in: bundle, compatibleWith: nil)!
        case .bottomRight:
            return UIImage(named: "orientation_bottom_right", in: bundle, compatibleWith: nil)!
        case .topRight:
            return UIImage(named: "orientation_top_right", in: bundle, compatibleWith: nil)!
        case .up:
            return UIImage(named: "orientation_up", in: bundle, compatibleWith: nil)!
        case .down:
            return UIImage(named: "orientation_down", in: bundle, compatibleWith: nil)!
        case .unknown:
            return UIImage(named: "event_orientation", in: bundle, compatibleWith: nil)!
        }
    }
}
