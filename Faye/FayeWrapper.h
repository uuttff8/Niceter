//
//  FayeWrapper.h
//  FayeObjcToIos
//
//  Created by uuttff8 on 3/13/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

#ifndef FayeWrapper_h
#define FayeWrapper_h

#import "FayeClient.h"

//
// Event Delegate
//
@protocol TREventControllerDelegate <NSObject>

- (void) messageReceived:(NSDictionary *)messageDict channel:(NSString *)channel;
- (void) snapshotReceived:(id) snapshot channel:(NSString *)channel;
- (void) serverSubscriptionEstablished;
- (void) serverSubscriptionDisconnected;

@end

//
// Events
//
@interface TREventController : NSObject<FayeClientDelegate>

@property (nonatomic, readonly) BOOL subscriptionReady;
@property (strong, nonatomic) id <TREventControllerDelegate> delegate;
@property (nonatomic) BOOL logging;

- (id)initWithDelegate:(id <TREventControllerDelegate>)delegate andChannels:(NSArray *)channels;

- (void) disconnect;
- (void) reconnect;


@end


#endif /* FayeWrapper_h */
