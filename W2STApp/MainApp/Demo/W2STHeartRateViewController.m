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


#import <BlueSTSDK/BlueSTSDKFeatureHeartRate.h>

#import "W2STHeartRateViewController.h"

@interface W2STHeartRateViewController() <BlueSTSDKFeatureDelegate>

@end

@implementation W2STHeartRateViewController{
    
    __weak IBOutlet UIImageView *mHeartImage;
    __weak IBOutlet UILabel *mHeartRateLabel;
    __weak IBOutlet UILabel *mEnergyLabel;
    __weak IBOutlet UILabel *mRRIntervalLabel;

    BlueSTSDKFeature *mHearRate;

    CAAnimation *mPulseAnimation;
    
    NSString *mHeartRateUnit;
    NSString *mEnergyUnit;
    NSString *mRRIntervalUnit;

}

-(CAAnimation*) createPulseAnimation{
    
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.xy"];
    

    [animation setValues:@[@1.0,@0.8,@1.2,@1.0]];
    [animation setKeyTimes:@[@0.0,@0.25,@0.75,@1.0]];
    
    animation.duration = 0.3;
    return animation;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    mPulseAnimation = [self createPulseAnimation];

}

-(void) extractUnit{
    NSArray<BlueSTSDKFeatureField*> *dataDesc = [mHearRate getFieldsDesc];
    mHeartRateUnit = [dataDesc[0] unit];
    mEnergyUnit = [dataDesc[1] unit];
    mRRIntervalUnit = [dataDesc[2] unit];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //enable the notification
    mHearRate = [self.node getFeatureOfType:BlueSTSDKFeatureHeartRate.class];
    if(mHearRate!=nil){
        [self extractUnit];
        [mHearRate addFeatureDelegate:self];
        [self.node enableNotification:mHearRate];
    }else{
        //
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(mHearRate!=nil){
        [mHearRate removeFeatureDelegate:self];
        [self.node disableNotification:mHearRate];
        mHearRate=nil;
    }//if
}

#define RATE_STRING @"%d %@"
#define ENERGY_STRING @"Energy: %d %@"
#define RRINTERVAL_STRING @"RR Interval: %.2f %@"
#define PULSE_ANIMATION_KEY @"Pulse"
#define HEART_IMAGE @"heart"
#define HEART_GRAY_IMAGE @"heart_gray"

#pragma mark - BlueSTSDKFeatureDelegate
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
    int32_t rate = [BlueSTSDKFeatureHeartRate getHeartRate:sample];
    int32_t energy = [BlueSTSDKFeatureHeartRate getEnergyExtended:sample];
    float rrInterval = [BlueSTSDKFeatureHeartRate getRRInterval:sample];

    NSString *rateString = rate>0 ? [NSString stringWithFormat:RATE_STRING,rate,mHeartRateUnit] : nil;
    NSString *energyString = energy>0 ? [NSString stringWithFormat:ENERGY_STRING,energy,mEnergyUnit]:nil ;
    NSString *rrIntervalString = !isnan(rrInterval) ? [NSString stringWithFormat:RRINTERVAL_STRING,rrInterval,mRRIntervalUnit] : nil;
    UIImage *heartImage = rateString !=nil ?
        [UIImage imageNamed:HEART_IMAGE] :
        [UIImage imageNamed:HEART_GRAY_IMAGE];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        mHeartRateLabel.text = rateString;
        mEnergyLabel.text = energyString;
        mRRIntervalLabel.text = rrIntervalString;
        mHeartImage.image = heartImage;
        if(rateString!=nil)
            [mHeartImage.layer addAnimation:mPulseAnimation forKey:PULSE_ANIMATION_KEY];
        
    });
    
}




@end
