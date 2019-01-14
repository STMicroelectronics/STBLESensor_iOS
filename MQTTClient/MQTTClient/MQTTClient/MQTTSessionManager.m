//
//  MCMQTTSessionManager.m
//  MQTTClient
//
//  Created by Christoph Krey on 09.07.14.
//  Copyright © 2013-2017 Christoph Krey. All rights reserved.
//

#import "MQTTSessionManager.h"
#import "MQTTCoreDataPersistence.h"
#import "MQTTLog.h"
#import "ReconnectTimer.h"
#import "ForegroundReconnection.h"

@interface MCMQTTSessionManager()

@property (nonatomic, readwrite) MCMQTTSessionManagerState state;
@property (nonatomic, readwrite) NSError *lastErrorCode;

@property (strong, nonatomic) ReconnectTimer *reconnectTimer;
@property (nonatomic) BOOL reconnectFlag;

@property (strong, nonatomic) MCMQTTSession *session;

@property (strong, nonatomic) NSString *host;
@property (nonatomic) UInt32 port;
@property (nonatomic) BOOL tls;
@property (nonatomic) NSInteger keepalive;
@property (nonatomic) BOOL clean;
@property (nonatomic) BOOL auth;
@property (nonatomic) BOOL will;
@property (strong, nonatomic) NSString *user;
@property (strong, nonatomic) NSString *pass;
@property (strong, nonatomic) NSString *willTopic;
@property (strong, nonatomic) NSData *willMsg;
@property (nonatomic) NSInteger willQos;
@property (nonatomic) BOOL willRetainFlag;
@property (strong, nonatomic) NSString *clientId;
@property (strong, nonatomic) dispatch_queue_t queue;
@property (strong, nonatomic) MQTTSSLSecurityPolicy *securityPolicy;
@property (strong, nonatomic) NSArray *certificates;
@property (nonatomic) MQTTProtocolVersion protocolLevel;

#if TARGET_OS_IPHONE == 1
@property (strong, nonatomic) ForegroundReconnection *foregroundReconnection;
#endif

@property (nonatomic) BOOL persistent;
@property (nonatomic) NSUInteger maxWindowSize;
@property (nonatomic) NSUInteger maxSize;
@property (nonatomic) NSUInteger maxMessages;
@property (strong, nonatomic) NSString *streamSSLLevel;

@property (strong, nonatomic) NSDictionary<NSString *, NSNumber *> *internalSubscriptions;
@property (strong, nonatomic) NSDictionary<NSString *, NSNumber *> *effectiveSubscriptions;
@property (strong, nonatomic) NSLock *subscriptionLock;

@end

#define RECONNECT_TIMER 1.0
#define RECONNECT_TIMER_MAX_DEFAULT 64.0

@implementation MCMQTTSessionManager

- (instancetype)init {
    self = [self initWithPersistence:MQTT_PERSISTENT
                       maxWindowSize:MQTT_MAX_WINDOW_SIZE
                         maxMessages:MQTT_MAX_MESSAGES
                             maxSize:MQTT_MAX_SIZE
          maxConnectionRetryInterval:RECONNECT_TIMER_MAX_DEFAULT
                 connectInForeground:YES
                      streamSSLLevel:(NSString *)kCFStreamSocketSecurityLevelNegotiatedSSL
                               queue:dispatch_get_main_queue()];
    return self;
}

- (MCMQTTSessionManager *)initWithPersistence:(BOOL)persistent
                              maxWindowSize:(NSUInteger)maxWindowSize
                                maxMessages:(NSUInteger)maxMessages
                                    maxSize:(NSUInteger)maxSize
                 maxConnectionRetryInterval:(NSTimeInterval)maxRetryInterval
                        connectInForeground:(BOOL)connectInForeground
                             streamSSLLevel:(NSString *)streamSSLLevel
                                      queue:(dispatch_queue_t)queue {
    self = [super init];

    self.streamSSLLevel = streamSSLLevel;
    self.queue = queue;
    [self updateState:MCMQTTSessionManagerStateStarting];
    self.internalSubscriptions = [[NSMutableDictionary alloc] init];
    self.effectiveSubscriptions = [[NSMutableDictionary alloc] init];
    self.persistent = persistent;
    self.maxWindowSize = maxWindowSize;
    self.maxSize = maxSize;
    self.maxMessages = maxMessages;
    
    __weak MCMQTTSessionManager *weakSelf = self;
    self.reconnectTimer = [[ReconnectTimer alloc] initWithRetryInterval:RECONNECT_TIMER
                                                       maxRetryInterval:maxRetryInterval
                                                                  queue:self.queue
                                                         reconnectBlock:^{
                                                             [weakSelf reconnect:nil];
                                                         }];
#if TARGET_OS_IPHONE == 1
    if (connectInForeground) {
        self.foregroundReconnection = [[ForegroundReconnection alloc] initWithMCMQTTSessionManager:self];
    }
#endif
    self.subscriptionLock = [[NSLock alloc] init];
    
    return self;
}

- (void)connectTo:(NSString *)host
             port:(NSInteger)port
              tls:(BOOL)tls
        keepalive:(NSInteger)keepalive
            clean:(BOOL)clean
             auth:(BOOL)auth
             user:(NSString *)user
             pass:(NSString *)pass
             will:(BOOL)will
        willTopic:(NSString *)willTopic
          willMsg:(NSData *)willMsg
          willQos:(MQTTQosLevel)willQos
   willRetainFlag:(BOOL)willRetainFlag
     withClientId:(NSString *)clientId
   securityPolicy:(MQTTSSLSecurityPolicy *)securityPolicy
     certificates:(NSArray *)certificates
    protocolLevel:(MQTTProtocolVersion)protocolLevel
   connectHandler:(MQTTConnectHandler)connectHandler {
    DDLogVerbose(@"MQTTSessionManager connectTo:%@", host);
    BOOL shouldReconnect = self.session != nil;
    if (!self.session ||
        ![host isEqualToString:self.host] ||
        port != self.port ||
        tls != self.tls ||
        keepalive != self.keepalive ||
        clean != self.clean ||
        auth != self.auth ||
        ![user isEqualToString:self.user] ||
        ![pass isEqualToString:self.pass] ||
        ![willTopic isEqualToString:self.willTopic] ||
        ![willMsg isEqualToData:self.willMsg] ||
        willQos != self.willQos ||
        willRetainFlag != self.willRetainFlag ||
        ![clientId isEqualToString:self.clientId] ||
        securityPolicy != self.securityPolicy ||
        certificates != self.certificates) {
        self.host = host;
        self.port = (int)port;
        self.tls = tls;
        self.keepalive = keepalive;
        self.clean = clean;
        self.auth = auth;
        self.user = user;
        self.pass = pass;
        self.will = will;
        self.willTopic = willTopic;
        self.willMsg = willMsg;
        self.willQos = willQos;
        self.willRetainFlag = willRetainFlag;
        self.clientId = clientId;
        self.securityPolicy = securityPolicy;
        self.certificates = certificates;
        self.protocolLevel = protocolLevel;
        
        self.session = [[MCMQTTSession alloc] initWithClientId:clientId
                                                    userName:auth ? user : nil
                                                    password:auth ? pass : nil
                                                   keepAlive:keepalive
                                                cleanSession:clean
                                                        will:will
                                                   willTopic:willTopic
                                                     willMsg:willMsg
                                                     willQoS:willQos
                                              willRetainFlag:willRetainFlag
                                               protocolLevel:protocolLevel
                                                       queue:self.queue
                                              securityPolicy:securityPolicy
                                                certificates:certificates];
        self.session.streamSSLLevel = self.streamSSLLevel;
        MQTTCoreDataPersistence *persistence = [[MQTTCoreDataPersistence alloc] init];
        
        persistence.persistent = self.persistent;
        persistence.maxWindowSize = self.maxWindowSize;
        persistence.maxSize = self.maxSize;
        persistence.maxMessages = self.maxMessages;
        
        self.session.persistence = persistence;
        
        self.session.delegate = self;
        self.reconnectFlag = FALSE;
    }
    if (shouldReconnect) {
        DDLogVerbose(@"[MCMQTTSessionManager] reconnecting");
        [self disconnectWithDisconnectHandler:nil];
        [self reconnect:connectHandler];
    } else {
        DDLogVerbose(@"[MCMQTTSessionManager] connecting");
        [self connectToInternal:connectHandler];
    }
}

- (UInt16)sendData:(NSData *)data topic:(NSString *)topic qos:(MQTTQosLevel)qos retain:(BOOL)retainFlag {
    if (self.state != MCMQTTSessionManagerStateConnected) {
        [self connectToLast:nil];
    }
    UInt16 msgId = [self.session publishData:data
                                     onTopic:topic
                                      retain:retainFlag
                                         qos:qos];
    return msgId;
}


- (void)disconnectWithDisconnectHandler:(MQTTDisconnectHandler)disconnectHandler {
    [self updateState:MCMQTTSessionManagerStateClosing];
    [self.session closeWithDisconnectHandler:disconnectHandler];
    [self.reconnectTimer stop];
}

- (BOOL)requiresTearDown {
    return (self.state != MCMQTTSessionManagerStateClosed &&
            self.state != MCMQTTSessionManagerStateStarting);
}

- (void)updateState:(MCMQTTSessionManagerState)newState {
    self.state = newState;

    if ([self.delegate respondsToSelector:@selector(sessionManager:didChangeState:)]) {
        [self.delegate sessionManager:self didChangeState:newState];
    }
}


#pragma mark - MQTT Callback methods

- (void)handleEvent:(MCMQTTSession *)session event:(MCMQTTSessionEvent)eventCode error:(NSError *)error {
#ifdef DEBUG
    __unused const NSDictionary *events = @{
                                            @(MCMQTTSessionEventConnected): @"connected",
                                            @(MCMQTTSessionEventConnectionRefused): @"connection refused",
                                            @(MCMQTTSessionEventConnectionClosed): @"connection closed",
                                            @(MCMQTTSessionEventConnectionError): @"connection error",
                                            @(MCMQTTSessionEventProtocolError): @"protocoll error",
                                            @(MCMQTTSessionEventConnectionClosedByBroker): @"connection closed by broker"
                                            };
    DDLogVerbose(@"[MCMQTTSessionManager] eventCode: %@ (%ld) %@", events[@(eventCode)], (long)eventCode, error);
#endif
    switch (eventCode) {
        case MCMQTTSessionEventConnected:
            self.lastErrorCode = nil;
            [self updateState:MCMQTTSessionManagerStateConnected];
            [self.reconnectTimer resetRetryInterval];
            break;
            
        case MCMQTTSessionEventConnectionClosed:
            [self updateState:MCMQTTSessionManagerStateClosed];
            break;
            
        case MCMQTTSessionEventConnectionClosedByBroker:
            if (self.state != MCMQTTSessionManagerStateClosing) {
                [self triggerDelayedReconnect];
            }
            [self updateState:MCMQTTSessionManagerStateClosed];
            break;

        case MCMQTTSessionEventProtocolError:
        case MCMQTTSessionEventConnectionRefused:
        case MCMQTTSessionEventConnectionError:
            [self triggerDelayedReconnect];
            self.lastErrorCode = error;
            [self updateState:MCMQTTSessionManagerStateError];
            break;

        default:
            break;
    }
}

- (void)newMessage:(MCMQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(sessionManager:didReceiveMessage:onTopic:retained:)]) {
            [self.delegate sessionManager:self didReceiveMessage:data onTopic:topic retained:retained];
        }
        if ([self.delegate respondsToSelector:@selector(handleMessage:onTopic:retained:)]) {
            [self.delegate handleMessage:data onTopic:topic retained:retained];
        }
    }
}

- (void)connected:(MCMQTTSession *)session sessionPresent:(BOOL)sessionPresent {
    if (self.clean || !self.reconnectFlag || !sessionPresent) {
        NSDictionary *subscriptions = [self.internalSubscriptions copy];
        [self.subscriptionLock lock];
        self.effectiveSubscriptions = [[NSMutableDictionary alloc] init];
        [self.subscriptionLock unlock];
        if (subscriptions.count) {
            __weak MCMQTTSessionManager *weakSelf = self;
            [self.session subscribeToTopics:subscriptions subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
                MCMQTTSessionManager *strongSelf = weakSelf;
                if (!error) {
                    NSArray<NSString *> *allTopics = subscriptions.allKeys;
                    for (int i = 0; i < allTopics.count; i++) {
                        NSString *topic = allTopics[i];
                        NSNumber *gQos = gQoss[i];
                        [strongSelf.subscriptionLock lock];
                        NSMutableDictionary *newEffectiveSubscriptions = [strongSelf.subscriptions mutableCopy];
                        newEffectiveSubscriptions[topic] = gQos;
                        strongSelf.effectiveSubscriptions = newEffectiveSubscriptions;
                        [strongSelf.subscriptionLock unlock];
                    }
                }
            }];

        }
        self.reconnectFlag = TRUE;
    }
}

- (void)messageDelivered:(MCMQTTSession *)session msgID:(UInt16)msgID {
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(sessionManager:didDeliverMessage:)]) {
            [self.delegate sessionManager:self didDeliverMessage:msgID];
        }
        if ([self.delegate respondsToSelector:@selector(messageDelivered:)]) {
            [self.delegate messageDelivered:msgID];
        }
    }
}


- (void)connectToInternal:(MQTTConnectHandler)connectHandler {
    if (self.session && self.state == MCMQTTSessionManagerStateStarting) {
        [self updateState:MCMQTTSessionManagerStateConnecting];
        [self.session connectToHost:self.host
                               port:self.port
                           usingSSL:self.tls
                     connectHandler:connectHandler];
    }
}

- (void)reconnect:(MQTTConnectHandler)connectHandler {
    [self updateState:MCMQTTSessionManagerStateStarting];
    [self connectToInternal:connectHandler];
}

- (void)connectToLast:(MQTTConnectHandler)connectHandler {
    if (self.state == MCMQTTSessionManagerStateConnected) {
        return;
    }
    [self.reconnectTimer resetRetryInterval];
    [self reconnect:connectHandler];
}

- (void)triggerDelayedReconnect {
    [self.reconnectTimer schedule];
}

- (NSDictionary<NSString *, NSNumber *> *)subscriptions {
    return self.internalSubscriptions;
}

- (void)setSubscriptions:(NSDictionary<NSString *, NSNumber *> *)newSubscriptions {
    if (self.state == MCMQTTSessionManagerStateConnected) {
        NSDictionary *currentSubscriptions = [self.effectiveSubscriptions copy];

        for (NSString *topicFilter in currentSubscriptions) {
            if (!newSubscriptions[topicFilter]) {
                __weak MCMQTTSessionManager *weakSelf = self;
                [self.session unsubscribeTopic:topicFilter unsubscribeHandler:^(NSError *error) {
                    MCMQTTSessionManager *strongSelf = weakSelf;
                    if (!error) {
                        [strongSelf.subscriptionLock lock];
                        NSMutableDictionary *newEffectiveSubscriptions = [strongSelf.subscriptions mutableCopy];
                        [newEffectiveSubscriptions removeObjectForKey:topicFilter];
                        strongSelf.effectiveSubscriptions = newEffectiveSubscriptions;
                        [strongSelf.subscriptionLock unlock];
                    }
                }];
            }
        }

        for (NSString *topicFilter in newSubscriptions) {
            if (!currentSubscriptions[topicFilter]) {
                NSNumber *number = newSubscriptions[topicFilter];
                MQTTQosLevel qos = number.unsignedIntValue;
                __weak MCMQTTSessionManager *weakSelf = self;
                [self.session subscribeToTopic:topicFilter atLevel:qos subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
                    MCMQTTSessionManager *strongSelf = weakSelf;
                    if (!error) {
                        NSNumber *gQos = gQoss[0];
                        [strongSelf.subscriptionLock lock];
                        NSMutableDictionary *newEffectiveSubscriptions = [strongSelf.subscriptions mutableCopy];
                        newEffectiveSubscriptions[topicFilter] = gQos;
                        strongSelf.effectiveSubscriptions = newEffectiveSubscriptions;
                        [strongSelf.subscriptionLock unlock];
                    }
                }];
            }
        }
    }
    self.internalSubscriptions = newSubscriptions;
    DDLogVerbose(@"MCMQTTSessionManager internalSubscriptions: %@", self.internalSubscriptions);
}

@end
