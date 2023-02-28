//
//  ABNFViewController.h
//  MSCDemo
//
//  Created by wangdan on 15-4-25.
//  Copyright (c) 2015年 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iflyMSC/iflyMSC.h"

@class PopupView;
@class IFlyDataUploader;
@class IFlySpeechRecognizer;

/**
 abnf语法识别demo
 使用该功能需要下面步骤：
 1. 创建识别对象，数据上传对象；
 2. 上传语法内容，然后获取grammarID,参照ABNFViewController.m的buildGrammer实现；
 3. 将grammarID作为参数设置到识别对象中；
 4. 有选择的实现识别回调；
 5. 启动识别
 ****/


@interface ABNFViewController : UIViewController<IFlySpeechRecognizerDelegate,UIActionSheetDelegate>


@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;//语法识别对象
@property (nonatomic, strong) IFlyDataUploader *uploader;//数据上传对象

@property (nonatomic, strong) PopupView *popUpView;


@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *uploadBtn;
@property (weak, nonatomic) IBOutlet UIButton *startRecBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;


@property (nonatomic, assign) BOOL isCanceled;
@property (nonatomic, strong) NSString *grammarType; //语法类型
@property (nonatomic, strong) NSMutableString *curResult;//当前session的结果
@end
