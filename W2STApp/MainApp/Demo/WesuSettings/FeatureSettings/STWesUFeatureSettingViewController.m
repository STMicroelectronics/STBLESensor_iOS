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

#import "STWesUFeatureSettingViewController.h"
#import "STWeSUFeatureSettingDialogViewController.h"

#import <BlueSTSDK/BlueSTSDKWeSURegisterDefines.h>

@interface FeatureSettingsData : NSObject
@property NSString* name;
@property BlueSTSDKWeSURegisterName_e registerToRead;
@property BlueSTSDKWeSUFeatureConfig *config;

+(instancetype)createWithName:(NSString *)name reg:(BlueSTSDKWeSURegisterName_e)reg;

@end

@implementation FeatureSettingsData

+(instancetype)createWithName:(NSString *)name reg:(BlueSTSDKWeSURegisterName_e)reg{
    FeatureSettingsData *temp = [[FeatureSettingsData alloc]init];
    
    temp.name=name;
    temp.registerToRead=reg;
    temp.config=nil;
    return temp;
}

@end


@interface STWesUFeatureSettingViewController () <UITableViewDataSource,
    UITableViewDelegate, BlueSTSDKConfigControlDelegate,STWeSUFeatureSettingDialogDelegate>

@end

@implementation STWesUFeatureSettingViewController{
    NSArray<FeatureSettingsData*> *mRegisters;
    __weak IBOutlet UIView *mEditDialog;
    STWeSUFeatureSettingDialogViewController *mEditController;
    __weak IBOutlet UITableView *mFeatureTable;
    FeatureSettingsData *mEditingData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    mRegisters = @[
                   [FeatureSettingsData createWithName:@"Accelerometer, Gyroscope, Magnetometer"
                                                   reg:BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0080],
                   [FeatureSettingsData createWithName:@"Pressure"
                                                   reg:BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0010],
                   [FeatureSettingsData createWithName:@"Temperature"
                                                   reg:BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0004],
                   [FeatureSettingsData createWithName:@"Battery"
                                                   reg:BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURE_CTRLS_0002],
                   [FeatureSettingsData createWithName:@"Motion FX"
                                                   reg:BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0100],
                   [FeatureSettingsData createWithName:@"FreeFall (deprecated)"
                                                   reg:BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0200],
                   [FeatureSettingsData createWithName:@"Accelerometer Events"
                                                   reg:BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0400],
                   [FeatureSettingsData createWithName:@"Activity Recognition"
                                                   reg:BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0010],
                   [FeatureSettingsData createWithName:@"Carry Position"
                                                   reg:BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURE_CTRLS_0008],
                   ];
        mFeatureTable.dataSource=self;
        mFeatureTable.delegate=self;    
    }

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_configControl addConfigDelegate:self];
    [self readRegister];
    mEditingData=nil;
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_configControl removeConfigDelegate:self];
}

-(void)readRegister{
    BlueSTSDKRegisterTarget_e target = _sessionRegister ?
        BlueSTSDK_REGISTER_TARGET_SESSION : BlueSTSDK_REGISTER_TARGET_PERSISTENT;
    for (FeatureSettingsData *feature in mRegisters){
        BlueSTSDKRegister *reg = [BlueSTSDKWeSURegisterDefines lookUpWithRegisterName:feature.registerToRead];
        BlueSTSDKCommand *cmd = [BlueSTSDKCommand commandWithRegister:reg target:target];
        [_configControl read:cmd];
    }    
}

-(void)updateRegister:(FeatureSettingsData*)newData{
    BlueSTSDKRegisterTarget_e target = _sessionRegister ?
    BlueSTSDK_REGISTER_TARGET_SESSION : BlueSTSDK_REGISTER_TARGET_PERSISTENT;
    BlueSTSDKRegister *reg = [BlueSTSDKWeSURegisterDefines lookUpWithRegisterName:newData.registerToRead];
    BlueSTSDKCommand *cmd = [BlueSTSDKCommand commandWithRegister:reg target:target];
    [BlueSTSDKWeSURegisterDefines encodeFeaturConfing:newData.config forCommand:cmd];
    [_configControl write:cmd];
}

-(FeatureSettingsData*) getSettingsForRegister:(BlueSTSDKRegister*)reg{
    BlueSTSDKWeSURegisterName_e registerName =
        [BlueSTSDKWeSURegisterDefines lookUpRegisterNameWithAddress:reg.address target:reg.target];
    for(FeatureSettingsData *data in mRegisters){
        if(data.registerToRead==registerName)
            return data;
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return mRegisters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"featureSettingsCell" forIndexPath:indexPath];
    
    FeatureSettingsData *conf = mRegisters[indexPath.row];
    
    cell.textLabel.text = conf.name;
    cell.detailTextLabel.text=@"";
    if(conf.config!=nil){
        cell.detailTextLabel.text=[conf.config description];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    mEditingData = mRegisters[indexPath.row];
    [mEditController displayWithConfig:mEditingData.config];
    mEditDialog.hidden=false;

}

#pragma mark - BlueSTSDKConfigControlDelegate
-(void) configControl:(BlueSTSDKConfigControl *) configControl
didRegisterReadResult:(BlueSTSDKCommand *)cmd
                error:(NSInteger)error {
    if (cmd == nil || cmd.registerField == nil)
        return;
    
    FeatureSettingsData *data = [self getSettingsForRegister:cmd.registerField];
    
    data.config = [BlueSTSDKWeSURegisterDefines extractFeatureConfig:cmd];
    
    dispatch_async(dispatch_get_main_queue(),^{
        [mFeatureTable reloadData];
    });
}

-(void) configControl:(BlueSTSDKConfigControl *) configControl
didRegisterWriteResult:(BlueSTSDKCommand *)cmd error:(NSInteger)error {    }

-(void) configControl:(BlueSTSDKConfigControl *)configControl
     didRequestResult:(BlueSTSDKCommand *)cmd success:(bool)success {
    
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.destinationViewController isKindOfClass:STWeSUFeatureSettingDialogViewController.class]){
        mEditController = (STWeSUFeatureSettingDialogViewController *)segue.destinationViewController;
        mEditController.delegate=self;
    }
}

#pragma mark - STWeSUFeatureSettingDialogDelegate
-(void)onCancel{
    mEditDialog.hidden=true;
    mEditingData=nil;
}

-(void)onSelectedWithConfig:(BlueSTSDKWeSUFeatureConfig *)config{
    mEditDialog.hidden=true;
    mEditingData.config=config;
    [self updateRegister:mEditingData];
    mEditingData=nil;

    dispatch_async(dispatch_get_main_queue(),^{
        [mFeatureTable reloadData];
    });
    
    
}

@end
