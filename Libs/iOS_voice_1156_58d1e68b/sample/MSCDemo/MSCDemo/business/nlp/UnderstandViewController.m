//
//  UnderstandViewController.m
//  MSCDemo_UI
//
//  Created by wangdan on 15-4-25.
//  Copyright (c) 2015年 iflytek. All rights reserved.
//

#import "UnderstandViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "iflyMSC/IFlyMSC.h"
#import "Definition.h"
#import "IATConfig.h"
#import "PopupView.h"
@implementation UnderstandViewController


#pragma mark - 视图生命周期

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    CGFloat posY = self.textView.frame.origin.y+self.textView.frame.size.height/6;
    _popUpView = [[PopupView alloc] initWithFrame:CGRectMake(100, posY, 0, 0) withParentView:self.view];
    
//    _popUpView = [[PopupView alloc]initWithFrame:CGRectMake(100, 100, 0, 0) withParentView:self.view];
    
    _iFlySpeechUnderstander = [IFlySpeechUnderstander sharedInstance];
    _iFlySpeechUnderstander.delegate = self;
    
    _defaultText = @"北京到上海的火车";
    _textView.text = [NSString stringWithFormat:@"你可以输入:\n%@ \n明天下午3点提醒我4点开会\n牛顿第一定律\n1+101+524/(2+38)*85",self.defaultText];
    
    
    UIBarButtonItem *spaceBtnItem= [[ UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem * hideBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"隐藏" style:UIBarButtonItemStylePlain target:self action:@selector(onKeyBoardDown:)];
    [hideBtnItem setTintColor:[UIColor whiteColor]];
    UIToolbar * toolbar = [[ UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    NSArray * array = [NSArray arrayWithObjects:spaceBtnItem,hideBtnItem, nil];
    [toolbar setItems:array];
    _textView.inputAccessoryView = toolbar;
    
    _textView.layer.borderWidth = 0.5f;
    _textView.layer.borderColor = [[UIColor whiteColor] CGColor];
    [_textView.layer setCornerRadius:7.0f];
    

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [_onlineRecBtn setEnabled:YES];
    [_cancelBtn setEnabled:YES];
    [_stopBtn setEnabled:YES];
    [_textUnderBtn setEnabled:YES];
    
    self.isSpeechUnderstander = NO;
    self.isTextUnderstander = NO;
    
    [super viewWillAppear:animated];
    [self initRecognizer];
}



- (void)viewWillDisappear:(BOOL)animated
{
    [_iFlySpeechUnderstander cancel];//终止语义
    [_iFlySpeechUnderstander setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - 按钮响应事件

/**
 文本语义理解启动
 ****/
- (IBAction)textUnderBtnHandler:(id)sender {
    
    if (self.isSpeechUnderstander){
        return;
    }
    
    NSLog(@"%s",__func__);
    
    if(self.iFlyUnderStand == nil)
    {
        self.iFlyUnderStand = [[IFlyTextUnderstander alloc] init];
    }

    NSString * text;
    
    if ([_textView.text isEqualToString:@""]){
        text  = _defaultText;
    }else {
        text =_textView.text;
    }
    
    self.isTextUnderstander = YES;

    //启动文本语义搜索
    [self.iFlyUnderStand understandText:text withCompletionHandler:^(NSString* restult, IFlySpeechError* error)
     {
         NSLog(@"result is : %@",restult);
         _textView.text = restult;
         if (error!=nil && error.errorCode!=0) {
             
             NSString* errorText = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
             
             [self.popUpView setText: errorText];
             [self.view addSubview:self.popUpView];
         }
         
         self.isTextUnderstander = NO;
         
     }];
}


/**
 语音语义理解启动
 ****/
- (IBAction)onlinRecBtnHandler:(id)sender {
    
    if (self.isTextUnderstander){
        return;
    }
    
    NSLog(@"%s",__func__);
    
    [_textView setText:@""];
    [_textView resignFirstResponder];
    
    //设置为麦克风输入语音
    [_iFlySpeechUnderstander setParameter:IFLY_AUDIO_SOURCE_MIC forKey:@"audio_source"];
    
    bool ret = [_iFlySpeechUnderstander startListening];
    
    if (ret) {
        
        self.isSpeechUnderstander = YES;
        
        [_onlineRecBtn setEnabled:NO];
        [_cancelBtn setEnabled:YES];
        [_stopBtn setEnabled:YES];
        
        [_textUnderBtn setEnabled:NO];
        
        self.isCanceled = NO;
        
        
    }
    else
    {
        [_popUpView showText: @"启动识别服务失败，请稍后重试"];//可能是上次请求未结束
    }
}



/**
 停止录音
 ****/
- (IBAction)stopBtnHandler:(id)sender {
    
    [_iFlySpeechUnderstander stopListening];

    [_textView resignFirstResponder];
}


/**
 取消
 ****/
- (IBAction)cancelBtnHandler:(id)sender {
    self.isCanceled = YES;

    
    [_iFlySpeechUnderstander cancel];
    
    [_popUpView removeFromSuperview];
    [_textView resignFirstResponder];
}


/**
 清空按钮响应函数
 ****/
- (IBAction)clearBtnHandler:(id)sender {
    
    
    _textView.text = @"";
}


- (IBAction)onSetting:(id)sender {
    
    //解决多次快速点击导致出现多个设置界面
    if ([[self.navigationController topViewController] isKindOfClass:[UnderstandViewController class]]){
        [self performSegueWithIdentifier:@"NLPSegue" sender:self];
    }
    
}



#pragma mark - View lifecycle
/**
 隐藏键盘
 ****/
-(void)onKeyBoardDown:(id) sender
{
    [_textView resignFirstResponder];
}

#pragma mark - 识别回调 IFlySpeechRecognizerDelegate
/**
 音量变化回调
 volume 录音的音量，音量范围0~30
 ****/
- (void) onVolumeChanged: (int)volume
{
    if (self.isCanceled) {
        [_popUpView removeFromSuperview];
        return;
    }
    
    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
    [_popUpView showText: vol];
}


/**
 开始识别回调
 ****/
- (void) onBeginOfSpeech
{
    [_popUpView showText: @"正在录音"];
}

/**
 停止录音回调
 ****/
- (void) onEndOfSpeech
{
    [_popUpView showText: @"停止录音"];
}


/**
 语义理解服务结束回调（注：无论是否正确都会回调）
 error.errorCode =
 0     听写正确
 other 听写出错
 ****/
- (void) onError:(IFlySpeechError *) error
{
    NSLog(@"%s",__func__);
    
    NSString *text ;
    if (self.isCanceled) {
        text = @"语义理解取消";
    }
    else if (error.errorCode ==0 ) {
        if (_result.length==0) {
            text = @"无识别结果";
        }
        else
        {
            text = @"识别成功";
        }
    }
    else
    {
        text = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
        NSLog(@"%@",text);
    }
    
    [_popUpView showText: text];
    
    self.isSpeechUnderstander = NO;
    
//    [_stopBtn setEnabled:NO];
//    [_cancelBtn setEnabled:NO];
    [_textUnderBtn setEnabled:YES];
    [_onlineRecBtn setEnabled:YES];
}


/**
 语义理解结果回调
 result 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度
 isLast：表示最后一次
 ****/
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSDictionary *dic = results [0];
    
    for (NSString *key in dic) {
        [result appendFormat:@"%@",key];
    }
    
    NSLog(@"听写结果：%@",result);
    
    _result = result;
    _textView.text = [NSString stringWithFormat:@"%@%@", _textView.text,result];
    [_textView scrollRangeToVisible:NSMakeRange([_textView.text length], 0)];
}




/**
 取消回调
 当调用了[_iFlySpeechUnderstander cancel]后，会回调此函数，
 ****/
- (void) onCancel
{
    NSLog(@"识别取消");
}


/**
 设置识别参数
 ****/
-(void)initRecognizer
{
    //语义理解单例
    if (_iFlySpeechUnderstander == nil) {
        _iFlySpeechUnderstander = [IFlySpeechUnderstander sharedInstance];
    }
    
    _iFlySpeechUnderstander.delegate = self;
    
    if (_iFlySpeechUnderstander != nil) {
        IATConfig *instance = [IATConfig sharedInstance];
        
        //参数意义与IATViewController保持一致，详情可以参照其解释
        [_iFlySpeechUnderstander setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        [_iFlySpeechUnderstander setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
        [_iFlySpeechUnderstander setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
        [_iFlySpeechUnderstander setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        
        if ([instance.language isEqualToString:[IATConfig chinese]]) {
            [_iFlySpeechUnderstander setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            [_iFlySpeechUnderstander setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
        }else if ([instance.language isEqualToString:[IATConfig english]]) {
            [_iFlySpeechUnderstander setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        }
        [_iFlySpeechUnderstander setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
    }
}

@end
