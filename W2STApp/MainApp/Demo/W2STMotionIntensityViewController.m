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

#import <BlueSTSDK/BlueSTSDKFeatureMotionIntensity.h>
#import <BlueSTSDK/BlueSTSDK_LocalizeUtil.h>

#import "W2STMotionIntensityViewController.h"

#define MOTION_INTENSITY_VALUE_FORMAT BLUESTSDK_LOCALIZE(@"The Motion intensity value is: %d",nil)
#define DEG_TO_RAG(x) ((x)*(M_PI/180.0f))

#define ANIMATION_DURATION_S (0.3f)

static float sNeedleOffset[] = {
        DEG_TO_RAG(-135),
        DEG_TO_RAG(-108),
        DEG_TO_RAG(-81),
        DEG_TO_RAG(-54),
        DEG_TO_RAG(-27),
        DEG_TO_RAG(  0),
        DEG_TO_RAG( 27),
        DEG_TO_RAG( 54),
        DEG_TO_RAG( 81),
        DEG_TO_RAG( 108),
        DEG_TO_RAG( 135),
};

@interface W2STMotionIntensityViewController ()<BlueSTSDKFeatureDelegate>

@property (weak, nonatomic) IBOutlet UILabel *mMotionIntensityValue;
@property (weak, nonatomic) IBOutlet UIImageView *mMotionIntensityNeedle;

@end



@implementation W2STMotionIntensityViewController{
    BlueSTSDKFeature *mFeature;
}

-(CAAnimation*) createRotateAnimationFrom:(CGFloat)from to:(CGFloat)to{
    
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    animation.additive=YES;
    
    [animation setValues:@[@(from),@(to)]];
    
    animation.duration = ANIMATION_DURATION_S;
    return animation;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //enable the notification
    mFeature =(BlueSTSDKFeatureMotionIntensity*)[self.node getFeatureOfType:BlueSTSDKFeatureMotionIntensity.class];
    if(mFeature!=nil){
        [mFeature addFeatureDelegate:self];
        [self.node enableNotification:mFeature];
    }//if
}//viewDidAppear

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //if we are ploting something stop it
    if(mFeature!=nil){
        [mFeature removeFeatureDelegate:self];
        [self.node disableNotification:mFeature];
        mFeature=nil;
    }//if
}


#pragma mark - BlueSTSDKFeatureDelegate
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
    int8_t status = [BlueSTSDKFeatureMotionIntensity getMotionIntensity:sample];
    if(status<0 || status>=(sizeof(sNeedleOffset)/sizeof(sNeedleOffset[0])))
        return;
    
    
    float rotationAngleRad = sNeedleOffset[status];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _mMotionIntensityValue.text = [NSString stringWithFormat:MOTION_INTENSITY_VALUE_FORMAT,status ];
        
        [UIView animateWithDuration:ANIMATION_DURATION_S animations:^{
            _mMotionIntensityNeedle.transform = CGAffineTransformMakeRotation(rotationAngleRad);
        }];
        
    });
    
}


@end
