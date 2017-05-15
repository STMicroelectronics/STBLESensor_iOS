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

#import "W2STIBMWatsonQuickStartConnectionFactory.h"
#import "W2STBMWatsonQuickStartFeatureListener.h"

#define DATA_URL_FORMAT @"https://quickstart.internetofthings.ibmcloud.com/#/device/%@/sensor/"

#define MQTT_BROKER @"quickstart.messaging.internetofthings.ibmcloud.com"
#define MQTT_BROKER_PORT 8883
#define MIN_UPDATE_INTERVAL (1.0)

@implementation W2STIBMWatsonQuickStartConnectionFactory{
    NSString *mType;
    NSString *mDeviceId;
}

+(instancetype)createWithDeviceType:(NSString*)type deviceId:(NSString*)deviceId{
    return [[W2STIBMWatsonQuickStartConnectionFactory alloc]
                initWithDeviceType:type deviceId:deviceId];
}

-(instancetype)initWithDeviceType:(NSString*)type deviceId:(NSString*)deviceId{
    self = [super init];
    mType = type;
    mDeviceId = deviceId;
    return self;
}


-(MQTTSession*) getSession{
    MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
    transport.host = MQTT_BROKER;
    transport.port = MQTT_BROKER_PORT;
    transport.tls=YES;
    
    MQTTSession *session = [[MQTTSession alloc] init];
    session.transport = transport;
    session.clientId= [NSString stringWithFormat:@"d:quickstart:%@:%@",mType,mDeviceId ];
    
    return session;
}

-(NSURL*) getDataUrl{
    NSString *url = [NSString stringWithFormat:DATA_URL_FORMAT, mDeviceId ];
    return [NSURL URLWithString:url];
}

-(id<BlueSTSDKFeatureDelegate>)getFeatureDelegateWithSession:(MQTTSession*)session{
    return [[W2STBMWatsonQuickStartFeatureListener alloc]initWithSession:session
                                                  minUpdateInterval:MIN_UPDATE_INTERVAL];
}

-(BOOL)isSupportedFeature:(BlueSTSDKFeature*)feature{
    return true;
}

@end
