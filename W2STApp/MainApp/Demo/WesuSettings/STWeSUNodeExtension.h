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

#import <Foundation/Foundation.h>

#import "BlueSTSDK/BlueSTSDK.h"

#define LED_INTMNG  @"00"
#define LED_ON      @"11"
#define LED_OFF     @"12"

#define RTC_TIMER_INVALID           @"00"
#define RTC_TIMER_DEFAULT           @"D0"
#define RTC_TIMER_DEFAULT_RUNNING   @"D1"
#define RTC_TIMER_RESTORED          @"A0"
#define RTC_TIMER_RESTORED_RUNNING  @"A1"
#define RTC_TIMER_USER              @"B0"
#define RTC_TIMER_USER_RUNNING      @"B1"
#define RTC_TIMER_FORCED            @"B3"

#define DFU_REBOOT_APPL      @"0"
#define DFU_REBOOT_USBDFU    @"1"
#define DFU_REBOOT_OTABLEDFU @"2"

#define PWR_OFF_STANDBY_BLE @"FD"
#define PWR_OFF_STANDBY     @"FE"
#define PWR_OFF_REBOOT      @"FC"
#define PWR_OFF_REBOOT_DEF  @"FB"
#define PWR_OFF_SHUTDOWN    @"FA"

#define LOCALNAME_MAX 15
#define LOCALNAME_MAX_ADV 5

@interface STWeSUNodeExtension : NSObject

@property (retain, readonly) BlueSTSDKNode *node;

@property (retain, readonly) NSDictionary *featureMapGroupA;
@property (retain, readonly) NSDictionary *featureMapGroupB;
@property (retain, readonly) NSDictionary *ledConfig;
@property (retain, readonly) NSDictionary *powerMode;
@property (retain, readonly) NSDictionary *bleOutputPowerMap;
@property (retain, readonly) NSDictionary *rtcTimer;
@property (retain, readonly) NSDictionary *dfuReboot;
@property (retain, readonly) NSDictionary *powerOff;

@property (retain, readonly) NSArray *featureMapGroupAOrderedKeys;
@property (retain, readonly) NSArray *featureMapGroupBOrderedKeys;
@property (retain, readonly) NSArray *ledConfigOrderedKeys;
@property (retain, readonly) NSArray *powerModeOrderedKeys;
@property (retain, readonly) NSArray *bleOutputPowerMapOrderedKeys;
@property (retain, readonly) NSArray *rtcTimerOrderedKeys;
@property (retain, readonly) NSArray *dfuRebootOrderedKeys;
@property (retain, readonly) NSArray *powerOffOrderedKeys;

//+(instancetype)sharedInstance;
+(instancetype)nodeExtWithNode:(BlueSTSDKNode *)node;
-(instancetype)initWithNode:(BlueSTSDKNode *)node;

-(void)asyncReadWithReg:(BlueSTSDKRegister *)reg target:(BlueSTSDKRegisterTarget_e)target;
-(void)asyncReadWithRegName:(BlueSTSDKWeSURegisterName_e)regName target:(BlueSTSDKRegisterTarget_e)target;

//actions
-(BOOL) writeSingleReg:(NSInteger)value regName:(BlueSTSDKWeSURegisterName_e)regName target:(BlueSTSDKRegisterTarget_e)target autosync:(BOOL)autosync;
-(BOOL) writeSingleRegFromDec:(NSString *)dec regName:(BlueSTSDKWeSURegisterName_e)regName target:(BlueSTSDKRegisterTarget_e)target autosync:(BOOL)autosync;
-(BOOL) writeSingleRegFromHex:(NSString *)hex regName:(BlueSTSDKWeSURegisterName_e)regName target:(BlueSTSDKRegisterTarget_e)target autosync:(BOOL)autosync;
-(BOOL) writeLocalName:(NSString *)name;
-(BOOL) writePubblicAddress:(NSString *)address;
-(BOOL) writeRTCDateTime:(NSString *)time;

-(BOOL) writeLedConfig:(NSString *)value target:(BlueSTSDKRegisterTarget_e)target;
-(BOOL) writeTimerFrequency:(NSString *)value target:(BlueSTSDKRegisterTarget_e)target;
-(BOOL) writePowerMode:(NSString *)value target:(BlueSTSDKRegisterTarget_e)target;
-(BOOL) writeMapGroup:(NSString *)value regName:(BlueSTSDKWeSURegisterName_e)regName target:(BlueSTSDKRegisterTarget_e)target;
-(BOOL) writeBLEOutputPower:(NSString *)value;
-(BOOL) writeDFUReboot:(NSString *)value;
-(BOOL) writePowerOff:(NSString *)value;

//debug console actions
-(BOOL) writeText:(NSString *) text;
-(BOOL) sendBlinkMe;
@end
