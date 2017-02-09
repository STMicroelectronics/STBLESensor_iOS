//
//  W2STDemoTabViewController.m
//  W2STApp
//
//  Created by Giovanni Visentini on 12/05/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STDemoTabViewController.h"

@interface W2STDemoTabViewController ()
@end

@implementation W2STDemoTabViewController{}

-(W2STSDKFeature*) getFeaureType:(Class)type{
    NSArray *features = [self.node getFeatures];
    
    NSUInteger featureIdx = [features indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass: type]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    if(featureIdx == NSNotFound){
        return nil;
    }//else
    return [features objectAtIndex:featureIdx];
}

@end