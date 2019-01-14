//
//  MQTTClientTests.m
//  MQTTClientTests
//
//  Created by Christoph Krey on 13.01.14.
//  Copyright © 2014-2017 Christoph Krey. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "MQTTLog.h"
#import "MQTTTestHelpers.h"

@interface MQTTClientOnlyTests : MQTTTestHelpers
@end

@implementation MQTTClientOnlyTests

- (void)tearDown {
    [self.session closeWithReturnCode:MQTTSuccess
                sessionExpiryInterval:nil
                         reasonString:nil
                         userProperty:nil
                    disconnectHandler:nil];
    self.session.delegate = nil;
    self.session = nil;
    
    [super tearDown];
}

<<<<<<< HEAD
- (void)testConnectToWrongHostResultsInError {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    NSMutableDictionary *parameters = [MQTTTestHelpers.broker mutableCopy];
    
    parameters[@"host"] = @"abc";
    self.session = [MQTTTestHelpers session:parameters];
    [self.session connectWithConnectHandler:^(NSError *error) {
        XCTAssertNotNil(error);
        XCTAssertEqual(self.session.status, MQTTSessionStatusClosed);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
    
}

- (void)testConnectToWrongPort1884ResultsInError {
    XCTestExpectation *expectation = [self expectationWithDescription:@""];
    
    NSMutableDictionary *parameters = [MQTTTestHelpers.broker mutableCopy];
    
    parameters[@"port"] = @1884;
    self.session = [MQTTTestHelpers session:parameters];
    [self.session connectWithConnectHandler:^(NSError *error) {
        XCTAssertNotNil(error);
        XCTAssertEqual(self.session.status, MQTTSessionStatusClosed);
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
    
=======
- (void)test_connect_host_not_found {
    for (NSString *broker in self.brokers.allKeys) {
        DDLogVerbose(@"testing broker %@", broker);
        NSMutableDictionary *parameters = [self.brokers[broker] mutableCopy];
        
        parameters[@"host"] = @"abc";
        self.session = [MQTTTestHelpers session:parameters];
        self.session.delegate = self;
        self.event = -1;
        [self.session connect];
        while (self.event == -1) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        XCTAssertNotEqual(self.event, (NSInteger)MCMQTTSessionEventConnected, @"MCMQTTSessionEventConnected %@", self.error);
        XCTAssertNotEqual(self.event, (NSInteger)MCMQTTSessionEventConnectionRefused, @"MCMQTTSessionEventConnectionRefused %@", self.error);
        XCTAssertNotEqual(self.event, (NSInteger)MCMQTTSessionEventProtocolError, @"MCMQTTSessionEventProtocolError %@", self.error);
    }
}


- (void)test_connect_1889 {
    for (NSString *broker in self.brokers.allKeys) {
        DDLogVerbose(@"testing broker %@", broker);
        NSMutableDictionary *parameters = [self.brokers[broker] mutableCopy];
        
        parameters[@"port"] = @1889;

        self.session = [MQTTTestHelpers session:parameters];
        self.session.delegate = self;
        self.event = -1;
        [self.session connect];
        while (self.event == -1) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
        XCTAssertNotEqual(self.event, (NSInteger)MCMQTTSessionEventConnected, @"MCMQTTSessionEventConnected %@", self.error);
        XCTAssertNotEqual(self.event, (NSInteger)MCMQTTSessionEventConnectionRefused, @"MCMQTTSessionEventConnectionRefused %@", self.error);
        XCTAssertNotEqual(self.event, (NSInteger)MCMQTTSessionEventProtocolError, @"MCMQTTSessionEventProtocolErrorr %@", self.error);
    }
>>>>>>> rename mqttSession to avoid conlision with aws iot
}

@end
