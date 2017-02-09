/*
 * Copyright (c) 2017  STMicroelectronics – All rights reserved
 * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list of conditions
 *   and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice, this list of
 *   conditions and the following disclaimer in the documentation and/or other materials provided
 *   with the distribution.
 *
 * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
 *   STMicroelectronics company nor the names of its contributors may be used to endorse or
 *   promote products derived from this software without specific prior written permission.
 *
 * - All of the icons, pictures, logos and other images that are provided with the source code
 *   in a directory whose title begins with st_images may only be used for internal purposes and
 *   shall not be redistributed to any third party or modified in any way.
 *
 * - Any redistributions in binary form shall not include the capability to display any of the
 *   icons, pictures, logos and other images that are provided with the source code in a directory
 *   whose title begins with st_images.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 */


#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import <BlueSTSDK/BlueSTSDKFeatureAudioADPCM.h>
#import <BlueSTSDK/BlueSTSDKFeatureAudioADPCMSync.h>

#import "W2STBlueVoiceViewController.h"
#import "UIViewController+W2STDemoTab.h"
#import "Reachability.h"
#import "BlueVoiceInsertAsrKeyViewController.h"
#import "BlueVoiceGoogleAsrRequest.h"

#define ASRKEY @"BlueVoice_AsrKey"

#define RECORDING_STATUS @"Recording..."
#define EMPTY_RESPONSE @"Empty response"
#define SENDING_STATUS   @"Sending..."
#define PARSE_ERROR @"Error parsing the response";
#define CONNECTION_ERROR @"Connection error";

#define ENABLE @"Enabled"
#define DISABLE @"Disabled"

#define CODEC_NAME @"ADPCM"
#define NUM_CHANNELS (1)
#define NUM_BUFFERS (18)
#define SAMPLE_TYPE int16_t
#define BUFFER_SIZE (40*sizeof(SAMPLE_TYPE))
#define SAMPLE_RATE_HZ (8000.0f)

#define MIN_ASR_CONFIDENCE (0.75f)

@interface SyncQueue:NSObject
    +(instancetype)queue;
    -(void)push:(NSData*)obj;
    -(NSData *)pop;
@end

@implementation SyncQueue{
    NSMutableArray *data;
    NSData *prevData;
    NSCondition *conditionLock;
}

+ (instancetype)queue {
    return [[SyncQueue alloc] init];
}

-(instancetype)init{
    self = [super init];
    uint8_t  preBuffer[BUFFER_SIZE];
    memset(preBuffer,0,BUFFER_SIZE);
    prevData = [NSData dataWithBytes:preBuffer length:BUFFER_SIZE];
    data = [NSMutableArray array];
    conditionLock = [[NSCondition alloc] init];
    return self;
}

- (void)push:(NSData *)obj {
    [conditionLock lock];
    [data addObject:obj];
    [conditionLock signal];
    [conditionLock unlock];
}

- (NSData *)pop {
    NSData *obj;
    [conditionLock lock];
    if(data.count==0){
        obj = prevData;
    }else{
        obj = data[0];
        prevData=obj;
        [data removeObjectAtIndex:0];
    }
    [conditionLock unlock];
    return obj;
}


@end

@interface W2STBlueVoiceViewController()<BlueSTSDKFeatureDelegate,BlueVoiceInsertAsrKeyDelegate,
        BlueVoiceGoogleAsrRequestDelegate,UITableViewDataSource>

@end

@implementation W2STBlueVoiceViewController{
    BlueSTSDKFeatureAudioADPCM *mFeatureAudio;
    BlueSTSDKFeatureAudioADPCMSync *mFeatureAudioSync;
    AudioStreamBasicDescription format;
    AudioQueueRef queue;
    AudioQueueBufferRef buffers[NUM_BUFFERS];
    Reachability *mInternetReachability;
    NSMutableArray<NSString*> *mAsrResposeList;
    BOOL mIsRecording;
    BOOL mIsMute;
    NSMutableData *mRecordedData;
    BlueVoiceGoogleAsrRequest *mAsrRequest;
    SyncQueue *mSyncQueue;
    __weak IBOutlet UIButton *mAddAsrKeyButton;
    __weak IBOutlet UILabel *mCodecLabel;
    __weak IBOutlet MPVolumeView *mVolumeController;
    __weak IBOutlet UILabel *mSamplingLabel;
    __weak IBOutlet UILabel *mAsrLabel;
    __weak IBOutlet UILabel *mAsrRequestStatusLabel;
    __weak IBOutlet UITableView *mAsrResponseListView;
    __weak IBOutlet UIView *mInsertKeyView;
    __weak IBOutlet UIButton *mRecordButton;
    __weak IBOutlet UILabel *mSpeechReconitionEnabledLabel;
}

static

void callback(void *custom_data, AudioQueueRef queue, AudioQueueBufferRef buffer){
    SyncQueue *dataQueue = (__bridge SyncQueue *)custom_data;

    NSData *sample = [dataQueue pop];

    [sample getBytes:buffer->mAudioData length:buffer->mAudioDataBytesCapacity];

    AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);

}

-(void) initAudioQueue{
    //https://developer.apple.com/library/mac/documentation/MusicAudio/Reference/CoreAudioDataTypesRef/#//apple_ref/c/tdef/AudioStreamBasicDescription

    format.mSampleRate       = SAMPLE_RATE_HZ;
    format.mFormatID         = kAudioFormatLinearPCM;
    format.mFormatFlags      = kLinearPCMFormatFlagIsSignedInteger  ;
    format.mBitsPerChannel   = 8 * sizeof(SAMPLE_TYPE);
    format.mChannelsPerFrame = NUM_CHANNELS;
    format.mBytesPerFrame    = sizeof(SAMPLE_TYPE) * NUM_CHANNELS;
    format.mFramesPerPacket  = 1;
    format.mBytesPerPacket   = format.mBytesPerFrame * format.mFramesPerPacket;

    AudioQueueNewOutput(&format, callback,(__bridge void *) mSyncQueue,NULL, NULL, 0, &queue);

    for (int i = 0; i < NUM_BUFFERS; i++) {
        AudioQueueAllocateBuffer(queue, BUFFER_SIZE, &buffers[i]);
        buffers[i]->mAudioDataByteSize = BUFFER_SIZE;
        memset(buffers[i]->mAudioData,0,BUFFER_SIZE);
        AudioQueueEnqueueBuffer(queue, buffers[i], 0, NULL);
    }//for

    AudioQueueStart(queue, NULL);
    mIsMute=false;
}

-(void) initConnectionListener{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotificationChanged:)
                                                 name:kReachabilityChangedNotification object:nil];


    mInternetReachability = [Reachability reachabilityForInternetConnection];
    [mInternetReachability startNotifier];
    [self onReachabilityChange:mInternetReachability];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    mAsrResposeList = [NSMutableArray array];
    mSyncQueue = [SyncQueue queue];
    mAsrRequest = [BlueVoiceGoogleAsrRequest createRequestWithKey:[self getCurrentKey] delegate:self];
    mAsrResponseListView.dataSource=self;
    mCodecLabel.text=CODEC_NAME;
    mSamplingLabel.text =[NSString stringWithFormat:@"%u kHz",
                          (uint32_t)SAMPLE_RATE_HZ/1000];
    [self disableASR];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    mFeatureAudio = (BlueSTSDKFeatureAudioADPCM *)
            [self.node getFeatureOfType:BlueSTSDKFeatureAudioADPCM.class];
    mFeatureAudioSync = (BlueSTSDKFeatureAudioADPCMSync *)
            [self.node getFeatureOfType:BlueSTSDKFeatureAudioADPCMSync.class];

    
    if(mFeatureAudioSync!=nil && mFeatureAudio!=nil){
        [self initAudioQueue];
        [self initConnectionListener];
        [self enableASR];
        [mFeatureAudio addFeatureDelegate:self];
        [mFeatureAudioSync addFeatureDelegate:self];
        [self.node enableNotification:mFeatureAudio];
        [self.node enableNotification:mFeatureAudioSync];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    AudioQueueStop(queue, true);

    if(mFeatureAudio!=nil){
        [mFeatureAudio removeFeatureDelegate:self];
        [self.node disableNotification:mFeatureAudio];
        mFeatureAudio=nil;
    }//if

    if(mFeatureAudioSync!=nil){
        [mFeatureAudioSync removeFeatureDelegate:self];
        [self.node disableNotification:mFeatureAudioSync];
        mFeatureAudioSync=nil;
    }//if
}

-(void) didAudioFeatureUpdate:(BlueSTSDKFeatureAudioADPCM *)feature
                       sample:(BlueSTSDKFeatureSample*)sample{

    NSData *audioData = [BlueSTSDKFeatureAudioADPCM getLinearPCMAudio:sample];
    [mSyncQueue push:audioData];
    if(mIsRecording && mRecordedData!=nil){
        @synchronized (mRecordedData) {
            [mRecordedData appendData:audioData];
        }
    }
}

-(void) didAudioSyncFeatureUpdate:(BlueSTSDKFeatureAudioADPCMSync *)feature
                           sample:(BlueSTSDKFeatureSample*)sample{
    [mFeatureAudio.audioManager setSyncParam:sample];
}

- (void)didUpdateFeature:(BlueSTSDKFeature *)feature sample:(BlueSTSDKFeatureSample *)sample {
    if([feature isKindOfClass:[BlueSTSDKFeatureAudioADPCM class]]){
        [self didAudioFeatureUpdate:(BlueSTSDKFeatureAudioADPCM *)feature sample:sample];
    }
    if([feature isKindOfClass:[BlueSTSDKFeatureAudioADPCMSync class]]){
        [self didAudioSyncFeatureUpdate:(BlueSTSDKFeatureAudioADPCMSync *) feature sample:sample];
    }

}

/*!
 * Called by Reachability whenever status changes.
 */
- (void)onNotificationChanged:(NSNotification *)note
{
    Reachability* curReach = [note object];
    if(![curReach isKindOfClass:[Reachability class]])
        return;

    [self onReachabilityChange:curReach];

}

-(void)onReachabilityChange:(Reachability *)reach{
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if(netStatus==NotReachable){
        [self disableASR];
    } else if([self hasASRKey]){
        [self enableASR];
    }
}

-(void)hideAsrWidget:(BOOL)show{
    mRecordButton.hidden=show;
    mAsrResponseListView.hidden=show;
    mAsrLabel.hidden=show;
    mAsrRequestStatusLabel.hidden=show;
    mAddAsrKeyButton.hidden=[self hasASRKey];
}

- (void)enableASR {
    NetworkStatus netStatus = [mInternetReachability currentReachabilityStatus];
    if(netStatus!=NotReachable && [self hasASRKey]){
        dispatch_async(dispatch_get_main_queue(),^{
            [self hideAsrWidget:false];
            mSpeechReconitionEnabledLabel.text = ENABLE;
        });
    }
}

- (BOOL)hasASRKey {
    return [self getCurrentKey]!=nil;
}

- (void)disableASR {
    NetworkStatus netStatus = [mInternetReachability currentReachabilityStatus];
    if(netStatus==NotReachable || ![self hasASRKey]){
        dispatch_async(dispatch_get_main_queue(),^{
            [self hideAsrWidget:true];
            mSpeechReconitionEnabledLabel.text = DISABLE;
        });
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.destinationViewController isKindOfClass:BlueVoiceInsertAsrKeyViewController .class]){
        BlueVoiceInsertAsrKeyViewController *temp = segue.destinationViewController;
        temp.delegate=self;
    }//if
}

- (IBAction)onInsertKeyClick:(UIButton *)sender {
    mInsertKeyView.hidden=false;
}

- (NSString *)getCurrentKey {
    return [[NSUserDefaults standardUserDefaults] stringForKey:ASRKEY ];
}

- (void)didInsertKey:(NSString *)key {
    mInsertKeyView.hidden=true;
    if(key!=nil){
        mAsrRequest = [BlueVoiceGoogleAsrRequest createRequestWithKey:key delegate:self];
        [[NSUserDefaults standardUserDefaults] setObject:key
                                                  forKey:ASRKEY];
        [self enableASR];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return mAsrResposeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AsrResult"];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AsrResult"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.textLabel.text= [mAsrResposeList objectAtIndex:indexPath.row];

    return cell;

}

- (IBAction)onRecordStart:(UIButton *)sender {
    mRecordedData = [NSMutableData data];
    mAsrRequestStatusLabel.text=RECORDING_STATUS;
    mIsRecording=true;
    if(!mIsMute)
        AudioQueueSetParameter(queue, kAudioQueueParam_Volume,0.0);
}

/**
 *  return the position of the app document directory
 *
 *  @return position of the document directory
 */
-(NSURL*) getDumpFileDirectoryUrl{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = paths[0];
    return documentsDirectory;
}

-(void) openDumpFile:(NSData*)data{
    
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsDirectory = [self getDumpFileDirectoryUrl];
    
        
        NSString *fileName = @"audio.bin" ;
        NSURL *fileUrl = [NSURL URLWithString:fileName relativeToURL:documentsDirectory];
    
        if(![fileManager fileExistsAtPath:fileUrl.path]){
            [fileManager createFileAtPath:fileUrl.path contents:nil attributes:nil];
        }
        
        NSError *error = nil;
        NSFileHandle *file = [NSFileHandle fileHandleForWritingToURL:fileUrl error:&error];
        [file writeData:data];
        [file closeFile];
}

- (IBAction)onRecordStop:(UIButton *)sender {
    mIsRecording=false;
    if(!mIsMute)
        AudioQueueSetParameter(queue, kAudioQueueParam_Volume,1.0);
    
    //[self openDumpFile:mRecordedData];

    [mAsrRequest sendRequestWithAudioData:mRecordedData samplingRate:(uint32_t)SAMPLE_RATE_HZ];
    mAsrRequestStatusLabel.text=SENDING_STATUS;
    mRecordedData=nil;
}


- (void)onResponseIsReady:(NSString *)response confidence:(float)confidence {
    dispatch_sync(dispatch_get_main_queue(),^{
        if(response==nil || confidence < MIN_ASR_CONFIDENCE)
            mAsrRequestStatusLabel.text=EMPTY_RESPONSE;
        else {
            mAsrRequestStatusLabel.text = @"";
            [mAsrResposeList insertObject:response atIndex:0];
            [mAsrResponseListView reloadData];
        }
    });
}

- (void)onParseResponseError {
    dispatch_sync(dispatch_get_main_queue(),^{
        mAsrRequestStatusLabel.text=PARSE_ERROR;
    });
}

- (void)onConnectionError {
    dispatch_sync(dispatch_get_main_queue(),^{
        mAsrRequestStatusLabel.text=CONNECTION_ERROR;
    });
}

- (IBAction)onMuteClicked:(UIButton *)sender {

    UIImage *img;
    if(!mIsMute){
        img = [UIImage imageNamed:@"volume_off"];
        AudioQueueSetParameter(queue, kAudioQueueParam_Volume,0.0);
    }else{
        img=[UIImage imageNamed:@"volume_on"];
        AudioQueueSetParameter(queue, kAudioQueueParam_Volume,1.0);
    }
    mIsMute=!mIsMute;
    [sender setImage:img forState:UIControlStateNormal];

}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

@end
