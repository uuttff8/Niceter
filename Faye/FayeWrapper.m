//
//  FayeWrapper.m
//  FayeObjcToIos
//
//  Created by uuttff8 on 3/13/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FayeWrapper.h"
#import "TRConnectionMonitor.h"
#import "FayeClient.h"
#import "Gittker-Swift.h"

typedef enum {
    kConnected,                     // Intend to be connected
    kDisconnected                   // Don't reconnect
} TREventControllerState;

@interface TREventController ()

@property (strong, nonatomic) FayeClient *faye;
@property (nonatomic) double connectWait;
@property (strong) NSString *fayeClientId;
@property (nonatomic) TREventControllerState state;
@property (strong) NSString *userId;
@property (strong) NSTimer *connectTimer;
@property (strong) TRConnectionMonitor *connectionMonitor;
@property (strong) NSArray *channels;

- (void)connectInternal;
- (void)connectNow;

@end

@implementation TREventController

- (id)initWithDelegate:(id <TREventControllerDelegate>)delegate andChannels:(NSArray *)channels {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _fayeClientId = nil;
        _subscriptionReady = NO;
        _state = kConnected;
        _channels = channels;
        
        self.connectWait = 0.0;
        [self connectNow];
    }
    return self;
}

- (void)connectInternal {
    if(_state != kConnected) return;
    
    if(self.connectWait > 0) {
        double interval = self.connectWait + (((float) arc4random_uniform(100)) / 50.0);
        
        if (_logging) {
            NSLog(@"Waiting %f before attempting reconnection", interval);
        }
        
        
        _connectTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                         target:self
                                                       selector: @selector(connectNow)
                                                       userInfo:nil
                                                        repeats:NO];
    } else {
        [self connectNow];
    }
    
}

// This is called after waiting for the timeout, it's responsible for incrementing the timeout value
// and attempting a connection
- (void)connectNow {
    if (_logging) {
        NSLog(@"connectNow");
    }
    
    _connectTimer = nil;
    
    if(self.connectWait == 0) {
        self.connectWait = 1;
    } else {
        self.connectWait = self.connectWait * 1.3;
        if(self.connectWait > 20) self.connectWait = 20;
    }
    if (_logging) {
        NSLog(@"Incrementing next connect wait to %f", self.connectWait);
    }
    
    NSURL *url = [NSURL URLWithString:@"wss://ws.gitter.im/bayeux"];
    
    [self disconnect];
    
    _faye = [[FayeClient alloc] initWithURLString:[url absoluteString] channel:@"/api/v1/ping"];
    _connectionMonitor = [TRConnectionMonitor monitorWithFaye:_faye delegate:self];
    
    _faye.delegate = self;
    
    [self subscribeToUserChannels];
    
    [_faye connectToServer];
}

- (void)connectionHasFailed:(FayeClient *)faye {
    if(faye != _faye) {
        if (_logging) {
            
            NSLog(@"Ignoring old failed connection");
        }
        return;
    }
    if (_logging) {
        NSLog(@"Faye connection has failed. Attempting to reconnect");
    }
    [self reconnect];
}

- (void)subscribeToUserChannels {
    if(_userId) {
//        NSString *channel = @"/api/v1/user/5ac21dd2d73408ce4f940b10/rooms"; // @"/api/v1/rooms/5e679403d73408ce4fdc403a/chatMessages";
        for (NSString * channel in self.channels) {
            [_faye subscribeToChannel:channel];
        }
    }
}


- (void)unsubscribeFromUserChannels {
    if(_userId) {
//        NSString *channel = @"/api/v1/rooms/5e679403d73408ce4fdc403a/chatMessages";
        
        for (NSString * channel in self.channels) {
            [_faye unsubscribeFromChannel:channel];
        }
        
    }
}

- (void) reconnect {
    if (_logging) {
        NSLog(@"Reconnect");
    }
    
    [self disconnect];
    
    _state = kConnected;
    _subscriptionReady = NO;
    [self connectInternal];
}

- (void) disconnect {
    if (_logging) {
        NSLog(@"Disconnect");
    }
    
    [_connectionMonitor cancel];
    _connectionMonitor = nil;
    _subscriptionReady = NO;
    
    [_connectTimer invalidate];
    if(_faye.webSocketConnected) {
        [_faye disconnectFromServer];
    }
    _faye.delegate = nil;
    _faye = nil;
    _state = kDisconnected;
}


- (void)dealloc {
    _faye.delegate = nil;
}

#pragma mark Faye Delegate Methods

- (void)messageReceived:(NSDictionary *)messageDict channel:(NSString *)channel {
    if (_logging) {
        NSLog(@"Message received: %@", messageDict);
    }
    
    [_delegate messageReceived:messageDict channel:channel];
    
    //    if([channel hasSuffix:TROUPES_SUBCHANNEL]) {
    //        [[NSNotificationCenter defaultCenter] postNotificationName:IncomingTroupeNotification object:messageDict];
    //    } else {
    //        [[NSNotificationCenter defaultCenter] postNotificationName:IncomingUserNotification object:messageDict];
    //    }
}


- (void)connectedToServer {
    if (_logging) {
        NSLog(@"Connected to faye server");
    }
    [_connectTimer invalidate];
    _subscriptionReady = NO;
    
    if(!_fayeClientId || ![_faye.fayeClientId isEqualToString:_fayeClientId]) {
        // First connectToServer message
        if (_logging) {
            NSLog(@"Connected to server with a new clientId");
        }
        _fayeClientId = _faye.fayeClientId;
    }
    
    // Reset the backing off timer back to zero
    self.connectWait = 0;
}

- (void)disconnectedFromServer {
    if (_logging) {
        NSLog(@"Disconnected from server");
    }
    
    [_delegate serverSubscriptionDisconnected];
    
    _subscriptionReady = NO;
    
    if(_state == kConnected) {
        if (_logging) {
            NSLog(@"Attempting reconnection");
        }
        // If we're supposed to be connected, then reconnect
        [self connectInternal];
    }
}

- (void)connectionFailed {
    if (_logging) {
        NSLog(@"connectionFailed");
    }
    [self reconnect];
}

- (void)didSubscribeToChannel:(NSString *)channel {
    if([_connectionMonitor isPingSubscribe:channel]) {
        return;
    }
    
    if (_logging) {
        NSLog(@"didSubscribeToChannel");
    }
    
    if(!_subscriptionReady) {
        if (_logging) {
            NSLog(@"subscribedToChannel");
        }
        
        _subscriptionReady = YES;
        [_delegate serverSubscriptionEstablished];
        
        //        [[NSNotificationCenter defaultCenter] postNotificationName:TroupeRealtimeActivated object:self];
    }
}

- (void)didUnsubscribeFromChannel:(NSString *)channel {
    if (_logging) {
        NSLog(@"didUnsubscribeFromChannel");
    }
    if([_connectionMonitor isPingUnsubscribe:channel]) {
        return;
    }
}

- (void)subscriptionFailedWithError:(NSString *)error {
    if (_logging) {
        NSLog(@"subscriptionFailedWithError: %@", error);
    }
    [_connectionMonitor cancel];
    [self reconnect];
}

- (void)fayeClientError:(NSError *)error {
    if (_logging) {
        NSLog(@"fayeClientError: %@", error);
    }
    [self reconnect];
}

- (void)fayeClientWillReceiveMessage:(NSDictionary *)messageDict withCallback:(FayeClientMessageHandler)callback {
    NSString *channel = [messageDict objectForKey:@"channel"];
    if([channel isEqualToString:@"/meta/handshake"]) {
        
        NSDictionary *ext = [messageDict objectForKey:@"ext"];
        NSString *newUserId = [ext objectForKey:@"userId"];
        
        
        id s = [messageDict objectForKey:@"successful"];
        if(s) {
            CFBooleanRef b = CFBridgingRetain(s);
            BOOL successful = CFBooleanGetValue(b);
            CFRelease(b);
            
            if(successful) {
                self.connectWait = 0;
            } else {
                if(messageDict[@"error"]) {
                    if(messageDict[@"advice"] && [messageDict[@"advice"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *advice = messageDict[@"advice"];
                        NSString *reconnect = advice[@"reconnect"];
                        
                        if([reconnect isEqualToString:@"none"]) {
                            if (_logging) {
                                NSLog(@"Auth token has been revoked. Deleting token...");
                            }
                            //                            [[TRAuthController sharedInstance] signOut];
                            //                            [[NSNotificationCenter defaultCenter] postNotificationName:AuthTokenRevoked object:nil];
                        }
                    }
                }
            }
        }
        
        if(newUserId != _userId && ![_userId isEqualToString:newUserId]) {
            if(_userId) {
                [self unsubscribeFromUserChannels];
            }
            
            _userId = newUserId;
            //            [[NSNotificationCenter defaultCenter] postNotificationName:UserIdChanged object:newUserId];
            
            [self subscribeToUserChannels];
        }
    }
    
    if([channel isEqualToString:@"/meta/subscribe"]) {
        NSDictionary *ext = [messageDict objectForKey:@"ext"];
        id snapshot = [ext objectForKey:@"snapshot"];
        if(snapshot) {
            NSString *subscribedChannel = [messageDict objectForKey:@"subscription"];
            [_delegate snapshotReceived:snapshot channel:subscribedChannel];
        }
    }
    
    callback(messageDict);
}


- (void)fayeClientWillSendMessage:(NSDictionary *)messageDict withCallback:(FayeClientMessageHandler)callback {
    NSString *channel = [messageDict objectForKey:@"channel"];
    if([channel isEqualToString:@"/meta/handshake"]) {
        NSMutableDictionary *dict2 = [NSMutableDictionary dictionaryWithDictionary:messageDict];
        messageDict = dict2;
        
        // Ext object exists?
        NSDictionary *ext = [dict2 objectForKey:@"ext"];
        NSMutableDictionary *ext2;
        if(!ext) {
            // No ext object, create it
            ext2 = [NSMutableDictionary dictionaryWithCapacity:1];
            [dict2 setObject:ext2 forKey:@"ext"];
        } else {
            ext2 = [NSMutableDictionary dictionaryWithDictionary:ext];
        }
        
        KeychainSwiftCBridge *keychain = [[KeychainSwiftCBridge alloc] init];
        NSString *authToken = [keychain get:@"access_token"];
        if (authToken) {
            [ext2 setObject:authToken forKey:@"token"];
        }
        
#if TARGET_OS_IPHONE
        [ext2 setObject:@"mobile" forKey:@"connType"];
#if BETA
        [ext2 setObject:@"iosbeta" forKey:@"client"];
#else
        [ext2 setObject:@"ios" forKey:@"client"];
#endif
#else
        [ext2 setObject:@"online" forKey:@"connType"];
        
#if BETA
        [ext2 setObject:@"osxbeta" forKey:@"client"];
#else
        [ext2 setObject:@"osx" forKey:@"client"];
#endif
        
#endif
        
        
    }
    callback(messageDict);
}

@end
