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

#import <BlueSTSDK/BlueSTSDKFeatureProximityGesture.h>

#import "BlueMSDemosViewController.h"
#import "W2STProximityGestureViewController.h"

#define DEFAULT_ALPHA 0.3f
#define SELECTED_ALPHA 1.0f

@interface W2STProximityGestureViewController ()<BlueSTSDKFeatureDelegate>
/**
 *  last image that we change
 */
@property (weak, nonatomic) UIImageView *currentActivityImage;
@end

@implementation W2STProximityGestureViewController{
    /**
     *  featire that will send the data
     */
    BlueSTSDKFeature *mGestureFeature;
    bool featureWasEnabled;
}

-(void)switchOffImage{
    //set the alpha for all the image -> disable it
    self.gestureLeftIcon.alpha=DEFAULT_ALPHA;
    self.gestureTagIcon.alpha=DEFAULT_ALPHA;
    self.gestureRightIcon.alpha=DEFAULT_ALPHA;
    _currentActivityImage=nil;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self switchOffImage];
    
    featureWasEnabled = false;

    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(applicationDidEnterBackground:)
        name:UIApplicationDidEnterBackgroundNotification
        object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(applicationDidBecomeActive:)
        name:UIApplicationDidBecomeActiveNotification
        object:nil];
    
    //enable the notification
    mGestureFeature = [self.node getFeatureOfType:BlueSTSDKFeatureProximityGesture.class];
    if(mGestureFeature!=nil){
        [mGestureFeature addFeatureDelegate:self];
        [self.node enableNotification:mGestureFeature];
        [self.node readFeature:mGestureFeature];
    }else{
        //[self.view makeToast:@"Sensor Fusion NotFound"];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //if we are ploting something stop it
    if(mGestureFeature!=nil){
        [mGestureFeature removeFeatureDelegate:self];
        [self.node disableNotification:mGestureFeature];
        [NSThread sleepForTimeInterval:0.1];
        mGestureFeature=nil;
    }//if
}

#pragma mark - Handling BLE Notification

/** Disabling Notification */
-(void)applicationDidEnterBackground:(NSNotification *)notification {
    mGestureFeature = [self.node getFeatureOfType:BlueSTSDKFeatureProximityGesture.class];
    if(mGestureFeature != nil){
        if([self.node isEnableNotification: mGestureFeature]){
            if(featureWasEnabled == false){
                featureWasEnabled = true;
            }
            [mGestureFeature removeFeatureDelegate:self];
            [self.node disableNotification:mGestureFeature];
            [NSThread sleepForTimeInterval:0.1];
            mGestureFeature=nil;
        }
    }
}

/** Enabling Notification */
-(void)applicationDidBecomeActive:(NSNotification *)notification {
    mGestureFeature = [self.node getFeatureOfType:BlueSTSDKFeatureProximityGesture.class];
        if(featureWasEnabled) {
            featureWasEnabled = false;
            [mGestureFeature addFeatureDelegate:self];
            [self.node enableNotification:mGestureFeature];
            [self.node readFeature:mGestureFeature];
        }
}

/**
 *  retrive the image link with the activity state
 *
 *  @param type activity that we are doing
 *
 *  @return image link with that activity or null if we don't have an image for that activity
 */
-(UIImageView*)getImageForType:(BlueSTSDKFeatureProximityGestureType)type{
    switch (type) {
        case BlueSTSDKFeatureProximityGestureLeft:
            return self.gestureLeftIcon;
        case BlueSTSDKFeatureProximityGestureRight:
            return self.gestureRightIcon;
        case BlueSTSDKFeatureProximityGestureTap:
            return self.gestureTagIcon;
        default:
            return nil;
    }//switch
}//getImageForType

#pragma mark - BlueSTSDKFeatureDelegate
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
    BlueSTSDKFeatureProximityGestureType type = [BlueSTSDKFeatureProximityGesture getGestureType:sample];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self->_currentActivityImage!=nil)
            self->_currentActivityImage.alpha=DEFAULT_ALPHA;
        self->_currentActivityImage = [self getImageForType:type];
        if(self->_currentActivityImage!=nil){
            self->_currentActivityImage.alpha=SELECTED_ALPHA;
            self->_currentActivityImage.transform=CGAffineTransformMakeScale(0.8, 0.8);
            [UIView animateWithDuration:1/3.0f
                             animations:^{
                                 self->_currentActivityImage.transform=CGAffineTransformMakeScale(1.0, 1.0);
                             }];
         }
        
    });
    
}

@end
