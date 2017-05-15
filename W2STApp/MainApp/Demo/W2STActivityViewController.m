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

#import <BlueSTSDK/BlueSTSDKFeatureActivity.h>
#import <BlueSTSDK_Gui/MBProgressHUD.h>

#define START_MESSAGE @"Activity detection started"
#define START_MESSAGE_DISPLAY_TIME 1.0f

#define LICENSE_NOT_VALID_MSG @"Check the license"

#import "BlueMSDemosViewController.h"
#import "W2STActivityViewController.h"

#import "BlueMSDemoTabViewController+WesuLicenseCheck.h"

#define DEFAULT_ALPHA 0.3f
#define SELECTED_ALPHA 1.0f

@interface W2STActivityViewController ()<BlueSTSDKFeatureDelegate>
    /**
    *  last image that we change
    */
    @property (weak, nonatomic) UIImageView *currentActivityImage;
@end

@implementation W2STActivityViewController{
    /**
     *  featire that will send the data
     */
    BlueSTSDKFeatureActivity *mActivityFeature;
}

-(void)switchOffImage{
    //set the alpha for all the image -> disable it
    self.standingImage.alpha=DEFAULT_ALPHA;
    self.walkingImage.alpha=DEFAULT_ALPHA;
    self.fastWalkingImage.alpha=DEFAULT_ALPHA;
    self.joggingImage.alpha=DEFAULT_ALPHA;
    self.bikingImage.alpha=DEFAULT_ALPHA;
    self.drivingImage.alpha=DEFAULT_ALPHA;
    _currentActivityImage=nil;
}

-(void)displayStartMessage{
    MBProgressHUD *message = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    message.mode = MBProgressHUDModeText;
    message.removeFromSuperViewOnHide = YES;
    message.labelText = START_MESSAGE;
    [message hide:true afterDelay:START_MESSAGE_DISPLAY_TIME];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self switchOffImage];
    //enable the notification
    mActivityFeature = (BlueSTSDKFeatureActivity*)
        [self.node getFeatureOfType:BlueSTSDKFeatureActivity.class];
    if(mActivityFeature!=nil){
        [mActivityFeature addFeatureDelegate:self];
        [self.node enableNotification:mActivityFeature];
        [self.node readFeature:mActivityFeature];
        [self displayStartMessage];
        
        if(self.node.type==BlueSTSDKNodeTypeSTEVAL_WESU1)
            [self checkLicenseFromRegister:
                            BlueSTSDK_REGISTER_NAME_MOTION_AR_VALUE_LIC_STATUS
                           errorString:LICENSE_NOT_VALID_MSG];
        
    }else{
        //[self.view makeToast:@"Sensor Fusion NotFound"];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //if we are ploting something stop it
    if(mActivityFeature!=nil){
        [mActivityFeature removeFeatureDelegate:self];
        [self.node disableNotification:mActivityFeature];
        mActivityFeature=nil;
    }//if
}

/**
 *  retrive the image link with the activity state
 *
 *  @param type activity that we are doing
 *
 *  @return image link with that activity or null if we don't have an image for that activity
 */
-(UIImageView*)getImageForType:(BlueSTSDKFeatureActivityType)type{
    switch (type) {
        case BlueSTSDKFeatureActivityTypeStanding:
            return self.standingImage;
        case BlueSTSDKFeatureActivityTypeWalking:
            return self.walkingImage;
        case BlueSTSDKFeatureActivityTypeFastWalking:
            return self.fastWalkingImage;
        case BlueSTSDKFeatureActivityTypeJogging:
            return self.joggingImage;
        case BlueSTSDKFeatureActivityTypeBiking:
            return self.bikingImage;
        case BlueSTSDKFeatureActivityTypeDriving:
            return self.drivingImage;
        default:
            return nil;
    }//switch
}//getImageForType

#pragma mark - BlueSTSDKFeatureDelegate
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
    BlueSTSDKFeatureActivityType type = [BlueSTSDKFeatureActivity getActivityType:sample];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_currentActivityImage!=nil)
            _currentActivityImage.alpha=DEFAULT_ALPHA;
        _currentActivityImage = [self getImageForType:type];
        if(_currentActivityImage!=nil)
            _currentActivityImage.alpha=SELECTED_ALPHA;
        
    });
    
}

@end
