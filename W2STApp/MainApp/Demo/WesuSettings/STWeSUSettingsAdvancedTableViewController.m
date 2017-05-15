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

#import "STWeSUSettingsAdvancedTableViewController.h"
#import "STWeSUSettingsItem.h"
#import "STWeSUTools.h"
#import "STWeSUNodeExtension.h"
#import "BlueSTSDK/BlueSTSDK.h"

@interface STWeSUSettingsAdvancedTableViewController ()
@property (retain, readonly) STWeSUNodeExtension *nodeExt;
@end

@implementation STWeSUSettingsAdvancedTableViewController {
    NSArray *mSettings;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _nodeExt = [STWeSUNodeExtension nodeExtWithNode:self.node];
    
    mSettings = @[
                  [STWeSUSettingsSection sectionWithTitle:@"Accelerometer" items:@[
                       MAKE_ITEMN(@50, TARGET_P, BlueSTSDK_REGISTER_NAME_ACCELEROMETER_CONFIG_FS, @"Full Scale (g)", @"Accelerometer Full scale (g)"),
                       MAKE_ITEMN(@50, TARGET_P, BlueSTSDK_REGISTER_NAME_ACCELEROMETER_CONFIG_ODR, @"Output Data Rate (Hz)", @"Accelerometer Output Data Rate (Hz)"),
                  ]],
                  [STWeSUSettingsSection sectionWithTitle:@"Gyroscope" items:@[
                       MAKE_ITEMN(@50, TARGET_P, BlueSTSDK_REGISTER_NAME_GYROSCOPE_CONFIG_FS, @"Full Scale (dps)", @"Gyroscope Full scale (dps)"),
                       MAKE_ITEMN(@50, TARGET_P, BlueSTSDK_REGISTER_NAME_GYROSCOPE_CONFIG_ODR, @"Output Data Rate (Hz)", @"Gyroscope Output Data Rate (Hz)"),
                  ]],
                  [STWeSUSettingsSection sectionWithTitle:@"Magnetometer" items:@[
                       MAKE_ITEMN(@50, TARGET_P, BlueSTSDK_REGISTER_NAME_MAGNETOMETER_CONFIG_FS, @"Full Scale (gauss)", @"Magnetometer Full scale (gauss)"),
                       MAKE_ITEMN(@50, TARGET_P, BlueSTSDK_REGISTER_NAME_MAGNETOMETER_CONFIG_ODR, @"Output Data Rate (Hz)", @"Magnetometer Output Data Rate (Hz)"),
                  ]],
                  [STWeSUSettingsSection sectionWithTitle:@"Pressure" items:@[
                       MAKE_ITEMN(@50, TARGET_P, BlueSTSDK_REGISTER_NAME_PRESSURE_CONFIG_ODR, @"Output Data Rate (Hz)", @"Pressure Output Data Rate (Hz)"),
                  ]],
                 ];
    
    if (self.node.configControl) {
        [self.node.configControl addConfigDelegate:self];
    }
    else {
        //[STWeSUTools alertWithForView:self title:@"Error" message:@"No config control found"];
    }
    
    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor whiteColor];
    self.refreshControl.tintColor = [UIColor blueColor];
    [self.refreshControl addTarget:self
                            action:@selector(refreshAction)
                  forControlEvents:UIControlEventValueChanged];
    
    [self performSelector:@selector(refreshAction) withObject:nil afterDelay:0.1];
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.node) {
        self.navigationItem.title = self.node.friendlyName;
    }
}


-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.node.configControl removeConfigDelegate:self];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSInteger n = [mSettings count];
    return n;
}
#pragma mark - Misc
- (void)refreshActionStart {
    
}

- (void)refreshAction {
    
    @try {
        for(STWeSUSettingsSection *section in mSettings) {
            for(STWeSUSettingsItem *item in section.items) {
                [self.nodeExt asyncReadWithRegName:item.regName target:item.target];
            }
        }
    }
    @catch (NSException *exception) {
    }
    @finally {
        [self performSelector:@selector(refreshEndAction) withObject:nil afterDelay:1];
    }
}
- (void)refreshEndAction {
    [self.refreshControl endRefreshing];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    STWeSUSettingsItem *item = TAKE_ITEM(mSettings, indexPath.section, indexPath.row);
    return item.height;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return TAKE_SECTION(mSettings, section).title;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    assert(section < [mSettings count]);
    
    NSInteger nrow = [TAKE_SECTION(mSettings, section).items count];
    return nrow;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellsettingadvitem" forIndexPath:indexPath];
    
    // Configure the cell...
    STWeSUSettingsItem *item = TAKE_ITEM(mSettings, indexPath.section, indexPath.row);
    if (!item.indexPath) item.indexPath = indexPath;
    UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
    textLabel.text = item.title;
    
    UILabel *detailTextLabel = (UILabel *)[cell viewWithTag:2];
    detailTextLabel.text = item.valueA ? item.valueA : item.details; //the first to fill with a briefly description
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    return;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    STWeSUSettingsItem * item = [self findItemWithIndexPath:indexPath];
    
    if (!item || !cell) return;
    
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:item.title
                                                                    message:[NSString stringWithFormat:@"%@", item.details]
                                                             preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* update = nil;
    UIAlertAction* ok = nil;
    UIAlertAction* cancel = nil;
    
    bool readonly = NO;
    bool updateauto = NO;
    
    
    switch(item.regName)
    {
        case BlueSTSDK_REGISTER_NAME_ACCELEROMETER_CONFIG_FS: //
        case BlueSTSDK_REGISTER_NAME_ACCELEROMETER_CONFIG_ODR://
        case BlueSTSDK_REGISTER_NAME_GYROSCOPE_CONFIG_FS://
        case BlueSTSDK_REGISTER_NAME_GYROSCOPE_CONFIG_ODR://
        case BlueSTSDK_REGISTER_NAME_MAGNETOMETER_CONFIG_FS://
        case BlueSTSDK_REGISTER_NAME_MAGNETOMETER_CONFIG_ODR://
        case BlueSTSDK_REGISTER_NAME_PRESSURE_CONFIG_ODR://
        {
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = item.title;
                textField.text = item.valueA ? item.valueA : @"";
            }];
            ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            NSString *value = ((UITextField*)alert.textFields[0]).text;
                                            BOOL res = [self.nodeExt writeSingleRegFromDec:value regName:item.regName target:item.target autosync:YES];
                                            if (!res) [self notifyErrorMessage:nil];
                                        }];
            updateauto = YES;
        }
            break;
        default:
            [alert setMessage:@"Data not available"];
            readonly = YES;
    }
    cancel = [UIAlertAction actionWithTitle:(readonly ? @"Ok" : @"Cancel") style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //nothing
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                    }];
    if (updateauto) {
        update = [UIAlertAction actionWithTitle:@"Reload" style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            //nothing
                                            [self.nodeExt asyncReadWithRegName:item.regName target:item.target];
                                        }];
        
    }
    if (update) [alert addAction:update];
    if (ok && !readonly) [alert addAction:ok];
    if (cancel) [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - BlueSTSDKConfigControlDelegate
-(void) configControl:(BlueSTSDKConfigControl *) configControl didRegisterReadResult:(BlueSTSDKCommand *)cmd error:(NSInteger)error {
    if (cmd == nil || cmd.registerField == nil)
        return;
    
    BlueSTSDKRegister *reg = cmd.registerField;
    NSData * payload = cmd.data;
    
    unsigned char buffer[payload.length];
    [payload getBytes:buffer length:payload.length];
    BlueSTSDKWeSURegisterName_e regname = [BlueSTSDKWeSURegisterDefines lookUpRegisterNameWithAddress:reg.address target:cmd.target];
    UITableViewCell *cell = nil;
    NSInteger len = payload.length;
    bool checksize = len == reg.size * 2;
    NSInteger value = len >= 2 ? (buffer[0] + (buffer[1]<<8)) : buffer[0]; //calculate a short value
    STWeSUSettingsItem *item = [self findItemWithTarget:cmd.target regName:regname];
    
    if (item && checksize && (error == 0 || error == 2)) {
        switch(regname)
        {
            case BlueSTSDK_REGISTER_NAME_ACCELEROMETER_CONFIG_FS: //
            case BlueSTSDK_REGISTER_NAME_ACCELEROMETER_CONFIG_ODR://
            case BlueSTSDK_REGISTER_NAME_GYROSCOPE_CONFIG_FS://
            case BlueSTSDK_REGISTER_NAME_GYROSCOPE_CONFIG_ODR://
            case BlueSTSDK_REGISTER_NAME_MAGNETOMETER_CONFIG_FS://
            case BlueSTSDK_REGISTER_NAME_MAGNETOMETER_CONFIG_ODR://
            case BlueSTSDK_REGISTER_NAME_PRESSURE_CONFIG_ODR://
                item.valueA = [NSString stringWithFormat:@"%ld", (long)value];
                item.text = item.valueA;
                break;
                //power mode

            default:
                break;
        }
        
        if (item && item.indexPath) {
            cell = [self.tableView cellForRowAtIndexPath:item.indexPath];
            if (cell) {
                dispatch_async(dispatch_get_main_queue(),^{
                    UILabel *detailTextLabel = (UILabel *)[cell viewWithTag:2];
                    detailTextLabel.text = item.text;
                });
            }
        }
    }
}
-(void) configControl:(BlueSTSDKConfigControl *) configControl didRegisterWriteResult:(BlueSTSDKCommand *)cmd error:(NSInteger)error {
    if (error == 0 && cmd && cmd.registerField && self.node.configControl) {
        BlueSTSDKCommand *readCmd = [BlueSTSDKCommand commandWithRegister:cmd.registerField target:cmd.target];
        dispatch_async(dispatch_get_main_queue(),^{
            [self.node.configControl read:readCmd];
        });
    }
}
-(void) configControl:(BlueSTSDKConfigControl *)configControl didRequestResult:(BlueSTSDKCommand *)cmd success:(bool)success {
    
}
#pragma mark - Misc
-(STWeSUSettingsItem *)findItemWithTarget:(BlueSTSDKRegisterTarget_e)target regName:(BlueSTSDKWeSURegisterName_e) regName {
    STWeSUSettingsItem *item_res = nil;
    
    for(STWeSUSettingsSection *section in mSettings) {
        for(STWeSUSettingsItem *item in section.items) {
            if (item.target == target && item.regName == regName) {
                item_res = item;
            }
            
            if (item_res != nil) break;
        }
        
        if (item_res != nil) break;
    }
    return item_res;
}
-(STWeSUSettingsItem *)findItemWithIndexPath:(NSIndexPath *)indexPath {
    STWeSUSettingsItem *item_res = nil;
    
    for(STWeSUSettingsSection *section in mSettings) {
        for(STWeSUSettingsItem *item in section.items) {
            if (item.indexPath.section == indexPath.section && item.indexPath.row == indexPath.row) {
                item_res = item;
            }
            
            if (item_res != nil) break;
        }
        
        if (item_res != nil) break;
    }
    return item_res;
}
-(void)notifyErrorMessage:(NSString *)message {
    NSString * msg = message && ![message isEqualToString:@""] ? message : @"Register writing failed!";
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                              message:msg
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = nil;
    
    ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    [alertController dismissViewControllerAnimated:YES completion:nil];
                                }];
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
