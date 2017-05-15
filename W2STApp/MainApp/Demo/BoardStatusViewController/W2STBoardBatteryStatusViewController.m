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

#import <BlueSTSDK/BlueSTSDKFeatureBattery.h>

#import "W2STBoardBatteryStatusViewController.h"

@interface W2STBoardBatteryStatusViewController () <BlueSTSDKFeatureDelegate,
    BlueSTSDKFeatureBatteryDelegate>
    @property (weak, nonatomic) IBOutlet UIImageView *batteryImage;
    @property (weak, nonatomic) IBOutlet UILabel *levelLabel;
    @property (weak, nonatomic) IBOutlet UILabel *statusLabel;
    @property (weak, nonatomic) IBOutlet UILabel *voltageLabel;
    @property (weak, nonatomic) IBOutlet UILabel *currentLabel;
    @property (weak, nonatomic) IBOutlet UILabel *remainingTimeLabel;
@end

@implementation W2STBoardBatteryStatusViewController{
    BlueSTSDKFeatureBattery *batteryFeature;
    float mBatteryCapacity;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    mBatteryCapacity=NAN;
}

-(void)loadBatteryCapacity{
    if(!isnan(mBatteryCapacity)) //already load
        return;
    //else
    [batteryFeature readBatteryCapacity];
}

-(void)loadMaxAssorbedCurrent{
    [batteryFeature readMaxAbsorbedCurrent];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    batteryFeature = (BlueSTSDKFeatureBattery*)
        [self.delegate extractFeatureType: BlueSTSDKFeatureBattery.class];
    if(batteryFeature!=nil){
        [batteryFeature addFeatureDelegate:self];
        [batteryFeature addBatteryDelegate:self];
        [self.delegate enableNotificationForFeature:batteryFeature];
        [self loadBatteryCapacity];
        [self loadMaxAssorbedCurrent];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(batteryFeature!=nil){
        [batteryFeature removeFeatureDelegate:self];
        [batteryFeature removeBatteryDelegate:self];
        [self.delegate disableNotificationForFeature:batteryFeature];
    }
}

#define BATTERY_STEPS 20
-(UIImage*) getBatteryStatusImageWithLevel:(float)level status:(BlueSTSDKFeatureBatteryStatus)status{
    
    uint8_t levelInt = ((uint8_t)(level/BATTERY_STEPS+0.5f))*BATTERY_STEPS;
    if(status != BlueSTSDKFeatureBatteryStatusCharging){
        return [UIImage imageNamed:
                [NSString stringWithFormat:@"battery_%d",levelInt]];
    }else //is charging
        return [UIImage imageNamed:
                [NSString stringWithFormat:@"battery_%dc",levelInt]];
}

static float getRemainingMinute(float current, float batteryCapacity){
    if(current>0)
        return NAN;
    return (batteryCapacity/(-current))*(60);
}

bool displayRemainingTime(BlueSTSDKFeatureBatteryStatus batteryStatus){
    return batteryStatus != BlueSTSDKFeatureBatteryStatusCharging;
}

#pragma mark - BlueSTSDKFeatureDelegate
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
    float chargeValue = [BlueSTSDKFeatureBattery getBatteryLevel:sample];
    float currentValue = [BlueSTSDKFeatureBattery getBatteryCurrent:sample];
    BlueSTSDKFeatureBatteryStatus batteryStatus = [BlueSTSDKFeatureBattery getBatteryStatus:sample ];
    NSString *current = [NSString stringWithFormat:@"Current: %.1f mA",currentValue];
    NSString *voltage = [NSString stringWithFormat:@"Voltage: %.3f V",
                         [BlueSTSDKFeatureBattery getBatteryVoltage:sample]];
    NSString *charge = [NSString stringWithFormat:@"Charge: %.1f %%",chargeValue ];
//    NSString *status = [NSString stringWithFormat:@"Status: %@",  ];
    NSString *status =[BlueSTSDKFeatureBattery getBatteryStatusStr:sample ];
    UIImage *batteryImage = [self getBatteryStatusImageWithLevel:chargeValue
                                                          status:batteryStatus];
    float remainingBattery = mBatteryCapacity* (chargeValue/100.0f);
    
    float remainingTime = getRemainingMinute(currentValue, remainingBattery);
    NSString *remainingTimeStr = isnan(remainingTime) ? nil : [NSString stringWithFormat:@"Autonomy: %.1f m",remainingTime];
    
    dispatch_sync(dispatch_get_main_queue(),^{
        self.levelLabel.text=charge;
        self.currentLabel.text=current;
        self.voltageLabel.text=voltage;
        self.statusLabel.text=status;
        self.batteryImage.image = batteryImage;
        if(displayRemainingTime(batteryStatus)){
            self.remainingTimeLabel.text = remainingTimeStr;
        }else{
            self.remainingTimeLabel.text=nil;
        }
    });
    
}

#pragma mark - BlueSTSDKFeatureBatteryDelegate

-(void)didCapacityRead:(BlueSTSDKFeatureBattery *)feature
              capacity:(uint16_t)capacity{
    mBatteryCapacity = capacity;
}

-(void)didMaxAssorbedCurrentRead:(BlueSTSDKFeatureBattery *)feature
                         current:(float)current{ }

@end
