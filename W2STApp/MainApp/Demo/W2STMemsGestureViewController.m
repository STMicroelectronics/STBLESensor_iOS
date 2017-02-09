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

#import <BlueSTSDK/BlueSTSDKFeatureMemsGesture.h>

#import "W2STMemsGestureViewController.h"

#define DEFAULT_ALPHA 0.3f
#define SELECTED_ALPHA 1.0f
#define AUTOMATIC_DESELECT_TIMEOUT_SEC 3

@interface W2STMemsGestureViewController () <BlueSTSDKFeatureDelegate>
    @property (weak, nonatomic) UIImageView *currentActivityImage;
@end

@implementation W2STMemsGestureViewController{
    BlueSTSDKFeatureMemsGesture *mGestureFeature;
    uint64_t mLastValidTimestamp;
}

-(void)switchOffImage{
    //set the alpha for all the image -> disable it
    self.glanceIcon.alpha=DEFAULT_ALPHA;
    self.wakeUpIcon.alpha=DEFAULT_ALPHA;
    self.pickUpIcon.alpha=DEFAULT_ALPHA;
    _currentActivityImage=nil;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self switchOffImage];
    mLastValidTimestamp=-1;
    //enable the notification
    mGestureFeature = (BlueSTSDKFeatureMemsGesture*)
    [self.node getFeatureOfType:BlueSTSDKFeatureMemsGesture.class];
    if(mGestureFeature!=nil){
        [mGestureFeature addFeatureDelegate:self];
        [self.node enableNotification:mGestureFeature];
        [self.node readFeature:mGestureFeature];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //if we are ploting something stop it
    if(mGestureFeature!=nil){
        [mGestureFeature removeFeatureDelegate:self];
        [self.node disableNotification:mGestureFeature];
        mGestureFeature=nil;
    }//if
}

/**
 *  retrive the image link with the activity state
 *
 *  @param type activity that we are doing
 *
 *  @return image link with that activity or null if we don't have an image for that activity
 */
-(UIImageView*)getImageForType:(BlueSTSDKFeatureMemsGestureType)type{
    switch (type) {
        case BlueSTSDKFeatureMemsGestureGlance:
            return self.glanceIcon;
        case BlueSTSDKFeatureMemsGesturePickUp:
            return self.pickUpIcon;
        case BlueSTSDKFeatureMemsGestureWakeUp:
            return self.wakeUpIcon;
        default:
            return nil;
    }//switch
}//getImageForType

#pragma mark - BlueSTSDKFeatureDelegate
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
    BlueSTSDKFeatureMemsGestureType type = [BlueSTSDKFeatureMemsGesture getGestureType:sample];
    UIImageView *typeIcon =[self getImageForType:type];
    uint64_t timestamp =sample.timestamp;
    if(typeIcon==nil)
        return;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_currentActivityImage!=nil)
            _currentActivityImage.alpha=DEFAULT_ALPHA;
        _currentActivityImage = typeIcon;
        mLastValidTimestamp=timestamp;
        if(_currentActivityImage!=nil){
            _currentActivityImage.alpha=SELECTED_ALPHA;
            _currentActivityImage.transform=CGAffineTransformMakeScale(0.8, 0.8);
            [UIView animateWithDuration:1/3.0f
                             animations:^{
                                 _currentActivityImage.transform=CGAffineTransformMakeScale(1.0, 1.0);
                             }];
            //if already selected hide the
            dispatch_after(
                    dispatch_time(DISPATCH_TIME_NOW,
                      (int64_t)(AUTOMATIC_DESELECT_TIMEOUT_SEC * NSEC_PER_SEC)),
                    dispatch_get_main_queue(), ^{
                        if(timestamp==mLastValidTimestamp){
                            _currentActivityImage.alpha=DEFAULT_ALPHA;
                            _currentActivityImage=nil;
                        }
            });
        }
        
    });
    
}

@end
