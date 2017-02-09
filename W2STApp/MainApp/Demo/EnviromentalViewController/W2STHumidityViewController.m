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
#import "W2STHumidityViewController.h"


#import <BlueSTSDK/BlueSTSDKFeatureField.h>
#import <BlueSTSDK/BlueSTSDKFeatureHumidity.h>

@interface W2STHumidityViewController () <BlueSTSDKFeatureDelegate>

@end

@implementation W2STHumidityViewController{
    NSArray *mHumidityFeature;
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    mHumidityFeature = [self.delegate extractFeaturesType: BlueSTSDKFeatureHumidity.class];
    if(mHumidityFeature.count != 0){
        for (BlueSTSDKFeature *f in mHumidityFeature){
            [f addFeatureDelegate:self];
            [self.delegate enableNotificationForFeature:f];
        }//for
        _humidityImage.image = [UIImage imageNamed:@"humidity"];
    }//if
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(mHumidityFeature.count != 0){
        for (BlueSTSDKFeature *f in mHumidityFeature){
            [f removeFeatureDelegate:self];
            [self.delegate disableNotificationForFeature:f];
        }//for
    }//if
}

#pragma mark - BlueSTSDKFeatureDelegate
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
    BlueSTSDKFeatureField *humDesc = feature.getFieldsDesc[0];

    NSMutableString *humidityLabel = [NSMutableString stringWithCapacity:32];
    for (NSUInteger i=0; i<mHumidityFeature.count ; i++){
        BlueSTSDKFeatureSample *s = [mHumidityFeature[i] lastSample];
        float humidity = [BlueSTSDKFeatureHumidity getHumidity:s];
        [humidityLabel appendFormat: @"%.2f %@\n", humidity, humDesc.unit];
    }//for
    
    //remove the last \n
    [humidityLabel deleteCharactersInRange:NSMakeRange(humidityLabel.length-1, 1)];

    //use the first feature for change the icon
    float humidity = [BlueSTSDKFeatureHumidity getHumidity:
                      [mHumidityFeature[0] lastSample]];
    
  //  NSLog(@"temp: %f -> %d image: %@",humidity,pressureId,imageName);
    dispatch_sync(dispatch_get_main_queue(),^{
        _humidityLabel.text=humidityLabel;
        _humidityImage.alpha=humidity/100;
    });
}


@end
