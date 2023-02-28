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

#import "W2STLuminosityViewController.h"

#import <BlueSTSDK/BlueSTSDKFeatureLuminosity.h>

@interface W2STLuminosityViewController () <BlueSTSDKFeatureDelegate>

@end

@implementation W2STLuminosityViewController{
    NSArray *mLuminosityFeatures;
    bool featureWasEnabled;
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    featureWasEnabled = false;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(applicationDidEnterBackground:)
            name:UIApplicationDidEnterBackgroundNotification
            object:nil];
        
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(applicationDidBecomeActive:)
        name:UIApplicationDidBecomeActiveNotification
        object:nil];
    
    mLuminosityFeatures = [self.node getFeaturesOfType:BlueSTSDKFeatureLuminosity.class];
    
    if(mLuminosityFeatures.count != 0){
        for (BlueSTSDKFeature *f in mLuminosityFeatures){
            [f addFeatureDelegate:self];
            [self.node enableNotification:f];
        }//for
        if (@available(iOS 13.0, *)) {
            _luminosityImage.image = [UIImage imageNamed: @"luminosity" inBundle: [NSBundle bundleForClass:[W2STLuminosityViewController class]] withConfiguration: nil];
        } else {
            _luminosityImage.image = [UIImage imageNamed:@"luminosity"];
        }
    }//if

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(mLuminosityFeatures.count != 0){
        for (BlueSTSDKFeature *f in mLuminosityFeatures){
            [f removeFeatureDelegate:self];
            [self.node disableNotification:f];
            [NSThread sleepForTimeInterval:0.1];
        }//for
    }//if
}

#pragma mark - BlueSTSDKFeatureDelegate
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
    BlueSTSDKFeatureField *lumDesc = feature.getFieldsDesc[0];

    
    NSMutableString *luminosityLabel = [NSMutableString stringWithCapacity:32];
    for (NSUInteger i=0; i<mLuminosityFeatures.count ; i++){
        BlueSTSDKFeatureSample *s = [mLuminosityFeatures[i] lastSample];
        float luminosity = [BlueSTSDKFeatureLuminosity getLuminosity:s];
        [luminosityLabel appendFormat: @"%.2f %@\n", luminosity, lumDesc.unit];
    }//for
    
    //remove the last \n
    [luminosityLabel deleteCharactersInRange:NSMakeRange(luminosityLabel.length-1, 1)];
    
    dispatch_sync(dispatch_get_main_queue(),^{
        self->_luminosityLabel.text=luminosityLabel;
    });
}

#pragma mark - Handling BLE Notification

/** Disabling Notification */
-(void)applicationDidEnterBackground:(NSNotification *)notification {
    if(mLuminosityFeatures.count != 0){
        for (BlueSTSDKFeature *f in mLuminosityFeatures){
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
    if(mLuminosityFeatures.count != 0){
        if(featureWasEnabled) {
            featureWasEnabled = false;
            for (BlueSTSDKFeature *f in mLuminosityFeatures){
                [f addFeatureDelegate:self];
                [self.node enableNotification:f];
            }//for
            if (@available(iOS 13.0, *)) {
                _luminosityImage.image = [UIImage imageNamed: @"luminosity" inBundle: [NSBundle bundleForClass:[W2STLuminosityViewController class]] withConfiguration: nil];
            } else {
                _luminosityImage.image = [UIImage imageNamed:@"luminosity"];
            }
        }
    }//if
}

@end
