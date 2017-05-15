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

#include <BlueSTSDK/BlueSTSDKFeature.h>
#import <MQTTClient.h>

#include "Provider/W2STCloudConfigViewController.h"
#import "W2STCloudProviderSelectViewController.h"

/**
 * Class that contains the name and the seguie for each supported cloud provider
 */
@interface CloudProvider : NSObject
    @property NSString *name; //service name
    @property NSString *segue; // segue that will send to the specific view controller
    +(instancetype) providerWithName:(NSString*) name segue:(NSString*)segue;
    -(instancetype) initWithName:(NSString*) name segue:(NSString*)segue;
@end
@implementation CloudProvider

+(instancetype)providerWithName:(NSString *)name segue:(NSString *)segue{
    return [[CloudProvider alloc]initWithName:name segue:segue];
}

-(instancetype) initWithName:(NSString *)name segue:(NSString *)segue{
    self = [super init];
    _name=name;
    _segue=segue;
    return self;
}

@end

//list of available cloud provider
static NSArray<CloudProvider*> *sCloudProvider;

@interface W2STCloudProviderSelectViewController ()
    <UITableViewDataSource,UITableViewDelegate>

@end

@implementation W2STCloudProviderSelectViewController{
    __weak IBOutlet UITableView *mCloudProviderList;
}

+(void)initialize{
    if(self == [W2STCloudProviderSelectViewController class]){
        sCloudProvider = @[
                           [CloudProvider providerWithName:@"IBM Watson IoT - Quickstart"
                                                     segue:@"BlueMxQuickStart_segue"],
                           [CloudProvider providerWithName:@"IBM Watson IoT"
                                                     segue:@"BlueMx_segue"],
                           [CloudProvider providerWithName:@"Generic Mqtt"
                                                     segue:@"GenericMqtt_segue"],
                        ];
        
    }
    
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if([segue.destinationViewController isKindOfClass:W2STCloudConfigViewController.class]){
        W2STCloudConfigViewController *temp = (W2STCloudConfigViewController *)segue.destinationViewController;
        temp.node=self.node;
    }
    
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    mCloudProviderList.dataSource=self;
    mCloudProviderList.delegate=self;
    [mCloudProviderList reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [sCloudProvider count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellTableIdentifier = @"CloudProviderName";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellTableIdentifier];
    
    cell.textLabel.text= sCloudProvider[indexPath.row].name;
    
    return cell;
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self performSegueWithIdentifier:sCloudProvider[indexPath.row].segue
                              sender:self];
    
}

@end
