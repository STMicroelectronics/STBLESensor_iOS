//
//  ISEViewController.m
//  MSCDemo_UI
//
//  Created by 张剑 on 15/1/15.
//
//

#import "ISEViewController.h"
#import "ISESettingViewController.h"
#import "PopupView.h"
#import "ISEParams.h"
#import "IFlyMSC/IFlyMSC.h"

#import "ISEResult.h"
#import "ISEResultXmlParser.h"
#import "Definition.h"



#define _DEMO_UI_MARGIN                  5
#define _DEMO_UI_BUTTON_HEIGHT           49
#define _DEMO_UI_TOOLBAR_HEIGHT          44
#define _DEMO_UI_STATUSBAR_HEIGHT        20



#pragma mark - const values

NSString* const KCIseHideBtnTitle=@"隐藏";

NSString* const KCTextCNSyllable=@"text_cn_syllable";
NSString* const KCTextCNWord=@"text_cn_word";
NSString* const KCTextCNSentence=@"text_cn_sentence";
NSString* const KCTextENWord=@"text_en_word";
NSString* const KCTextENSentence=@"text_en_sentence";

NSString* const KCResultNotify1=@"请点击“开始评测”按钮";
NSString* const KCResultNotify2=@"请朗读以上内容";
NSString* const KCResultNotify3=@"停止评测，结果等待中...";


#pragma mark -

@interface ISEViewController () <IFlySpeechEvaluatorDelegate ,ISESettingDelegate ,ISEResultXmlParserDelegate,IFlyPcmRecorderDelegate>

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, assign) CGFloat textViewHeight;
@property (nonatomic, strong) IBOutlet UITextView *resultView;
@property (nonatomic, strong) NSString* resultText;
@property (nonatomic, assign) CGFloat resultViewHeight;

@property (nonatomic, strong) IBOutlet UIButton *startBtn;
@property (nonatomic, strong) IBOutlet UIButton *stopBtn;
@property (nonatomic, strong) IBOutlet UIButton *parseBtn;
@property (nonatomic, strong) IBOutlet UIButton *cancelBtn;

@property (nonatomic, strong) PopupView *popupView;
@property (nonatomic, strong) ISESettingViewController *settingViewCtrl;
@property (nonatomic, strong) IFlySpeechEvaluator *iFlySpeechEvaluator;

@property (nonatomic, assign) BOOL isSessionResultAppear;
@property (nonatomic, assign) BOOL isSessionEnd;

@property (nonatomic, assign) BOOL isValidInput;
@property (nonatomic, assign) BOOL isDidset;

@property (nonatomic,strong) IFlyPcmRecorder *pcmRecorder;//录音器，用于音频流识别的数据传入
@property (nonatomic,assign) BOOL isBeginOfSpeech;//是否已经返回BeginOfSpeech回调

@end

@implementation ISEViewController

static NSString *LocalizedEvaString(NSString *key, NSString *comment) {
    return NSLocalizedStringFromTable(key, @"eva/eva", comment);
}

/**
 设置UIButton的ExclusiveTouch属性
 ****/
-(void)setExclusiveTouchForButtons:(UIView *)myView
{
    for (UIView * button in [myView subviews]) {
        if([button isKindOfClass:[UIButton class]])
        {
            [((UIButton *)button) setExclusiveTouch:YES];
        }
        else if ([button isKindOfClass:[UIView class]])
        {
            [self setExclusiveTouchForButtons:button];
        }
    }
}


#pragma mark -

- (void)viewWillAppear:(BOOL)animated {
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [super viewWillAppear:animated];
    self.iFlySpeechEvaluator.delegate = self;
    
    self.isSessionResultAppear=YES;
    self.isSessionEnd=YES;
    self.startBtn.enabled=YES;
}

- (void)viewWillDisappear:(BOOL)animated{

//     unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [self.iFlySpeechEvaluator cancel];
    self.iFlySpeechEvaluator.delegate = nil;
    self.resultView.text =KCResultNotify1;
    self.resultText=@"";
    
    [_pcmRecorder stop];
    _pcmRecorder.delegate = nil;
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    // adjust the UI for iOS 7
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (IOS7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.navigationController.navigationBar.translucent = NO;
    }
#endif

    //键盘工具栏
    UIBarButtonItem *spaceBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];
    UIBarButtonItem *hideBtnItem = [[UIBarButtonItem alloc] initWithTitle:KCIseHideBtnTitle
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(onKeyBoardDown:)];
    [hideBtnItem setTintColor:[UIColor whiteColor]];
    UIToolbar *keyboardToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _DEMO_UI_TOOLBAR_HEIGHT)];
    keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
    NSArray *array = [NSArray arrayWithObjects:spaceBtnItem, hideBtnItem, nil];
    [keyboardToolbar setItems:array];
    self.textView.inputAccessoryView = keyboardToolbar;
    
    self.textView.layer.cornerRadius = 8;
    self.textView.layer.borderWidth = 1;
    self.textView.layer.borderColor =[[UIColor whiteColor] CGColor];

    self.resultView.layer.cornerRadius = 8;
    self.resultView.layer.borderWidth = 1;
    self.resultView.layer.borderColor =[[UIColor whiteColor] CGColor];
    [self.resultView setEditable:NO];
    
    self.popupView = [[PopupView alloc]initWithFrame:CGRectMake(100, 300, 0, 0)];
    self.popupView.ParentView = self.view;


	if (!self.iFlySpeechEvaluator) {
		self.iFlySpeechEvaluator = [IFlySpeechEvaluator sharedInstance];
	}
	self.iFlySpeechEvaluator.delegate = self;
	//清空参数，目的是评测和听写的参数采用相同数据
	[self.iFlySpeechEvaluator setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    _isSessionResultAppear=YES;
    _isSessionEnd=YES;
    _isValidInput=YES;
    self.iseParams=[ISEParams fromUserDefaults];
    [self reloadCategoryText];
    
    //初始化录音器
    if (_pcmRecorder == nil)
    {
        _pcmRecorder = [IFlyPcmRecorder sharedInstance];
    }
    
    _pcmRecorder.delegate = self;
    
    [_pcmRecorder setSample:@"16000"];
    
    [_pcmRecorder setSaveAudioPath:nil];    //不保存录音文件
    
    //避免同时产生多个按钮事件
    [self setExclusiveTouchForButtons:self.view];
}

-(void)reloadCategoryText{
    
    [self.iFlySpeechEvaluator setParameter:self.iseParams.bos forKey:[IFlySpeechConstant VAD_BOS]];
    [self.iFlySpeechEvaluator setParameter:self.iseParams.eos forKey:[IFlySpeechConstant VAD_EOS]];
    [self.iFlySpeechEvaluator setParameter:self.iseParams.category forKey:[IFlySpeechConstant ISE_CATEGORY]];
    [self.iFlySpeechEvaluator setParameter:self.iseParams.language forKey:[IFlySpeechConstant LANGUAGE]];
    [self.iFlySpeechEvaluator setParameter:self.iseParams.rstLevel forKey:[IFlySpeechConstant ISE_RESULT_LEVEL]];
    [self.iFlySpeechEvaluator setParameter:self.iseParams.timeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
    [self.iFlySpeechEvaluator setParameter:self.iseParams.audioSource forKey:[IFlySpeechConstant AUDIO_SOURCE]];
    
    if ([self.iseParams.language isEqualToString:KCLanguageZHCN]) {
        if ([self.iseParams.category isEqualToString:KCCategorySyllable]) {
            self.textView.text = LocalizedEvaString(KCTextCNSyllable, nil);
        }
        else if ([self.iseParams.category isEqualToString:KCCategoryWord]) {
            self.textView.text = LocalizedEvaString(KCTextCNWord, nil);
        }
        else {
            self.textView.text = LocalizedEvaString(KCTextCNSentence, nil);
        }
    }
    else {
        if ([self.iseParams.category isEqualToString:KCCategoryWord]) {
            self.textView.text = LocalizedEvaString(KCTextENWord, nil);
        }
        else {
            self.textView.text = LocalizedEvaString(KCTextENSentence, nil);
        }
        self.isValidInput=YES;

    }
}

-(void)resetBtnSatus:(IFlySpeechError *)errorCode{
    
    if(errorCode && errorCode.errorCode!=0){
        self.isSessionResultAppear=NO;
        self.isSessionEnd=YES;
        self.resultView.text =KCResultNotify1;
        self.resultText=@"";
    }else{
        if(self.isSessionResultAppear == NO){
            self.resultView.text =KCResultNotify1;
            self.resultText=@"";
        }
        self.isSessionResultAppear=YES;
        self.isSessionEnd=YES;
    }
    self.startBtn.enabled=YES;
}

#pragma mark - keyboard

/*!
 *  隐藏键盘
 *
 *  @param sender textView or resultView
 */
-(void)onKeyBoardDown:(id) sender{
    [self.textView resignFirstResponder];
}


-(void)setViewSize:(BOOL)show Notification:(NSNotification*) notification{

    if (!self.isDidset){
        self.textViewHeight = self.textView.frame.size.height;
        self.resultViewHeight = self.resultView.frame.size.height;
        self.isDidset = YES;
    }

    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    int keyboardHeight = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;

    CGRect textRect = self.textView.frame;
    CGRect resultRect = self.resultView.frame;
    if (show) {
        textRect.size.height = self.view.frame.size.height - keyboardHeight - _DEMO_UI_MARGIN*4;
        resultRect.size.height = 0;
    }
    else{
        textRect.size.height = self.textViewHeight;
        resultRect.size.height = self.resultViewHeight;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3]; // if you want to slide up the view

        self.textView.frame = textRect;
        self.resultView.frame=resultRect;
        
        [UIView commitAnimations];
    });

}

-(void)keyboardWillShow:(NSNotification *)notification {
        [self setViewSize:YES Notification:notification];
}

-(void)keyboardWillHide :(NSNotification *)notification{
        [self setViewSize:NO Notification:notification];
}


#pragma mark -
#pragma mark - Button handler

/*!
 *  设置
 *
 *  @param sender settingBtn
 */
- (IBAction)onSetting:(id)sender {
	if (!self.settingViewCtrl) {
		self.settingViewCtrl = [[ISESettingViewController alloc] initWithStyle:UITableViewStylePlain];
		self.settingViewCtrl.delegate = self;
	}
    
    //解决两次快速点击崩溃问题
    if (![[self.navigationController topViewController] isKindOfClass:[ISESettingViewController class]]){
        [self.navigationController pushViewController:self.settingViewCtrl animated:YES];
    }
	
}

/*!
 *  开始录音
 *
 *  @param sender startBtn
 */
- (IBAction)onBtnStart:(id)sender {
    
    NSLog(@"%s[IN]",__func__);
    
	[self.iFlySpeechEvaluator setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
	[self.iFlySpeechEvaluator setParameter:@"utf-8" forKey:[IFlySpeechConstant TEXT_ENCODING]];
	[self.iFlySpeechEvaluator setParameter:@"xml" forKey:[IFlySpeechConstant ISE_RESULT_TYPE]];

    [self.iFlySpeechEvaluator setParameter:@"eva.pcm" forKey:[IFlySpeechConstant ISE_AUDIO_PATH]];
    
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    
    NSLog(@"text encoding:%@",[self.iFlySpeechEvaluator parameterForKey:[IFlySpeechConstant TEXT_ENCODING]]);
    NSLog(@"language:%@",[self.iFlySpeechEvaluator parameterForKey:[IFlySpeechConstant LANGUAGE]]);
    
    BOOL isUTF8=[[self.iFlySpeechEvaluator parameterForKey:[IFlySpeechConstant TEXT_ENCODING]] isEqualToString:@"utf-8"];
    BOOL isZhCN=[[self.iFlySpeechEvaluator parameterForKey:[IFlySpeechConstant LANGUAGE]] isEqualToString:KCLanguageZHCN];
    
    BOOL needAddTextBom=isUTF8&&isZhCN;
    NSMutableData *buffer = nil;
    if(needAddTextBom){
        if(self.textView.text && [self.textView.text length]>0){
            Byte bomHeader[] = { 0xEF, 0xBB, 0xBF };
            buffer = [NSMutableData dataWithBytes:bomHeader length:sizeof(bomHeader)];
            [buffer appendData:[self.textView.text dataUsingEncoding:NSUTF8StringEncoding]];
            NSLog(@" \ncn buffer length: %lu",(unsigned long)[buffer length]);
        }
    }else{
        buffer= [NSMutableData dataWithData:[self.textView.text dataUsingEncoding:encoding]];
        NSLog(@" \nen buffer length: %lu",(unsigned long)[buffer length]);
    }
    self.resultView.text =KCResultNotify2;
    self.resultText=@"";
	
   BOOL ret = [self.iFlySpeechEvaluator startListening:buffer params:nil];
    if(ret){
        self.isSessionResultAppear=NO;
        self.isSessionEnd=NO;
        self.startBtn.enabled=NO;
        
        //采用音频流评测，将评测音频数据通过writeAudio:传入。使用方法类似于语音听写控件中的音频流识别功能。
        if ([self.iseParams.audioSource isEqualToString:IFLY_AUDIO_SOURCE_STREAM]){
            
            _isBeginOfSpeech = NO;
            //初始化录音环境
            [IFlyAudioSession initRecordingAudioSession];
            
            _pcmRecorder.delegate = self;
            
            //启动录音器服务
            BOOL ret = [_pcmRecorder start];
            
            NSLog(@"%s[OUT],Success,Recorder ret=%d",__func__,ret);
        }
    }
}

/*!
 *  暂停录音
 *
 *  @param sender stopBtn
 */
- (IBAction)onBtnStop:(id)sender {
    
    if(!self.isSessionResultAppear &&  !self.isSessionEnd){
        self.resultView.text =KCResultNotify3;
        self.resultText=@"";
    }
    
    if ([self.iseParams.audioSource isEqualToString:IFLY_AUDIO_SOURCE_STREAM] && !_isBeginOfSpeech){
        NSLog(@"%s,停止录音",__func__);
        [_pcmRecorder stop];
    }
    
	[self.iFlySpeechEvaluator stopListening];
    [self.resultView resignFirstResponder];
    [self.textView resignFirstResponder];
    self.startBtn.enabled=YES;
}

/*!
 *  取消
 *
 *  @param sender cancelBtn
 */
- (IBAction)onBtnCancel:(id)sender {
    
    if ([self.iseParams.audioSource isEqualToString:IFLY_AUDIO_SOURCE_STREAM] && !_isBeginOfSpeech){
        NSLog(@"%s,停止录音",__func__);
        [_pcmRecorder stop];
    }

	[self.iFlySpeechEvaluator cancel];
	[self.resultView resignFirstResponder];
    [self.textView resignFirstResponder];
	[self.popupView removeFromSuperview];
    self.resultView.text =KCResultNotify1;
    self.resultText=@"";
    self.startBtn.enabled=YES;
}


/*!
 *  开始解析
 *
 *  @param sender parseBtn
 */
- (IBAction)onBtnParse:(id)sender {
    
    ISEResultXmlParser* parser=[[ISEResultXmlParser alloc] init];
    parser.delegate=self;
    [parser parserXml:self.resultText];
    
}


#pragma mark - ISESettingDelegate

/*!
 *  设置参数改变
 *
 *  @param params 参数
 */
- (void)onParamsChanged:(ISEParams *)params {
    self.iseParams=params;
    [self performSelectorOnMainThread:@selector(reloadCategoryText) withObject:nil waitUntilDone:NO];
}

#pragma mark - IFlySpeechEvaluatorDelegate
/*!
 *  音量和数据回调
 *
 *  @param volume 音量
 *  @param buffer 音频数据
 */
- (void)onVolumeChanged:(int)volume buffer:(NSData *)buffer {
//    NSLog(@"volume:%d",volume);
    [self.popupView setText:[NSString stringWithFormat:@"音量：%d",volume]];
    [self.view addSubview:self.popupView];
}

/*!
 *  开始录音回调
 *  当调用了`startListening`函数之后，如果没有发生错误则会回调此函数。如果发生错误则回调onError:函数
 */
- (void)onBeginOfSpeech {
    
    if ([self.iseParams.audioSource isEqualToString:IFLY_AUDIO_SOURCE_STREAM]){
        _isBeginOfSpeech =YES;
    }
    
}

/*!
 *  停止录音回调
 *    当调用了`stopListening`函数或者引擎内部自动检测到断点，如果没有发生错误则回调此函数。
 *  如果发生错误则回调onError:函数
 */
- (void)onEndOfSpeech {
    
    if ([self.iseParams.audioSource isEqualToString:IFLY_AUDIO_SOURCE_STREAM]){
        [_pcmRecorder stop];
    }
    
}

/*!
 *  正在取消
 */
- (void)onCancel {
    
}

/*!
 *  评测结果回调
 *    在进行语音评测过程中的任何时刻都有可能回调此函数，你可以根据errorCode进行相应的处理.
 *  当errorCode没有错误时，表示此次会话正常结束，否则，表示此次会话有错误发生。特别的当调用
 *  `cancel`函数时，引擎不会自动结束，需要等到回调此函数，才表示此次会话结束。在没有回调此函
 *  数之前如果重新调用了`startListenging`函数则会报错误。
 *
 *  @param errorCode 错误描述类
 */
- (void)onError:(IFlySpeechError *)errorCode {
    if(errorCode && errorCode.errorCode!=0){
        [self.popupView setText:[NSString stringWithFormat:@"错误码：%d %@",[errorCode errorCode],[errorCode errorDesc]]];
        [self.view addSubview:self.popupView];
        
    }
    
    [self performSelectorOnMainThread:@selector(resetBtnSatus:) withObject:errorCode waitUntilDone:NO];

}

/*!
 *  评测结果回调
 *   在评测过程中可能会多次回调此函数，你最好不要在此回调函数中进行界面的更改等操作，只需要将回调的结果保存起来。
 *
 *  @param results -[out] 评测结果。
 *  @param isLast  -[out] 是否最后一条结果
 */
- (void)onResults:(NSData *)results isLast:(BOOL)isLast{
	if (results) {
		NSString *showText = @"";
        
        const char* chResult=[results bytes];
        
        BOOL isUTF8=[[self.iFlySpeechEvaluator parameterForKey:[IFlySpeechConstant RESULT_ENCODING]]isEqualToString:@"utf-8"];
        NSString* strResults=nil;
        if(isUTF8){
            strResults=[[NSString alloc] initWithBytes:chResult length:[results length] encoding:NSUTF8StringEncoding];
        }else{
            NSLog(@"result encoding: gb2312");
            NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            strResults=[[NSString alloc] initWithBytes:chResult length:[results length] encoding:encoding];
        }
        if(strResults){
            showText = [showText stringByAppendingString:strResults];
        }
        
        self.resultText=showText;
		self.resultView.text = showText;
        self.isSessionResultAppear=YES;
        self.isSessionEnd=YES;
        if(isLast){
            [self.popupView setText:@"评测结束"];
            [self.view addSubview:self.popupView];
        }

	}
    else{
        if(isLast){
            [self.popupView setText:@"你好像没有说话哦"];
            [self.view addSubview:self.popupView];
        }
        self.isSessionEnd=YES;
    }
    self.startBtn.enabled=YES;
}

#pragma mark - ISEResultXmlParserDelegate

-(void)onISEResultXmlParser:(NSXMLParser *)parser Error:(NSError*)error{
    
}

-(void)onISEResultXmlParserResult:(ISEResult*)result{
    self.resultView.text=[result toString];
}


#pragma mark - IFlyPcmRecorderDelegate

- (void) onIFlyRecorderBuffer: (const void *)buffer bufferSize:(int)size
{
    NSData *audioBuffer = [NSData dataWithBytes:buffer length:size];
    
    int ret = [self.iFlySpeechEvaluator writeAudio:audioBuffer];
    if (!ret)
    {
        [self.iFlySpeechEvaluator stopListening];
    }
}

- (void) onIFlyRecorderError:(IFlyPcmRecorder*)recoder theError:(int) error
{
    
}

//power:0-100,注意控件返回的音频值为0-30
- (void) onIFlyRecorderVolumeChanged:(int) power
{
    [self.popupView setText:[NSString stringWithFormat:@"音量：%d",power]];
    [self.view addSubview:self.popupView];}


@end
