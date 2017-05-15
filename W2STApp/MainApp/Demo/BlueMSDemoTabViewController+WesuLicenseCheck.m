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


#import <BlueSTSDK_Gui/MBProgressHUD.h>

#import "BlueMSDemoTabViewController+WesuLicenseCheck.h"
#import <BlueSTSDK/BlueSTSDKConfigControl.h>

#define START_MESSAGE_DISPLAY_TIME 2.0f

@interface LiceseStatusDelegate : NSObject<BlueSTSDKConfigControlDelegate>

+(instancetype)delegateWithRegisterAddress:(NSInteger)adr
                                   message:(NSString*)mesasge showOn:(UIView*)view;

@end

@implementation LiceseStatusDelegate{
    NSInteger mRegisterAddress;
    NSString *mMessage;
    UIView *mRootView;
}

+(instancetype)delegateWithRegisterAddress:(NSInteger)adr
                                   message:(NSString*)mesasge showOn:(UIView*)view{
    return [[LiceseStatusDelegate alloc]initWithRegisterAddress:adr message:mesasge
                                                         showOn:view];
}


-(instancetype)initWithRegisterAddress:(NSInteger)adr
                               message:(NSString*)mesasge
                                showOn:(UIView*)view{
    self = [super init];
    mRegisterAddress=adr;
    mMessage=mesasge;
    mRootView=view;
    return self;
}

+(void)displayMessage:(NSString*)msg showOn:(UIView*)view{
    MBProgressHUD *message = [MBProgressHUD showHUDAddedTo:view animated:YES];
    message.mode = MBProgressHUDModeText;
    message.removeFromSuperViewOnHide = YES;
    message.labelText = msg;
    [message hide:true afterDelay:START_MESSAGE_DISPLAY_TIME];
}

-(void) configControl:(BlueSTSDKConfigControl *)configControl
didRegisterReadResult:(BlueSTSDKCommand *)cmd
                error:(NSInteger)error{
    
    if(cmd.registerField.address!=mRegisterAddress)
        return;
    
    uint8_t regValue;
    [cmd.data getBytes:&regValue length:1];
    
    if(regValue==0){
        dispatch_async(dispatch_get_main_queue(), ^{
            [LiceseStatusDelegate displayMessage:mMessage showOn:mRootView];
        });
    }
    
    [configControl removeConfigDelegate:self];
    
    
}

-(void) configControl:(BlueSTSDKConfigControl *)configControl
didRegisterWriteResult:(BlueSTSDKCommand *)cmd
                error:(NSInteger)error{
    
}

-(void) configControl:(BlueSTSDKConfigControl *)configControl
     didRequestResult:(BlueSTSDKCommand *)cmd
              success:(bool)success{
}

@end

@implementation BlueMSDemoTabViewController (WesuLicenseCheck)


    -(void)checkLicenseFromRegister:(BlueSTSDKWeSURegisterName_e)regLic
errorString:(NSString*)errorString{
    if(self.node.type!=BlueSTSDKNodeTypeSTEVAL_WESU1)
        return;
    BlueSTSDKConfigControl *control = self.node.configControl;
    if(control==nil)
        return;
    //else

    
    BlueSTSDKRegister *licRegister =[BlueSTSDKWeSURegisterDefines lookUpWithRegisterName:regLic];

    LiceseStatusDelegate *delegate = [LiceseStatusDelegate delegateWithRegisterAddress:licRegister.address
                                      message:errorString showOn:self.view];
    
    [control addConfigDelegate:delegate];
        
    BlueSTSDKCommand *readLicStatus = [BlueSTSDKCommand commandWithRegister: licRegister
                                                                     target:BlueSTSDK_REGISTER_TARGET_SESSION];
    [control read:readLicStatus];
}

@end
