//
//  RootViewController.h
//  MSCDemo
//
//  Created by wangdan on 15-4-25.
//  Copyright (c) 2015年 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PopupView;

@interface RootViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) PopupView * _popUpView;
@property (strong, nonatomic) IBOutlet UITableView *tbView;

@end
