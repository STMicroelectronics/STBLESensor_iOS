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


#import <BlueSTSDK/BlueSTSDKStdCharToFeatureMap.h>
#import <BlueSTSDK_Gui/BlueSTSDKMainViewController.h>

#import "BlueMSMainViewController.h"
#include "BlueMSDemosViewController.h"



@interface BlueMSMainViewController ()<BlueSTSDKAboutViewControllerDelegate,
BlueSTSDKNodeListViewControllerDelegate>

@end

@implementation BlueMSMainViewController

/**
 *  laod the BlueSTSDKMainView and set the delegate for it
 */
-(void)viewDidLoad{
    [super viewDidLoad];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"BlueSTSDKMainView"
                                                         bundle:[NSBundle bundleForClass:BlueSTSDKMainViewController.class]
                                ];
    
    BlueSTSDKMainViewController *mainView = [storyBoard instantiateInitialViewController];
    mainView.delegateMain=nil;
    mainView.delegateAbout=self;
    mainView.delegateNodeList=self;
    
    [self pushViewController:mainView animated:TRUE];
}

#pragma mark - BlueSTSDKAboutViewControllerDelegate

- (NSString*) htmlFile{
    NSBundle *bundle = [NSBundle mainBundle];
    return [bundle pathForResource:@"text" ofType:@"html"];
}

- (UIImage*) headImage{
    return [UIImage imageNamed:@"press_contact.jpg"];
}

#pragma mark - BlueSTSDKNodeListViewControllerDelegate

/**
 *  filter the node for show only the ones with remote features
 *
 *  @param node node to filter
 *
 */
-(bool) displayNode:(BlueSTSDKNode*)node{
    [node addExternalCharacteristics:[BlueSTSDKStdCharToFeatureMap getManageStdCharacteristics]];
    return true;
}


/**
 *  when the user select a node show the main view form the DemoView storyboard
 *
 *  @param node node selected
 *
 *  @return controller with the demo to show
 */
-(UIViewController*) demoViewControllerWithNode:(BlueSTSDKNode*)node
                                    menuManager:(id<BlueSTSDKViewControllerMenuDelegate>)menuManager{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"BlueMS" bundle:nil];
    
    BlueMSDemosViewController *mainView = [storyBoard instantiateInitialViewController];
    mainView.node=node;
    mainView.menuDelegate = menuManager;
    
    return mainView;
}

@end
