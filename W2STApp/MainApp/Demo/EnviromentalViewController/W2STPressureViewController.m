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
    bool featureWasEnabled;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    featureWasEnabled = false;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(applicationDidEnterBackground:)
            name:UIApplicationDidEnterBackgroundNotification
            object:nil];
        
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(applicationDidBecomeActive:)
        name:UIApplicationDidBecomeActiveNotification
        object:nil];
    
    mPressureFeatures = [self.node getFeaturesOfType: BlueSTSDKFeaturePressure.class];
    if(mPressureFeatures.count != 0){
        for (BlueSTSDKFeature *f in mPressureFeatures){
            [f addFeatureDelegate:self];
            [self.node enableNotification:f];
        }
        if (@available(iOS 13.0, *)) {
            _pressureImage.image = [UIImage imageNamed: @"pressure" inBundle: [NSBundle bundleForClass:[W2STPressureViewController class]] withConfiguration: nil];
        } else {
            _pressureImage.image = [UIImage imageNamed:@"pressure"];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(mPressureFeatures.count != 0){
        for (BlueSTSDKFeature *f in mPressureFeatures){
            [f removeFeatureDelegate:self];
            [self.node disableNotification:f];
            [NSThread sleepForTimeInterval:0.1];
        }
    }
}


#pragma mark - BlueSTSDKFeatureDelegate
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
    
    BlueSTSDKFeatureField *pressDesc = feature.getFieldsDesc[0];
    
    NSMutableString *pressureLabel = [NSMutableString stringWithCapacity:32];
    for (NSUInteger i=0; i<mPressureFeatures.count ; i++){
        BlueSTSDKFeatureSample *s = [mPressureFeatures[i] lastSample];
        float pressure = [BlueSTSDKFeaturePressure getPressure:s];
        [pressureLabel appendFormat: @"%.2f %@\n", pressure, pressDesc.unit];
    }//for
    //remove the last \n
    [pressureLabel deleteCharactersInRange:NSMakeRange(pressureLabel.length-1, 1)];
    
    dispatch_sync(dispatch_get_main_queue(),^{
        self->_pressureLabel.text=pressureLabel;
    });
}

#pragma mark - Handling BLE Notification

/** Disabling Notification */
-(void)applicationDidEnterBackground:(NSNotification *)notification {
    if(mPressureFeatures.count != 0){
        for (BlueSTSDKFeature *f in mPressureFeatures){
            if([self.node isEnableNotification: f]){
                if(featureWasEnabled == false){
                    featureWasEnabled = true;
                }
                [f removeFeatureDelegate:self];
                [self.node disableNotification:f];
                [NSThread sleepForTimeInterval:0.1];
            }else {
                featureWasEnabled = false;
            }
        }
    }
}

/** Enabling Notification */
-(void)applicationDidBecomeActive:(NSNotification *)notification {
    if(mPressureFeatures.count != 0){
        if(featureWasEnabled) {
            featureWasEnabled = false;
            for (BlueSTSDKFeature *f in mPressureFeatures){
                [f addFeatureDelegate:self];
                [self.node enableNotification:f];
            }
        }
        if (@available(iOS 13.0, *)) {
            _pressureImage.image = [UIImage imageNamed: @"pressure" inBundle: [NSBundle bundleForClass:[W2STPressureViewController class]] withConfiguration: nil];
        } else {
            _pressureImage.image = [UIImage imageNamed:@"pressure"];
        }
    }
}

@end
