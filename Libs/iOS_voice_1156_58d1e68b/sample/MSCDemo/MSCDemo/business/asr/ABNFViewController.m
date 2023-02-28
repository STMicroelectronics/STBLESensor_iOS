//
//  ABNFViewController.m
//  MSCDemo
//
//  Created by wangdan on 15-4-25.
//  Copyright (c) 2015年 iflytek. All rights reserved.
//

#import "ABNFViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Definition.h"
#import "PopupView.h"
#import "ISRDataHelper.h"
#import "IATConfig.h"


#define GRAMMAR_TYPE_BNF     @"bnf"
#define GRAMMAR_TYPE_ABNF    @"abnf"


@implementation ABNFViewController

static NSString * _cloudGrammerid =nil;//在线语法grammerID


#pragma mark - 视图生命周期

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.isCanceled = NO;
    self.curResult = [[NSMutableString alloc]init];
    self.grammarType = GRAMMAR_TYPE_ABNF;
    self.uploader = [[IFlyDataUploader alloc] init];
    
    CGFloat posY = self.textView.frame.origin.y+self.textView.frame.size.height/6;
    _popUpView = [[PopupView alloc] initWithFrame:CGRectMake(100, posY, 0, 0) withParentView:self.view];
    _textView.layer.borderColor = [[UIColor whiteColor] CGColor];
    _textView.layer.borderWidth = 0.5f;
    [_textView.layer setCornerRadius:7.0f];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initRecognizer];
    _cloudGrammerid =nil;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_iFlySpeechRecognizer cancel];    //终止识别
    [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    [super viewWillDisappear:animated];
}



- (void) dealloc
{
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Button handler

- (IBAction)starRecBtnHandler:(id)sender {
    
    self.textView.text = @"";
    
    //确保语法已经上传
    if (![self isCommitted]) {
        
        [_popUpView showText:@"   请先上传\
         语法"];
        [self.view addSubview:_popUpView];
        
        return;
    }
    
    //保存录音文件，保存在sdk工作路径中，如未设置工作路径，则默认保存在library/cache下
    [_iFlySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    //启动语法识别
    BOOL ret = [_iFlySpeechRecognizer startListening];
    
    if (ret) {
        
//        [_stopBtn setEnabled:YES];
//        [_cancelBtn setEnabled:YES];
        [_startRecBtn setEnabled:NO];
        [_uploadBtn setEnabled:NO];
        
        self.isCanceled = NO;
        [self.curResult setString:@""];
    }
    else{
        
        [_popUpView showText: @"启动识别服务失败，请稍后重试"];//可能是上次请求未结束
        [self.view addSubview:_popUpView];
    }

}


- (IBAction)stopBtnHandler:(id)sender {
    
    NSLog(@"%s",__func__);
    
    [_iFlySpeechRecognizer stopListening];
    [_textView resignFirstResponder];
}


- (IBAction)cancelBtnHandler:(id)sender {
    
    NSLog(@"%s",__func__);
    
    self.isCanceled = YES;
    [_iFlySpeechRecognizer cancel];
    [_textView resignFirstResponder];
}


- (IBAction)uploadBtnHandler:(id)sender {
    
    [_iFlySpeechRecognizer stopListening];
    [_uploadBtn setEnabled:NO];
    [_startRecBtn setEnabled:NO];
    [self showPopup];

    [self buildGrammer];    //构建语法
}

- (IBAction)onSetting:(id)sender {
    
    //解决多次快速点击导致出现多个设置界面
    if ([[self.navigationController topViewController] isKindOfClass:[ABNFViewController class]]){
        [self performSegueWithIdentifier:@"ASRSegue" sender:self];
    }
    
}

/**
 文件读取
 *****/
-(NSString *)readFile:(NSString *)filePath
{
    NSData *reader = [NSData dataWithContentsOfFile:filePath];
    return [[NSString alloc] initWithData:reader encoding:NSUTF8StringEncoding];
}



/**
 构建语法
 ****/
-(void) buildGrammer
{
    NSString *grammarContent = nil;
    NSString *appPath = [[NSBundle mainBundle] resourcePath];
    
    //设置字符编码
    [_iFlySpeechRecognizer setParameter:@"utf-8" forKey:[IFlySpeechConstant TEXT_ENCODING]];
    //设置识别模式
    [_iFlySpeechRecognizer setParameter:@"asr" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    
    //读取abnf内容
    NSString *bnfFilePath = [[NSString alloc] initWithFormat:@"%@/bnf/grammar_sample.abnf",appPath];
    grammarContent = [self readFile:bnfFilePath];
    
    //开始构建
    [_iFlySpeechRecognizer buildGrammarCompletionHandler:^(NSString * grammerID, IFlySpeechError *error){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (![error errorCode]) {
                
                NSLog(@"errorCode=%d",[error errorCode]);
               
                [_popUpView showText:@"上传成功"];
                
                _textView.text = grammarContent;
            }
            else {
                [_popUpView showText:@"上传失败"];
            }
            
            _cloudGrammerid = grammerID;
            
            //设置grammarid
            [_iFlySpeechRecognizer setParameter:_cloudGrammerid forKey:[IFlySpeechConstant CLOUD_GRAMMAR]];
            _uploadBtn.enabled = YES;
            _startRecBtn.enabled = YES;
        });
        
    }grammarType:self.grammarType grammarContent:grammarContent];
}


#pragma mark - IFlySpeechRecognizerDelegate

/**
 * 音量变化回调
 * volume   录音的音量，音量范围0~30
 ****/
- (void) onVolumeChanged: (int)volume
{
    NSString * vol = [NSString stringWithFormat:@"音量：%d",volume];
    
    [_popUpView showText: vol];
}

/**
 开始识别回调
 ****/
- (void) onBeginOfSpeech
{
    [_popUpView showText:@"正在录音"];
}

/**
 停止识别回调
 ****/
- (void) onEndOfSpeech
{
    [_popUpView showText: @"停止录音"];
}



/**
 识别结果回调（注：无论是否正确都会回调）
 error.errorCode =
 0     听写正确
 other 听写出错
 ****/
- (void) onError:(IFlySpeechError *) error
{
    NSLog(@"error=%d",[error errorCode]);
    
    NSString *text ;
    
    if (self.isCanceled) {
        text = @"识别取消";
    }
    else if (error.errorCode ==0 ) {
        
        if (self.curResult.length==0 || [self.curResult hasPrefix:@"nomatch"]) {
            
            text = @"无匹配结果";
        }
        else
        {
            text = @"识别成功";
            _textView.text = _curResult;
        }
    }
    else
    {
        text = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
        NSLog(@"%@",text);
    }
    
    [_popUpView showText: text];
    
//    [_stopBtn setEnabled:NO];
//    [_cancelBtn setEnabled:NO];
    [_uploadBtn setEnabled:YES];
    [_startRecBtn setEnabled:YES];
}


/**
 识别结果回调
 result 识别结果，NSArray的第一个元素为NSDictionary，
 NSDictionary的key为识别结果，value为置信度
 isLast：表示最后一次
 ****/
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    NSMutableString *result = [[NSMutableString alloc] init];
    NSMutableString * resultString = [[NSMutableString alloc]init];
    NSDictionary *dic = results[0];
    
    for (NSString *key in dic) {
        
        [result appendFormat:@"%@",key];
        
        NSString * resultFromJson =  [ISRDataHelper stringFromABNFJson:result];
        [resultString appendString:resultFromJson];
        
    }
    if (isLast) {
        
        NSLog(@"result is:%@",self.curResult);
    }
    
    [self.curResult appendString:resultString];

}

/**
 取消识别回调
 ****/
- (void) onCancel
{
    [_popUpView showText: @"正在取消"];
}




/**
 隐藏键盘
 ****/
-(void)onKeyBoardDown:(id) sender
{
    [_textView resignFirstResponder];
}



-(void) showPopup
{
    [_popUpView showText: @"正在上传..."];

}

-(BOOL) isCommitted
{
    if (_cloudGrammerid == nil || _cloudGrammerid.length == 0) {
        return NO;
    }
    
    return YES;
}


/**
 设置识别参数
 ****/
-(void)initRecognizer
{
    //语法识别实例
    
    //单例模式，无UI的实例
    if (_iFlySpeechRecognizer == nil) {
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    }
    _iFlySpeechRecognizer.delegate = self;
    
    if (_iFlySpeechRecognizer != nil) {
        IATConfig *instance = [IATConfig sharedInstance];
        
        //设置听写模式
        [_iFlySpeechRecognizer setParameter:@"asr" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
        //设置听写结果格式为json
        [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
        
        //参数意义与IATViewController保持一致，详情可以参照其解释
        [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
        [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
        [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        if ([instance.language isEqualToString:[IATConfig chinese]]) {
            [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
            [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
        }else if ([instance.language isEqualToString:[IATConfig english]]) {
            [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        }
    }
}



@end
