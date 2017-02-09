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

#import "STWeSUNodeExtension.h"

@implementation STWeSUNodeExtension

//+(instancetype)sharedInstance {
//    static STWeSUNodeExtension *this = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        this = [[self alloc] init];
//    });
//    return this;
//}

+(instancetype)nodeExtWithNode:(BlueSTSDKNode *)node {
    return [[self alloc] initWithNode:node];
}

-(instancetype)initWithNode:(BlueSTSDKNode *)node {
    self = [self init];
    assert(node);
    _node = node;
    return node ? self : nil;
}
-(instancetype)init {
    self = [super init];
    
    _ledConfig = @{
                   LED_INTMNG : @"Internally managed",
                   LED_ON     : @"User On",
                   LED_OFF    : @"User Off",
                   };
    _ledConfigOrderedKeys = @[@"00",@"11",@"12"];
    
    _powerMode = @{
                   @"00" : @"Full run",
                   @"01" : @"Low power run",
                   @"10" : @"Low power",
                   };
    _powerModeOrderedKeys = @[@"00",@"01",@"10"];
    
    _featureMapGroupA = @{
                          //group A
                          @"0080" : @"Accelerometer",
                          @"0040" : @"Gyroscope",
                          @"0020" : @"Magnetometer",
                          @"0010" : @"Pressure",
                          @"0004" : @"Temperature",
                          @"0002" : @"Battery",
                          };
    _featureMapGroupAOrderedKeys = @[@"0080",@"0040",@"0020",@"0010",@"0004",@"0002"];
    _featureMapGroupB = @{
                          //group B
                          @"0001" : @"Pedometer",
                          @"0080" : @"Sensor Fusion AHRS Mems",
                          @"0200" : @"FreeFall",
                          @"0010" : @"Activity Recognition",
                          @"0008" : @"Carry Position",
                          };
    _featureMapGroupBOrderedKeys = @[@"0001",@"0080",@"0200",@"0010",@"0008"];
    _bleOutputPowerMap = @{
                           @"090F" : @"+8 dBm (HP)",
                           @"090E" : @"+5 dBm (HP)",
                           @"090D" : @"+1 dBm (HP)",
                           @"090C" : @"-2 dBm (HP)",
                           @"090B" : @"-5 dBm (HP)",
                           @"090A" : @"-8 dBm (HP)",
                           @"0909" : @"-12 dBm (HP)",
                           @"0908" : @"-15 dBm (HP)",
                           @"080F" : @"+5 dBm",
                           @"080E" : @"+2 dBm",
                           @"080D" : @"-2 dBm",
                           @"080C" : @"-5 dBm",
                           @"080B" : @"-8 dBm",
                           @"080A" : @"-11 dBm",
                           @"0809" : @"-15 dBm",
                           @"0808" : @"-18 dBm",
                           };
    _bleOutputPowerMapOrderedKeys = @[@"090F",@"090E",@"090D",@"090C",@"090B",@"090A",@"0909",@"0908",@"080F",@"080E",@"080D",@"080C",@"080B",@"080A",@"0809",@"0808"];
    
    _rtcTimer = @{
                  RTC_TIMER_INVALID          : @"Invalid",
                  RTC_TIMER_DEFAULT          : @"Default",
                  RTC_TIMER_DEFAULT_RUNNING  : @"Default Running",
                  RTC_TIMER_RESTORED         : @"Restored",
                  RTC_TIMER_RESTORED_RUNNING : @"Restored Running",
                  RTC_TIMER_USER             : @"User",
                  RTC_TIMER_USER_RUNNING     : @"User Running",
                  RTC_TIMER_FORCED           : @"Forced",
                  };
    _rtcTimerOrderedKeys = @[
                             RTC_TIMER_INVALID,
                             RTC_TIMER_DEFAULT,
                             RTC_TIMER_DEFAULT_RUNNING,
                             RTC_TIMER_RESTORED,
                             RTC_TIMER_RESTORED_RUNNING,
                             RTC_TIMER_USER,
                             RTC_TIMER_USER_RUNNING,
                             RTC_TIMER_FORCED,
                             ];
    
    _dfuReboot = @{
                   DFU_REBOOT_APPL      : @"Application Mode",
                   DFU_REBOOT_USBDFU    : @"USB DFU",
                   DFU_REBOOT_OTABLEDFU : @"OTA BLE DFU",
                   };
    _dfuRebootOrderedKeys = @[DFU_REBOOT_APPL, DFU_REBOOT_USBDFU, DFU_REBOOT_OTABLEDFU];
    
    _powerOff = @{
                  PWR_OFF_STANDBY_BLE  : @"Stand-by (BLE)",
                  PWR_OFF_STANDBY      : @"Stand-by",
                  PWR_OFF_REBOOT       : @"Reboot",
                  PWR_OFF_REBOOT_DEF   : @"Reboot with defaults",
                  PWR_OFF_SHUTDOWN     : @"Shutdown",
                  };
    _powerOffOrderedKeys = @[PWR_OFF_STANDBY_BLE, PWR_OFF_STANDBY, PWR_OFF_REBOOT, PWR_OFF_REBOOT_DEF, PWR_OFF_SHUTDOWN];
    
    return self;
}

#pragma mark -- Read
-(void)asyncReadWithReg:(BlueSTSDKRegister *)reg target:(BlueSTSDKRegisterTarget_e)target {
    if (self.node.isConnected && self.node.configControl && reg) {
        BlueSTSDKCommand *cmd = nil;
        if (target == BlueSTSDK_REGISTER_TARGET_BOTH) {
            cmd = [BlueSTSDKCommand commandWithRegister:reg target:BlueSTSDK_REGISTER_TARGET_PERSISTENT];
            [self.node.configControl read:cmd];
            cmd = [BlueSTSDKCommand commandWithRegister:reg target:BlueSTSDK_REGISTER_TARGET_SESSION];
            [self.node.configControl read:cmd];
        }
        else {
            cmd = [BlueSTSDKCommand commandWithRegister:reg target:target];
            [self.node.configControl read:cmd];
        }
    }
}
-(void)asyncReadWithRegName:(BlueSTSDKWeSURegisterName_e)regName target:(BlueSTSDKRegisterTarget_e)target {
    if (regName != BlueSTSDK_REGISTER_NAME_NONE) {
        BlueSTSDKRegister *reg = [BlueSTSDKWeSURegisterDefines lookUpWithRegisterName:regName];
        [self asyncReadWithReg:reg target:target];
    }
}

#pragma mark -- Write
-(BOOL) writeSingleReg:(NSInteger)value regName:(BlueSTSDKWeSURegisterName_e)regName target:(BlueSTSDKRegisterTarget_e)target autosync:(BOOL)autosync {
    BOOL ret = NO;
    BlueSTSDKRegister *reg = [BlueSTSDKWeSURegisterDefines lookUpWithRegisterName:regName];
    if (self.node.isConnected && self.node.configControl && reg) {
        
        if ((reg.access & BlueSTSDK_REGISTER_ACCESS_W) > 0) {
            size_t s = reg.size * 2;
            unsigned char buffer[s];
            buffer[0] = (unsigned char)(value & 0xFF);
            buffer[1] = (unsigned char)((value>>8) & 0xFF);
            NSData* data = [NSData dataWithBytes:buffer length:s];
            BlueSTSDKCommand* cmd = [BlueSTSDKCommand commandWithRegister:reg target:target data:data];
            
            [self.node.configControl write:cmd];
            NSLog(@"Writing register -- address: 0x%02X target %@ value: 0x%02X%02X for: %@", (int)reg.address,
                  (cmd.target == BlueSTSDK_REGISTER_TARGET_PERSISTENT ? @"P" : @"S"),
                  buffer[1],
                  buffer[0],  self.node.friendlyName);
            
            if (autosync) {
                if (target == BlueSTSDK_REGISTER_TARGET_PERSISTENT && reg.target == BlueSTSDK_REGISTER_TARGET_BOTH) {
                    [self asyncReadWithReg:reg target:BlueSTSDK_REGISTER_TARGET_SESSION];
                }
            }
            ret = YES;
        }
        else {
            NSLog(@"Writing register -- Error: try to write a readonly register, address 0x%02lX for: %@",
                  (long)reg.address, self.node.friendlyName);
        }
    }
    return ret;
}
-(BOOL) writeSingleRegFromDec:(NSString *)dec regName:(BlueSTSDKWeSURegisterName_e)regName target:(BlueSTSDKRegisterTarget_e)target  autosync:(BOOL)autosync {
    int value = 0x00;
    NSScanner *scanner = [NSScanner scannerWithString:dec];
    [scanner scanInt: &value];
    return [self writeSingleReg:value regName:regName target:target autosync:autosync];
}
-(BOOL) writeSingleRegFromHex:(NSString *)hex regName:(BlueSTSDKWeSURegisterName_e)regName target:(BlueSTSDKRegisterTarget_e)target  autosync:(BOOL)autosync {
    unsigned int value = 0x00;
    NSScanner *scanner = [NSScanner scannerWithString:hex];
    [scanner scanHexInt: &value];
    return [self writeSingleReg:value regName:regName target:target autosync:autosync];
}
-(BOOL) writeLocalName:(NSString *)name {
    BOOL ret = NO;
    if (self.node.isConnected && self.node.configControl) {
        BlueSTSDKRegister *reg = [BlueSTSDKWeSURegisterDefines lookUpWithRegisterName:BlueSTSDK_REGISTER_NAME_BLE_LOC_NAME];
        size_t s = reg.size * 2;
        unsigned char buffer[s];
        memset(buffer, 0x00, s);
        buffer[0] = 0x09;
        
        NSData* dataname = [name dataUsingEncoding:NSUTF8StringEncoding];
        //max localname is 5 chars
        [dataname getBytes:(void *)(buffer+1) length:MIN(LOCALNAME_MAX, dataname.length)];
        
        
        NSData* data = [NSData dataWithBytes:buffer length:s];
        BlueSTSDKCommand* cmd = [BlueSTSDKCommand commandWithRegister:reg target:BlueSTSDK_REGISTER_TARGET_PERSISTENT data:data];
        [self.node.configControl write:cmd];
        
        //update the board name
        //self.node.name = name;
        //[self.node friendlyName:YES];
        [self asyncReadWithReg:reg target:BlueSTSDK_REGISTER_TARGET_PERSISTENT];
        ret = YES;
    }
    return ret;
}
-(BOOL) writePubblicAddress:(NSString *)address {
    BOOL ret = NO;
    if (self.node.isConnected && self.node.configControl) {
        BlueSTSDKRegister *reg = [BlueSTSDKWeSURegisterDefines lookUpWithRegisterName:BlueSTSDK_REGISTER_NAME_BLE_PUB_ADDR];
        size_t s = reg.size * 2;
        unsigned char buffer[s];
        unsigned int value = 0;
        NSScanner *scanner = nil;
        memset(buffer, 0x00, s);
        
        NSString *regex = @"[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]";
        NSString *lowerstr = [address lowercaseString];
        
        NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
        BOOL result = [regExPredicate evaluateWithObject: lowerstr];
        
        if (result) {
            NSArray *strarray = [address componentsSeparatedByString: @":"];
            int  i = 5;
            
            for(NSString *strvalue in strarray) {
                scanner = [NSScanner scannerWithString:strvalue];
                [scanner scanHexInt:&value];
                buffer[i--] = (unsigned char)value;
            }
            
            NSData* data = [NSData dataWithBytes:buffer length:s];
            BlueSTSDKCommand* cmd = [BlueSTSDKCommand commandWithRegister:reg target:BlueSTSDK_REGISTER_TARGET_PERSISTENT data:data];
            
            [self.node.configControl write:cmd];
            //self.node.address = address;
            //[self.node friendlyName:YES];
            ret = YES;
        }
    }
    return ret;
}
//receive in the format DD/MM/YY HH:MM:SS WD
-(BOOL) writeRTCDateTime:(NSString *)time {
    BOOL ret = NO;
    if (self.node.isConnected && self.node.configControl) {
        BlueSTSDKRegister *reg = [BlueSTSDKWeSURegisterDefines lookUpWithRegisterName:BlueSTSDK_REGISTER_NAME_RTC_DATE_TIME];
        size_t s = reg.size * 2;
        assert(s >= 8);
        unsigned char buffer[s];
        NSInteger value = 0;
        memset(buffer, 0x00, s);
        
        
        if (!time || time.length < 19) {
            //if a not valid string init auto
            NSDate *now = [NSDate date];
            NSCalendar *gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *componentsDate = [gregorian components:(NSCalendarUnitYear |
                                                                      NSCalendarUnitMonth |
                                                                      NSCalendarUnitDay |
                                                                      NSCalendarUnitHour |
                                                                      NSCalendarUnitMinute |
                                                                      NSCalendarUnitSecond |
                                                                      NSCalendarUnitWeekday) fromDate:now];
            
            buffer[0] = value = [componentsDate hour]; //hour - 24h
            buffer[1] = value = [componentsDate minute]; //minute
            buffer[2] = value = [componentsDate second]; //second
            buffer[3] = value = [componentsDate day]; //day of month 1..31
            buffer[4] = value = [componentsDate month]; //month 1..12
            buffer[5] = value = [componentsDate year] % 100; //year YY
            buffer[6] = value = [componentsDate weekday]; //day of week, 1=sun, 2=mon ... 7=sat
            buffer[6] = value = (buffer[6] == 1 ? 7 : buffer[6] - 1); //1=mon .. 7=sun
            
        }
        else {
            NSString *dd = @"";
            NSString *MM = @"";
            NSString *yy = @"";
            NSString *hh = @"";
            NSString *mm = @"";
            NSString *ss = @"";
            NSString *wd = @"";
            dd = [time substringWithRange:NSMakeRange(0, 2)];
            MM = [time substringWithRange:NSMakeRange(3, 2)];
            yy = [time substringWithRange:NSMakeRange(6, 2)];
            hh = [time substringWithRange:NSMakeRange(9, 2)];
            mm = [time substringWithRange:NSMakeRange(12, 2)];
            ss = [time substringWithRange:NSMakeRange(15, 2)];
            
            buffer[0] = [hh intValue]; //hour - 24h
            buffer[1] = [mm intValue]; //minute
            buffer[2] = [ss intValue]; //second
            buffer[3] = [dd intValue]; //day of month 1..31
            buffer[4] = [MM intValue]; //month 1..12
            buffer[5] = [yy intValue]; //year YY
            buffer[6] = [wd intValue]; //1=mon .. 7=sun
        }
        buffer[7] = 0xB3; //Timer forced
        
        if ((buffer[0] >= 0 && buffer[0] < 24) && (buffer[1] >= 0 && buffer[1] < 60) &&
           (buffer[2] >= 0 && buffer[2] < 60) && (buffer[3] >= 1 && buffer[3] <= 31) &&
           (buffer[4] >= 1 && buffer[4] <= 12) && (buffer[5] >= 0 && buffer[5] < 100))
        {
            //a simple check of the date
            NSData* data = [NSData dataWithBytes:buffer length:s];
            BlueSTSDKCommand* cmd = [BlueSTSDKCommand commandWithRegister:reg target:BlueSTSDK_REGISTER_TARGET_SESSION data:data];
            
            [self.node.configControl write:cmd];
            [self asyncReadWithReg:reg target:BlueSTSDK_REGISTER_TARGET_SESSION];
            ret = YES;
        }
    }
    return ret;
}
#pragma mark - Simple action (one register)
-(BOOL) writeLedConfig:(NSString *)value target:(BlueSTSDKRegisterTarget_e)target {
    BOOL ret = NO;
    //the write is done session or persistent
    BlueSTSDKRegisterTarget_e loctarget = target == BlueSTSDK_REGISTER_TARGET_SESSION ? BlueSTSDK_REGISTER_TARGET_SESSION : BlueSTSDK_REGISTER_TARGET_PERSISTENT;
    if ([self.ledConfigOrderedKeys containsObject:value]) {
        ret = [self writeSingleRegFromHex:value regName:BlueSTSDK_REGISTER_NAME_LED_CONFIG target:loctarget autosync:YES];
    }
    return ret;
}
-(BOOL) writeTimerFrequency:(NSString *)value target:(BlueSTSDKRegisterTarget_e)target {
    BOOL ret = NO;
    //the write is done session or persistent
    BlueSTSDKRegisterTarget_e loctarget = target == BlueSTSDK_REGISTER_TARGET_SESSION ? BlueSTSDK_REGISTER_TARGET_SESSION : BlueSTSDK_REGISTER_TARGET_PERSISTENT;
    ret = [self writeSingleRegFromDec:value regName:BlueSTSDK_REGISTER_NAME_TIMER_FREQ target:loctarget autosync:YES];
    return ret;
}
-(BOOL) writePowerMode:(NSString *)value target:(BlueSTSDKRegisterTarget_e)target {
    BOOL ret = NO;
    BlueSTSDKRegisterTarget_e loctarget = target == BlueSTSDK_REGISTER_TARGET_SESSION ? BlueSTSDK_REGISTER_TARGET_SESSION : BlueSTSDK_REGISTER_TARGET_PERSISTENT;
    if ([self.powerModeOrderedKeys containsObject:value]) {
        ret = [self writeSingleRegFromHex:value regName:BlueSTSDK_REGISTER_NAME_PWR_MODE_CONFIG target:loctarget autosync:YES];
    }
    return ret;
}
-(BOOL) writeMapGroup:(NSString *)value regName:(BlueSTSDKWeSURegisterName_e)regName target:(BlueSTSDKRegisterTarget_e)target {
    BOOL ret = NO;
    BlueSTSDKRegisterTarget_e loctarget = target == BlueSTSDK_REGISTER_TARGET_SESSION ? BlueSTSDK_REGISTER_TARGET_SESSION : BlueSTSDK_REGISTER_TARGET_PERSISTENT;
    if (regName != BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURES_MAP || regName != BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURES_MAP) {
        ret = [self writeSingleRegFromHex:value regName:regName target:loctarget autosync:YES];
    }
    return ret;
}
-(BOOL) writeBLEOutputPower:(NSString *)value {
    BOOL ret = NO;
    if ([self.bleOutputPowerMapOrderedKeys containsObject:value]) {
        ret = [self writeSingleRegFromHex:value regName:BlueSTSDK_REGISTER_NAME_RADIO_TXPWR_CONFIG target:BlueSTSDK_REGISTER_TARGET_PERSISTENT autosync:YES];
    }
    return ret;
}
-(BOOL) writeDFUReboot:(NSString *)value {
    BOOL ret = NO;
    if ([self.dfuRebootOrderedKeys containsObject:value]) {
        ret = [self writeSingleRegFromHex:value regName:BlueSTSDK_REGISTER_NAME_DFU_REBOOT target:BlueSTSDK_REGISTER_TARGET_SESSION autosync:YES];
    }
    return ret;
}
-(BOOL) writePowerOff:(NSString *)value {
    BOOL ret = NO;
    if ([self.powerOffOrderedKeys containsObject:value]) {
        ret = [self writeSingleRegFromHex:value regName:BlueSTSDK_REGISTER_NAME_POWER_OFF target:BlueSTSDK_REGISTER_TARGET_SESSION autosync:YES];
    }
    return ret;
}
#pragma mark - Debug console based commands
-(BOOL) writeText:(NSString *) text {
    BOOL ret = NO;
    if (self.node && self.node.isConnected && self.node.debugConsole) {
        NSInteger n = [self.node.debugConsole writeMessage:text];
        ret = n > 0;
    }
    return ret;
}

-(BOOL) sendBlinkMe {
    return [self writeText:@"!blinkme\n"];
}
@end
