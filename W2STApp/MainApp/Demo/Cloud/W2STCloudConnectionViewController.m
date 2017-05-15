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

#import <BlueSTSDK_Gui/UIViewController+BlueSTSDK.h>

#include "W2STCloudConnectionViewController.h"
#include "W2STCloudFeatureTableViewCell.h"
#include "W2STCloudDataPageViewController.h"


#define DISCONNECT_BUTTON_LABEL @"Disconnect"
#define CONNECT_BUTTON_LABEL @"Connect"
#define MISSING_PARA_DIALOG_TITLE @"Error"
#define MISSING_PARA_DIALOG_MSG @"Missing data"

@interface W2STCloudConnectionViewController ()
    <UITableViewDataSource,MQTTSessionDelegate,W2STCloudFeatureTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIButton *mShowDataButton;
@property (weak, nonatomic) IBOutlet UIButton *mConnectButton;
@property (weak, nonatomic) IBOutlet UITableView *mListFeature;

@end

@implementation W2STCloudConnectionViewController{
    NSMutableArray<BlueSTSDKFeature*> *mEnabledFeature;
    id<BlueSTSDKFeatureDelegate> mFeatureListener;
    id<W2STMQTTConnectionFactory> mConnectionFactory;
    MQTTSession *mSession;
    BOOL mKeepConnectionOpen;
}

-(BOOL)isConnected{
    if(mSession!=nil)
        if(mSession.status==MQTTSessionStatusConnected)
            return true;
    return false;
}

- (IBAction)onConnectButtonPress:(UIButton *)sender {
    mConnectionFactory = [self.connectionFactoryBuilder buildConnectionFactory];
    if(mConnectionFactory==nil){
        [self showErrorMsg:MISSING_PARA_DIALOG_MSG
                     title:MISSING_PARA_DIALOG_TITLE
           closeController:false];
        return;

    }
    [_mConnectButton setEnabled:false];
    if(![self isConnected]){
        mSession = [mConnectionFactory getSession];
        mSession.delegate =self;
        [mSession connect];
    }else{
        [mSession disconnect];
    }
}

-(void)extractEnabledFeature{
    mEnabledFeature = [NSMutableArray array];
    for(BlueSTSDKFeature * f in [self.node getFeatures]){
        if (f.enabled && [mConnectionFactory isSupportedFeature:f]){
            [mEnabledFeature addObject:f];
        }
    }
}

-(void)viewDidLoad{
    [super viewDidLoad];
    _mListFeature.dataSource=self;
}

-(void)disableAllNotification{
    for(BlueSTSDKFeature * f in [self.node getFeatures]){
        if ([self.node isEnableNotification:f]){
            [f removeFeatureDelegate:mFeatureListener];
            [self.node disableNotification:f];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(mSession!=nil && !mKeepConnectionOpen)
        if(mSession.status==MQTTSessionStatusConnected)
            [mSession disconnect];
    //next time close the conneciton
    mKeepConnectionOpen=false;
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return mEnabledFeature.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellTableIdentifier = @"BlueMSCloudLogTableViewCell";
    W2STCloudFeatureTableViewCell *cell = (W2STCloudFeatureTableViewCell *)
    [tableView dequeueReusableCellWithIdentifier:cellTableIdentifier];
    
    if (cell == nil) {
        cell = [[W2STCloudFeatureTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellTableIdentifier];
    }
    
    cell.delegate = self;
    cell.feature = [mEnabledFeature objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - W2STCloudFeatureTableViewCellDelegate

-(void)onFeatureIsSelected:(BlueSTSDKFeature*)feature newStatus:(BOOL)newStatus{
    if(newStatus){
        [feature addFeatureDelegate:mFeatureListener];
        [self.node enableNotification:feature];
    }else{
        [feature removeFeatureDelegate:mFeatureListener];
        [self.node disableNotification:feature];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.destinationViewController isKindOfClass:[W2STCloudDataPageViewController class]]){
        W2STCloudDataPageViewController *controller = (W2STCloudDataPageViewController*) segue.destinationViewController;
        controller.cloudDataPageUrl = [mConnectionFactory getDataUrl];
        mKeepConnectionOpen=true;
        return;
    }
}

#pragma mark - MQTTSessionDelegate

- (void)connected:(MQTTSession *)session{
    mFeatureListener = [mConnectionFactory getFeatureDelegateWithSession:mSession];
    [self extractEnabledFeature];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_mConnectButton setTitle:DISCONNECT_BUTTON_LABEL forState:UIControlStateNormal];
        [_mConnectButton setEnabled:true];
        [_mListFeature reloadData];
        _mShowDataButton.hidden=[mConnectionFactory getDataUrl]==nil;
        _mListFeature.hidden=false;
    });
}

-(void)connectionClosed:(MQTTSession *)session{
    [self disableAllNotification];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_mConnectButton setTitle:CONNECT_BUTTON_LABEL forState:UIControlStateNormal];
        [_mConnectButton setEnabled:true];
        [mEnabledFeature removeAllObjects];
        [_mListFeature reloadData];
        _mShowDataButton.hidden=true;
        _mListFeature.hidden=true;
    });
}

-(void)connectionError:(MQTTSession *)session error:(NSError *)error{
    [self showErrorMsg:@"Connection Error"
                 title:[error localizedDescription]
       closeController:false];
}

- (void)connectionRefused:(MQTTSession *)session error:(NSError *)error{
    [self showErrorMsg:@"Connection Refused"
                 title:[error localizedDescription]
       closeController:false];
}

@end
