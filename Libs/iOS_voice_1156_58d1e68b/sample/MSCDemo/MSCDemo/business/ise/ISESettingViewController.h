//
//  ISESettingViewController.h
//  MSCDemo_UI
//
//  Created by 张剑 on 15/1/16.
//
//

#import <UIKit/UIKit.h>

@class ISEParams;

@protocol ISESettingDelegate <NSObject>

- (void)onParamsChanged:(ISEParams *)params;

@end

@interface ISESettingViewController : UITableViewController <UIActionSheetDelegate,UITextFieldDelegate>

@property (nonatomic, strong) ISEParams *iseParams;
@property (nonatomic, weak) id <ISESettingDelegate> delegate;

@end
