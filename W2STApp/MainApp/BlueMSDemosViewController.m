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
#import <BlueSTSDK/BlueSTSDK-Swift.h>
#import <BlueSTSDK/BlueSTSDKFeatureTemperature.h>
#import <BlueSTSDK/BlueSTSDKFeaturePressure.h>
#import <BlueSTSDK/BlueSTSDKFeatureLuminosity.h>
#import <BlueSTSDK/BlueSTSDKFeatureHumidity.h>
#import <BlueSTSDK/BlueSTSDKFeatureMemsSensorFusion.h>
#import <BlueSTSDK/BlueSTSDKFeatureMemsSensorFusionCompact.h>
#import <BlueSTSDK/BlueSTSDKFeatureCarryPosition.h>
#import <BlueSTSDK/BlueSTSDKFeatureProximityGesture.h>
#import <BlueSTSDK/BlueSTSDKFeatureMemsGesture.h>
#import <BlueSTSDK/BlueSTSDKFeaturePedometer.h>
#import <BlueSTSDK/BlueSTSDKFeatureAccelerometerEvent.h>
#import <BlueSTSDK/BlueSTSDKFeatureSwitch.h>
#import <BlueSTSDK/BlueSTSDKFeatureHeartRate.h>
#import <BlueSTSDK/BlueSTSDKFeatureCompass.h>
#import <BlueSTSDK/BlueSTSDKFeatureMotionIntensity.h>
#import <BlueSTSDK/BlueSTSDKFeatureDirectionOfArrival.h>
#import <BlueSTSDK/BlueSTSDKFeatureBeamForming.h>

#import "W2STApp-Swift.h"
//#import "ST_BLE_Sensor-Swift.h"
#import "BlueMSDemosViewController.h"
#import "BlueMSDemosViewController+WesuFwVersion.h"

#import "BlueMSDemoTabViewController.h"
#import "W2STPlotFeatureDemoViewController.h"

#define SHOW_LICENSE_MANAGER_NAME BLUESTSDK_LOCALIZE(@"License Manager",nil)
#define SHOW_SETTINGS_NAME BLUESTSDK_LOCALIZE(@"Settings",nil)

#define ENVIROMENTAL_DEMO_POSITION 0
#define SENSOR_FUSION_DEMO_POSITION 1
#define FFTAMPLITUDE_DEMO_POSITION 2
#define PLOT_DEMO_POSITION 3
#define SD_LOGGING_POSITION 4
#define ACTIVITY_RECOGNITION_DEMO_POSITION 5
#define CARRY_POSITION_RECOGNITION_DEMO_POSITION 6
#define PROXIMITY_GESTURE_RECOGNITION_DEMO_POSITION 7
#define MEMS_GESTURE_RECOGNITION_DEMO_POSITION 8
#define PEDOMEMETER_DEMO_POSITION 9
#define ACC_EVENT_DEMO_POSITION 10
#define SWITCH_DEMO_POSITION 11
#define BLUEVOICE_DEMO_POSITION 12
#define SPEECHTOTEXT_DEMO_POSITION 13
#define BEAM_FORMING_DEMO_POSITION 14
#define DIRECTION_OF_ARRIVAL_DEMO_POSITION 15
#define AUDIO_SCENE_CLASSIFICAITON_POSITION 16
#define HEART_RATE_DEMO_POSITION 17
#define MOTIONID_DEMO_POSITION 18
#define COMPASS_DEMO_POSITION 19
#define LEVEL_DEMO_POSITION 20
#define COSENSOR_DEMO_POSITION 21
#define STM32WB_P2PSERVER_POSITION 22
#define REBOOT_OTA_POSITION 23
#define AILOG_POSITION 24
#define MULTI_NN_DEMO_POSITION 25
#define CLOUD_DEMO_POSITION 26
#define PREDICTIVE_DEMO_POSITION 27
#define RSSI_DEMO_POSITION 28
#define MOTIONALGO_DEMO_POSITION 29
#define FITNESS_ACTIVITY_DEMO_POSITION 30
#define MACHINE_LEARNING_CORE_POSITION 31
#define FINITE_STATE_MACHINE_POSITION 32
#define GNSS_FEATURE_POSITION 33
#define TOF_FEATURE_POSITION 34
#define AMBIENT_LIGHT_FEATURE_POSITION 35
#define PREDICTIVE_CLOUD_DEMO_POSITION 36
#define NEAIAD_FEATURE_POSITION 37
#define PNPL_POSITION 38
#define NEAICLASS_FEATURE_POSITION 39
#define STM32WBA_OTA_POSITION 40
#define HSDATALOG_POSITION 41
#define HSDATALOG2_POSITION 42
#define EXTFEATURE_POSITION 43
#define TEXTUAL_FEATURE_POSITION 44

#define NUMBER_OF_DEMOS 45

@interface BlueMSDemosViewController () <UITabBarControllerDelegate, UINavigationControllerDelegate>

@end

@implementation BlueMSDemosViewController {
    UISwipeGestureRecognizer *leftGesture;
    UISwipeGestureRecognizer *rightGesture;
    UIAlertAction *registerSettings;
    UIAlertAction *nucleoSettings;
    bool mFwVarningDisplayed;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self updateViewControllers];
    [self initializeDemos];
    
    // create the gesture recognizer
    leftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipeGesture:)];
    leftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipeGesture:)];
    rightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    
    // add it to the view
    [self.view addGestureRecognizer:leftGesture];
    [self.view addGestureRecognizer:rightGesture];
    
    registerSettings = [self createRegisterSettings];
    [self.menuDelegate addMenuAction:registerSettings];

    if ([_node getFeatureOfType:BlueSTSDKFeatureExtendedConfiguration.class] == nil) {
        nucleoSettings = [self createNucleoSettings];
        [self.menuDelegate addMenuAction:nucleoSettings];
    }

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

- (void)viewWillAppear:(BOOL)animated {

    self.delegate = self;
    
    // hide the navigation bar in case of more than 5 demos,
    // in this way the user can't edit the item in the tabbar and we have more
    // space for the demo
    self.moreNavigationController.navigationBarHidden = true;
    self.moreNavigationController.delegate = self;

    if (self.node.type == BlueSTSDKNodeTypeSTEVAL_WESU1) {
        if (!mFwVarningDisplayed) {
            [self checkFwVersion];
            mFwVarningDisplayed = true;
        }
        [self.menuDelegate removeMenuAction:nucleoSettings];
    } else {
        [self.menuDelegate removeMenuAction:registerSettings];
    }
    
    [super viewWillAppear:animated];
}


- (BOOL)hasAudioStream {
    BlueSTSDKNode *node = self.node;
    BOOL hasADPCMStream = [node getFeatureOfType:BlueSTSDKFeatureAudioADPCM.class]!=nil &&
    [node getFeatureOfType:BlueSTSDKFeatureAudioADPCMSync.class]!=nil ;
    BOOL hasOPUSStream = [node getFeatureOfType:BlueSTSDKFeatureAudioOpus.class]!=nil &&
    [node getFeatureOfType:BlueSTSDKFeatureAudioOpusConf.class]!=nil ;
    return hasOPUSStream || hasADPCMStream ;
}

//  Demo Management

- (void)updateViewControllers {
    self.addedViewControllers = self.viewControllers.mutableCopy;
    [self setViewControllers: @[] animated: NO];

    HighSpeedDataLogViewController *vc1 = [[HighSpeedDataLogViewController alloc] init];
    if (@available(iOS 13.0, *)) {
        vc1.tabBarItem = [[UITabBarItem alloc] initWithTitle: @"HighSpeed Data Log" image: [UIImage imageNamed:(NSString *) @"ic_hsdlog" inBundle:(NSBundle *) [NSBundle bundleForClass:[BlueMSDemosViewController class]] withConfiguration:(UIImageConfiguration *) nil] selectedImage: nil];
    } else {
        vc1.tabBarItem = [[UITabBarItem alloc] initWithTitle: @"HighSpeed Data Log" image: [UIImage imageNamed:@"ic_hsdlog"] selectedImage: nil];
    }
    [self.addedViewControllers addObject: vc1];
    
    HighSpeedDataLog2ViewController *vc2 = [[HighSpeedDataLog2ViewController alloc] init];
    if (@available(iOS 13.0, *)) {
        vc2.tabBarItem = [[UITabBarItem alloc] initWithTitle: @"HighSpeed Data Log 2" image: [UIImage imageNamed:(NSString *) @"ic_hsdlog" inBundle:(NSBundle *) [NSBundle bundleForClass:[BlueMSDemosViewController class]] withConfiguration:(UIImageConfiguration *) nil] selectedImage: nil];
    } else {
        vc2.tabBarItem = [[UITabBarItem alloc] initWithTitle: @"HighSpeed Data Log 2" image: [UIImage imageNamed:@"ic_hsdlog"] selectedImage: nil];
    }
    [self.addedViewControllers addObject: vc2];
    
    ExtendedConfigurationViewController *vc3 = [ExtendedConfigurationViewController new];
    if (@available(iOS 13.0, *)) {
        vc3.tabBarItem = [[UITabBarItem alloc] initWithTitle: @"Board Configuration" image: [UIImage imageNamed:(NSString *) @"ic_ext_conf" inBundle:(NSBundle *) [NSBundle bundleForClass:[BlueMSDemosViewController class]] withConfiguration:(UIImageConfiguration *) nil] selectedImage: nil];
    } else {
        vc3.tabBarItem = [[UITabBarItem alloc] initWithTitle: @"Board Configuration" image: [UIImage imageNamed:@"ic_ext_conf"] selectedImage: nil];
    }
    [self.addedViewControllers addObject: vc3];

    GenericTextualFeatureViewController *vc4 = [GenericTextualFeatureViewController new];
    if (@available(iOS 13.0, *)) {
        vc4.tabBarItem = [[UITabBarItem alloc] initWithTitle: @"Textual Monitor" image: [UIImage imageNamed:(NSString *) @"ic_text" inBundle:(NSBundle *) [NSBundle bundleForClass:[BlueMSDemosViewController class]] withConfiguration:(UIImageConfiguration *) nil] selectedImage: nil];
    } else {
        vc4.tabBarItem = [[UITabBarItem alloc] initWithTitle: @"Textual Monitor" image: [UIImage imageNamed:@"ic_text"] selectedImage: nil];
    }
    [self.addedViewControllers addObject: vc4];
    
    //  remove is after the initialization to permit to correctly initialize the
    //  demo that have some internal view controller to pass the valid node also to the subview

    [self removeOptionalDemo];
}

- (void)initializeDemos {
    for (UIViewController *vc in self.addedViewControllers) {
        [BlueSTSDKDemoViewProtocolUtil setupDemoProtocolWithDemo: vc
                                                            node: self.node
                                                    menuDelegate: self.menuDelegate];
        
        [BlueSTDemoNestedNavigationViewController setViewControllerProperty: vc
                                                                       node: self.node
                                                               menuDelegate: self.menuDelegate];
    }
    
    [self setViewControllers: self.addedViewControllers animated: NO];
}

/**
 *  check the presence of the feature needed for run the demos, if they aren't present
 * remove the demo button
 */
- (void)removeOptionalDemo {
    if (self.addedViewControllers.count != NUMBER_OF_DEMOS) {
        return;
    }
    
    NSMutableIndexSet *indexesToRemove = [NSMutableIndexSet indexSet];
    BlueSTSDKNode *node = self.node;
    
    //check to have almost one feature needed for run the demo, if not remove it
    if ([node getFeatureOfType:BlueSTSDKFeatureMemsSensorFusion.class] == nil &&
       [node getFeatureOfType:BlueSTSDKFeatureMemsSensorFusionCompact.class] == nil)
        [indexesToRemove addIndex:SENSOR_FUSION_DEMO_POSITION];
    if ([node getFeatureOfType:BlueSTSDKFeatureTemperature.class] == nil &&
        [node getFeatureOfType:BlueSTSDKFeaturePressure.class] == nil &&
        [node getFeatureOfType:BlueSTSDKFeatureHumidity.class] == nil &&
        [node getFeatureOfType:BlueSTSDKFeatureLuminosity.class] == nil)
        [indexesToRemove addIndex:ENVIROMENTAL_DEMO_POSITION];
    if ([self.node getFeatureOfType:BlueSTSDKFeatureActivity.class] == nil)
        [indexesToRemove addIndex:ACTIVITY_RECOGNITION_DEMO_POSITION];
    if ([self.node getFeatureOfType:BlueSTSDKFeatureCarryPosition.class] == nil)
        [indexesToRemove addIndex:CARRY_POSITION_RECOGNITION_DEMO_POSITION];
    if ([self.node getFeatureOfType:BlueSTSDKFeatureProximityGesture.class] == nil)
        [indexesToRemove addIndex:PROXIMITY_GESTURE_RECOGNITION_DEMO_POSITION];
    if ([self.node getFeatureOfType:BlueSTSDKFeatureMemsGesture.class] == nil)
        [indexesToRemove addIndex:MEMS_GESTURE_RECOGNITION_DEMO_POSITION];
    if ([self.node getFeatureOfType:BlueSTSDKFeaturePedometer.class] == nil)
        [indexesToRemove addIndex:PEDOMEMETER_DEMO_POSITION];
    if ([self.node getFeatureOfType:BlueSTSDKFeatureAccelerometerEvent.class] == nil)
        [indexesToRemove addIndex:ACC_EVENT_DEMO_POSITION];
    if ([self.node getFeatureOfType:BlueSTSDKFeatureSwitch.class] == nil)
        [indexesToRemove addIndex:SWITCH_DEMO_POSITION];
    if ( ![self hasAudioStream]) {
        [indexesToRemove addIndex:BLUEVOICE_DEMO_POSITION];
        [indexesToRemove addIndex:SPEECHTOTEXT_DEMO_POSITION];
    }
    if ([node getFeatureOfType:BlueSTSDKFeatureHeartRate.class] == nil) {
        [indexesToRemove addIndex:HEART_RATE_DEMO_POSITION];
    }
    if ([node getFeatureOfType:BlueSTSDKFeatureMotionIntensity.class] == nil) {
        [indexesToRemove addIndex:MOTIONID_DEMO_POSITION];
    }
    if ([node getFeatureOfType:BlueSTSDKFeatureCompass.class] == nil) {
        [indexesToRemove addIndex:COMPASS_DEMO_POSITION];
    }
    if ([node getFeatureOfType:BlueSTSDKFeatureDirectionOfArrival.class] == nil) {
        [indexesToRemove addIndex:DIRECTION_OF_ARRIVAL_DEMO_POSITION];
    }
    if (![self hasAudioStream] ||
       [node getFeatureOfType:BlueSTSDKFeatureBeamForming.class] == nil) {
        [indexesToRemove addIndex:BEAM_FORMING_DEMO_POSITION];
    }
    if ([node getFeatureOfType:BlueSTSDKFeatureSDLogging.class] == nil) {
        [indexesToRemove addIndex:SD_LOGGING_POSITION];
    }
    if ([node getFeatureOfType:BlueSTSDKFeatureAudioCalssification.class] == nil) {
        [indexesToRemove addIndex:AUDIO_SCENE_CLASSIFICAITON_POSITION];
    }
        
    if (![W2STPlotFeatureDemoViewController canPlotFeatureForNode:node]) {
        [indexesToRemove addIndex:PLOT_DEMO_POSITION];
    }
    if ([node getFeatureOfType:BlueSTSDKSTM32WBRebootOtaModeFeature.class] == nil) {
        [indexesToRemove addIndex:REBOOT_OTA_POSITION];
    }
    if ([node getFeatureOfType:STM32WBControlLedFeature.class] == nil ||
       [node getFeatureOfType:STM32WBSwitchStatusFeature.class] == nil) {
        [indexesToRemove addIndex:STM32WB_P2PSERVER_POSITION];
    }
    
    if ([node getFeatureOfType:BlueSTSDKSTM32WBOTAControlFeature.class] == nil ||
        [node getFeatureOfType:BlueSTSDKSTM32WBOtaUploadFeature.class] == nil ||
        [node getFeatureOfType:BlueSTSDKSTM32WBOTAWillRebootFeature.class] == nil) {
        [indexesToRemove addIndex:STM32WBA_OTA_POSITION];
    }
    
    if ([node getFeatureOfType:BlueSTSDKFeatureCOSensor.class] == nil) {
        [indexesToRemove addIndex:COSENSOR_DEMO_POSITION];
    }
    
    if ([node getFeatureOfType:BlueSTSDKFeatureAILogging.class] == nil) {
        [indexesToRemove addIndex:AILOG_POSITION];
    }
    
    if ([node getFeatureOfType:BlueSTSDKFeatureFFTAmplitude.class] == nil) {
        [indexesToRemove addIndex:FFTAMPLITUDE_DEMO_POSITION];
    }
    
    if ([node getFeatureOfType:BlueSTSDKFeatureEulerAngle.class] == nil) {
        [indexesToRemove addIndex:LEVEL_DEMO_POSITION];
    }
    
    if ([node getFeatureOfType:BlueSTSDKFeaturePredictiveSpeedStatus.class] == nil &&
       [node getFeatureOfType:BlueSTSDKFeaturePredictiveFrequencyDomainStatus.class] == nil &&
       [node getFeatureOfType:BlueSTSDKFeaturePredictiveAccelerationStatus.class] == nil) {
        [indexesToRemove addIndex:PREDICTIVE_DEMO_POSITION];
        [indexesToRemove addIndex:PREDICTIVE_CLOUD_DEMO_POSITION];
    }
    
    if ([node getFeatureOfType:BlueSTSDKFeatureMotionAlogrithm.class] == nil) {
        [indexesToRemove addIndex:MOTIONALGO_DEMO_POSITION];
    }
    
    if ([node getFeatureOfType:BlueSTSDKFeatureFitnessActivity.class] == nil) {
        [indexesToRemove addIndex:FITNESS_ACTIVITY_DEMO_POSITION];
    }
    
    
    if ([node getFeatureOfType:BlueSTSDKFeatureAudioCalssification.class] == nil ||
       [node getFeatureOfType:BlueSTSDKFeatureActivity.class] == nil) {
        [indexesToRemove addIndex:MULTI_NN_DEMO_POSITION];
    }
    
    if ([node getFeatureOfType:BlueSTSDKFeatureMachineLearningCore.class] == nil) {
        [indexesToRemove addIndex:MACHINE_LEARNING_CORE_POSITION];
    }
    if ([node getFeatureOfType:BlueSTSDKFeatureFiniteStateMachine.class] == nil) {
        [indexesToRemove addIndex:FINITE_STATE_MACHINE_POSITION];
    }
    if ([node getFeatureOfType:BlueSTSDKFeatureHighSpeedDataLog.class] == nil) {
        [indexesToRemove addIndex:HSDATALOG_POSITION];
        [indexesToRemove addIndex:HSDATALOG2_POSITION];
    }
    
    if ([node getFeatureOfType:BlueSTSDKFeatureHighSpeedDataLog.class] != nil) {
        if([node getFeatureOfType:BlueSTSDKFeaturePnPL.class] == nil) {
            [indexesToRemove addIndex:HSDATALOG2_POSITION];
        } else {
            [indexesToRemove addIndex:HSDATALOG_POSITION];
            [indexesToRemove addIndex:PNPL_POSITION];
        }
    }
    
    if ([node getFeatureOfType:BlueSTSDKFeatureExtendedConfiguration.class] == nil) {
        [indexesToRemove addIndex:EXTFEATURE_POSITION];
    }
    
    if([node getFeatureOfType:BlueSTSDKFeatureColorAmbientLight.class] == nil) {
        [indexesToRemove addIndex:AMBIENT_LIGHT_FEATURE_POSITION];
    }
    
    if([node getFeatureOfType:BlueSTSDKFeatureGNSS.class] == nil) {
        [indexesToRemove addIndex:GNSS_FEATURE_POSITION];
    }
    
    if([node getFeatureOfType:BlueSTSDKFeatureNEAIAnomalyDetection.class] == nil) {
        [indexesToRemove addIndex:NEAIAD_FEATURE_POSITION];
    }
    
    if([node getFeatureOfType:BlueSTSDKFeaturePnPL.class] == nil) {
        [indexesToRemove addIndex:PNPL_POSITION];
    }
    
    if([node getFeatureOfType:BlueSTSDKFeatureNEAIClassification.class] == nil) {
        [indexesToRemove addIndex:NEAICLASS_FEATURE_POSITION];
    }
    
    if([node getFeatureOfType:BlueSTSDKFeatureToFMultiObject.class] == nil) {
        [indexesToRemove addIndex:TOF_FEATURE_POSITION];
    }
    
    [self.addedViewControllers removeObjectsAtIndexes:indexesToRemove];
}

//  Swipe Management

/**
 * swipe left -> change the current demo with the next one
 */
- (void)leftSwipeGesture:(UISwipeGestureRecognizer *)sender {
    NSUInteger current = self.selectedIndex;
    if (current < self.viewControllers.count) {
        self.selectedIndex=current+1;
    }
}

/**
 * swipe right -> change the current demo with the previous one
 */
- (void)rightSwipeGesture:(UISwipeGestureRecognizer *)sender {
    NSUInteger current = self.selectedIndex;
    if (current > 0) {
        self.selectedIndex=current-1;
    }
}

//  Nucleo Settings

- (UIAlertAction *)createNucleoSettings {
    return [UIAlertAction actionWithTitle:SHOW_SETTINGS_NAME
                                    style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action) {
                                      [self moveToNucleoSettingsViewController];
                                  }];
}

- (void)moveToNucleoSettingsViewController {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"BlueMSNucleoPreferences" bundle:[NSBundle bundleForClass:[self class]]];
    
    BlueMSNucleoPrefViewController *settingsControlView = [storyBoard instantiateInitialViewController];
    
    settingsControlView.node=self.node;
    
    [self changeViewController:settingsControlView];
}

/**
 * on Ipad, show the tabItem name below the icon an not after
 * https://stackoverflow.com/questions/44822558/ios-11-uitabbar-uitabbaritem-positioning-issue
 */
- (UITraitCollection *)traitCollection {
  UITraitCollection *curr = [super traitCollection];
  UITraitCollection *compact = [UITraitCollection  traitCollectionWithHorizontalSizeClass:UIUserInterfaceSizeClassCompact];

  return [UITraitCollection traitCollectionWithTraitsFromCollections:@[curr, compact]];
}

#pragma mark - UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    self.navigationItem.title = viewController.navigationItem.title;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return YES;
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    navigationController.navigationBarHidden = YES;
}

@end
