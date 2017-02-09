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


#import <BlueSTSDK/BlueSTSDKFeaturePedometer.h>

#import "BlueMSDemosViewController.h"
#import "W2STPedometerViewController.h"

#define NSTEPS_STRING @"Steps: %lu"
#define FREQ_STRING @"Frequency: %u %@"

@interface W2STPedometerViewController ()<BlueSTSDKFeatureDelegate>
/**
 *  last image that we change
 */
@property (weak, nonatomic) UIImageView *currentActivityImage;
@end

@implementation W2STPedometerViewController{
    /**
     *  feature that will send the data
     */
    BlueSTSDKFeature *mPedometerFeature;
    
    NSString *mFrequencyUnit;
    
    BOOL mFlipImage;
    CGAffineTransform mFlipX;
    CGAffineTransform mUnFlipX;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    mFlipImage=true;
    mFlipX =CGAffineTransformMake( -1, 0, 0, 1,0,0 );
    mUnFlipX =CGAffineTransformIdentity;
    
}

-(void) extractFrequencyUnit{
    NSArray *dataDesc = [mPedometerFeature getFieldsDesc];
    BlueSTSDKFeatureField *freqField = dataDesc[1];
    mFrequencyUnit  = freqField.unit;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //enable the notification
    mPedometerFeature = [self.node getFeatureOfType:BlueSTSDKFeaturePedometer.class];
    if(mPedometerFeature!=nil){
        [self extractFrequencyUnit];
        [mPedometerFeature addFeatureDelegate:self];
        [self.node enableNotification:mPedometerFeature];
        [self.node readFeature:mPedometerFeature];
    }else{
        //[self.view makeToast:@"Sensor Fusion NotFound"];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(mPedometerFeature!=nil){
        [mPedometerFeature removeFeatureDelegate:self];
        [self.node disableNotification:mPedometerFeature];
        mPedometerFeature=nil;
    }//if
}


#pragma mark - BlueSTSDKFeatureDelegate
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
    NSUInteger nStep = [BlueSTSDKFeaturePedometer getSteps:sample];
    UInt16 freq = [BlueSTSDKFeaturePedometer getFrequency:sample];
    NSString *nStepString = [NSString stringWithFormat:NSTEPS_STRING,(unsigned long)nStep];
    NSString *freqString = [NSString stringWithFormat:FREQ_STRING,freq,mFrequencyUnit];
    dispatch_async(dispatch_get_main_queue(), ^{
        _nStepsLabel.text = nStepString;
        _frequencyLabel.text = freqString;
        if([_pedometerIcon.layer animationKeys].count==0){
            if(mFlipImage)
                _pedometerIcon.layer.affineTransform =mFlipX;
            else
                _pedometerIcon.layer.affineTransform = mUnFlipX;
            
            mFlipImage=!mFlipImage;
        }
    });
    
}

@end
