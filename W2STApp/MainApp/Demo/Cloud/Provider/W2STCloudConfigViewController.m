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

#import "W2STCloudConfigViewController.h"
#include "W2STCloudConnectionViewController.h"

@interface W2STCloudConfigViewController ()

@end

@implementation W2STCloudConfigViewController

+(NSString*) getDeviceIdForNode:(BlueSTSDKNode*)node{
    NSString *temp = [node friendlyName];
    temp = [temp stringByReplacingOccurrencesOfString:@" " withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"@" withString:@"_"];
    return temp;
}

+(NSString*) getDeviceType:(BlueSTSDKNodeType)type{
    
    switch (type) {
        case BlueSTSDKNodeTypeNucleo:
            return @"NUCLEO";
        case BlueSTSDKNodeTypeSensor_Tile:
            return @"SENSOR_TILE";
        case BlueSTSDKNodeTypeBlue_Coin:
            return @"BLUE_COIN";
        case BlueSTSDKNodeTypeSTEVAL_WESU1:
            return @"STEVAL_WESU1";
        case BlueSTSDKNodeTypeGeneric:
        default:
            return @"GENERIC";
    }
    
}

/**
 * hide the keyboard when the user touch something outside the UITextField
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    if (![[touch view] isKindOfClass:[UITextField class]]) {
        [self.view endEditing:YES];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.destinationViewController isKindOfClass:W2STCloudConnectionViewController.class]){
        W2STCloudConnectionViewController *temp = (W2STCloudConnectionViewController *)segue.destinationViewController;
        temp.node=self.node;
        temp.connectionFactoryBuilder=self;
    }
    
}

-(nullable id<W2STMQTTConnectionFactory>) buildConnectionFactory{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must overwrite %@ in a subclass]",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}


@end
