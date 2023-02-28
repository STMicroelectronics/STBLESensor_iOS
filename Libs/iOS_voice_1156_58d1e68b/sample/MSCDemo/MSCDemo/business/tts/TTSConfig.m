//
//  TTSConfig.m
//  MSCDemo_UI
//
//  Created by wangdan on 15-4-25.
//  Copyright (c) 2015年 iflytek. All rights reserved.
//

#import "TTSConfig.h"

@implementation TTSConfig

-(id)init {
    self  = [super init];
    if (self) {
        [self defaultSetting];
        return  self;
    }
    return nil;
}

+(TTSConfig *)sharedInstance {
    static TTSConfig  * instance = nil;
    static dispatch_once_t predict;
    dispatch_once(&predict, ^{
        instance = [[TTSConfig alloc] init];
    });
    return instance;
}


-(void)defaultSetting {
    _speed = @"50";
    _volume = @"50";
    _pitch = @"50";
    _sampleRate = @"16000";
    _engineType = @"auto";
    _vcnName = @"xiaoyan";
    
    
//    云端支持发音人：小燕（xiaoyan）、小宇（xiaoyu）、凯瑟琳（Catherine）、
//    亨利（henry）、玛丽（vimary）、小研（vixy）、小琪（vixq）、
//    小峰（vixf）、小梅（vixm）、小莉（vixl）、小蓉（四川话）、
//    小芸（vixyun）、小坤（vixk）、小强（vixqa）、小莹（vixying）、 小新（vixx）、楠楠（vinn）老孙（vils）<br>
//    对于网络TTS的发音人角色，不同引擎类型支持的发音人不同，使用中请注意选择。
    
    

    _vcnNickNameArray = @[@"小燕", @"小宇", @"小研", @"小琪",@"小峰",@"小新",@"小坤",@"维语",@"越南语",@"印地语",@"西班牙语",@"俄语",@"法语"];
    _vcnIdentiferArray = @[@"xiaoyan",@"xiaoyu",@"vixy",@"vixq",@"vixf",@"vixx",@"vixk",@"Guli",@"XiaoYun",@"Abha",@"Gabriela",@"Allabent",@"Mariane"];
}


@end
