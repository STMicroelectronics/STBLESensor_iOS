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

#import "BlueVoiceGoogleAsrRequest.h"

#define GOOGLE_ASR_URL @"https://www.google.com/speech-api/v2/recognize?xjerr=1&client=chromium&lang=en-US&key=%@"

#define RESULT @"result"
#define TRANSCRIPT @"transcript"
#define CONFIDENCE @"confidence"
#define ALTERNATIVE @"alternative"

@interface BlueVoiceGoogleAsrRequest()<NSURLSessionDelegate>
@end

@implementation BlueVoiceGoogleAsrRequest {
    NSURL *mRequestUrl;
    id <BlueVoiceGoogleAsrRequestDelegate> mDelegate;
}


+ (instancetype)createRequestWithKey:(NSString *)key delegate:(id <BlueVoiceGoogleAsrRequestDelegate>)delegate{
    return [[self alloc] initWithKey:key delegate:delegate];
}

-(instancetype) initWithKey:(NSString*)key delegate:(id <BlueVoiceGoogleAsrRequestDelegate>)delegate{
    self = [super init];
    mRequestUrl =[NSURL URLWithString:[NSString stringWithFormat:GOOGLE_ASR_URL,key]];
    mDelegate=delegate;
    return self;
}

+ (instancetype)createRequestWithKey:(NSString *)key  {
    return nil;
}

- (void)sendRequestWithAudioData:(NSData *)data samplingRate:(uint32_t)samplingRate{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[mRequestUrl standardizedURL]];

    request.HTTPMethod=@"POST";
    request.timeoutInterval=10.0;
    request.cachePolicy=NSURLRequestReloadIgnoringLocalCacheData;
    [request setValue:[NSString stringWithFormat:@"audio/l16; rate=%u",samplingRate] forHTTPHeaderField:@"Content-Type"];


    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];


    NSURLSessionDataTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self parseResponseData:data HTTPResp:response error:error];
    }];

    [task resume];
}

-(void)parseResponseData:(NSData *)data HTTPResp:(NSURLResponse *)response error:(NSError *)error{
    if(error!=nil){
        NSLog(@"Connection Error: %@",[error description]);
        [mDelegate onConnectionError];
        return;
    }

    //remove the first empty result
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"{\"result\":[]}" withString:@""];

    NSLog(@"Resp: %@",jsonString);

    data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

    NSError *parseError=nil;
    NSDictionary *responseObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];

    if(!parseError) {
        NSArray *responseArray = responseObj[RESULT];
        for (NSDictionary *alternative in responseArray) {
            NSArray *altArray = alternative[ALTERNATIVE];
            for (NSDictionary *transcript in altArray) {
                NSString *str = transcript[TRANSCRIPT];
                float confidence;
                NSString *confStr =transcript[CONFIDENCE];
                if(confStr!=nil)
                    confidence = [confStr floatValue];
                else
                    confidence =1.0f;
                [mDelegate onResponseIsReady: str confidence:confidence];
                return;
            }//for
        }//for
    } else {
        [mDelegate onParseResponseError];
    }//if-else

}

@end
