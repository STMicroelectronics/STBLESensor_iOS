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

#import "W2STFeatureDebugTableViewController.h"
#import "BlueMSDemosViewController.h"

#import <BlueSTSDK/BlueSTSDKFeature.h>
#import <BlueSTSDK/BlueSTSDKFeatureField.h>
#import <BlueSTSDK/BlueSTSDKFeatureLogCSV.h>

#define DEFAULT_MESSAGE @"Click for enable the notification"

@implementation W2STFeatureDebugTableViewController{
    NSArray *mAvailableFeatures;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //TODO REMOVE THE DISABLED FEATURES
    mAvailableFeatures = [self.node getFeatures];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    for (BlueSTSDKFeature *f in mAvailableFeatures){
        [f removeFeatureDelegate:self];
    }
}


#pragma mark - BlueSTSDKFeatureDelegate

- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
    NSUInteger index = [mAvailableFeatures indexOfObject:feature];
    NSIndexPath *cellIndex =[NSIndexPath indexPathForRow:index inSection: 0];
    NSString *desc = [feature description];
    dispatch_sync(dispatch_get_main_queue(),^{
        [_featureTable beginUpdates];
        UITableViewCell *cell = [_featureTable cellForRowAtIndexPath: cellIndex];
        cell.detailTextLabel.text = desc;
        //[_featureTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:cellIndex] withRowAnimation:UITableViewRowAnimationNone];
        [_featureTable endUpdates];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return mAvailableFeatures.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NodeFeature" forIndexPath:indexPath];
    
    BlueSTSDKFeature *f = [mAvailableFeatures objectAtIndex:indexPath.row];
    
    cell.textLabel.text =f.name;
    cell.detailTextLabel.text= DEFAULT_MESSAGE;
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BlueSTSDKFeature *f =(BlueSTSDKFeature*) mAvailableFeatures[indexPath.row];
    [f addFeatureDelegate:self];
    if([f isKindOfClass:[BlueSTSDKFeatureAutoConfigurable class]]){
        [((BlueSTSDKFeatureAutoConfigurable*)f) addFeatureConfigurationDelegate:self];
    }
    if([self.node isEnableNotification:f]){
        [self.node disableNotification:f];
        [tableView cellForRowAtIndexPath:indexPath].detailTextLabel.text= DEFAULT_MESSAGE;
    }else{
        if([f isKindOfClass:[BlueSTSDKFeatureAutoConfigurable class]]){
            [((BlueSTSDKFeatureAutoConfigurable*)f) startAutoConfiguration];
        }
        [self.node enableNotification:f];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:true];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    BlueSTSDKFeature *f =(BlueSTSDKFeature*) mAvailableFeatures[indexPath.row];
    if([f isKindOfClass:[BlueSTSDKFeatureAutoConfigurable class]]){
        [((BlueSTSDKFeatureAutoConfigurable*)f) startAutoConfiguration];
    }
}


- (void)didAutoConfigurationStart:(BlueSTSDKFeatureAutoConfigurable *)feature{
    NSLog(@"%@: conf start",feature.name);
}
- (void)didAutoConfigurationChange:(BlueSTSDKFeatureAutoConfigurable *)feature status:(int32_t)status{
    NSLog(@"%@: conf change :%d",feature.name,status);
    NSUInteger index = [mAvailableFeatures indexOfObject:feature];
    NSIndexPath *cellIndex =[NSIndexPath indexPathForRow:index inSection: 0];
    dispatch_async(dispatch_get_main_queue(),^{
        [_featureTable beginUpdates];
        UITableViewCell *cell = [_featureTable cellForRowAtIndexPath: cellIndex];
        if(feature.isConfigured)
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
        [_featureTable endUpdates];
    });
}

- (void)didConfigurationFinished:(BlueSTSDKFeatureAutoConfigurable *)feature status:(int32_t)status{
    NSLog(@"%@: conf stop :%d",feature.name,status);    
}

-(void) debug:(BlueSTSDKDebug*)debug didStdOutReceived:(NSString*) msg{
    NSLog(@"stdOut: %@",msg);
}
-(void) debug:(BlueSTSDKDebug*)debug didStdErrReceived:(NSString*) msg{
    NSLog(@"stdErr: %@",msg);
}
-(void) debug:(BlueSTSDKDebug*)debug didStdInSend:(NSString*) msg error:(NSError*)error{
    if(error!=nil)
        NSLog(@"stdIn: %@ error: %@",msg,[error localizedDescription]);
    else
        NSLog(@"stdIn: %@",msg);
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    	// Pass the selected object to the new view controller.
}
*/

@end
