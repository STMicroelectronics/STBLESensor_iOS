//
//  MQTTMQTTTestSessionManager.m
//  MQTTClient
//
//  Created by Christoph Krey on 21.08.15.
//  Copyright © 2015-2017 Christoph Krey. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MQTTLog.h"
#import "MCMQTTSessionManager.h"
#import "MCMQTTCFSocketTransport.h"
#import "MQTTTestHelpers.h"

@interface MCMQTTSessionManager (Tests)

- (void)connectWithParameters:(NSDictionary *)parameters clean:(BOOL)clean;

@end

@implementation MCMQTTSessionManager (Tests)

- (void)connectWithParameters:(NSDictionary *)parameters clean:(BOOL)clean {
    [self connectTo:parameters[@"host"]
               port:[parameters[@"port"] intValue]
                tls:[parameters[@"tls"] boolValue]
          keepalive:60
              clean:clean
               auth:NO
               user:nil
               pass:nil
               will:NO
          willTopic:nil
            willMsg:nil
            willQos:MQTTQosLevelAtMostOnce
     willRetainFlag:NO
       withClientId:nil
     securityPolicy:[MQTTTestHelpers securityPolicy:parameters]
       certificates:[MQTTTestHelpers clientCerts:parameters]
      protocolLevel:[parameters[@"protocollevel"] intValue]
            runLoop:[NSRunLoop currentRunLoop]];
}

@end

@interface MQTTTestSessionManager : MQTTTestHelpers <MCMQTTSessionManagerDelegate>
@property (nonatomic) int step;
@property (nonatomic) int sent;
@property (nonatomic) int received;
@property (nonatomic) int processed;

@end

@implementation MQTTTestSessionManager

- (void)testMCMQTTSessionManagerClean {
    [MQTTLog setLogLevel:DDLogLevelInfo];
    [self testMCMQTTSessionManager:true];
}

- (void)testMCMQTTSessionManagerNoClean {
    [MQTTLog setLogLevel:DDLogLevelInfo];
    [self testMCMQTTSessionManager:false];
}

- (void)testMCMQTTSessionManager:(BOOL)clean {
    for (NSString *broker in self.brokers.allKeys) {
        DDLogInfo(@"testing broker %@", broker);
        NSDictionary *parameters = self.brokers[broker];
        if ([parameters[@"websocket"] boolValue]) {
            continue;
        }
        self.step = -1;
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:[parameters[@"timeout"] intValue]
                                                          target:self
                                                        selector:@selector(stepper:)
                                                        userInfo:nil
                                                         repeats:true];
        
        self.received = 0;
        MCMQTTSessionManager *manager = [[MCMQTTSessionManager alloc] init];
        manager.delegate = self;
        
        [manager addObserver:self
                  forKeyPath:@"effectiveSubscriptions"
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:nil];
        manager.subscriptions = [@{TOPIC: @(0)} mutableCopy];
        [manager connectWithParameters:parameters clean:clean];
        
        while (self.step == -1 && manager.state != MCMQTTSessionManagerStateConnected) {
            DDLogInfo(@"[testMCMQTTSessionManager] waiting for connect %d", manager.state);
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        XCTAssertEqual(manager.state, MCMQTTSessionManagerStateConnected);
        [manager sendData:[[NSData alloc] init] topic:TOPIC qos:MQTTQosLevelAtMostOnce retain:true];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        
        while (self.step <= 0) {
            DDLogInfo(@"[testMCMQTTSessionManager] received %lu/%lu on TOPIC", (unsigned long)self.received, (unsigned long)self.sent);
            [manager sendData:[[NSDate date].description dataUsingEncoding:NSUTF8StringEncoding]
                        topic:TOPIC qos:MQTTQosLevelAtMostOnce retain:FALSE];
            self.sent++;
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        
        manager.subscriptions = [@{TOPIC: @(0),@"$SYS/#": @(0)} mutableCopy];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        
        while (self.step == 1) {
            DDLogInfo(@"[testMCMQTTSessionManager] received %lu/%lu on TOPIC or $SYS/#", (unsigned long)self.received, (unsigned long)self.sent);
            [manager sendData:[[NSDate date].description dataUsingEncoding:NSUTF8StringEncoding]
                        topic:TOPIC qos:MQTTQosLevelAtMostOnce retain:FALSE];
            self.sent++;
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        
        manager.subscriptions = [@{@"$SYS/#": @(0)} mutableCopy];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        
        while (self.step <= 2) {
            DDLogInfo(@"[testMCMQTTSessionManager] received %lu/%lu on $SYS/#", (unsigned long)self.received, (unsigned long)self.sent);
            [manager sendData:[[NSDate date].description dataUsingEncoding:NSUTF8StringEncoding]
                        topic:TOPIC qos:MQTTQosLevelAtMostOnce retain:FALSE];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        
        manager.subscriptions = [@{} mutableCopy];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        
        while (self.step <= 3) {
            DDLogInfo(@"[testMCMQTTSessionManager] received %lu/%lu on nothing", (unsigned long)self.received, (unsigned long)self.sent);
            [manager sendData:[[NSDate date].description dataUsingEncoding:NSUTF8StringEncoding]
                        topic:TOPIC qos:MQTTQosLevelAtMostOnce retain:FALSE];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        
        [manager disconnect];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        
        while (self.step <= 4) {
            DDLogInfo(@"[testMCMQTTSessionManager] received %lu/%lu after disconnect", (unsigned long)self.received, (unsigned long)self.sent);
            [manager sendData:[[NSDate date].description dataUsingEncoding:NSUTF8StringEncoding]
                        topic:TOPIC qos:MQTTQosLevelAtMostOnce retain:FALSE];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        XCTAssertEqual(self.received, self.sent);
        [manager removeObserver:self forKeyPath:@"effectiveSubscriptions"];
        [timer invalidate];
    }
}

- (void)testMCMQTTSessionManagerPersistent {
    [MQTTLog setLogLevel:DDLogLevelInfo];
    for (NSString *broker in self.brokers.allKeys) {
        DDLogInfo(@"testing broker %@", broker);
        NSDictionary *parameters = self.brokers[broker];
        if ([parameters[@"websocket"] boolValue]) {
            continue;
        }
        
        self.step = -1;
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:[parameters[@"timeout"] intValue]
                                                          target:self
                                                        selector:@selector(stepper:)
                                                        userInfo:nil
                                                         repeats:true];
        
        self.received = 0;
        MCMQTTSessionManager *manager = [[MCMQTTSessionManager alloc] initWithPersistence:true
                                                                        maxWindowSize:2
                                                                          maxMessages:1024
                                                                              maxSize:64*1024*1024];
        manager.delegate = self;
        [manager addObserver:self
                  forKeyPath:@"effectiveSubscriptions"
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:nil];
        
        manager.subscriptions = [@{TOPIC: @(0)} mutableCopy];
        [manager connectWithParameters:parameters clean:YES];
        while (self.step == -1 && manager.state != MCMQTTSessionManagerStateConnected) {
            DDLogInfo(@"[testMCMQTTSessionManagerPersistent] waiting for connect %d", manager.state);
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        XCTAssertEqual(manager.state, MCMQTTSessionManagerStateConnected);
        [manager sendData:[[NSData alloc] init] topic:TOPIC qos:MQTTQosLevelAtMostOnce retain:true];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        
        while (self.step <= 0) {
            DDLogInfo(@"received %lu/%lu on TOPIC", (unsigned long)self.received, (unsigned long)self.sent);
            [manager sendData:[@"data" dataUsingEncoding:NSUTF8StringEncoding] topic:TOPIC qos:MQTTQosLevelAtMostOnce retain:FALSE];
            self.sent++;
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
        }
        
        manager.subscriptions = [@{TOPIC: @(0),@"a": @(1),@"b": @(2),@"$SYS/#": @(0)} mutableCopy];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        
        while (self.step == 1) {
            DDLogInfo(@"[testMCMQTTSessionManagerPersistent] received %lu/%lu on TOPIC or $SYS/#", (unsigned long)self.received, (unsigned long)self.sent);
            [manager sendData:[@"data" dataUsingEncoding:NSUTF8StringEncoding] topic:TOPIC qos:MQTTQosLevelAtMostOnce retain:FALSE];
            self.sent++;
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
        }
        
        manager.subscriptions = [@{@"$SYS/#": @(0)} mutableCopy];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        
        while (self.step <= 2) {
            DDLogInfo(@"[testMCMQTTSessionManagerPersistent] received %lu/%lu on $SYS/#", (unsigned long)self.received, (unsigned long)self.sent);
            [manager sendData:[@"data" dataUsingEncoding:NSUTF8StringEncoding] topic:TOPIC qos:MQTTQosLevelAtMostOnce retain:FALSE];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
        }
        
        manager.subscriptions = [@{} mutableCopy];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        
        while (self.step <= 3) {
            DDLogInfo(@"[testMCMQTTSessionManagerPersistent] received %lu/%lu on nothing", (unsigned long)self.received, (unsigned long)self.sent);
            [manager sendData:[@"data" dataUsingEncoding:NSUTF8StringEncoding] topic:TOPIC qos:MQTTQosLevelAtMostOnce retain:FALSE];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
        }
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        
        [manager disconnect];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        
        while (self.step <= 4) {
            DDLogInfo(@"[testMCMQTTSessionManagerPersistent] received %lu/%lu after disconnect", (unsigned long)self.received, (unsigned long)self.sent);
            [manager sendData:[[NSDate date].description dataUsingEncoding:NSUTF8StringEncoding]
                        topic:TOPIC qos:MQTTQosLevelAtMostOnce retain:FALSE];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
        }
        XCTAssertEqual(self.received, self.sent);
        [manager removeObserver:self forKeyPath:@"effectiveSubscriptions"];
        
        [timer invalidate];
    }
}

- (void)testSessionManagerShort {
    [MQTTLog setLogLevel:DDLogLevelInfo];
    for (NSString *broker in self.brokers.allKeys) {
        DDLogInfo(@"testing broker %@", broker);
        NSDictionary *parameters = self.brokers[broker];
        if ([parameters[@"websocket"] boolValue]) {
            continue;
        }
        
        MCMQTTSessionManager *manager = [[MCMQTTSessionManager alloc] init];
        manager.delegate = self;
        [manager addObserver:self
                  forKeyPath:@"effectiveSubscriptions"
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:nil];
        
        // allow 5 sec for connect
        self.timedout = false;
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                          target:self
                                                        selector:@selector(timedout:)
                                                        userInfo:nil
                                                         repeats:false];
        
        
        manager.subscriptions = @{TOPIC: @(MQTTQosLevelExactlyOnce)};
        [manager connectWithParameters:parameters clean:YES];

        while (!self.timedout && manager.state != MCMQTTSessionManagerStateConnected) {
            DDLogInfo(@"waiting for connect %d", manager.state);
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
        }
        if (timer.valid) [timer invalidate];
        
        // allow 5 sec for sending and receiving
        self.timedout = false;
        timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                 target:self
                                               selector:@selector(timedout:)
                                               userInfo:nil
                                                repeats:false];
        
        
        while (!self.timedout) {
            [manager sendData:[[NSDate date].description dataUsingEncoding:NSUTF8StringEncoding]
                        topic:TOPIC qos:MQTTQosLevelExactlyOnce retain:FALSE];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        if (timer.valid) [timer invalidate];
        [manager sendData:[[NSData alloc] init] topic:TOPIC qos:MQTTQosLevelExactlyOnce retain:true];
        
        // allow 3 sec for disconnect
        self.timedout = false;
        timer = [NSTimer scheduledTimerWithTimeInterval:3
                                                 target:self
                                               selector:@selector(timedout:)
                                               userInfo:nil
                                                repeats:false];
        
        [manager disconnect];
        while (!self.timedout && manager.state != MCMQTTSessionStatusClosed) {
            DDLogInfo(@"waiting for disconnect %d", manager.state);
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
        }
        if (timer.valid) [timer invalidate];
        [manager removeObserver:self forKeyPath:@"effectiveSubscriptions"];
    }
}

- (void)testSessionManagerALotSubscriptions {
    [MQTTLog setLogLevel:DDLogLevelInfo];
    for (NSString *broker in self.brokers.allKeys) {
        DDLogInfo(@"testing broker %@", broker);
        NSDictionary *parameters = self.brokers[broker];
        if ([parameters[@"websocket"] boolValue]) {
            continue;
        }
        
        MCMQTTSessionManager *manager = [[MCMQTTSessionManager alloc] init];
        manager.delegate = self;
        
        [manager addObserver:self
                  forKeyPath:@"effectiveSubscriptions"
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:nil];
        
        NSMutableDictionary *subscriptions = [@{TOPIC: @(0),
                                                @"a0": @(1),
                                                @"b0": @(2),
                                                @"a1": @(1),
                                                @"b1": @(2),
                                                @"a2": @(1),
                                                @"b2": @(2),
                                                @"a3": @(1),
                                                @"b3": @(2),
                                                @"a4": @(1),
                                                @"b4": @(2),
                                                @"a5": @(1),
                                                @"b5": @(2),
                                                @"a6": @(1),
                                                @"b6": @(2),
                                                @"a7": @(1),
                                                @"b7": @(2),
                                                @"a8": @(1),
                                                @"b8": @(2),
                                                @"a9": @(1),
                                                @"b9": @(2),
                                                @"a0/x": @(1),
                                                @"b0/x": @(2),
                                                @"a1/x": @(1),
                                                @"b1/x": @(2),
                                                @"a2/x": @(1),
                                                @"b2/x": @(2),
                                                @"a3/x": @(1),
                                                @"b3/x": @(2),
                                                @"a4/x": @(1),
                                                @"b4/x": @(2),
                                                @"a5/x": @(1),
                                                @"b5/x": @(2),
                                                @"a6/x": @(1),
                                                @"b6/x": @(2),
                                                @"a7/x": @(1),
                                                @"b7/x": @(2),
                                                @"a8/x": @(1),
                                                @"b8/x": @(2),
                                                @"a9/x": @(1),
                                                @"b9/x": @(2),
                                                @"a0/x/y/z": @(1),
                                                @"b0/x/y/z": @(2),
                                                @"a1/x/y/z": @(1),
                                                @"b1/x/y/z": @(2),
                                                @"a2/x/y/z": @(1),
                                                @"b2/x/y/z": @(2),
                                                @"a3/x/y/z": @(1),
                                                @"b3/x/y/z": @(2),
                                                @"a4/x/y/z": @(1),
                                                @"b4/x/y/z": @(2),
                                                @"a5/x/y/z": @(1),
                                                @"b5/x/y/z": @(2),
                                                @"a6/x/y/z": @(1),
                                                @"b6/x/y/z": @(2),
                                                @"a7/x/y/z": @(1),
                                                @"b7/x/y/z": @(2),
                                                @"a8/x/y/z": @(1),
                                                @"b8/x/y/z": @(2),
                                                @"a9/x/y/z": @(1),
                                                @"b9/x/y/z": @(2),
                                                @"$SYS/#": @(0)
                                                } mutableCopy];

        manager.subscriptions = subscriptions;
        
        // allow 5 sec for connect
        self.timedout = false;
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                          target:self
                                                        selector:@selector(timedout:)
                                                        userInfo:nil
                                                         repeats:false];

        [manager connectWithParameters:parameters clean:YES];
        
        while (!self.timedout && manager.state != MCMQTTSessionManagerStateConnected) {
            DDLogInfo(@"waiting for connect %d", manager.state);
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
        }
        if (timer.valid) [timer invalidate];
        
        manager.subscriptions = @{};
        
        // allow 5 sec for subscribing
        self.timedout = false;
        timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                 target:self
                                               selector:@selector(timedout:)
                                               userInfo:nil
                                                repeats:false];
        
        
        while (!self.timedout) {
            [manager sendData:[[NSDate date].description dataUsingEncoding:NSUTF8StringEncoding]
                        topic:TOPIC qos:MQTTQosLevelExactlyOnce retain:FALSE];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        if (timer.valid) [timer invalidate];
        
        manager.subscriptions = [@{TOPIC: @(0),
                                   @"a0": @(1),
                                   @"b0": @(2),
                                   @"a1": @(1),
                                   @"b1": @(2),
                                   @"a2": @(1),
                                   @"b2": @(2),
                                   @"a3": @(1),
                                   @"b3": @(2),
                                   @"a4": @(1),
                                   @"b4": @(2),
                                   @"a5": @(1),
                                   @"b5": @(2),
                                   @"a6": @(1),
                                   @"b6": @(2),
                                   @"a7": @(1),
                                   @"b7": @(2),
                                   @"a8": @(1),
                                   @"b8": @(2),
                                   @"a9": @(1),
                                   @"b9": @(2),
                                   @"a0/x/y/z": @(1),
                                   @"b0/x/y/z": @(2),
                                   @"a1/x/y/z": @(1),
                                   @"b1/x/y/z": @(2),
                                   @"a2/x/y/z": @(1),
                                   @"b2/x/y/z": @(2),
                                   @"a3/x/y/z": @(1),
                                   @"b3/x/y/z": @(2),
                                   @"a4/x/y/z": @(1),
                                   @"b4/x/y/z": @(2),
                                   @"a5/x/y/z": @(1),
                                   @"b5/x/y/z": @(2),
                                   @"a6/x/y/z": @(1),
                                   @"b6/x/y/z": @(2),
                                   @"a7/x/y/z": @(1),
                                   @"b7/x/y/z": @(2),
                                   @"a8/x/y/z": @(1),
                                   @"b8/x/y/z": @(2),
                                   @"a9/x/y/z": @(1),
                                   @"b9/x/y/z": @(2),
                                   @"$SYS/#": @(0)
                                   } mutableCopy];
        
        // allow 5 sec for subscribing
        self.timedout = false;
        timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                 target:self
                                               selector:@selector(timedout:)
                                               userInfo:nil
                                                repeats:false];
        
        
        while (!self.timedout) {
            [manager sendData:[[NSDate date].description dataUsingEncoding:NSUTF8StringEncoding]
                        topic:TOPIC qos:MQTTQosLevelExactlyOnce retain:FALSE];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        if (timer.valid) [timer invalidate];
        
        manager.subscriptions = [@{TOPIC: @(0),
                                   @"a0": @(1),
                                   @"b0": @(2),
                                   @"a1": @(1),
                                   @"b1": @(2),
                                   @"a2": @(1),
                                   @"b2": @(2),
                                   @"a3": @(1),
                                   @"b3": @(2),
                                   @"a4": @(1),
                                   @"b4": @(2),
                                   @"a5": @(1),
                                   @"b5": @(2),
                                   @"a6": @(1),
                                   @"b6": @(2),
                                   @"a7": @(1),
                                   @"b7": @(2),
                                   @"a8": @(1),
                                   @"b8": @(2),
                                   @"a9": @(1),
                                   @"b9": @(2),
                                   @"a0/x": @(1),
                                   @"b0/x": @(2),
                                   @"a1/x": @(1),
                                   @"b1/x": @(2),
                                   @"a2/x": @(1),
                                   @"b2/x": @(2),
                                   @"a3/x": @(1),
                                   @"b3/x": @(2),
                                   @"a4/x": @(1),
                                   @"b4/x": @(2),
                                   @"a5/x": @(1),
                                   @"b5/x": @(2),
                                   @"a6/x": @(1),
                                   @"b6/x": @(2),
                                   @"a7/x": @(1),
                                   @"b7/x": @(2),
                                   @"a8/x": @(1),
                                   @"b8/x": @(2),
                                   @"a9/x": @(1),
                                   @"b9/x": @(2),
                                   @"$SYS/#": @(0)
                                   } mutableCopy];
        
        // allow 5 sec for subscribing
        self.timedout = false;
        timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                 target:self
                                               selector:@selector(timedout:)
                                               userInfo:nil
                                                repeats:false];
        
        
        while (!self.timedout) {
            [manager sendData:[[NSDate date].description dataUsingEncoding:NSUTF8StringEncoding]
                        topic:TOPIC qos:MQTTQosLevelExactlyOnce retain:FALSE];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        if (timer.valid) [timer invalidate];
        
        
        for (int i = 0; i < 30; i++) {
            subscriptions[[NSString stringWithFormat:@"abc/%d", i]] = @1;
            manager.subscriptions = subscriptions;
        }
        
        for (int i = 0; i < 30; i++) {
            [subscriptions removeObjectForKey:[NSString stringWithFormat:@"abc/%d", i]];
            manager.subscriptions = subscriptions;
        }
        
        // allow 5 sec for subscribing
        self.timedout = false;
        timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                 target:self
                                               selector:@selector(timedout:)
                                               userInfo:nil
                                                repeats:false];

        while (!self.timedout) {
            [manager sendData:[[NSDate date].description dataUsingEncoding:NSUTF8StringEncoding]
                        topic:TOPIC qos:MQTTQosLevelExactlyOnce retain:FALSE];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        if (timer.valid) [timer invalidate];
        
        // allow 5 sec for sending and receiving
        self.timedout = false;
        timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                 target:self
                                               selector:@selector(timedout:)
                                               userInfo:nil
                                                repeats:false];

        while (!self.timedout) {
            [manager sendData:[[NSDate date].description dataUsingEncoding:NSUTF8StringEncoding]
                        topic:TOPIC qos:MQTTQosLevelExactlyOnce retain:FALSE];
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        if (timer.valid) [timer invalidate];
        
        [manager sendData:[[NSData alloc] init] topic:TOPIC qos:MQTTQosLevelExactlyOnce retain:true];
        
        // allow 3 sec for disconnect
        self.timedout = false;
        timer = [NSTimer scheduledTimerWithTimeInterval:3
                                                 target:self
                                               selector:@selector(timedout:)
                                               userInfo:nil
                                                repeats:false];
        
        [manager disconnect];
        while (!self.timedout && manager.state != MCMQTTSessionStatusClosed) {
            DDLogInfo(@"waiting for disconnect %d", manager.state);
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]];
        }
        
        if (timer.valid) [timer invalidate];
        
        [manager removeObserver:self forKeyPath:@"effectiveSubscriptions"];
    }
}

- (void)testMCMQTTSessionManagerRecconnectionWithConnectToLast {
    for (NSString *broker in self.brokers.allKeys) {
        DDLogInfo(@"testing broker %@", broker);
        NSDictionary *parameters = self.brokers[broker];
        if ([parameters[@"websocket"] boolValue]) {
            continue;
        }
        self.step = -1;
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:[parameters[@"timeout"] intValue]
                                                          target:self
                                                        selector:@selector(stepper:)
                                                        userInfo:nil
                                                         repeats:true];

        MCMQTTSessionManager *manager = [[MCMQTTSessionManager alloc] init];
        manager.delegate = self;

        [manager connectWithParameters:parameters clean:YES];

        while (self.step == -1 && manager.state != MCMQTTSessionManagerStateConnected) {
            DDLogInfo(@"[testMCMQTTSessionManager] waiting for connect %d", manager.state);
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        XCTAssertEqual(manager.state, MCMQTTSessionManagerStateConnected);

        [manager disconnect];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];

        XCTAssertEqual(manager.state, MCMQTTSessionManagerStateClosed);

        while (self.step <= 0) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }

        [manager connectToLast];
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];

        XCTAssertEqual(manager.state, MCMQTTSessionManagerStateConnected);

        while (self.step <= 1) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        
        [timer invalidate];
    }
}

#pragma mark - helpers


- (void)sessionManager:(MCMQTTSessionManager *)sessionManager
     didReceiveMessage:(NSData *)data
               onTopic:(NSString *)topic
              retained:(BOOL)retained {
    DDLogInfo(@"[MCMQTTSessionManager] didReceiveMessage (%lu) t:%@ r%d",
              (unsigned long)data.length, topic, retained);
    if ([topic isEqualToString:TOPIC]) {
        if (!retained && data.length) {
            self.received++;
        } else {
            self.received = 0;
        }
    }
}

- (void)sessionManager:(MCMQTTSessionManager *)sessionManager didDeliverMessage:(UInt16)msgID {
    DDLogVerbose(@"[MCMQTTSessionManager] messageDelivered %d", msgID);
}

- (void)timedout:(NSTimer *)timer {
    DDLogVerbose(@"[MCMQTTSessionManager] timedout");
    self.timedout = true;
}

- (void)stepper:(NSTimer *)timer {
    DDLogVerbose(@"[MCMQTTSessionManager] stepper s:%d", self.step);
    self.step++;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"effectiveSubscriptions"]) {
        MCMQTTSessionManager *manager = (MCMQTTSessionManager *)object;
        DDLogInfo(@"[MCMQTTSessionManager] effectiveSubscriptions changed: %@", manager.effectiveSubscriptions);
    }
}

@end
