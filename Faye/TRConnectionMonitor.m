//
//  TRConnectionMonitor.m
//  TroupeNotifier
//
//  Created by Andrew Newdigate on 08/05/2013.
//  Copyright (c) 2013 Andrew Newdigate. All rights reserved.
//

#import "TRConnectionMonitor.h"

#define PING_CHANNEL @"/api/v1/ping"
#define PING_FREQUENCY 60

@interface TRConnectionMonitor()

@property(nonatomic,strong) NSTimer *pingTimer;
@property(nonatomic,strong) NSTimer *subscribeTimer;
@property(nonatomic,strong) FayeClient *faye;

@end

@implementation TRConnectionMonitor {
    id <TRConnectionMonitorDelegate> _delegate;
}

- (id)initWithFaye:(FayeClient *)faye delegate:(id <TRConnectionMonitorDelegate>)delegate {
    self = [super init];
    if (self) {
        [_subscribeTimer invalidate];
        _subscribeTimer = nil;
        
        _delegate = delegate;

        [_pingTimer invalidate];
        _pingTimer = nil;

        _faye = faye;
        _pingTimer = [NSTimer scheduledTimerWithTimeInterval:PING_FREQUENCY
                                                      target:self
                                                    selector:@selector(pingTimeout)
                                                    userInfo:nil
                                                     repeats:NO];
    }

    return self;
}

+ (id)monitorWithFaye:(FayeClient *)faye delegate:(id<TRConnectionMonitorDelegate>) delegate {
    return [[self alloc] initWithFaye:faye delegate:delegate];
}


- (void) cancel {
    NSLog(@"Cancelling connection monitor");

    [_subscribeTimer invalidate];
    _subscribeTimer = nil;
    
    [_pingTimer invalidate];
    _pingTimer = nil;
    
    _faye = nil;
}

- (BOOL) isPingSubscribe:(NSString *)channel {
    if(![channel isEqualToString:PING_CHANNEL]) {
        return NO;
    }
    
    NSLog(@"Subscribe successful");
    
    [_pingTimer invalidate];
    _pingTimer = nil;
    
    [_subscribeTimer invalidate];
    _subscribeTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                       target:self
                                                     selector:@selector(subscribeTimeout)
                                                     userInfo:nil
                                                      repeats:NO];
    [_faye unsubscribeFromChannel:PING_CHANNEL];
    
    return YES;
}

- (BOOL) isPingUnsubscribe:(NSString *)channel {
    if(![channel isEqualToString:PING_CHANNEL]) {
        return NO;
    }

    NSLog(@"Unsubscribe successful");

    [_subscribeTimer invalidate];
    _subscribeTimer = nil;
    
    [_pingTimer invalidate];
    _pingTimer = [NSTimer scheduledTimerWithTimeInterval:PING_FREQUENCY
                                                  target:self
                                                selector:@selector(pingTimeout)
                                                userInfo:nil
                                                 repeats:NO];
    return YES;
}

- (void) pingTimeout {
    NSLog(@"Pinging faye server");
    [_pingTimer invalidate];
    _pingTimer = nil;
    
    [_subscribeTimer invalidate];    
    _subscribeTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                                       target:self
                                                     selector:@selector(subscribeTimeout)
                                                     userInfo:nil
                                                      repeats:NO];
    
    [_faye subscribeToChannel:PING_CHANNEL];
}

- (void) subscribeTimeout {
    NSLog(@"Ping timeout, disconnecting from server");

    [_delegate connectionHasFailed:_faye];
    [self cancel];
}



@end
