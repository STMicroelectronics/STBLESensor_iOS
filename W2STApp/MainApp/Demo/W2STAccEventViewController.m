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

#import <BlueSTSDK/BlueSTSDKFeatureAccelerometerEvent.h>

#import "W2STAccEventViewController.h"
#import "W2STAccEventSingleEventDisplayViewController.h"
#import "W2STAccEventMultipleEventDisplayViewController.h"
#import "W2STSelectAccEventViewController.h"

#define DEFAULT_EVENT_INDEX 1

static BlueSTSDKFeatureAccelerationDetectableEventType sEventType_Wesu[] ={
    BlueSTSDKFeatureEventTypeNone,
    BlueSTSDKFeatureEventTypeMultiple
};

static BlueSTSDKFeatureAccelerationDetectableEventType sEventType_Nucleo[] ={
    BlueSTSDKFeatureEventTypeNone,
    BlueSTSDKFeatureEventTypeOrientation,
    BlueSTSDKFeatureEventTypeFreeFall,
    BlueSTSDKFeatureEventTypeSingleTap,
    BlueSTSDKFeatureEventTypeDoubleTap,
    BlueSTSDKFeatureEventTypeWakeUp,
    BlueSTSDKFeatureEventTypeTilt,
    BlueSTSDKFeatureEventTypePedometer
};

#define TITLE_FORMAT @"Event Enabled: %@"
#define DEFAULT_TITLE @"Select event"

@interface W2STAccEventViewController ()< UIPickerViewDataSource,
    UIPickerViewDelegate,
    W2STSelectAccEventDelegate, BlueSTSDKFeatureDelegate,
    BlueSTSDKFeatureAccelerationEnableTypeDelegate>

@end

@implementation W2STAccEventViewController{
    /**
     *  feature that will send the data
     */
    BlueSTSDKFeatureAccelerometerEvent *mAccEventFeature;
    NSInteger mCurrentEventTypeIndex;
    
    W2STAccEventSingleEventDisplayViewController *mSingleEventView;
    W2STAccEventMultipleEventDisplayViewController *mMultipleEventView;
    
    BlueSTSDKFeatureAccelerationDetectableEventType *mSupportedEventType;
    NSUInteger mSupportedEventTypeSize;
}


-(void)setEventTitleLabel:(BlueSTSDKFeatureAccelerationDetectableEventType)event{
    
    NSString *newButtonTitle;
    if(event != BlueSTSDKFeatureEventTypeNone){
        newButtonTitle=[NSString stringWithFormat:TITLE_FORMAT,
                               [BlueSTSDKFeatureAccelerometerEvent detectableEventTypeToString:event]];
    }else{
        newButtonTitle =DEFAULT_TITLE;
    }//if-else
    
    [_selectEventButton setTitle:newButtonTitle forState:UIControlStateNormal];

}

-(void)setSupportedEventTypeForNode:(BlueSTSDKNodeType)type{
    if(type==BlueSTSDKNodeTypeSTEVAL_WESU1){
        mSupportedEventType = sEventType_Wesu;
        mSupportedEventTypeSize = sizeof(sEventType_Wesu)/sizeof(BlueSTSDKFeatureAccelerationDetectableEventType);
        return;
    }
    mSupportedEventType = sEventType_Nucleo;
    mSupportedEventTypeSize = sizeof(sEventType_Nucleo)/sizeof(BlueSTSDKFeatureAccelerationDetectableEventType);
    
}

-(void)viewDidLoad{
    [super viewDidLoad];
    mCurrentEventTypeIndex=-1;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //enable the notification
    mAccEventFeature = (BlueSTSDKFeatureAccelerometerEvent*)
        [self.node getFeatureOfType:BlueSTSDKFeatureAccelerometerEvent.class];
    [self setEventTitleLabel:BlueSTSDKFeatureEventTypeNone];
    [self setSupportedEventTypeForNode:self.node.type];
    if(mAccEventFeature!=nil){
        [mAccEventFeature addFeatureDelegate:self];
        [mAccEventFeature addFeatureAccelerationEnableTypeDelegate:self];
        [self.node enableNotification:mAccEventFeature];
        if(mCurrentEventTypeIndex<0) // if it is the first time, set the default demo
            [self selectEventAtIndex:DEFAULT_EVENT_INDEX];
        else{
            //force the new event
            NSInteger temp = mCurrentEventTypeIndex;
            mCurrentEventTypeIndex=-1;
            [self selectEventAtIndex:temp];
        }
        //[self.node readFeature:mAccEventFeature];
    }else{
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(mAccEventFeature!=nil){
        [mAccEventFeature removeFeatureDelegate:self];
        [mAccEventFeature removeFeatureAccelerationEnableTypeDelegate:self];
        [self.node disableNotification:mAccEventFeature];
        mAccEventFeature=nil;
    }//if
}

#pragma mark - BlueSTSDKFeatureDelegate
- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample{
        const BlueSTSDKFeatureAccelerometerEventType event =
            [BlueSTSDKFeatureAccelerometerEvent getAccelerationEvent:sample];
    
        const int32_t nSteps = [BlueSTSDKFeatureAccelerometerEvent getPedometerSteps:sample];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayEventType:event data:nSteps];
        });
    
    }

#pragma mark - BlueSTSDKFeatureAccelerationEnableTypeDelegate
-(void)didTypeChangeStatus:(BlueSTSDKFeatureAccelerometerEvent *)feature
                      type:(BlueSTSDKFeatureAccelerationDetectableEventType)type
                 newStatus:(BOOL)newStatus{
    NSLog(@"Event %@ Status:%d",[BlueSTSDKFeatureAccelerometerEvent detectableEventTypeToString:type],newStatus);
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.destinationViewController isKindOfClass:W2STSelectAccEventViewController.class]){
        W2STSelectAccEventViewController *temp = (W2STSelectAccEventViewController *)segue.destinationViewController;
        temp.delegate=self;
        temp.pickerDataDelegate=self;
        temp.pickerDelegate=self;
        
        //needed for center the ancor in the center bottom instead of the top left corner..
        UIPopoverPresentationController* possiblePopOver =temp.popoverPresentationController;
        possiblePopOver.sourceRect = possiblePopOver.sourceView.bounds;

        return;
    }//if
    if([segue.destinationViewController isKindOfClass:W2STAccEventSingleEventDisplayViewController.class]){
        mSingleEventView = segue.destinationViewController;
        return;
    }
    if([segue.destinationViewController isKindOfClass:W2STAccEventMultipleEventDisplayViewController.class]){
        mMultipleEventView = segue.destinationViewController;
        return;
    }

}

-(void) selectEventAtIndex:(NSUInteger)row{
    
    BlueSTSDKFeatureAccelerationDetectableEventType selectEvent;
    if (row>mSupportedEventTypeSize)
        selectEvent = BlueSTSDKFeatureEventTypeNone;
    else
        selectEvent= mSupportedEventType[row];
    
    if(mCurrentEventTypeIndex!=row){ // the user select the something new
        mCurrentEventTypeIndex=row;
        [mAccEventFeature enableEvent:selectEvent enable:true];
        [self setEventTitleLabel:mSupportedEventType[row]];
        if(selectEvent==BlueSTSDKFeatureEventTypeMultiple){
            mMultipleEventView.view.hidden=NO;
            mSingleEventView.view.hidden=YES;
        }else{
            mMultipleEventView.view.hidden=YES;
            mSingleEventView.view.hidden=NO;
        }
        [self enableEventType:selectEvent];
    }
    
}


-(void)displayEventType:(BlueSTSDKFeatureAccelerometerEventType) event data:(int32_t)eventData{
    if(mSingleEventView.view.hidden==NO){
        [mSingleEventView displayEventType:event data:eventData];
    }
    if(mMultipleEventView.view.hidden==NO){
        [mMultipleEventView displayEventType:event data:eventData];
    }
}

-(void)enableEventType:(BlueSTSDKFeatureAccelerationDetectableEventType) event{
    if(mSingleEventView.view.hidden==NO){
        [mSingleEventView enableEventType:event];
    }
    if(mMultipleEventView.view.hidden==NO){
        [mMultipleEventView enableEventType:event];
    }
        
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component{
    return mSupportedEventTypeSize;
}

#pragma mark -  UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component{
    
    BlueSTSDKFeatureAccelerationDetectableEventType temp = mSupportedEventType[row];
    return [BlueSTSDKFeatureAccelerometerEvent detectableEventTypeToString:temp];
}


@end
