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


#import <BlueSTSDK/BlueSTSDKFeatureCarryPosition.h>

#import <BlueSTSDK_Gui/MBProgressHUD.h>

#define START_MESSAGE @"Carry detection started"
#define START_MESSAGE_DISPLAY_TIME 1.0f
#define LICENSE_NOT_VALID_MSG @"Check the license"

#import "BlueMSDemosViewController.h"
#import "W2STCarryPositionViewController.h"
#import "BlueMSDemoTabViewController+WesuLicenseCheck.h"


#define DEFAULT_ALPHA 0.3f
#define SELECTED_ALPHA 1.0f

@interface W2STCarryPositionViewController ()<BlueSTSDKFeatureDelegate>
    /**
    *  last image that we change
    */
    @property (weak, nonatomic) UIImageView *currentActivityImage;
@end

@implementation W2STCarryPositionViewController{
    /**
     *  featire that will send the data
     */
    BlueSTSDKFeatureCarryPosition *mPositionFeature;
}

-(void) switchOffImages{
    //set the alpha for all the image -> disable it
    self.handImage.alpha=DEFAULT_ALPHA;
    self.headImage.alpha=DEFAULT_ALPHA;
    self.shirtImage.alpha=DEFAULT_ALPHA;
    self.trouserImage.alpha=DEFAULT_ALPHA;
    self.deskImage.alpha=DEFAULT_ALPHA;
    self.armImage.alpha=DEFAULT_ALPHA;
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
    [self switchOffImages];
    //enable the notification
    mPositionFeature = (BlueSTSDKFeatureCarryPosition*)
        [self.node getFeatureOfType:BlueSTSDKFeatureCarryPosition.class];
    if(mPositionFeature!=nil){
        [mPositionFeature addFeatureDelegate:self];
        [self.node enableNotification:mPositionFeature];
        [self.node readFeature:mPositionFeature];
        [self displayStartMessage];
        if(self.node.type==BlueSTSDKNodeTypeSTEVAL_WESU1)
            [self checkLicenseFromRegister:
             BlueSTSDK_REGISTER_NAME_MOTION_CP_VALUE_LIC_STATUS
                               errorString:LICENSE_NOT_VALID_MSG];

    }else{
        //[self.view makeToast:@"Sensor Fusion NotFound"];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //if we are ploting something stop it
    if(mPositionFeature!=nil){
        [mPositionFeature removeFeatureDelegate:self];
        [self.node disableNotification:mPositionFeature];
        mPositionFeature=nil;
    }//if
}

/**
 *  retrive the image link with the postion
 *
 *  @param type device position detected
 *
 *  @return image link with that position or null if we don't have an image for that position
 */
-(UIImageView*)getImageForType:(BlueSTSDKFeatureCarryPositionType)type{
    switch (type) {
        case BlueSTSDKFeatureCarryPositionInHand:
            return self.handImage;
        case BlueSTSDKFeatureCarryPositionOnDesk:
            return self.deskImage;
        case BlueSTSDKFeatureCarryPositionArmSwing:
            return self.armImage;
        case BlueSTSDKFeatureCarryPositionNearHead:
            return self.headImage;
        case BlueSTSDKFeatureCarryPositionShirtPocket:
            return self.shirtImage;
        case BlueSTSDKFeatureCarryPositionTrousersPocket:
            return self.trouserImage;
        default:
            return nil;
    }//switch
}//getImageForType

#pragma mark - BlueSTSDKFeatureDelegate
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
    BlueSTSDKFeatureCarryPositionType type = [BlueSTSDKFeatureCarryPosition getPositionType:sample];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_currentActivityImage!=nil)
            _currentActivityImage.alpha=DEFAULT_ALPHA;
        _currentActivityImage = [self getImageForType:type];
        if(_currentActivityImage!=nil)
            _currentActivityImage.alpha=SELECTED_ALPHA;
        
    });
    
}

@end
