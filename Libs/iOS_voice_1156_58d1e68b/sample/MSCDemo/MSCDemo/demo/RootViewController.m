//
//  RootViewController.m
//  MSCDemo
//
//  Created by wangdan on 15-4-25.
//  Copyright (c) 2015年 iflytek. All rights reserved.
//

#import "RootViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "Definition.h"
#import "PopupView.h"

#import "iflyMSC/IFlyMSC.h"

/*
 SDK Demo包含以下功能：
 1.语音识别
 2.语义理解
 3.语法识别
 4.语音合成
 5.语音评测
 6.语音唤醒（仅提醒）
 7.声纹识别（仅提醒）
*/

@implementation RootViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ( IOS7_OR_LATER )
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.navigationController.navigationBar.translucent = NO;
    }
#endif
    _tbView.delegate = self;
    _tbView.dataSource = self;
    _tbView.separatorColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
    
    
    
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"返回";
    temporaryBarButtonItem.target = self;
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if ( indexPath.row == 5 || indexPath.row == 6) {
            UIAlertView *alert =
            [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                       message:@"本Demo暂未集成该功能，如需使用请前往http://www.xfyun.cn下载，谢谢!"
                                      delegate:self
                             cancelButtonTitle:@"好哒^_^" otherButtonTitles:nil];
            [alert show];
        }
        
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, 0.5)];
        view.backgroundColor = [UIColor blackColor];
        return  view;
    }else {
        return nil;
    }
}

@end
