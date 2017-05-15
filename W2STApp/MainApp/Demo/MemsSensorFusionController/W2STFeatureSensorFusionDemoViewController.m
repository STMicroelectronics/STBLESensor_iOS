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
#import <GLKit/GLKit.h>
#import <AudioToolbox/AudioServices.h>
#import <BlueSTSDK_Gui/MBProgressHUD.h>

#import "W2STFeatureSensorFusionDemoViewController.h"

#import "BlueMSDemosViewController.h"
#import "W2STSimpleDialogViewController.h"
#import "BlueMSDemoTabViewController+WesuLicenseCheck.h"

#import <BlueSTSDK/BlueSTSDKFeatureAccelerometerEvent.h>
#import <BlueSTSDK/BlueSTSDKFeatureMemsSensorFusionCompact.h>
#import <BlueSTSDK/BlueSTSDKFeatureMemsSensorFusion.h>

#import <BlueSTSDK/BlueSTSDKFeatureProximity.h>
#import <BlueSTSDK/BlueSTSDKFeatureField.h>

#define SCENE_MODEL_FILE @"art.scnassets/cubeModel.dae"
#define SCENE_MODEL_NAME @"Cube"
#define CUBE_DEFAULT_SCALE 1.5f
#define MAX_PROXIMITY_VALUE (255)


#define RESET_POSITION_ID 0
#define RESET_POSITION_STORYBOARD_ID @"ResetPositionDialogID"
#define RESET_POSITION_MESSAGE_NUCLEO @"Keep the board as shown in the image"
#define RESET_POSITION_MESSAGE_STEVAL_WESU1 @"Keep the board as shown in the image"
#define RESET_POSITION_MESSAGE_GENERIC @"Keep the board horizontaly"

#define RESET_CALIB_ID 1
#define RESET_CALIB_STORYBOARD_ID @"ResetCalibDialogID"

#define FREE_FALL_MESSAGE @"Free fall detected!"
#define FREE_FALL_DIALOG_DURATION_S 2.0f


#define LICENSE_NOT_VALID_MSG @"Check the license"


@interface W2STFeatureSensorFusionDemoViewController ()
    <BlueSTSDKFeatureDelegate,BlueSTSDKFeatureAutoConfigurableDelegate,
    W2STSimpleDialogViewControllerDelegate>

@end

@implementation W2STFeatureSensorFusionDemoViewController{
    BlueSTSDKFeatureMemsSensorFusion *mSensorFusionFeature;
    BlueSTSDKFeatureProximity *mProximityFeature;
    BlueSTSDKFeatureAccelerometerEvent *mFreeFallFeature;
    W2STSimpleDialogViewController *mResetPositionDialogController;
    GLKQuaternion mQuatReset;
    SCNScene *mScene;
    SCNNode *mObjectNode;
    SCNNode *mCameraNode;
    SCNNode *mLightNode;
    SCNNode *mAmbientLightNode;
    bool mShowResetMessage;
    bool mShowCalibMessage;
}

-(void)sceneViewSetup{
    mScene = [SCNScene sceneNamed:SCENE_MODEL_FILE];
    
    mObjectNode = [mScene.rootNode childNodeWithName:SCENE_MODEL_NAME recursively:YES];
    mObjectNode.scale = SCNVector3Make(CUBE_DEFAULT_SCALE, CUBE_DEFAULT_SCALE,
                                       CUBE_DEFAULT_SCALE);
    [self.sceneView prepareObjects:[NSArray arrayWithObject:mObjectNode] withCompletionHandler:nil];
    self.sceneView.scene = mScene;

}

-(void) setCalibrationButtonState:(BOOL)status{
    if(status)
        self.calibrationButton.imageView.image = [UIImage imageNamed:@"calibrated.png"];
    else
        self.calibrationButton.imageView.image = [UIImage imageNamed:@"uncalibrated.png"];
}


- (void)viewDidLoad {
    [super viewDidLoad];    
    [self sceneViewSetup];
    
    mQuatReset = GLKQuaternionIdentity;
    mShowCalibMessage=true;
    mShowResetMessage=true;
}

-(void)enableProximityNotification{
    mProximityFeature = (BlueSTSDKFeatureProximity*)
    [self.node getFeatureOfType:BlueSTSDKFeatureProximity.class];
    if(mProximityFeature!=nil){
                [mProximityFeature addFeatureDelegate:self];
        [self enableProximity: self.proximityButton];
    }else{
        //[self.view makeToast:@"Proximity Not Found"];
        self.proximityButton.enabled=false;
        self.proximityButton.alpha=0;
    }//if
}

-(void)enableFreeFallNotificaiton{
    mFreeFallFeature = (BlueSTSDKFeatureAccelerometerEvent*)
    [self.node getFeatureOfType:BlueSTSDKFeatureAccelerometerEvent.class];
    if(mFreeFallFeature!=nil){
        [mFreeFallFeature addFeatureDelegate:self];
        [mFreeFallFeature enableEvent:BlueSTSDKFeatureEventTypeFreeFall enable:true];
        [self.node enableNotification:mFreeFallFeature];
    }else{
        //[self.view makeToast:@"Proximity Not Found"];
    }//if
}

-(void)enableSensorFusionNotificaiton{
    mSensorFusionFeature = (BlueSTSDKFeatureMemsSensorFusion*)
    [self.node getFeatureOfType:BlueSTSDKFeatureMemsSensorFusionCompact.class];
    if(mSensorFusionFeature==nil)
        mSensorFusionFeature = (BlueSTSDKFeatureMemsSensorFusion*)
        [self.node getFeatureOfType:BlueSTSDKFeatureMemsSensorFusion.class];
    if(mSensorFusionFeature!=nil){
        [self setCalibrationButtonState:mSensorFusionFeature.isConfigured];
        [mSensorFusionFeature addFeatureDelegate:self];
        [mSensorFusionFeature addFeatureConfigurationDelegate:self];
        //the state is trasmitted by the board when connectes
        //[mSensorFusionFeature requestAutoConfigurationStatus];
        if(![mSensorFusionFeature isConfigured]
           && (self.node.type!=BlueSTSDKNodeTypeSTEVAL_WESU1)) // the wesu will autocalibrate itself
           [self askCalibration:self.calibrationButton];
        [self.node enableNotification:mSensorFusionFeature];
    }else{
        //[self.view makeToast:@"Sensor Fusion NotFound"];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self prepareResetDialogForNode];
    
    [self enableSensorFusionNotificaiton];
    [self enableProximityNotification];
    [self enableFreeFallNotificaiton];
    
    
    if(self.node.type==BlueSTSDKNodeTypeSTEVAL_WESU1)
        [self checkLicenseFromRegister:
         BlueSTSDK_REGISTER_NAME_MOTION_FX_CALIBRATION_LIC_STATUS
                           errorString:LICENSE_NOT_VALID_MSG];


}


-(void)disableSensorFusionNotification{
    if(mSensorFusionFeature!=nil){
        [self.node disableNotification:mSensorFusionFeature];
        [mSensorFusionFeature removeFeatureConfigurationDelegate:self];
        [mSensorFusionFeature removeFeatureDelegate:self];
    }//if SensorFusion
}

-(void)disableProximityNotification{
    if(mProximityFeature!=nil){
        [mProximityFeature removeFeatureDelegate:self];
        [self.node disableNotification:mProximityFeature];
    }//if Proximity
}

-(void)disableFreeFallNotification{
    if(mFreeFallFeature!=nil){
        [mFreeFallFeature removeFeatureDelegate:self];
        [mFreeFallFeature enableEvent:BlueSTSDKFeatureEventTypeFreeFall enable:false];
        [self.node disableNotification:mFreeFallFeature];
    }//if Proximity
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self disableSensorFusionNotification];
    [self disableProximityNotification];
    [self disableFreeFallNotification];

}

-(void)resetCubePosition{
    BlueSTSDKFeatureSample *data = mSensorFusionFeature.lastSample;
    mQuatReset.z = -[BlueSTSDKFeatureMemsSensorFusionCompact getQi:data];
    mQuatReset.y = [BlueSTSDKFeatureMemsSensorFusionCompact getQj:data];
    mQuatReset.x = [BlueSTSDKFeatureMemsSensorFusionCompact getQk:data];
    mQuatReset.w = [BlueSTSDKFeatureMemsSensorFusionCompact getQs:data];
    mQuatReset = GLKQuaternionInvert(mQuatReset);
}

- (IBAction)resetPositionAction:(UIButton *)sender {
    if(mShowResetMessage){
        self.positionResetMessage.hidden=NO;
    }else
        [self resetCubePosition];
}

-(void)startCalibration{
    //we delete the last calibration -> set the status to false
    [self setCalibrationButtonState:false];
    [mSensorFusionFeature startAutoConfiguration];
}

- (IBAction)askCalibration:(UIButton *)sender {
    if(mShowCalibMessage)
        self.calibrateResetMessage.hidden=NO;
    else
        [self startCalibration];
}

- (IBAction)enableProximity:(UIButton *)sender {
    
    if([self.node isEnableNotification:mProximityFeature]){
        [self.node disableNotification:mProximityFeature];
        mObjectNode.scale = SCNVector3Make(CUBE_DEFAULT_SCALE, CUBE_DEFAULT_SCALE,
                                           CUBE_DEFAULT_SCALE);
        sender.selected=false;
    }else{
        [self.node enableNotification:mProximityFeature];
        sender.selected=true;
    }//if else
}

-(void) updateRotation:(BlueSTSDKFeatureSample*)sample{
    GLKQuaternion temp;
    temp.z = -[BlueSTSDKFeatureMemsSensorFusionCompact getQi:sample];
    temp.y = [BlueSTSDKFeatureMemsSensorFusionCompact getQj:sample];
    temp.x = [BlueSTSDKFeatureMemsSensorFusionCompact getQk:sample];
    temp.w = [BlueSTSDKFeatureMemsSensorFusionCompact getQs:sample];
    temp = GLKQuaternionMultiply(mQuatReset,temp);
    SCNQuaternion rot;
    rot.x = temp.x;
    rot.y = temp.y;
    rot.z = temp.z;
    rot.w = temp.w;
    dispatch_async(dispatch_get_main_queue(),^{
        mObjectNode.orientation = rot;
    });
}//

-(void) updateProximity:(BlueSTSDKFeatureSample*)sample{
    uint16_t distance = [BlueSTSDKFeatureProximity getProximityDistance:sample];
    
    if(distance != [BlueSTSDKFeatureProximity outOfRangeValue]){
        distance = MIN(distance,MAX_PROXIMITY_VALUE);
        
        float scale = CUBE_DEFAULT_SCALE*((((float)distance)/((float)MAX_PROXIMITY_VALUE)));
        mObjectNode.scale = SCNVector3Make(scale, scale,
                                           scale);
    }else{
        mObjectNode.scale = SCNVector3Make(CUBE_DEFAULT_SCALE, CUBE_DEFAULT_SCALE,
                                           CUBE_DEFAULT_SCALE);
    }//if else
}// updateProximity

-(void) updateFreeFall:(BlueSTSDKFeatureSample*)sample{
    if([BlueSTSDKFeatureAccelerometerEvent getAccelerationEvent:sample]==BlueSTSDKFeatureAccelerometerFreeFall){
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *message = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            message.mode = MBProgressHUDModeText;
            message.removeFromSuperViewOnHide = YES;
            message.labelText = FREE_FALL_MESSAGE;
            [message hide:true afterDelay:FREE_FALL_DIALOG_DURATION_S];
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        });
    }//if
    
    
}// updateProximity

#pragma mark - BlueSTSDKFeatureDelegate
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
    if(feature == mSensorFusionFeature)
        [self updateRotation:sample];
    else if(feature == mProximityFeature)
        [self updateProximity:sample];
    else if(feature == mFreeFallFeature)
        [self updateFreeFall:sample];
    //if-else
}

#pragma mark - BlueSTSDKFeatureAutoConfigurableDelegate
-(void)didAutoConfigurationChange:(BlueSTSDKFeatureAutoConfigurable *)feature
                           status:(int32_t)status{
    static dispatch_once_t once;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setCalibrationButtonState:feature.isConfigured];
        if(!feature.isConfigured){
            dispatch_once(&once, ^ {
                [self askCalibration:nil];
            });
        }
    });
}

-(void)prepareResetDialogForNode{
    switch (self.node.type) {
        case BlueSTSDKNodeTypeNucleo:
            mResetPositionDialogController.image.image = [UIImage imageNamed:@"nucleo_reset_position.png"];
            mResetPositionDialogController.message.text = RESET_POSITION_MESSAGE_NUCLEO;
            break;
        case BlueSTSDKNodeTypeSTEVAL_WESU1:
            mResetPositionDialogController.image.image = [UIImage imageNamed:@"steval_wesu1_reset_position.png"];
            mResetPositionDialogController.message.text = RESET_POSITION_MESSAGE_STEVAL_WESU1;
            break;
        case BlueSTSDKNodeTypeSensor_Tile:
            mResetPositionDialogController.image.image = [UIImage imageNamed:@"tile_reset_position.png"];
            mResetPositionDialogController.message.text = RESET_POSITION_MESSAGE_NUCLEO;
            break;
        default:
            mResetPositionDialogController.image.image = [UIImage imageNamed:@"board_generic.png"];
            mResetPositionDialogController.message.text = RESET_POSITION_MESSAGE_GENERIC;
            break;
    }//if
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.destinationViewController isKindOfClass:W2STSimpleDialogViewController.class]){
        W2STSimpleDialogViewController *temp = (W2STSimpleDialogViewController *)segue.destinationViewController;
        temp.delegate=self;
        if([temp.restorationIdentifier isEqualToString:RESET_CALIB_STORYBOARD_ID]){
            temp.dialogId = RESET_CALIB_ID;
        }else if([temp.restorationIdentifier isEqualToString:RESET_POSITION_STORYBOARD_ID]){
            temp.dialogId = RESET_POSITION_ID;
            mResetPositionDialogController=temp;
        }
    }
}

#pragma mark - W2STSimpleDialogViewControllerDelegate
-(void)buttonClicked:(NSUInteger)dialogId{
    
    if(dialogId==RESET_CALIB_ID){
        self.calibrateResetMessage.hidden=YES;
        mShowCalibMessage=false;
        [self startCalibration];
    } else if(dialogId == RESET_POSITION_ID) {
        self.positionResetMessage.hidden=YES;
        mShowResetMessage=false;
        [self resetCubePosition];
    }//if-else
}

@end
