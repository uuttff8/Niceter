//
//  TRConnectionMonitor.h
//  TroupeNotifier
//
//  Created by Andrew Newdigate on 08/05/2013.
//  Copyright (c) 2013 Andrew Newdigate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FayeClient.h"

@protocol TRConnectionMonitorDelegate

- (void) connectionHasFailed:(FayeClient *)faye;

@end

@interface TRConnectionMonitor : NSObject
- (id)initWithFaye:(FayeClient *)faye delegate:(id <TRConnectionMonitorDelegate>)delegate;

+ (id)monitorWithFaye:(FayeClient *)faye delegate:(id<TRConnectionMonitorDelegate>) delegate;


- (void) cancel;
- (BOOL) isPingSubscribe:(NSString *)channel;
- (BOOL) isPingUnsubscribe:(NSString *)channel;


@end
