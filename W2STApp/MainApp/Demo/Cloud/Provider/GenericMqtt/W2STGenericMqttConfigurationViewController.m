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

#import "W2STGenericMqttConfigurationViewController.h"
#import "W2STGenricMqttConnectionFactory.h"


#define BROCKER_KEY @"W2STGenericMqttConfigurationViewController_brocker"
#define PORT_KEY @"W2STGenericMqttConfigurationViewController_port"
#define USER_KEY @"W2STGenericMqttConfigurationViewController_user"
#define USE_TLS_KEY @"W2STGenericMqttConfigurationViewController_useTls"
#define CLIENT_ID_KEY @"W2STGenericMqttConfigurationViewController_clientId"

@interface W2STGenericMqttConfigurationViewController () <UITextFieldDelegate>

@end

@implementation W2STGenericMqttConfigurationViewController{
    __weak IBOutlet UIButton *mShowDetailsButton;
    __weak IBOutlet UITextField *mBrokerText;
    __weak IBOutlet UITextField *mPortText;
    
    __weak IBOutlet UITextField *mUserText;
    __weak IBOutlet UITextField *mPasswordText;
    __weak IBOutlet UITextField *mClientText;
    __weak IBOutlet UISwitch *mTlsSwtich;
    __weak IBOutlet UIView *mDetailsView;
}

- (IBAction)onDetailsButtonCliecked:(UIButton *)sender {
    mDetailsView.hidden=!mDetailsView.hidden;
}

-(void)storeSettings{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:mBrokerText.text forKey:BROCKER_KEY];
    [userDefaults setObject:mPortText.text forKey:PORT_KEY];
    [userDefaults setObject:mUserText.text forKey:USER_KEY];
    [userDefaults setObject:mClientText.text forKey:CLIENT_ID_KEY];
    [userDefaults setObject:@(mTlsSwtich.on) forKey:USE_TLS_KEY];
    [userDefaults synchronize];
}

-(void)loadSettings{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    mBrokerText.text = [userDefaults stringForKey:BROCKER_KEY];
    mPortText.text = [userDefaults stringForKey:PORT_KEY];
    mUserText.text = [userDefaults stringForKey:USER_KEY];
    mClientText.text = [userDefaults stringForKey:CLIENT_ID_KEY];
    mTlsSwtich.on = [((NSNumber*)([userDefaults objectForKey:USE_TLS_KEY]))boolValue];
    
}

-(void)setTextFieldDelegate{
    mBrokerText.delegate=self;
    mPortText.delegate=self;
    mUserText.delegate=self;
    mPasswordText.delegate=self;
    mClientText.delegate=self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadSettings];
    [self setTextFieldDelegate];
   
    if(mClientText.text==nil || mClientText.text.length==0){
        mClientText.text = [W2STCloudConfigViewController getDeviceIdForNode:self.node];
    }
    
}

-(void)showDetailsButton{
    mShowDetailsButton.hidden=false;
    mDetailsView.hidden=true;
}

-(nullable id<W2STMQTTConnectionFactory>) buildConnectionFactory{
    if( mBrokerText.text.length==0  ||
       mPortText.text.length==0 ){
        return nil;
    }
    [self storeSettings];
    [self showDetailsButton];
    return [W2STGenricMqttConnectionFactory createWithBorcker:mBrokerText.text
                                                         port:mPortText.text
                                                       useTls:mTlsSwtich.on
                                                         user:mUserText.text
                                                     password:mPasswordText.text
                                                     clientId:mClientText.text];
}

//hide keyboard when the user press return
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
