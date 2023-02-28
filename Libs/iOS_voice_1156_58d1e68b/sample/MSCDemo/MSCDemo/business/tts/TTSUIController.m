//
//  TTSUIController.m
//  MSCDemo_UI
//
//  Created by wangdan on 15-4-25.
//  Copyright (c) 2015年 iflytek. All rights reserved.
//

#import "TTSUIController.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVAudioSession.h>
#import <AudioToolbox/AudioSession.h>
#import "Definition.h"
#import "PopupView.h"
#import "AlertView.h"
#import "TTSConfig.h"

/*
 术语定义：
 demo中合成共包含两种工作方式：
 1.边合成边播放方式，简称通用合成；
 2.uri，只合成不播放方式，简称uir合成；
 以下demo中注释将采用简称。
 */

@interface TTSUIController ()<IFlySpeechSynthesizerDelegate,UIActionSheetDelegate>
@end

@implementation TTSUIController

#pragma mark - 视图生命周期

- (void)viewDidLoad
{
     [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;

     UIBarButtonItem *spaceBtnItem = [[ UIBarButtonItem alloc]     //键盘
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                     target:nil action:nil];
    
     UIBarButtonItem *hideBtnItem = [[UIBarButtonItem alloc]
                                      initWithTitle:@"隐藏" style:UIBarButtonItemStylePlain
                                      target:self action:@selector(onKeyBoardDown:)];
    
    [hideBtnItem setTintColor:[UIColor whiteColor]];
    UIToolbar *toolbar = [[ UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    NSArray *array = [NSArray arrayWithObjects:spaceBtnItem,hideBtnItem, nil];
    [toolbar setItems:array];
    
    _textView.inputAccessoryView = toolbar;
    _textView.layer.borderWidth = 0.5f;
    _textView.layer.borderColor = [[UIColor whiteColor] CGColor];
    [_textView.layer setCornerRadius:7.0f];


    CGFloat posY = self.textView.frame.origin.y+self.textView.frame.size.height/6;
    _popUpView = [[PopupView alloc] initWithFrame:CGRectMake(100, posY, 0, 0) withParentView:self.view];

    _inidicateView =  [[AlertView alloc]initWithFrame:CGRectMake(100, posY, 0, 0)];
    _inidicateView.ParentView = self.view;
    [self.view addSubview:_inidicateView];
    [_inidicateView hide];
    
    

    
    
#pragma mark - 初始化uri合成的音频存放路径和播放器

//     使用-(void)synthesize:(NSString *)text toUri:(NSString*)uri接口时， uri 需设置为保存音频的完整路径
//     若uri设为nil,则默认的音频保存在library/cache下
    NSString *prePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //uri合成路径设置
    _uriPath = [NSString stringWithFormat:@"%@/%@",prePath,@"uri.pcm"];
    //pcm播放器初始化
    _audioPlayer = [[PcmPlayer alloc] init];
    
 }
 

- (BOOL)shouldAutorotate{
    return NO;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initSynthesizer];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    self.isViewDidDisappear = true;
    [_iFlySpeechSynthesizer stopSpeaking];
    [_audioPlayer stop];
    [_inidicateView hide];
    _iFlySpeechSynthesizer.delegate = nil;
    
}

- (void) dealloc{
    
}


/*
- (void)changeAudioSessionWithPlayback:(UInt32) sessionCategory1
{

    OSStatus error ;//优化蓝牙播放音质，去杂音
    error = AudioSessionSetProperty (
                                     kAudioSessionProperty_AudioCategory,
                                     sizeof (sessionCategory1),
                                     &sessionCategory1
                                     );
    if (error) {
        NSLog(@"%s| AudioSessionSetProperty kAudioSessionProperty_AudioCategory error",__func__);
    }
    
    // check the audio route
    UInt32 size = sizeof(CFStringRef);
    CFStringRef route;
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &size, &route);
    
    NSLog(@"route = %@", route);
    
    CFRelease(route);
    
}
*/


#pragma mark - 事件响应函数
/**
 隐藏键盘
 ****/
- (void)onKeyBoardDown:(id) sender{
    [_textView resignFirstResponder];
    
}

/**
 开始通用合成
 ****/
- (IBAction)startSynBtnHandler:(id)sender {

    if ([_textView.text isEqualToString:@""]) {
        [_popUpView showText:@"无效的文本信息"];
        return;
    }
    
    if (_audioPlayer != nil && _audioPlayer.isPlaying == YES) {
        [_audioPlayer stop];
    }
    
    _synType = NomalType;
    
    self.hasError = NO;
    [NSThread sleepForTimeInterval:0.05];
    
    [_inidicateView setText: @"正在缓冲..."];
    [_inidicateView show];
    
    [_popUpView removeFromSuperview];
    self.isCanceled = NO;

    _iFlySpeechSynthesizer.delegate = self;
    
    NSString* str= _textView.text;
    
    [_iFlySpeechSynthesizer startSpeaking:str];
    if (_iFlySpeechSynthesizer.isSpeaking) {
        _state = Playing;
    }
}

/**
 开始uri合成
 ****/
- (IBAction)uriSynthesizeBtnHandler:(id)sender {
    
    if ([_textView.text isEqualToString:@""]) {
        [_popUpView showText:@"无效的文本信息"];
        return;
    }
    
    if (_audioPlayer != nil && _audioPlayer.isPlaying == YES) {
        [_audioPlayer stop];
    }
    
    _synType = UriType;
    
    self.hasError = NO;
    
    [NSThread sleepForTimeInterval:0.05];

    
    [_inidicateView setText: @"正在缓冲..."];
    [_inidicateView show];
    
    [_popUpView removeFromSuperview];
    
    self.isCanceled = NO;
    
    _iFlySpeechSynthesizer.delegate = self;
    
    [_iFlySpeechSynthesizer synthesize:_textView.text toUri:_uriPath];
    if (_iFlySpeechSynthesizer.isSpeaking) {
        _state = Playing;
    }
}



/**
 取消合成
 注：
 1、取消通用合成，并停止播放；
 2、uri合成取消时会保存已经合成的pcm；
 ****/
- (IBAction)cancelSynBtnHandler:(id)sender {
    [_inidicateView hide];
    [_iFlySpeechSynthesizer stopSpeaking];
    
}



/**
 暂停播放
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (IBAction)pauseSynBtnHandler:(id)sender {
    [_iFlySpeechSynthesizer pauseSpeaking];
}


/**
 恢复播放
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (IBAction)resumeSynBtnHandler:(id)sender {
    [_iFlySpeechSynthesizer resumeSpeaking];
}


- (IBAction)clearBtnHandler:(id)sender {
    [_textView setText:@""];
}



- (IBAction)onSetting:(id)sender {
    
    //解决多次快速点击导致出现多个设置界面
    if ([[self.navigationController topViewController] isKindOfClass:[TTSUIController class]]){
        [self performSegueWithIdentifier:@"TTSSegue" sender:self];
    }
    
}


#pragma mark - 合成回调 IFlySpeechSynthesizerDelegate

/**
 开始播放回调
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onSpeakBegin
{
    [_inidicateView hide];
    self.isCanceled = NO;
    if (_state  != Playing) {
        [_popUpView showText:@"开始播放"];
    }
    _state = Playing;
}



/**
 缓冲进度回调
 
 progress 缓冲进度
 msg 附加信息
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onBufferProgress:(int) progress message:(NSString *)msg
{
    NSLog(@"buffer progress %2d%%. msg: %@.", progress, msg);
}




/**
 播放进度回调
 
 progress 缓冲进度
 
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void) onSpeakProgress:(int) progress beginPos:(int)beginPos endPos:(int)endPos
{
    NSLog(@"speak progress %2d%%.", progress);
}


/**
 合成暂停回调
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onSpeakPaused
{
    [_inidicateView hide];
    [_popUpView showText:@"播放暂停"];
    
    _state = Paused;
}


/**
 合成结束（完成）回调

 对uri合成添加播放的功能
 ****/
- (void)onCompleted:(IFlySpeechError *) error
{
    NSLog(@"%s,error=%d",__func__,error.errorCode);
    
    if (error.errorCode != 0) {
        [_inidicateView hide];
        [_popUpView showText:[NSString stringWithFormat:@"错误码:%d",error.errorCode]];
        return;
    }
    NSString *text ;
    if (self.isCanceled) {
        text = @"合成已取消";
    }else if (error.errorCode == 0) {
        text = @"合成结束";
    }else {
        text = [NSString stringWithFormat:@"发生错误：%d %@",error.errorCode,error.errorDesc];
        self.hasError = YES;
        NSLog(@"%@",text);
    }
    
    [_inidicateView hide];
    [_popUpView showText:text];
    
    _state = NotStart;
    
    if (_synType == UriType) {//Uri合成类型
        
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:_uriPath]) {
            [self playUriAudio];//播放合成的音频
        }
    }
}


#pragma mark - 设置合成参数
- (void)initSynthesizer
{
    TTSConfig *instance = [TTSConfig sharedInstance];
    if (instance == nil) {
        return;
    }
    
    //合成服务单例
    if (_iFlySpeechSynthesizer == nil) {
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    }
    
    _iFlySpeechSynthesizer.delegate = self;

    //设置语速1-100
    [_iFlySpeechSynthesizer setParameter:instance.speed forKey:[IFlySpeechConstant SPEED]];
    
    //设置音量1-100
    [_iFlySpeechSynthesizer setParameter:instance.volume forKey:[IFlySpeechConstant VOLUME]];
    
    //设置音调1-100
    [_iFlySpeechSynthesizer setParameter:instance.pitch forKey:[IFlySpeechConstant PITCH]];
    
    //设置采样率
    [_iFlySpeechSynthesizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    //设置发音人
    [_iFlySpeechSynthesizer setParameter:instance.vcnName forKey:[IFlySpeechConstant VOICE_NAME]];
    
    //设置文本编码格式
    [_iFlySpeechSynthesizer setParameter:@"unicode" forKey:[IFlySpeechConstant TEXT_ENCODING]];
    
    
    NSDictionary* languageDic=@{@"Guli":@"text_uighur", //维语
                                @"XiaoYun":@"text_vietnam",//越南语
                                @"Abha":@"text_hindi",//印地语
                                @"Gabriela":@"text_spanish",//西班牙语
                                @"Allabent":@"text_russian",//俄语
                                @"Mariane":@"text_french"};//法语
    
    NSString* textNameKey=[languageDic valueForKey:instance.vcnName];
    NSString* textSample=nil;
    
    if(textNameKey && [textNameKey length]>0){
        textSample=NSLocalizedStringFromTable(textNameKey, @"tts/tts", nil);
    }else{
        textSample=NSLocalizedStringFromTable(@"text_chinese", @"tts/tts", nil);
    }

    [_textView setText:textSample];

}


#pragma mark - 播放uri合成音频

- (void)playUriAudio
{
    TTSConfig *instance = [TTSConfig sharedInstance];
    [_popUpView showText:@"uri合成完毕，即将开始播放"];
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    _audioPlayer = [[PcmPlayer alloc] initWithFilePath:_uriPath sampleRate:[instance.sampleRate integerValue]];
    [_audioPlayer play];
    
}

@end
