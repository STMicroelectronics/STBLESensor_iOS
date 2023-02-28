//
//  ISRConfigViewController.m
//  MSCDemo_UI
//
//  Created by wangdan on 15-4-25.
//  Copyright (c) 2015年 iflytek. All rights reserved.
//

#import "TTSConfigViewController.h"
#import "TTSConfig.h"
#import "Definition.h"


@interface TTSConfigViewController ()

@end

@implementation TTSConfigViewController

#pragma mark - 视图生命周期
- (void)viewDidLoad {
    
    NSLog(@"%s[IN]",__func__);
    
    [super viewDidLoad];
    [self initView];
    
    NSLog(@"%s[OUT]",__func__);
}

- (void)viewWillAppear:(BOOL)animated{
    NSLog(@"%s[IN]",__func__);
    
    [super viewWillAppear:animated];

    [self needUpdateSettings];
    
    NSLog(@"%s[OUT]",__func__);
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    _backScrollView.contentSize = CGSizeMake(size.width ,size.height+300);
}

- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}


#pragma mark - 界面初始化

-(void)initView{
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ( IOS7_OR_LATER )
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.navigationController.navigationBar.translucent = NO;
    }
#endif
    
    self.view.backgroundColor = [UIColor colorWithRed:26.0/255.0 green:26.0/255.0 blue:26.0/255.0 alpha:1.0];
    
    
    
    TTSConfig *instance = [TTSConfig sharedInstance];
    
    // 初始化发音人选择界面
    
    _vcnPicker.delegate = self;
    _vcnPicker.dataSource = self;
    _vcnPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _vcnPicker.textColor = [UIColor whiteColor];
    _vcnPicker.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    _vcnPicker.highlightedFont = [UIFont fontWithName:@"HelveticaNeue" size:17];
    _vcnPicker.highlightedTextColor = [UIColor colorWithRed:0.0 green:168.0/255.0 blue:255.0/255.0 alpha:1.0];
    _vcnPicker.interitemSpacing = 20.0;
    _vcnPicker.fisheyeFactor = 0.001;
    _vcnPicker.pickerViewStyle = AKPickerViewStyle3D;
    _vcnPicker.maskDisabled = false;
    
    _backScrollView.canCancelContentTouches = YES;
    _backScrollView.delaysContentTouches = NO;//优先使用子页面的触摸事件
    
    
    // 初始化音量、语速、语调界面
    
    [_roundSlider addTarget:self action:@selector(onMultiSectorValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIColor *blueColor = [UIColor colorWithRed:0.0 green:168.0/255.0 blue:255.0/255.0 alpha:1.0];
    UIColor *redColor = [UIColor colorWithRed:245.0/255.0 green:76.0/255.0 blue:76.0/255.0 alpha:1.0];
    UIColor *greenColor = [UIColor colorWithRed:29.0/255.0 green:207.0/255.0 blue:0.0 alpha:1.0];
    
    _pitchSec = [SAMultisectorSector sectorWithColor:redColor maxValue:100];//前端点
    _speedSec = [SAMultisectorSector sectorWithColor:blueColor maxValue:100];//后端点
    _volumeSec = [SAMultisectorSector sectorWithColor:greenColor maxValue:100];//录音超时
    
    _pitchSec.endValue = instance.pitch.integerValue;
    _speedSec.endValue = instance.speed.integerValue;
    _volumeSec.endValue = instance.volume.integerValue;
    
    [_roundSlider addSector:_pitchSec];
    [_roundSlider addSector:_speedSec];
    [_roundSlider addSector:_volumeSec];//半径依次增大
    
}
#pragma mark  界面更新

-(void)needUpdateRound{
    
    TTSConfig *instance = [TTSConfig sharedInstance];
    
    //更新语速、音量、语调
    _speedLabel.text = instance.speed;//超时等时间设置
    _volumeLabel.text = instance.volume;
    _pitchLabel.text = instance.pitch;
    
    _speedSec.endValue = instance.speed.integerValue;
    _volumeSec.endValue = instance.volume.integerValue;
    _pitchSec.endValue = instance.pitch.integerValue;
}

-(void)needUpdateEngineType{
    
    TTSConfig *instance = [TTSConfig sharedInstance];
    
    //更新引擎类型
    NSString *type = instance.engineType;
    if ([type isEqualToString:[IFlySpeechConstant TYPE_CLOUD]]) {
        _engineTypeSeg.selectedSegmentIndex = 0;
        _sampleRateSeg.hidden = NO;
        
    }else if ([type isEqualToString:[IFlySpeechConstant TYPE_LOCAL]]) {
        _engineTypeSeg.selectedSegmentIndex = 1;
        _sampleRateSeg.hidden = YES;
    }
    
}

-(void)needUpdateSampleRate{
    
    TTSConfig *instance = [TTSConfig sharedInstance];
    
    //更新采样率
    NSString *sampleRate = instance.sampleRate;//采样率
    if ([sampleRate isEqualToString:[IFlySpeechConstant SAMPLE_RATE_16K]]) {
        _sampleRateSeg.selectedSegmentIndex = 0;
        
    }else if ([sampleRate isEqualToString:[IFlySpeechConstant SAMPLE_RATE_8K]]) {
        _sampleRateSeg.selectedSegmentIndex = 1;
        
    }
}

-(void)needUpdateVcn{
    
    TTSConfig *instance = [TTSConfig sharedInstance];
    
    //更新发音人
    
    [self.vcnPicker reloadData];
    int vcnIndex= 0;
    if([instance.engineType isEqualToString: [IFlySpeechConstant TYPE_LOCAL]]){
        for (int i = 0;i < self.spVcnList.count; i++) {
            if([[[self.spVcnList objectAtIndex:i] objectForKey:@"name"] isEqualToString:instance.vcnName]){
                vcnIndex=i;
                break;
            }
        }
        [_vcnPicker selectItem:vcnIndex animated:NO];
    }
    else{
        for (int i = 0;i < instance.vcnIdentiferArray.count; i++) {
            if ([[instance.vcnIdentiferArray objectAtIndex:i] isEqualToString:instance.vcnName]) {
                vcnIndex=i;
                break;
            }
        }
        [_vcnPicker selectItem:vcnIndex animated:NO];
    }
}

-(void)needUpdateSettings{
    [self needUpdateRound];
    [self needUpdateEngineType];
    [self needUpdateSampleRate];
    [self needUpdateVcn];
    
}


#pragma mark - 界面操作响应


- (void)onMultiSectorValueChanged:(id)sender{
    
    TTSConfig *instance = [TTSConfig sharedInstance];
    instance.speed = [NSString stringWithFormat:@"%d", (int)_speedSec.endValue];
    instance.volume = [NSString stringWithFormat:@"%d", (int)_volumeSec.endValue];
    instance.pitch = [NSString stringWithFormat:@"%d", (int)_pitchSec.endValue];
    
    
    _speedLabel.text = instance.speed;
    _volumeLabel.text = instance.volume;
    _pitchLabel.text = instance.pitch;
    
    _speedSec.endValue = [instance.speed integerValue];
    _volumeSec.endValue = [instance.volume integerValue];
    _pitchSec.endValue = [instance.pitch integerValue];
}


- (IBAction)onSampleRateSegValueChanged:(id)sender {
    
    TTSConfig *instance = [TTSConfig sharedInstance];
    UISegmentedControl *seg = (UISegmentedControl*) sender;
    
    if (seg.selectedSegmentIndex == 0) {
        instance.sampleRate = [IFlySpeechConstant SAMPLE_RATE_16K];
    }else if (seg.selectedSegmentIndex == 1) {
        instance.sampleRate = [IFlySpeechConstant SAMPLE_RATE_8K];
    }
}


/*
 引擎模式选择处理
 支持云端和离线两种工作模式。
 */
- (IBAction)onEngineTypeSegValueChanged:(id)sender {
    
    NSLog(@"%s[IN]",__func__);
    
    TTSConfig *instance = [TTSConfig sharedInstance];
    UISegmentedControl *seg = (UISegmentedControl*) sender;
    
    if (seg.selectedSegmentIndex == 0) {
        instance.engineType = [IFlySpeechConstant TYPE_AUTO];
    }else if (seg.selectedSegmentIndex == 1) {
        instance.engineType = [IFlySpeechConstant TYPE_CLOUD];
    }else if (seg.selectedSegmentIndex == 2) {
        seg.selectedSegmentIndex = 0;
        instance.engineType = [IFlySpeechConstant TYPE_AUTO];
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                         message:@"本Demo未集成本地合成功能，如需使用请前往http://www.xfyun.cn下载，谢谢!"
                                                        delegate:self cancelButtonTitle:@"好哒^_^"
                                               otherButtonTitles:nil];
        [alert show];
    }
    
    NSLog(@"%s[OUT]",__func__);
}

#pragma mark - 发音人设置相关
#pragma mark  AKPickerViewDataSource

- (NSUInteger)numberOfItemsInPickerView:(AKPickerView *)pickerView{
    
    //    NSLog(@"%s[IN]",__func__);
    
    NSUInteger count = 1;
    
    TTSConfig* instance = [TTSConfig sharedInstance];
    
    //离线模式
    if(instance.engineType == [IFlySpeechConstant TYPE_LOCAL]){
        if(self.spVcnList == nil){
            count = 1;
        }
        else{
            count = self.spVcnList.count;
        }
    }
    else{
        count = instance.vcnIdentiferArray.count;
    }
    
    //    NSLog(@"%s,count=%d[OUT]",__func__,count);
    
    return count;
}

- (NSString *)pickerView:(AKPickerView *)pickerView titleForItem:(NSInteger)item{
    
    //    NSLog(@"%s[IN],item=%d",__func__,item);
    
    TTSConfig* instance = [TTSConfig sharedInstance];
    
    NSString *title = nil;
    
    //离线模式
    if(instance.engineType == [IFlySpeechConstant TYPE_LOCAL]){
        if(self.spVcnList.count > 0 && self.spVcnList.count > item){
            title = [[self.spVcnList objectAtIndex:item] objectForKey:@"nickname"];
        }
    }
    else{
        
        if(instance.vcnNickNameArray.count > item){
            title = [instance.vcnNickNameArray objectAtIndex:item];
        }
    }
    
    //    NSLog(@"%s[OUT],title=%@",__func__,title);
    
    return title;
}

#pragma mark   AKPickerViewDelegate
- (void)pickerView:(AKPickerView *)pickerView didSelectItem:(NSInteger)item{
    
    TTSConfig *instance = [TTSConfig sharedInstance];
    
    //    NSLog(@"%s[IN],item=%d",__func__,item);
    
    //离线模式
    if(instance.engineType == [IFlySpeechConstant TYPE_LOCAL])
    {
        if(self.spVcnList.count > 0 && self.spVcnList.count > item)
        {
            instance.vcnName = [[self.spVcnList objectAtIndex:item] objectForKey:@"name"];
            
            //显示从语记下载的发音人信息
            NSDictionary *info = [self.spVcnList objectAtIndex:item];
            NSString *vcnInfo= @"";
            
            //发音人名称
            NSString *name = [info objectForKey:@"name"];
            if(name){
                vcnInfo = [vcnInfo stringByAppendingFormat:@"\n姓名：%@",name];
            }
            
            //别名
            NSString *nickname = [info objectForKey:@"nickname"];
            if(nickname){
                vcnInfo = [vcnInfo stringByAppendingFormat:@"\n别名：%@",nickname];
            }
            
            //年龄
            NSString *age = [info objectForKey:@"age"];
            if(age){
                vcnInfo = [vcnInfo stringByAppendingFormat:@"\n年龄：%@",age];
            }
            
            //性别
            NSString *sex = [info objectForKey:@"sex"];
            if(sex){
                vcnInfo = [vcnInfo stringByAppendingFormat:@"\n性别：%@",sex];
            }
            
            NSLog(@"vcnInfo:%@",vcnInfo);
        }
    }
    else
    {
        instance.vcnName = [instance.vcnIdentiferArray objectAtIndex:item];
    }
    
    //    NSLog(@"%s[OUT]",__func__);
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 2 && buttonIndex == 1) {
        NSString *url = [IFlySpeechUtility  componentUrl];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

@end
