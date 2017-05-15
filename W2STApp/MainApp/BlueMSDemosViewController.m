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


#import <MessageUI/MessageUI.h>
#import <BlueSTSDK/BlueSTSDKFeatureTemperature.h>
#import <BlueSTSDK/BlueSTSDKFeaturePressure.h>
#import <BlueSTSDK/BlueSTSDKFeatureLuminosity.h>
#import <BlueSTSDK/BlueSTSDKFeatureHumidity.h>
#import <BlueSTSDK/BlueSTSDKFeatureMemsSensorFusion.h>
#import <BlueSTSDK/BlueSTSDKFeatureMemsSensorFusionCompact.h>
#import <BlueSTSDK/BlueSTSDKFeatureActivity.h>
#import <BlueSTSDK/BlueSTSDKFeatureCarryPosition.h>
#import <BlueSTSDK/BlueSTSDKFeatureProximityGesture.h>
#import <BlueSTSDK/BlueSTSDKFeatureMemsGesture.h>
#import <BlueSTSDK/BlueSTSDKFeaturePedometer.h>
#import <BlueSTSDK/BlueSTSDKFeatureAccelerometerEvent.h>
#import <BlueSTSDK/BlueSTSDKFeatureSwitch.h>
#import <BlueSTSDK/BlueSTSDKFeatureAudioADPCM.h>
#import <BlueSTSDK/BlueSTSDKFeatureAudioADPCMSync.h>
#import <BlueSTSDK/BlueSTSDKFeatureHeartRate.h>
#import <BlueSTSDK/BlueSTSDKFeatureCompass.h>
#import <BlueSTSDK/BlueSTSDKFeatureMotionIntensity.h>


#import "BlueMSDemosViewController.h"
#import "BlueMSDemosViewController+WesuFwVersion.h"

#import "BlueMSDemoTabViewController.h"

#import "W2STFeatureSensorFusionDemoViewController.h"

#define ENVIROMENTAL_DEMO_POSITION 0
#define SENSOR_FUSION_DEMO_POSITION 1
#define PLOT_DEMO_POSITION 2
#define ACTIVITY_RECOGNITION_DEMO_POSITION 3
#define CARRY_POSITION_RECOGNITION_DEMO_POSITION 4
#define PROXIMITY_GESTURE_RECOGNITION_DEMO_POSITION 5
#define MEMS_GESTURE_RECOGNITION_DEMO_POSITION 6
#define PEDOMEMETER_DEMO_POSITION 7
#define ACC_EVENT_DEMO_POSITION 8
#define SWITCH_DEMO_POSITION 9
#define BLUEVOICE_DEMO_POSITION 10
#define HEART_RATE_DEMO_POSITION 11
#define CLOUD_DEMO_POSITION 12
#define MOTIONID_DEMO_POSITION 13
#define COMPASS_DEMO_POSITION 14
#define RSSI_DEMO_POSITION 15
#define NUMBER_OF_DEMOS 16

@interface BlueMSDemosViewController () <UITabBarControllerDelegate>

@end

@implementation BlueMSDemosViewController{
    UISwipeGestureRecognizer *leftGesture;
    UISwipeGestureRecognizer *rightGesture;
    UIAlertAction *registerSettings;
    bool mFwVarningDisplayed;
}


-(void)viewDidLoad{
    [super viewDidLoad];

    //create the gesture recognizer
    leftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeGesture:)];
    leftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeGesture:)];
    rightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    //add it to the view
    [self.view addGestureRecognizer:leftGesture];
    [self.view addGestureRecognizer:rightGesture];
    
    registerSettings = [self createRegisterSettings];
    [self.menuDelegate addMenuAction:registerSettings];

    
    mFwVarningDisplayed=false;
    
    //add a button in the navbar
    /*
    if (self.node != nil && self.node.configControl != nil)
    {
        UIBarButtonItem *extraButton = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(extraButtonAction:)];
        self.navigationItem.rightBarButtonItems = @[self.actionButton, extraButton];
    }
     */
}

/**
 *  check the presence of the feature needed for run the demos, if they aren't present
 * remove the demo button
 */
-(void)removeOptionalDemo{
    
    NSMutableArray *availableDemos = [NSMutableArray arrayWithArray:self.viewControllers];
    if(availableDemos.count!=NUMBER_OF_DEMOS)
        return;
    NSMutableIndexSet *removeItem = [NSMutableIndexSet indexSet];
    BlueSTSDKNode *node = self.node;
    //check to have almost one feature needed for run the demo, if not remove it
    if( [node getFeatureOfType:BlueSTSDKFeatureMemsSensorFusion.class]==nil &&
       [node getFeatureOfType:BlueSTSDKFeatureMemsSensorFusionCompact.class]==nil)
        [removeItem addIndex:SENSOR_FUSION_DEMO_POSITION];
    if( [node getFeatureOfType:BlueSTSDKFeatureTemperature.class] == nil &&
        [node getFeatureOfType:BlueSTSDKFeaturePressure.class] == nil &&
        [node getFeatureOfType:BlueSTSDKFeatureHumidity.class] == nil &&
        [node getFeatureOfType:BlueSTSDKFeatureLuminosity.class] == nil)
        [removeItem addIndex:ENVIROMENTAL_DEMO_POSITION];
    if([self.node getFeatureOfType:BlueSTSDKFeatureActivity.class] == nil)
        [removeItem addIndex:ACTIVITY_RECOGNITION_DEMO_POSITION];
    if([self.node getFeatureOfType:BlueSTSDKFeatureCarryPosition.class] == nil)
        [removeItem addIndex:CARRY_POSITION_RECOGNITION_DEMO_POSITION];
    if([self.node getFeatureOfType:BlueSTSDKFeatureProximityGesture.class] == nil)
        [removeItem addIndex:PROXIMITY_GESTURE_RECOGNITION_DEMO_POSITION];
    if([self.node getFeatureOfType:BlueSTSDKFeatureMemsGesture.class] == nil)
        [removeItem addIndex:MEMS_GESTURE_RECOGNITION_DEMO_POSITION];
    if([self.node getFeatureOfType:BlueSTSDKFeaturePedometer.class] == nil)
        [removeItem addIndex:PEDOMEMETER_DEMO_POSITION];
    if([self.node getFeatureOfType:BlueSTSDKFeatureAccelerometerEvent.class] == nil)
        [removeItem addIndex:ACC_EVENT_DEMO_POSITION];
    if([self.node getFeatureOfType:BlueSTSDKFeatureSwitch.class] == nil)
        [removeItem addIndex:SWITCH_DEMO_POSITION];
    if( [node getFeatureOfType:BlueSTSDKFeatureAudioADPCM.class]==nil ||
        [node getFeatureOfType:BlueSTSDKFeatureAudioADPCMSync.class]==nil){
        [removeItem addIndex:BLUEVOICE_DEMO_POSITION];
    }
    if( [node getFeatureOfType:BlueSTSDKFeatureHeartRate.class]==nil){
        [removeItem addIndex:HEART_RATE_DEMO_POSITION];
    }
    if( [node getFeatureOfType:BlueSTSDKFeatureMotionIntensity.class]==nil){
        [removeItem addIndex:MOTIONID_DEMO_POSITION];
    }
    if( [node getFeatureOfType:BlueSTSDKFeatureCompass.class]==nil){
        [removeItem addIndex:COMPASS_DEMO_POSITION];
    }

    [availableDemos removeObjectsAtIndexes:removeItem];
    self.viewControllers = availableDemos;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.delegate=self;
    
    //hide the navigation bar in case of more than 5 demos,
    // in this way the user can't edit the item in the tabbar and we have more
    // space for the demo
    self.moreNavigationController.navigationBarHidden=true;
    
    [self removeOptionalDemo];

    for (UIViewController *c in self.viewControllers){
        if( [c isKindOfClass:[BlueMSDemoTabViewController class]]){
            BlueMSDemosViewController *temp = (BlueMSDemosViewController*)c;
            temp.node = self.node;
        }
    }
    
    if(self.node.type == BlueSTSDKNodeTypeSTEVAL_WESU1 ){
        if(!mFwVarningDisplayed){
            [self checkFwVersion];
            mFwVarningDisplayed=true;
        }
    }else{
        [self.menuDelegate removeMenuAction:registerSettings];
    }
    
}


//swipe left -> change the current demo with the next one
- (void)leftSwipeGesture:(UISwipeGestureRecognizer *)sender {
    NSUInteger current = self.selectedIndex;
    if(current < self.viewControllers.count){
        self.selectedIndex=current+1;
    }
}

//swipe right -> change the current demo with the previous one
- (void)rightSwipeGesture:(UISwipeGestureRecognizer *)sender {
    NSUInteger current = self.selectedIndex;
    if(current > 0){
        self.selectedIndex=current-1;
    }
}

#pragma mark - UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController{
    self.navigationItem.title = viewController.navigationItem.title;
}

@end
