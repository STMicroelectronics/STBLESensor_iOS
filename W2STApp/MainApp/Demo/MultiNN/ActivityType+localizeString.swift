/*
 * Copyright (c) 2019  STMicroelectronics – All rights reserved
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

extension BlueSTSDKFeatureActivity.ActivityType : CustomStringConvertible{
    
    private static let ACTIVITY_UNKNOWN = {
        return  NSLocalizedString("Unknown",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSMultiNetworkViewController.self),
                                  value: "Unknown",
                                  comment: "Unknown")
    }();
    
    private static let ACTIVITY_STANDING = {
        return  NSLocalizedString("Standing",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSMultiNetworkViewController.self),
                                  value: "Standing",
                                  comment: "Standing")
    }();
    
    private static let ACTIVITY_WALKING = {
        return  NSLocalizedString("Walking",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSMultiNetworkViewController.self),
                                  value: "Walking",
                                  comment: "Walking")
    }();
    
    private static let ACTIVITY_FAST_WALKING = {
        return  NSLocalizedString("Fast walking",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSMultiNetworkViewController.self),
                                  value: "Fast walking",
                                  comment: "Fast walking")
    }();
    
    private static let ACTIVITY_RUNNING = {
        return  NSLocalizedString("Jogging",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSMultiNetworkViewController.self),
                                  value: "Jogging",
                                  comment: "Jogging")
    }();
    
    private static let ACTIVITY_BIKING = {
        return  NSLocalizedString("Biking",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSMultiNetworkViewController.self),
                                  value: "Biking",
                                  comment: "Biking")
    }();

    private static let ACTIVITY_DRIVING = {
        return  NSLocalizedString("Driving",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSMultiNetworkViewController.self),
                                  value: "Driving",
                                  comment: "Driving")
    }();
    
    private static let ACTIVITY_STAIRS = {
        return  NSLocalizedString("Stairs",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSMultiNetworkViewController.self),
                                  value: "Stairs",
                                  comment: "Stairs")
    }();
    
    private static let ACTIVITY_ADULT_IN_CAR = {
        return  NSLocalizedString("Adult in Car",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSMultiNetworkViewController.self),
                                  value: "Adult in Car",
                                  comment: "Adult in Car")
    }();
    
    public var description: String{
        switch self{
        case .noActivity:
            return BlueSTSDKFeatureActivity.ActivityType.ACTIVITY_UNKNOWN
        case .standing:
            return BlueSTSDKFeatureActivity.ActivityType.ACTIVITY_STANDING
        case .walking:
            return BlueSTSDKFeatureActivity.ActivityType.ACTIVITY_WALKING
        case .fastWalking:
            return BlueSTSDKFeatureActivity.ActivityType.ACTIVITY_FAST_WALKING
        case .jogging:
            return BlueSTSDKFeatureActivity.ActivityType.ACTIVITY_RUNNING
        case .biking:
            return BlueSTSDKFeatureActivity.ActivityType.ACTIVITY_BIKING
        case .driving:
            return BlueSTSDKFeatureActivity.ActivityType.ACTIVITY_DRIVING
        case .stairs:
            return BlueSTSDKFeatureActivity.ActivityType.ACTIVITY_STAIRS
        case .adultInCar:
            return BlueSTSDKFeatureActivity.ActivityType.ACTIVITY_ADULT_IN_CAR
        case .error:
            return BlueSTSDKFeatureActivity.ActivityType.ACTIVITY_UNKNOWN
//        @unknown default:
//            return BlueSTSDKFeatureActivity.ActivityType.ACTIVITY_UNKNOWN
        }
    }
}
