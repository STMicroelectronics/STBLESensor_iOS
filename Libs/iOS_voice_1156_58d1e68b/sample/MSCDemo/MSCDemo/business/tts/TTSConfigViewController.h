//
//  TTSConfigViewController.h
//  MSCDemo_UI
//
//  Created by wangdan on 15-4-25.
//  Copyright (c) 2015年 iflytek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SAMultisectorControl.h"
#import "AKPickerView.h"
#import "iflyMSC/iflyMSC.h"

/*
 IFlySpeechPlusDelegate是从语记返回后的回调
 */
@interface TTSConfigViewController : UIViewController<AKPickerViewDataSource,AKPickerViewDelegate>

/**
 *  背景界面
 */
@property (weak, nonatomic) IBOutlet UIScrollView *backScrollView;

/**
 *  音量、语速、语调 设置子控件
 */
@property (strong, nonatomic)  SAMultisectorSector *volumeSec;
@property (strong, nonatomic)  SAMultisectorSector *speedSec;
@property (strong, nonatomic)  SAMultisectorSector *pitchSec;

/**
 *  子控件容器
 */
@property (weak, nonatomic) IBOutlet SAMultisectorControl *roundSlider;

@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *pitchLabel;

/**
 *  发音人选择控件
 */
@property (weak, nonatomic) IBOutlet AKPickerView *vcnPicker;

/**
 *  采样率选择
 */
@property (strong, nonatomic) IBOutlet UISegmentedControl *sampleRateSeg;

/**
 *  引擎类别
 */
@property (strong, nonatomic) IBOutlet UISegmentedControl *engineTypeSeg;

/**
 *  发音人列表
 */
@property (nonatomic, strong) NSArray *spVcnList;

@end
