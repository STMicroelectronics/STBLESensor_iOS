/*
 * Copyright (c) 2017  STMicroelectronics – All rights reserved
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

#import <Foundation/Foundation.h>

#import "W2STAccEventIconUtil.h"

UIImage* getEventImage(BlueSTSDKFeatureAccelerometerEventType event){
    switch (event) {
        case BlueSTSDKFeatureAccelerometerDoubleTap:
            return [UIImage imageNamed:@"acc_event_double_tap"];
        case BlueSTSDKFeatureAccelerometerFreeFall:
            return [UIImage imageNamed:@"acc_event_free_fall"];
        case BlueSTSDKFeatureAccelerometerSingleTap:
            return [UIImage imageNamed:@"acc_event_single_tap"];
        case BlueSTSDKFeatureAccelerometerTilt:
            return [UIImage imageNamed:@"acc_event_tilt"];
        case BlueSTSDKFeatureAccelerometerWakeUp:
            return [UIImage imageNamed:@"acc_event_wake_up"];
        case BlueSTSDKFeatureAccelerometerPedometer:
            return [UIImage imageNamed:@"acc_event_pedomiter"];
        case BlueSTSDKFeatureAccelerometerOrientationDown:
            return [UIImage imageNamed:@"acc_event_orientation_down"];
        case BlueSTSDKFeatureAccelerometerOrientationUp:
            return [UIImage imageNamed:@"acc_event_orientation_up"];
        case BlueSTSDKFeatureAccelerometerOrientationTopLeft:
            return [UIImage imageNamed:@"acc_event_orientation_top_left"];
        case BlueSTSDKFeatureAccelerometerOrientationTopRight:
            return [UIImage imageNamed:@"acc_event_orientation_top_right"];
        case BlueSTSDKFeatureAccelerometerOrientationBottomLeft:
            return [UIImage imageNamed:@"acc_event_orientation_bottom_left"];
        case BlueSTSDKFeatureAccelerometerOrientationBottomRight:
            return [UIImage imageNamed:@"acc_event_orientation_bottom_right"];
        case BlueSTSDKFeatureAccelerometerNoEvent:
            return [UIImage imageNamed:@"acc_event_none"];
        case BlueSTSDKFeatureAccelerometerError:
        default:
            return nil;
    }//switch
}

UIImage* getDefaultIconForEvent(BlueSTSDKFeatureAccelerationDetectableEventType event){
    switch (event) {
            return nil;
        case BlueSTSDKFeatureEventTypeOrientation:
            return getEventImage(BlueSTSDKFeatureAccelerometerOrientationTopLeft);
        case BlueSTSDKFeatureEventTypeFreeFall:
            return getEventImage(BlueSTSDKFeatureAccelerometerFreeFall);
        case BlueSTSDKFeatureEventTypeSingleTap:
            return getEventImage(BlueSTSDKFeatureAccelerometerSingleTap);
        case BlueSTSDKFeatureEventTypeDoubleTap:
            return getEventImage(BlueSTSDKFeatureAccelerometerDoubleTap);
        case BlueSTSDKFeatureEventTypeWakeUp:
            return getEventImage(BlueSTSDKFeatureAccelerometerWakeUp);
        case BlueSTSDKFeatureEventTypeTilt:
            return getEventImage(BlueSTSDKFeatureAccelerometerTilt);
        case BlueSTSDKFeatureEventTypePedometer:
            return getEventImage(BlueSTSDKFeatureAccelerometerPedometer);
        case BlueSTSDKFeatureEventTypeNone:
            return getEventImage(BlueSTSDKFeatureAccelerometerNoEvent);
        default:
            return getEventImage(BlueSTSDKFeatureAccelerometerNoEvent);
    }
}

BOOL hasOrientationEvent(BlueSTSDKFeatureAccelerationDetectableEventType event){
    
    return ((event & BlueSTSDKFeatureAccelerometerOrientationDown)!=0 ||
            (event & BlueSTSDKFeatureAccelerometerOrientationUp)!=0 ||
            (event & BlueSTSDKFeatureAccelerometerOrientationTopLeft)!=0 ||
            (event & BlueSTSDKFeatureAccelerometerOrientationTopRight)!=0 ||
            (event & BlueSTSDKFeatureAccelerometerOrientationBottomLeft)!=0 ||
            (event & BlueSTSDKFeatureAccelerometerOrientationBottomRight)!=0 ||
            (event & BlueSTSDKFeatureAccelerometerOrientationDown)!=0);
    
}


void shakeImage(UIImageView *image) {
    static NSString *animationKey = @"Shake";
    {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.duration = 0.3;
        animation.values = @[ @(-20), @(20), @(-20), @(20), @(-10), @(10), @(-5), @(5), @(0) ];
        [image.layer addAnimation:animation forKey:animationKey];
    }
}
