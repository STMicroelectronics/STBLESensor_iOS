//
// MCMQTTDecoder.m
// MQTTClient.framework
//
// Copyright © 2013-2017, Christoph Krey. All rights reserved.
//

#import "MQTTDecoder.h"

#import "MQTTLog.h"

@interface MCMQTTDecoder()
@property (nonatomic) NSMutableArray<NSInputStream *> *streams;
@end

@implementation MCMQTTDecoder

- (instancetype)init {
    self = [super init];
    self.state = MCMQTTDecoderStateInitializing;
    self.runLoop = [NSRunLoop currentRunLoop];
    self.runLoopMode = NSRunLoopCommonModes;
    self.streams = [NSMutableArray arrayWithCapacity:5];
    return self;
}

- (void)dealloc {
    [self close];
}

- (void)decodeMessage:(NSData *)data {
    NSInputStream *stream = [NSInputStream inputStreamWithData:data];
    [self openStream:stream];
}

- (void)openStream:(NSInputStream*)stream {
    [self.streams addObject:stream];
    stream.delegate = self;
    DDLogVerbose(@"[MCMQTTDecoder] #streams=%lu", (unsigned long)self.streams.count);
    if (self.streams.count == 1) {
        [stream scheduleInRunLoop:self.runLoop forMode:self.runLoopMode];
        [stream open];
    }
}

- (void)open {
    self.state = MCMQTTDecoderStateDecodingHeader;
}

- (void)close {
    if (self.streams) {
        for (NSInputStream *stream in self.streams) {
            [stream close];
            [stream removeFromRunLoop:self.runLoop forMode:self.runLoopMode];
            [stream setDelegate:nil];
        }
        [self.streams removeAllObjects];
    }
}

- (void)stream:(NSStream*)sender handleEvent:(NSStreamEvent)eventCode {
    NSInputStream *stream = (NSInputStream *)sender;
    
    if (eventCode & NSStreamEventOpenCompleted) {
        DDLogVerbose(@"[MCMQTTDecoder] NSStreamEventOpenCompleted");
    }
    
    if (eventCode & NSStreamEventHasBytesAvailable) {
        DDLogVerbose(@"[MCMQTTDecoder] NSStreamEventHasBytesAvailable");
        
        if (self.state == MCMQTTDecoderStateDecodingHeader) {
            UInt8 buffer;
            NSInteger n = [stream read:&buffer maxLength:1];
            if (n == -1) {
                self.state = MCMQTTDecoderStateConnectionError;
                [self.delegate decoder:self handleEvent:MCMQTTDecoderEventConnectionError error:stream.streamError];
            } else if (n == 1) {
                self.length = 0;
                self.lengthMultiplier = 1;
                self.state = MCMQTTDecoderStateDecodingLength;
                self.dataBuffer = [[NSMutableData alloc] init];
                [self.dataBuffer appendBytes:&buffer length:1];
                self.offset = 1;
                DDLogVerbose(@"[MCMQTTDecoder] fixedHeader=0x%02x", buffer);
            }
        }
        while (self.state == MCMQTTDecoderStateDecodingLength) {
            // TODO: check max packet length(prevent evil server response)
            UInt8 digit;
            NSInteger n = [stream read:&digit maxLength:1];
            if (n == -1) {
                self.state = MCMQTTDecoderStateConnectionError;
                [self.delegate decoder:self handleEvent:MCMQTTDecoderEventConnectionError error:stream.streamError];
                break;
            } else if (n == 0) {
                break;
            }
            DDLogVerbose(@"[MCMQTTDecoder] digit=0x%02x 0x%02x %d %d", digit, digit & 0x7f, (unsigned int)self.length, (unsigned int)self.lengthMultiplier);
            [self.dataBuffer appendBytes:&digit length:1];
            self.offset++;
            self.length += ((digit & 0x7f) * self.lengthMultiplier);
            if ((digit & 0x80) == 0x00) {
                self.state = MCMQTTDecoderStateDecodingData;
            } else {
                self.lengthMultiplier *= 128;
            }
        }
        DDLogVerbose(@"[MCMQTTDecoder] remainingLength=%d", (unsigned int)self.length);

        if (self.state == MCMQTTDecoderStateDecodingData) {
            if (self.length > 0) {
                NSInteger n, toRead;
                UInt8 buffer[768];
                toRead = self.length + self.offset - self.dataBuffer.length;
                if (toRead > sizeof buffer) {
                    toRead = sizeof buffer;
                }
                n = [stream read:buffer maxLength:toRead];
                if (n == -1) {
                    self.state = MCMQTTDecoderStateConnectionError;
                    [self.delegate decoder:self handleEvent:MCMQTTDecoderEventConnectionError error:stream.streamError];
                } else {
                    DDLogVerbose(@"[MCMQTTDecoder] read %ld %ld", (long)toRead, (long)n);
                    [self.dataBuffer appendBytes:buffer length:n];
                }
            }
            if (self.dataBuffer.length == self.length + self.offset) {
                DDLogVerbose(@"[MCMQTTDecoder] received (%lu)=%@...", (unsigned long)self.dataBuffer.length,
                                    [self.dataBuffer subdataWithRange:NSMakeRange(0, MIN(256, self.dataBuffer.length))]);
                [self.delegate decoder:self didReceiveMessage:self.dataBuffer];
                self.dataBuffer = nil;
                self.state = MCMQTTDecoderStateDecodingHeader;
            } else {
                DDLogError(@"[MCMQTTDecoder] oops received (%lu)=%@...", (unsigned long)self.dataBuffer.length,
                             [self.dataBuffer subdataWithRange:NSMakeRange(0, MIN(256, self.dataBuffer.length))]);
            }
        }
    }
    
    if (eventCode & NSStreamEventHasSpaceAvailable) {
        DDLogVerbose(@"[MCMQTTDecoder] NSStreamEventHasSpaceAvailable");
    }
    
    if (eventCode & NSStreamEventEndEncountered) {
        DDLogVerbose(@"[MCMQTTDecoder] NSStreamEventEndEncountered");
        
        if (self.streams) {
            [stream setDelegate:nil];
            [stream close];
            [self.streams removeObject:stream];
            if (self.streams.count) {
                NSInputStream *stream = (self.streams)[0];
                [stream scheduleInRunLoop:self.runLoop forMode:self.runLoopMode];
                [stream open];
            }
        }
    }
    
    if (eventCode & NSStreamEventErrorOccurred) {
        DDLogVerbose(@"[MCMQTTDecoder] NSStreamEventErrorOccurred");
        
        self.state = MCMQTTDecoderStateConnectionError;
        NSError *error = stream.streamError;
        if (self.streams) {
            [self.streams removeObject:stream];
            if (self.streams.count) {
                NSInputStream *stream = (self.streams)[0];
                [stream scheduleInRunLoop:self.runLoop forMode:self.runLoopMode];
                [stream open];
            }
        }
        [self.delegate decoder:self handleEvent:MCMQTTDecoderEventConnectionError error:error];
    }
}

@end
