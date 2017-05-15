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

#import "W2STAccEventMultipleEventDisplayViewController.h"
#import "W2STAccEventIconUtil.h"

@interface W2STAccEventMultipleEventDisplayViewController ()

@end

@implementation W2STAccEventMultipleEventDisplayViewController{
    
    __weak IBOutlet UIImageView *mOrientationIcon;
    __weak IBOutlet UIImageView *mSingleTapIcon;
    __weak IBOutlet UIImageView *mFreeFallIcon;
    __weak IBOutlet UIImageView *mTiltIcon;
    __weak IBOutlet UIImageView *mWakeUpIcon;
    
    __weak IBOutlet UIImageView *mPedomiterIcon;
    __weak IBOutlet UILabel *mPedomiterLabel;
    
    int32_t mNSteps;
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    mNSteps=-1;
}

static BOOL hasEvent(BlueSTSDKFeatureAccelerometerEventType eventSet,
                     BlueSTSDKFeatureAccelerometerEventType eventTest){
    return (eventSet & eventTest)!=0;
}

-(void)displayEventType:(BlueSTSDKFeatureAccelerometerEventType) event data:(int32_t)eventData{
    BlueSTSDKFeatureAccelerometerEventType orientationEvent =
        [BlueSTSDKFeatureAccelerometerEvent extractOrientationEvent:event];
    if(orientationEvent!=BlueSTSDKFeatureAccelerometerNoEvent){
        mOrientationIcon.image = getEventImage(orientationEvent);
    }
    if(hasEvent(event, BlueSTSDKFeatureAccelerometerPedometer) && eventData!=mNSteps){
        shakeImage(mPedomiterIcon);
        mPedomiterLabel.text = [NSString stringWithFormat:@"Number Steps: %d",eventData];
        mNSteps=eventData;
    }
    if(hasEvent(event, BlueSTSDKFeatureAccelerometerSingleTap) ||
       hasEvent(event, BlueSTSDKFeatureAccelerometerDoubleTap)){
        shakeImage(mSingleTapIcon);
    }
    if(hasEvent(event, BlueSTSDKFeatureAccelerometerFreeFall)){
        shakeImage(mFreeFallIcon);
    }
    if(hasEvent(event, BlueSTSDKFeatureAccelerometerWakeUp)){
        shakeImage(mWakeUpIcon);
    }
    if(hasEvent(event, BlueSTSDKFeatureAccelerometerTilt)){
        shakeImage(mTiltIcon);
    }
    
}

-(void)enableEventType:(BlueSTSDKFeatureAccelerationDetectableEventType) event{
    
}

@end
