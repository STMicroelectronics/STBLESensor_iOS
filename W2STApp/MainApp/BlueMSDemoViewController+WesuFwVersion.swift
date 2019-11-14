/*
 * Copyright (c) 2019 STMicroelectronics – All rights reserved
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
import Foundation

extension BlueMSDemosViewController : BlueSTSDKConfigControlDelegate{
   
 
    func readBoardVersion(control:BlueSTSDKConfigControl?){
        control?.addConfigDelegate(self)
        let command = BlueSTSDKCommand(register: BlueSTSDKWeSURegisterDefines.lookUp(withRegisterName: .REGISTER_NAME_FW_VER), target: .REGISTER_TARGET_PERSISTENT)
        control?.read(command)
    }

    func checkFwVersion(){
        if(self.node.state == .connected){
            readBoardVersion(control: self.node.configControl)
        }else{
            self.node.addStatusDelegate(self)
        }
    }
    

    
    func configControl(_ configControl: BlueSTSDKConfigControl!, didRegisterReadResult cmd: BlueSTSDKCommand!, error: Int) {
        
    }
    
    func configControl(_ configControl: BlueSTSDKConfigControl!, didRegisterWriteResult cmd: BlueSTSDKCommand!, error: Int) {
        
    }
    
    func configControl(_ configControl: BlueSTSDKConfigControl!, didRequestResult cmd: BlueSTSDKCommand!, success: Bool) {
        
    }
    

    
}



/*
 
 
 #define LAST_FW_VERSION_MAJOIR 1
 #define LAST_FW_VERSION_MINOR 1
 #define LAST_FW_VERSION_PATCH 0
 #define DFU_APP_URL @"itms://itunes.apple.com/it/app/st-bluedfu/id1187882971?mt=8"
 
 #define WESU_SETTINGS_ITEM BLUESTSDK_LOCALIZE(@"Register Settings",nil)
 
 #define UPDATE_FW_TITLE BLUESTSDK_LOCALIZE(@"New Firmware available",nil)
 #define UPDATE_FW_MESSAGE BLUESTSDK_LOCALIZE(@"Please update the firmware before continue",nil)
 #define UPDATE_FW_CONTINUE BLUESTSDK_LOCALIZE(@"Continue",nil)
 #define UPDATE_FW_UPDATE BLUESTSDK_LOCALIZE(@"Update",nil)
 
 @interface BlueMSDemosViewController (WesuFwVersion)<BlueSTSDKConfigControlDelegate,
 BlueSTSDKNodeStateDelegate>
 
 @end
 
 @implementation BlueMSDemosViewController (WesuFwVersion)
 
 
 
 -(void)checkFwVersion{
 if(self.node.state == BlueSTSDKNodeStateConnected){
 [self readBoardVersion:self.node.configControl];
 }else{
 [self.node addNodeStatusDelegate:self];
 }
 }
 
 - (void) node:(BlueSTSDKNode *)node didChangeState:(BlueSTSDKNodeState)newState prevState:(BlueSTSDKNodeState)prevState{
 if(newState==BlueSTSDKNodeStateConnected){
 [self readBoardVersion:node.configControl];
 [node removeNodeStatusDelegate:self];
 }
 }
 
 
 #pragma mark BlueSTSDKConfigControlDelegate
 
 -(void) configControl:(BlueSTSDKConfigControl *)configControl
 didRegisterReadResult:(BlueSTSDKCommand *)cmd error:(NSInteger)error{
 BlueSTSDKRegister *reg = [BlueSTSDKWeSURegisterDefines lookUpWithRegisterName:BlueSTSDK_REGISTER_NAME_FW_VER];
 if(error!=0 || cmd.registerField.address!=reg.address)
 return;
 //else
 [configControl removeConfigDelegate:self];
 BlueSTSDKFwVersion *nodeVersion = [BlueSTSDKWeSURegisterDefines extractFwVersion:cmd];
 BlueSTSDKFwVersion *lastVerion = [BlueSTSDKFwVersion versionMajor:LAST_FW_VERSION_MAJOIR
 minor:LAST_FW_VERSION_MINOR
 patch:LAST_FW_VERSION_PATCH];
 
 if( [nodeVersion compareVersion:lastVerion] == NSOrderedAscending){
 [self showUpdateFwDialog];
 }
 
 }
 
 -(void) showUpdateFwDialog{
 UIAlertController *alert;
 
 alert = [UIAlertController alertControllerWithTitle:UPDATE_FW_TITLE
 message:UPDATE_FW_MESSAGE
 preferredStyle:UIAlertControllerStyleAlert];
 
 
 UIAlertAction* continueAction = [UIAlertAction actionWithTitle:UPDATE_FW_UPDATE
 style:UIAlertActionStyleDefault
 handler:^(UIAlertAction * action) {
 UIApplication *app = [UIApplication sharedApplication];
 NSURL *url = [NSURL URLWithString:DFU_APP_URL];
 [app openURL:url options:@{} completionHandler:nil];
 }];
 UIAlertAction* updateAction = [UIAlertAction actionWithTitle:UPDATE_FW_CONTINUE
 style:UIAlertActionStyleCancel
 handler:nil];
 
 if(alert!=nil){
 [alert addAction:continueAction];
 [alert addAction:updateAction];
 [self presentViewController:alert animated:YES completion:nil];
 }
 
 }
 
 -(void) configControl:(BlueSTSDKConfigControl *)configControl
 didRequestResult:(BlueSTSDKCommand *)cmd success:(bool)success{
 
 }
 
 -(void) configControl:(BlueSTSDKConfigControl *)configControl
 didRegisterWriteResult:(BlueSTSDKCommand *)cmd error:(NSInteger)error{
 
 }
 
 
 -(UIAlertAction*)createRegisterSettings{
 return [UIAlertAction actionWithTitle:WESU_SETTINGS_ITEM
 style:UIAlertActionStyleDefault
 handler:^(UIAlertAction *action) {
 [self moveToRegisterSettingsViewController];
 }];
 }
 
 
 -(void)moveToRegisterSettingsViewController{
 UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"WeSUSettings" bundle:nil];
 
 STWeSUSettingsTableViewController *settingsControlView = [storyBoard instantiateInitialViewController];
 
 settingsControlView.node=self.node;
 
 [self changeViewController:settingsControlView];
 }
 
 @end
 
 */

