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

#import "W2STPressureViewController.h"

#import <BlueSTSDK/BlueSTSDKFeatureField.h>
#import <BlueSTSDK/BlueSTSDKFeaturePressure.h>

@interface W2STPressureViewController () <BlueSTSDKFeatureDelegate>

@end

@implementation W2STPressureViewController{
    NSArray *mPressureFeatures;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    mPressureFeatures = [self.delegate extractFeaturesType: BlueSTSDKFeaturePressure.class];
    if(mPressureFeatures.count != 0){
        for (BlueSTSDKFeature *f in mPressureFeatures){
            [f addFeatureDelegate:self];
            [self.delegate enableNotificationForFeature:f];
        }
        _pressureImage.image=[UIImage imageNamed:@"pressure"];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(mPressureFeatures.count != 0){
        for (BlueSTSDKFeature *f in mPressureFeatures){
            [f removeFeatureDelegate:self];
            [self.delegate disableNotificationForFeature:f];
        }
    }
}


#pragma mark - BlueSTSDKFeatureDelegate
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
    
    BlueSTSDKFeatureField *pressDesc = [feature.getFieldsDesc objectAtIndex:0];
    
    NSMutableString *pressureLabel = [NSMutableString stringWithCapacity:32];
    for (int i=0; i<mPressureFeatures.count ; i++){
        BlueSTSDKFeatureSample *s = [[mPressureFeatures objectAtIndex:i] lastSample];
        float pressure = [BlueSTSDKFeaturePressure getPressure:s];
        [pressureLabel appendFormat: @"%.2f %@\n", pressure, pressDesc.unit];
    }//for
    //remove the last \n
    [pressureLabel deleteCharactersInRange:NSMakeRange(pressureLabel.length-1, 1)];
    
    dispatch_sync(dispatch_get_main_queue(),^{
        _pressureLabel.text=pressureLabel;
    });
}


@end
