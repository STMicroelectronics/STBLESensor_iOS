//
//  W2STDemoTabViewController.h
//  W2STApp
//
//  Created by Giovanni Visentini on 12/05/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <BlueSTSDK/BlueSTSDKNode.h>

@interface W2STDemoTabViewController : UIViewController
    @property (weak,nonatomic) BlueSTSDKNode *node;

-(BlueSTSDKFeature*) getFeaureType:(Class)type;

@end
