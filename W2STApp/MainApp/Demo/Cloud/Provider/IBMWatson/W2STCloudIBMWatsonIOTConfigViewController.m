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

#import "W2STCloudIBMWatsonIOTConfigViewController.h"
#import "W2STIBMWatsonIOTConnectionFactory.h"

#define ORGANIZATION_KEY @"W2STCloudBlueMxConfigViewController_organization"
#define AUTH_KEY @"W2STCloudBlueMxConfigViewController_auth"
#define DEVICE_ID_KEY @"W2STCloudBlueMxConfigViewController_deviceId"
#define DEVICE_TYPE_KEY @"W2STCloudBlueMxConfigViewController_device_type"


@interface W2STCloudIBMWatsonIOTConfigViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *mDetailsView;
    @property (weak, nonatomic) IBOutlet UITextField *mOrganization;
    @property (weak, nonatomic) IBOutlet UITextField *mAuthTocken;
    @property (weak, nonatomic) IBOutlet UITextField *mDeviceType;
    @property (weak, nonatomic) IBOutlet UITextField *mDeviceId;
@property (weak, nonatomic) IBOutlet UIButton *mShowDetailsButton;

@end

@implementation W2STCloudIBMWatsonIOTConfigViewController
- (IBAction)onDetailsButtonPressed:(UIButton *)sender {
    _mDetailsView.hidden=!_mDetailsView.hidden;
}

-(void)storeSettings{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:_mOrganization.text forKey:ORGANIZATION_KEY];
    [userDefaults setObject:_mAuthTocken.text forKey:AUTH_KEY];
    [userDefaults setObject:_mDeviceType.text forKey:DEVICE_TYPE_KEY];
    [userDefaults setObject:_mDeviceId.text forKey:DEVICE_ID_KEY];
    [userDefaults synchronize];
}

-(void)loadSettings{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    _mOrganization.text = [userDefaults stringForKey:ORGANIZATION_KEY];
    _mAuthTocken.text = [userDefaults stringForKey:AUTH_KEY];
    _mDeviceId.text = [userDefaults stringForKey:DEVICE_ID_KEY];
    _mDeviceType.text = [userDefaults stringForKey:DEVICE_TYPE_KEY];
    
}

-(void)setTextFieldDelegate{
    _mOrganization.delegate=self;
    _mAuthTocken.delegate=self;
    _mDeviceType.delegate=self;
    _mDeviceId.delegate=self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self loadSettings];
    [self setTextFieldDelegate];
    if(_mDeviceId.text==nil || _mDeviceId.text.length==0){
        _mDeviceId.text = [W2STCloudConfigViewController getDeviceIdForNode:self.node];
    }
    
    if(_mDeviceType.text==nil || _mDeviceType.text.length==0){
        _mDeviceType.text = [W2STCloudConfigViewController getDeviceType:self.node.type];
    }
    
}

-(void)showDetailsButton{
    _mShowDetailsButton.hidden=false;
    _mDetailsView.hidden=true;
}

-(nullable id<W2STMQTTConnectionFactory>) buildConnectionFactory{
    if( _mOrganization.text.length==0  ||
       _mDeviceType.text.length==0  ||
       _mDeviceId.text.length==0  ||
       _mAuthTocken.text.length==0){
        return nil;
    }
    [self storeSettings];
    [self showDetailsButton];
    return [W2STIBMWatsonIOTConnectionFactory createWithOrganization:_mOrganization.text
                                                    deviceType:_mDeviceType.text
                                                      deviceId:_mDeviceId.text
                                                    authTocken:_mAuthTocken.text];
}

//hide keyboard when the user press return
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
