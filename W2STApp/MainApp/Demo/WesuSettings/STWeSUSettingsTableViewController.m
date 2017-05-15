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

#import "STWeSUSettingsTableViewController.h"
#import "STWeSUSettingsItem.h"
#import "STWeSUTools.h"
#import "STWeSUNodeExtension.h"
#import "STWeSUSettingsAdvancedTableViewController.h"
#import "STWeSUSettingsDataReadViewController.h"
#import "STWesUFeatureSettingViewController.h"


#define FEATURES_SETTINGS_NAME @"Feature Settings"
#define SHOW_FEATURE_SETTINGS_VIEW_SEGUE_NAME @"showFeatureSettingsViewSegue"

#define ADVENCED_MEMS_SETTINGS_ITEM_MAME @"Advanced MEMS Settings"
#define SHOW_SETTINGS_ADV_VIEW_SEGUE_NAME @"showSettingsAdvancedViewSegue"
#define SHOW_SETTINGS_DATAREAD_SEGUE_NAME @"datareadsegue"

@interface STWeSUSettingsTableViewController () <STWeSUSettingsDataReadViewControllerDelegate>
@property (retain, readonly) STWeSUNodeExtension *nodeExt;
@end

@implementation STWeSUSettingsTableViewController {
    NSArray *mSettings;
}



#define HEIGHT_MAP 70

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _nodeExt = [STWeSUNodeExtension nodeExtWithNode:self.node];
    
    mSettings = @[
                [STWeSUSettingsSection sectionWithTitle:@"Device general settings" items:@[
                    MAKE_ITEMN(@10, BlueSTSDK_REGISTER_TARGET_PERSISTENT, BlueSTSDK_REGISTER_NAME_BLE_LOC_NAME, @"Local Name", @"WeSU1"),
                    MAKE_ITEMN(@11, BlueSTSDK_REGISTER_TARGET_PERSISTENT, BlueSTSDK_REGISTER_NAME_BLE_PUB_ADDR, @"Pubblic Address", @"BLE Address"),
                    MAKE_ITEMN(@12, BlueSTSDK_REGISTER_TARGET_PERSISTENT, BlueSTSDK_REGISTER_NAME_FW_VER, @"Firmware Version", @"-"),
                    MAKE_ITEMN(@13, BlueSTSDK_REGISTER_TARGET_SESSION, BlueSTSDK_REGISTER_NAME_BLUENRG_INFO, @"BlueNRG Info", @"-"),
                                                                                            ]],
                [STWeSUSettingsSection sectionWithTitle:@"Session settings" items:@[
                    MAKE_ITEMN(@30, BlueSTSDK_REGISTER_TARGET_SESSION, BlueSTSDK_REGISTER_NAME_LED_CONFIG, @"Led Configuration", @"Set led configuration"),
                    MAKE_ITEMN(@31, BlueSTSDK_REGISTER_TARGET_SESSION, BlueSTSDK_REGISTER_NAME_TIMER_FREQ, @"Timer (Hz)", @"Frequency of sampling"),
                    MAKE_ITEMSH(@32, BlueSTSDK_REGISTER_TARGET_SESSION, BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURES_MAP, @"Data Read Group A", @"Feature mapping of the group A", HEIGHT_MAP),
                    MAKE_ITEMSH(@33, BlueSTSDK_REGISTER_TARGET_SESSION, BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURES_MAP, @"Data Read Group B", @"Feature mapping of the group B", HEIGHT_MAP),
                    MAKE_ITEMF(@34, BlueSTSDK_REGISTER_TARGET_SESSION, FEATURES_SETTINGS_NAME, @"Control Configuration for available features"),
                    MAKE_ITEMN(@35, BlueSTSDK_REGISTER_TARGET_SESSION, BlueSTSDK_REGISTER_NAME_PWR_MODE_CONFIG, @"Power Mode", @"Specify the power mode"),

                 ]],
                [STWeSUSettingsSection sectionWithTitle:@"Persistent settings" items:@[
                    MAKE_ITEMN(@50, BlueSTSDK_REGISTER_TARGET_PERSISTENT, BlueSTSDK_REGISTER_NAME_LED_CONFIG, @"Led Configuration", @"Set led configuration"),
                    MAKE_ITEMN(@51, BlueSTSDK_REGISTER_TARGET_PERSISTENT, BlueSTSDK_REGISTER_NAME_TIMER_FREQ, @"Timer (Hz)", @"Frequency of sampling"),
                    MAKE_ITEMSH(@52, BlueSTSDK_REGISTER_TARGET_PERSISTENT, BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURES_MAP, @"Data Read Group A", @"Feature mapping of the group A", HEIGHT_MAP),
                    MAKE_ITEMSH(@53, BlueSTSDK_REGISTER_TARGET_PERSISTENT, BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURES_MAP, @"Data Read Group B", @"Feature mapping of the group B", HEIGHT_MAP),
                    MAKE_ITEMF(@54, BlueSTSDK_REGISTER_TARGET_PERSISTENT,FEATURES_SETTINGS_NAME, @"Control Configuration for available features"),
                    MAKE_ITEMF(@55, BlueSTSDK_REGISTER_TARGET_PERSISTENT,ADVENCED_MEMS_SETTINGS_ITEM_MAME, @"Expert settings for node MEMS sensor"),
                    MAKE_ITEMN(@56, BlueSTSDK_REGISTER_TARGET_PERSISTENT, BlueSTSDK_REGISTER_NAME_PWR_MODE_CONFIG, @"Power Mode", @"Specify the power mode"),
                    MAKE_ITEMN(@57, BlueSTSDK_REGISTER_TARGET_PERSISTENT, BlueSTSDK_REGISTER_NAME_RADIO_TXPWR_CONFIG, @"BLE Output Power", @"Specify the output power"),
                 ]],
                [STWeSUSettingsSection sectionWithTitle:@"System" items:@[
                    MAKE_ITEMN(@70, BlueSTSDK_REGISTER_TARGET_SESSION, BlueSTSDK_REGISTER_NAME_RTC_DATE_TIME, @"RTC Timer", @"Set the internal timer"),
                    MAKE_ITEMN(@71, BlueSTSDK_REGISTER_TARGET_SESSION, BlueSTSDK_REGISTER_NAME_DFU_REBOOT, @"Node Firmware Upgrade", @"Restart node for DFU USB or OTA"),
                    MAKE_ITEMN(@71, BlueSTSDK_REGISTER_TARGET_SESSION, BlueSTSDK_REGISTER_NAME_POWER_OFF, @"Power-OFF Node", @"Power-OFF or Restart node"),
                 ]],
           ];
    
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
    if (self.node.configControl) {
        [self.node.configControl addConfigDelegate:self];
    }
    else {
        //[STWeSUTools alertWithForView:self title:@"Error" message:@"No config control found"];
    }

    if (self.node) {
        self.navigationItem.title = self.node.friendlyName;
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.node.configControl removeConfigDelegate:self];
}

#pragma mark - Misc


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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSInteger n = [mSettings count];
    return n;
}

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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellsettingitem" forIndexPath:indexPath];
    
    // Configure the cell...
    STWeSUSettingsItem *item = TAKE_ITEM(mSettings, indexPath.section, indexPath.row);
    if (!item.indexPath) item.indexPath = indexPath;
    if (item.type == STWeSUSettingsItemTypeFolder) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    UILabel *textLabel = (UILabel *)[cell viewWithTag:1];
    textLabel.text = item.title;

    UILabel *detailTextLabel = (UILabel *)[cell viewWithTag:2];
    detailTextLabel.text = item.text ? item.text : item.details; //the first to fill with a briefly description
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    return;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    STWeSUSettingsItem * item = [self findItemWithIndexPath:indexPath];
    
    if (!item || !cell) return;
    
    if (item.type != STWeSUSettingsItemTypeNormal) {
        if ([item.title isEqualToString:ADVENCED_MEMS_SETTINGS_ITEM_MAME]) {
            [self performSegueWithIdentifier:SHOW_SETTINGS_ADV_VIEW_SEGUE_NAME sender:self];
        }else if ([item.title isEqualToString:FEATURES_SETTINGS_NAME]) {
            [self performSegueWithIdentifier:SHOW_FEATURE_SETTINGS_VIEW_SEGUE_NAME sender:item];
        }
        else if([item.title isEqualToString:@"Data Read Group A"] || [item.title isEqualToString:@"Data Read Group B"]) {
            [self performSegueWithIdentifier:SHOW_SETTINGS_DATAREAD_SEGUE_NAME sender:item];
        }
    }
    else {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:item.title
                                                                        message:item.details //[NSString stringWithFormat:@"%@", item.details]
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* update = nil;
        UIAlertAction* ok = nil;
        UIAlertAction* cancel = nil;
        UIAlertAction* action = nil;
        
        bool readonly = NO;
        bool updateauto = NO;
        
        switch(item.regName)
        {
            case BlueSTSDK_REGISTER_NAME_BLE_LOC_NAME: //local name
            {
                [alert setMessage:[NSString stringWithFormat:@"Specify the node name (max %d chars)\nOnly first %d chars will be used in the advertisement", (int)LOCALNAME_MAX, (int)LOCALNAME_MAX_ADV]];
                [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    textField.placeholder = item.title;
                    textField.text = item.valueA ? item.valueA : @"";
                }];
                ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                NSString *value = ((UITextField*)alert.textFields[0]).text;
                                                if (value.length <= LOCALNAME_MAX)
                                                {
                                                    BOOL res = [self.nodeExt writeLocalName:value];
                                                    if (!res) [self notifyErrorMessage:nil];
                                                }
                                                else {
                                                    [self notifyErrorMessage:[NSString stringWithFormat:@"The node name must be max %d chars", (int)LOCALNAME_MAX]];
                                                }
                                            }];
            }
                break;
            case BlueSTSDK_REGISTER_NAME_BLE_PUB_ADDR: //public address
            {
                
                [alert setMessage:@"Specify the pubblic address\n(format XX:XX:XX:XX:XX:XX)"];
                [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    textField.placeholder = item.title;
                    textField.text = item.valueA ? item.valueA : @"";
                }];
                ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                NSString *value = ((UITextField*)alert.textFields[0]).text;
                                                BOOL res = [self.nodeExt writePubblicAddress:value];
                                                NSString *message = [NSString stringWithFormat:@"Invalid address\n%@\n(format XX:XX:XX:XX:XX:XX)", [value uppercaseString]];
                                                if (!res) [self notifyErrorMessage:message];
                                            }];
            }
                break;
            case BlueSTSDK_REGISTER_NAME_FW_VER: //fw version
            {
                readonly = YES;
                [alert setMessage:[NSString stringWithFormat:@"Version: %@", (item.text ? item.text : @"not available")]];
                
                //[self.nodeExt asyncReadWithRegName:BlueSTSDK_REGISTER_NAME_FW_VER target:BlueSTSDK_REGISTER_BlueSTSDK_REGISTER_TARGET_PERSISTENTERSISTENT];
            }
                break;
            case BlueSTSDK_REGISTER_NAME_LED_CONFIG: //led configuration
                [alert setMessage:@"Select the led configuration"];
                for(NSString *key in self.nodeExt.ledConfigOrderedKeys) {
                    action = [UIAlertAction actionWithTitle:self.nodeExt.ledConfig[key] style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        BOOL res = [self.nodeExt writeLedConfig:key target:item.target];
                                                        if (!res) [self notifyErrorMessage:nil];
                                                    }];
                    
                    if (action) [alert addAction:action];
                }
                updateauto = YES;
                break;
            case BlueSTSDK_REGISTER_NAME_PWR_MODE_CONFIG: //power mode
                [alert setMessage:@"Select the power mode"];
                for(NSString *key in self.nodeExt.powerModeOrderedKeys) {
                    action = [UIAlertAction actionWithTitle:self.nodeExt.powerMode[key] style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        BOOL res = [self.nodeExt writePowerMode:key target:item.target];
                                                        if (!res) [self notifyErrorMessage:nil];
                                                    }];
                    if (action) [alert addAction:action];
                }
                updateauto = YES;
                break;
            case BlueSTSDK_REGISTER_NAME_TIMER_FREQ: //public address
            {
                
                [alert setMessage:@"Specify the timer frequency (Hz)"];
                [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    textField.placeholder = item.title;
                    textField.text = item.valueA ? item.valueA : @"";
                }];
                ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                NSString *value = ((UITextField*)alert.textFields[0]).text;
                                                BOOL res = [self.nodeExt writeTimerFrequency:value target:item.target];
                                                if (!res) [self notifyErrorMessage:nil];
                                            }];
            }
                break;
            case BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURES_MAP: //output power
            case BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURES_MAP: //output power
            {
//                NSMutableString *message = [NSMutableString stringWithString:@"Enabling/disabling sensors\nMap sensors:\n"];
//                NSDictionary *arrayMapString = item.regName == BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURES_MAP ? self.nodeExt.featureMapGroupB : self.nodeExt.featureMapGroupA;
//                for(NSString *key in arrayMapString.allKeys) {
//                    [message appendFormat:@"0x%@\t%@\n", key, arrayMapString[key]];
//                }
//                
//                //NSMutableAttributedString *mtext = [[NSMutableAttributedString alloc] initWithString:message];
//                
//                [alert setMessage:message];
//                //alert.message
//                [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//                    textField.placeholder = item.title;
//                    textField.text = item.valueA ? item.valueA : @"";
//                }];
//                ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//                                            handler:^(UIAlertAction * action) {
//                                                NSString *value = ((UITextField*)alert.textFields[0]).text;
//                                                BOOL res = [self.nodeExt writeMapGroup:value regName:item.regName target:item.target];
//                                                if (!res) [self notifyErrorMessage:nil];
//                                            }];
            }
                break;
            case BlueSTSDK_REGISTER_NAME_RADIO_TXPWR_CONFIG: //output power
                [alert setMessage:@"Select the output power from the available values"];
                for(NSString *key in self.nodeExt.bleOutputPowerMapOrderedKeys) {
                    action = [UIAlertAction actionWithTitle:self.nodeExt.bleOutputPowerMap[key] style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        BOOL res = [self.nodeExt writeBLEOutputPower:key];
                                                        if (!res) [self notifyErrorMessage:nil];
                                                    }];
                    
                    if (action) [alert addAction:action];
                }
                updateauto = YES;
                break;
            case BlueSTSDK_REGISTER_NAME_RTC_DATE_TIME: //RTC Timer
            {
                [alert setMessage:@"Do you want to set the current date and time in the device?"];
                ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                BOOL res = [self.nodeExt writeRTCDateTime:nil];
                                                if (!res) {
                                                    [self notifyErrorMessage:nil];
                                                }
                                            }];
                updateauto = YES;
            }
                break;
            case BlueSTSDK_REGISTER_NAME_DFU_REBOOT: //dfu mode
                [alert setMessage:@"Set the DFU mode"];
                for(NSString *key in self.nodeExt.dfuReboot) {
                    action = [UIAlertAction actionWithTitle:self.nodeExt.dfuReboot[key] style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        BOOL res = [self.nodeExt writeDFUReboot:key];
                                                        if (!res) {
                                                            [self notifyErrorMessage:nil];
                                                        }
                                                        else {
                                                            [self needRestart];
                                                        }
                                                    }];
                    
                    if (action) [alert addAction:action];
                }
                break;
            case BlueSTSDK_REGISTER_NAME_POWER_OFF: //power off
                [alert setMessage:@""];
                for(NSString *key in self.nodeExt.powerOff) {
                    action = [UIAlertAction actionWithTitle:self.nodeExt.powerOff[key] style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * action) {
                                                        BOOL res = [self.nodeExt writePowerOff:key];
                                                        if (!res) [self notifyErrorMessage:nil];
                                                    }];
                    
                    if (action) [alert addAction:action];
                }
                break;
            default:
                [alert setMessage:@"Data not available"];
                readonly = YES;
        }
//        cancel = [UIAlertAction actionWithTitle:(readonly ? @"Ok" : @"Cancel") style:UIAlertActionStyleDefault
//                                        handler:^(UIAlertAction * action) {
//                                            //nothing
//                                            [alert dismissViewControllerAnimated:YES completion:nil];
//                                        }];
        cancel = [UIAlertAction actionWithTitle:(readonly ? @"Ok" : @"Cancel") style:UIAlertActionStyleCancel
                                        handler:nil];
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
}


NSString* macToString(unsigned char *buffer, NSInteger lenght){
    NSMutableString *str = [NSMutableString string];
    for(int i =0 ;i<6;i++){
        NSString *temp = [NSString stringWithFormat:@"%02X:",buffer[i] ];
        [str insertString:temp atIndex:0];
    }
    //remove last char
    [str deleteCharactersInRange:NSMakeRange(str.length-1, 1)];
    return str;
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
//    NSString *text = @"";
    NSString *key = @"";
    STWeSUSettingsItem *item = [self findItemWithTarget:cmd.target regName:regname];
    
    if (item && checksize && (error == 0 || error == 2)) {
        switch(regname)
        {
            /*mandatory registers*/
            case BlueSTSDK_REGISTER_NAME_FW_VER: //address
                item.valueA = [NSString stringWithFormat:@"%04X", (int)value];
                item.text = [NSString stringWithFormat:@"%X.%X.%02X", (int)((value >> 12) & 0x0F), (int)((value >> 8) & 0x0F), (int)(value & 0xFF)];
                break;

            case BlueSTSDK_REGISTER_NAME_LED_CONFIG: //led config
                key = [NSString stringWithFormat:@"%02X",(int)(value & 0xFF)];
                item.valueA = key;
                item.text = self.nodeExt.ledConfig[key] ? self.nodeExt.ledConfig[key] : [NSString stringWithFormat:@"Unknown config 0x%@", key];
                break;
            //local name
            case BlueSTSDK_REGISTER_NAME_BLE_LOC_NAME:
                item.valueA = [NSString stringWithUTF8String:(const char *)(&buffer[1])];
                item.text = item.valueA;
                break;
            
            //ble address
            case BlueSTSDK_REGISTER_NAME_BLE_PUB_ADDR:
            {
                item.valueA = macToString(buffer,len);
                item.text = item.valueA;
            }
                break;
                
            /*optional generic*/
            //ble output power
            case BlueSTSDK_REGISTER_NAME_RADIO_TXPWR_CONFIG:
                key = [NSString stringWithFormat:@"%04X",(int)value];
                item.valueA = key;
                item.text = self.nodeExt.bleOutputPowerMap[key] ? self.nodeExt.bleOutputPowerMap[key] : [NSString stringWithFormat:@"Unknown option 0x%@", key];
                break;
            //timer frequency
            case BlueSTSDK_REGISTER_NAME_TIMER_FREQ:
                item.valueA = [NSString stringWithFormat:@"%ld", (long)value];
                item.text = item.valueA;
                break;
            //power mode
            case BlueSTSDK_REGISTER_NAME_PWR_MODE_CONFIG:
                key = [NSString stringWithFormat:@"%02X",(int)(value & 0xFF)];
                item.valueA = key;
                item.text = self.nodeExt.powerMode[key] ? self.nodeExt.powerMode[key] : [NSString stringWithFormat:@"Low power - code 0x%@", key];
                break;
            //feature map group A and B
            case BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURES_MAP:
            case BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURES_MAP:
            {
                NSMutableString *str = [NSMutableString stringWithString:@""];
                NSDictionary *arrayMapString = regname == BlueSTSDK_REGISTER_NAME_GROUP_B_FEATURES_MAP ? self.nodeExt.featureMapGroupB : self.nodeExt.featureMapGroupA;
                if (value != 0) {
                    for(int i = 0; i < 16; i++) {
                        int map = 1<<i;
                        if ((value & map) > 0) {
                            //if the bit is set convert it in the string
                            NSString * mapstr = [NSString stringWithFormat:@"%04X",map];
                            
                            if (arrayMapString[mapstr]) {
                                [str appendFormat:@"%@ ", arrayMapString[mapstr]];
                            }
                        }
                    }
                }
                else {
                    [str appendString:@"No feature "];
                }
                [str appendFormat:@"(0x%04X)", (int)value];
                item.valueA = [NSString stringWithFormat:@"%04X", (int)value];
                item.text = str;
            }
                break;
                //power mode
            case BlueSTSDK_REGISTER_NAME_RTC_DATE_TIME:
                {
                    NSString *strDevTimer = @"Not Valid";
                    NSString *strRtcConfig = @"-";
                
                    if (len >= 8) {
                        if ((buffer[0] >= 0 && buffer[0] < 24) && (buffer[1] >= 0 && buffer[1] < 60) &&
                            (buffer[2] >= 0 && buffer[2] < 60) && (buffer[3] >= 1 && buffer[3] <= 31) &&
                            (buffer[4] >= 1 && buffer[4] <= 12) && (buffer[5] >= 0 && buffer[5] < 100)) {
                            strDevTimer = [NSString stringWithFormat:@"%02d/%02d/%02d - %02d:%02d", buffer[3], buffer[4], buffer[5], buffer[0], buffer[1]];
                            
                            key = [NSString stringWithFormat:@"%02X", buffer[7] & 0xFF];
                            strRtcConfig = self.nodeExt.rtcTimer[key] ? self.nodeExt.rtcTimer[key] : [NSString stringWithFormat:@"Code %@", key];
                        }
                
                    }
                    item.valueA = [NSString stringWithFormat:@"%@ (%@)", strDevTimer, strRtcConfig];
                    item.text = item.valueA;
                }
                break;
            case BlueSTSDK_REGISTER_NAME_BLUENRG_INFO:
             {
                 
                 item.valueA = [NSString stringWithFormat:@"HW: %X.%X FW:%X.%X%c",
                                   ((buffer[0] >> 4) & 0x0F),
                                   (buffer[0] & 0x0F),
                                   (buffer[3] & 0xFF),
                                   (buffer[2] >> 4 & 0x0F),
                                   ((buffer[2]  & 0x0F) - 1 +'a')];
                 item.text=item.valueA;
                }
                break;
                
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
-(void)needRestart {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                              message:@"Need a restart to apply change!\n Do you want to restart now?"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = nil;
    UIAlertAction* cancel = nil;
    
    ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //perform a reboot
                                    [self.nodeExt writePowerOff:PWR_OFF_REBOOT];
                                }];
    cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        //nothing
                                        [alertController dismissViewControllerAnimated:YES completion:nil];
                                    }];
    [alertController addAction:ok];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
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
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:SHOW_SETTINGS_ADV_VIEW_SEGUE_NAME]){
            STWeSUSettingsAdvancedTableViewController *dest = (STWeSUSettingsAdvancedTableViewController*)[segue destinationViewController];
            dest.node = self.node;
    }else if([segue.identifier isEqualToString:SHOW_FEATURE_SETTINGS_VIEW_SEGUE_NAME]){
        STWesUFeatureSettingViewController *dest = (STWesUFeatureSettingViewController*)[segue destinationViewController];
        STWeSUSettingsItem * item = (STWeSUSettingsItem *)sender;
        dest.configControl = self.node.configControl;
        dest.sessionRegister = item.target == BlueSTSDK_REGISTER_TARGET_SESSION;
    }else if([segue.identifier isEqualToString:SHOW_SETTINGS_DATAREAD_SEGUE_NAME]){
        STWeSUSettingsItem * item = (STWeSUSettingsItem *)sender;
        STWeSUSettingsDataReadViewController *dest = (STWeSUSettingsDataReadViewController*)[segue destinationViewController];
        unsigned value = 0x00;
        NSScanner *scanner = [NSScanner scannerWithString:item.valueA];
        [scanner scanHexInt: &value];

        dest.titleValue = item.title;
        dest.messageValue = item.details;
        dest.item = item;
        dest.value = value;
        //dest.backgroundImage = [STWeSUTools imageWithView:self.tableView];

        dest.options = item.regName == BlueSTSDK_REGISTER_NAME_GROUP_A_FEATURES_MAP ?
        @[ //group A
          @[@(0x0080), @"Accelerometer"],
          @[@(0x0040), @"Gyroscope"],
          @[@(0x0020), @"Magnetometer"],
          @[@(0x0010), @"Pressure"],
          @[@(0x0004), @"Temperature"],
          @[@(0x0002), @"Battery"],
          ]:
        @[ //group B
          @[@(0x0001), @"Pedometer"],
          @[@(0x0080), @"SensFusion AHRS Mems"],
          @[@(0x0200), @"FreeFall"],
          @[@(0x0010), @"Activity Recognition"],
          @[@(0x0008), @"Carry Position"],
        ];
        dest.delegate = self;
    }//if
                         
}
#pragma mark - STWeSUSettingsDataReadViewControllerDelegate
-(void)resultDataReadViewController:(STWeSUSettingsDataReadViewController *)dataReadViewController button:(BOOL)ok value:(NSInteger)value {
    if (dataReadViewController && dataReadViewController.item && ok) {
        STWeSUSettingsItem *item = dataReadViewController.item;
        NSString *valueStr = [NSString stringWithFormat:@"%04X", (int)value];
        BOOL res = [self.nodeExt writeMapGroup:valueStr regName:item.regName target:item.target];
        if (!res) [self notifyErrorMessage:nil];
    }
}

@end
