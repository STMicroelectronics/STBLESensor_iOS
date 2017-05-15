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

#import "W2STCompassViewController.h"

#import "W2STSimpleDialogViewController.h"
#import <BlueSTSDK/BlueSTSDKFeatureCompass.h>

#define RESET_CALIB_ID 1
#define RESET_CALIB_STORYBOARD_ID @"ResetCalibDialogID"

#define ANGLE_FORMAT_STRING @"Angle: %2.2f"
#define ORIENTATION_FORMAT_STRING @"Orientation: %@"

@interface W2STCompassViewController ()<
    BlueSTSDKFeatureDelegate,
    BlueSTSDKFeatureAutoConfigurableDelegate,
    W2STSimpleDialogViewControllerDelegate>

@end

@implementation W2STCompassViewController{
    
    __weak IBOutlet UIImageView *mNeedleImage;
    __weak IBOutlet UILabel *mOrientationLabel;
    __weak IBOutlet UILabel *mAngleLabel;
    __weak IBOutlet UIButton *mCalibButton;
    __weak IBOutlet UIView *mCalibrateMessageView;

    BlueSTSDKFeatureCompass *mFeature;
    
    NSArray<NSString*>* mOrientation;
    bool mShowCalibMessage;
    
}

-(void)viewDidLoad{
    [super viewDidLoad];
    mShowCalibMessage = true;
    mOrientation = @[@"N",@"NE",@"E",@"SE",@"S",@"SW",@"W",@"NW"];
    mCalibrateMessageView.hidden=YES;

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //enable the notification
    mFeature =(BlueSTSDKFeatureCompass*)[self.node getFeatureOfType:BlueSTSDKFeatureCompass.class];
    if(mFeature!=nil){
        [self setCalibrationButtonState:mFeature.isConfigured];
        [mFeature addFeatureDelegate:self];
        [mFeature addFeatureConfigurationDelegate:self];
        //[mFeature requestAutoConfigurationStatus];
        //the state is trasmitted by the board when connectes
        //[mSensorFusionFeature requestAutoConfigurationStatus];
        if(![mFeature isConfigured])
            [self askCalibration:nil];
        [self.node enableNotification:mFeature];
    }//if
}//viewDidAppear

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //if we are ploting something stop it
    if(mFeature!=nil){
        [mFeature removeFeatureDelegate:self];
        [mFeature removeFeatureConfigurationDelegate:self];

        [self.node disableNotification:mFeature];
        mFeature=nil;
    }//if
}

static float degreeToRad(float angle){
    return angle*(M_PI/180.0);
}

-(NSString*) getOrientationNameForAngle:(float) angle{
    NSUInteger nOrientation = mOrientation.count;
    
    float section = 360.0f/nOrientation;
    angle = angle - (section/2) + 360.0f;
    int index = (int)(angle/section)+1;
    
    return mOrientation[index % nOrientation];
    
}

#pragma mark - BlueSTSDKFeatureDelegate
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
   
    float angle = [BlueSTSDKFeatureCompass getCompassAngle:sample];
    NSString *oritantionStr = [self getOrientationNameForAngle:angle];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        mNeedleImage.transform = CGAffineTransformMakeRotation(degreeToRad(angle));
        mAngleLabel.text = [NSString stringWithFormat:ANGLE_FORMAT_STRING,angle ];
        mOrientationLabel.text = [NSString stringWithFormat:ORIENTATION_FORMAT_STRING,oritantionStr];
        
    });
        
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

-(void) setCalibrationButtonState:(BOOL)status{
    if(status)
        mCalibButton.imageView.image = [UIImage imageNamed:@"calibrated.png"];
    else
        mCalibButton.imageView.image = [UIImage imageNamed:@"uncalibrated.png"];
}

-(void)startCalibration{
    //we delete the last calibration -> set the status to false
    [self setCalibrationButtonState:false];
    [mFeature startAutoConfiguration];
}

- (IBAction)askCalibration:(UIButton *)sender {
    if(mShowCalibMessage)
        mCalibrateMessageView.hidden=NO;
    else
        [self startCalibration];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.destinationViewController isKindOfClass:W2STSimpleDialogViewController.class]){
        W2STSimpleDialogViewController *temp = (W2STSimpleDialogViewController *)segue.destinationViewController;
        temp.delegate=self;
        if([temp.restorationIdentifier isEqualToString:RESET_CALIB_STORYBOARD_ID]){
            temp.dialogId = RESET_CALIB_ID;
        }    }
}

#pragma mark - W2STSimpleDialogViewControllerDelegate
-(void)buttonClicked:(NSUInteger)dialogId{
    
    if(dialogId==RESET_CALIB_ID){
        mCalibrateMessageView.hidden=YES;
        mShowCalibMessage=false;
        [self startCalibration];
    }
}




@end
