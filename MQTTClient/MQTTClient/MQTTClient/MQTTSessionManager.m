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
@property (strong, nonatomic) NSRunLoop *runLoop;
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

@property (strong, nonatomic) NSDictionary<NSString *, NSNumber *> *internalSubscriptions;
@property (strong, nonatomic) NSDictionary<NSString *, NSNumber *> *effectiveSubscriptions;
@property (strong, nonatomic) NSLock *subscriptionLock;

@end

#define RECONNECT_TIMER 1.0
#define RECONNECT_TIMER_MAX_DEFAULT 64.0
#define BACKGROUND_DISCONNECT_AFTER 8.0

@implementation MCMQTTSessionManager

- (MCMQTTSessionManager *)initWithPersistence:(BOOL)persistent
                              maxWindowSize:(NSUInteger)maxWindowSize
                                maxMessages:(NSUInteger)maxMessages
                                    maxSize:(NSUInteger)maxSize
                 maxConnectionRetryInterval:(NSTimeInterval)maxRetryInterval
                        connectInForeground:(BOOL)connectInForeground {
    self = [super init];
    
    [self updateState:MCMQTTSessionManagerStateStarting];
    self.internalSubscriptions = [[NSMutableDictionary alloc] init];
    self.effectiveSubscriptions = [[NSMutableDictionary alloc] init];
    
    self.persistent = persistent;
    self.maxWindowSize = maxWindowSize;
    self.maxSize = maxSize;
    self.maxMessages = maxMessages;
    self.reconnectTimer = [[ReconnectTimer alloc] initWithRetryInterval:RECONNECT_TIMER
                                                       maxRetryInterval:maxRetryInterval
                                                         reconnectBlock:^{
                                                             __weak MCMQTTSessionManager *weakSelf = self;
                                                             [weakSelf reconnect];
                                                         }];
#if TARGET_OS_IPHONE == 1
    if (connectInForeground) {
        self.foregroundReconnection = [[ForegroundReconnection alloc] initWithMCMQTTSessionManager:self];
    }
#endif
    self.subscriptionLock = [[NSLock alloc] init];
    
    return self;
}

- (MCMQTTSessionManager *)initWithPersistence:(BOOL)persistent
                              maxWindowSize:(NSUInteger)maxWindowSize
                                maxMessages:(NSUInteger)maxMessages
                                    maxSize:(NSUInteger)maxSize
                        connectInForeground:(BOOL)connectInForeground {
    self = [self initWithPersistence:persistent
                       maxWindowSize:maxWindowSize
                         maxMessages:maxMessages
                             maxSize:maxSize
          maxConnectionRetryInterval:RECONNECT_TIMER_MAX_DEFAULT
                 connectInForeground:connectInForeground];
    return self;
}

- (instancetype)init {
    self = [self initWithPersistence:MQTT_PERSISTENT
                       maxWindowSize:MQTT_MAX_WINDOW_SIZE
                         maxMessages:MQTT_MAX_MESSAGES
                             maxSize:MQTT_MAX_SIZE
          maxConnectionRetryInterval:RECONNECT_TIMER_MAX_DEFAULT
                 connectInForeground:YES];
    return self;
}

- (MCMQTTSessionManager *)initWithPersistence:(BOOL)persistent
                              maxWindowSize:(NSUInteger)maxWindowSize
                                maxMessages:(NSUInteger)maxMessages
                                    maxSize:(NSUInteger)maxSize {
    self = [self initWithPersistence:persistent
                       maxWindowSize:maxWindowSize
                         maxMessages:maxMessages
                             maxSize:maxSize
          maxConnectionRetryInterval:RECONNECT_TIMER_MAX_DEFAULT
                 connectInForeground:YES];
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
        willTopic:(NSString *)willTopic
             will:(NSData *)will
          willQos:(MQTTQosLevel)willQos
   willRetainFlag:(BOOL)willRetainFlag
     withClientId:(NSString *)clientId {
    [self connectTo:host
               port:port
                tls:tls
          keepalive:keepalive
              clean:clean
               auth:auth
               user:user
               pass:pass
               will:YES
          willTopic:willTopic
            willMsg:will
            willQos:willQos
     willRetainFlag:willRetainFlag
       withClientId:clientId];
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
     withClientId:(NSString *)clientId {
    [self connectTo:host
               port:port
                tls:tls
          keepalive:keepalive
              clean:clean
               auth:auth
               user:user
               pass:pass
               will:will
          willTopic:willTopic
            willMsg:willMsg
            willQos:willQos
     willRetainFlag:willRetainFlag
       withClientId:clientId
     securityPolicy:nil
       certificates:nil];
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
protocolLevel:(MQTTProtocolVersion)protocolLevel {
    [self connectTo:host
               port:port
                tls:tls
          keepalive:keepalive
              clean:clean
               auth:auth
               user:user
               pass:pass
               will:will
          willTopic:willTopic
            willMsg:willMsg
            willQos:willQos
     willRetainFlag:willRetainFlag
       withClientId:clientId
     securityPolicy:securityPolicy
       certificates:certificates
      protocolLevel:protocolLevel
            runLoop:[NSRunLoop currentRunLoop]];
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
     certificates:(NSArray *)certificates {
    [self connectTo:host
               port:port
                tls:tls
          keepalive:keepalive
              clean:clean
               auth:auth
               user:user
               pass:pass
               will:will
          willTopic:willTopic
            willMsg:willMsg
            willQos:willQos
     willRetainFlag:willRetainFlag
       withClientId:clientId
     securityPolicy:securityPolicy
       certificates:certificates
      protocolLevel:MQTTProtocolVersion311 // use this level as default, keeps it backwards compatible
            runLoop:[NSRunLoop currentRunLoop]];
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
          runLoop:(NSRunLoop *)runLoop {
    DDLogVerbose(@"MCMQTTSessionManager connectTo:%@", host);
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
        certificates != self.certificates ||
        runLoop != self.runLoop) {
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
        self.runLoop = runLoop;
        
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
                                                     runLoop:runLoop
                                                     forMode:NSDefaultRunLoopMode
                                              securityPolicy:securityPolicy
                                                certificates:certificates];

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
        [self disconnect];
        [self reconnect];
    } else {
        DDLogVerbose(@"[MCMQTTSessionManager] connecting");
        [self connectToInternal];
    }
}

- (UInt16)sendData:(NSData *)data topic:(NSString *)topic qos:(MQTTQosLevel)qos retain:(BOOL)retainFlag {
    if (self.state != MCMQTTSessionManagerStateConnected) {
        [self connectToLast];
    }
    UInt16 msgId = [self.session publishData:data
                                     onTopic:topic
                                      retain:retainFlag
                                         qos:qos];
    return msgId;
}

- (void)disconnect {
    [self updateState:MCMQTTSessionManagerStateClosing];
    [self.session close];
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
            [self.session subscribeToTopics:subscriptions subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
                if (!error) {
                    NSArray<NSString *> *allTopics = subscriptions.allKeys;
                    for (int i = 0; i < allTopics.count; i++) {
                        NSString *topic = allTopics[i];
                        NSNumber *gQos = gQoss[i];
                        [self.subscriptionLock lock];
                        NSMutableDictionary *newEffectiveSubscriptions = [self.subscriptions mutableCopy];
                        newEffectiveSubscriptions[topic] = gQos;
                        self.effectiveSubscriptions = newEffectiveSubscriptions;
                        [self.subscriptionLock unlock];
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


- (void)connectToInternal {
    if (self.session && self.state == MCMQTTSessionManagerStateStarting) {
        [self updateState:MCMQTTSessionManagerStateConnecting];
        [self.session connectToHost:self.host
                               port:self.port
                           usingSSL:self.tls];
    }
}

- (void)reconnect {
    [self updateState:MCMQTTSessionManagerStateStarting];
    [self connectToInternal];
}

- (void)connectToLast {
    if (self.state == MCMQTTSessionManagerStateConnected) {
        return;
    }
    [self.reconnectTimer resetRetryInterval];
    [self reconnect];
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
                [self.session unsubscribeTopic:topicFilter unsubscribeHandler:^(NSError *error) {
                    if (!error) {
                        [self.subscriptionLock lock];
                        NSMutableDictionary *newEffectiveSubscriptions = [self.subscriptions mutableCopy];
                        [newEffectiveSubscriptions removeObjectForKey:topicFilter];
                        self.effectiveSubscriptions = newEffectiveSubscriptions;
                        [self.subscriptionLock unlock];
                    }
                }];
            }
        }

        for (NSString *topicFilter in newSubscriptions) {
            if (!currentSubscriptions[topicFilter]) {
                NSNumber *number = newSubscriptions[topicFilter];
                MQTTQosLevel qos = number.unsignedIntValue;
                [self.session subscribeToTopic:topicFilter atLevel:qos subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
                    if (!error) {
                        NSNumber *gQos = gQoss[0];
                        [self.subscriptionLock lock];
                        NSMutableDictionary *newEffectiveSubscriptions = [self.subscriptions mutableCopy];
                        newEffectiveSubscriptions[topicFilter] = gQos;
                        self.effectiveSubscriptions = newEffectiveSubscriptions;
                        [self.subscriptionLock unlock];
                    }
                }];
            }
        }
    }
    self.internalSubscriptions = newSubscriptions;
    DDLogVerbose(@"MCMQTTSessionManager internalSubscriptions: %@", self.internalSubscriptions);
}

@end
