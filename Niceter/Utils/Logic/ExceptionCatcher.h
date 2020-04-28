//
//  ExceptionCatcher.h
//  Niceter
//
//  Created by uuttff8 on 4/28/20.
//  Copyright © 2020 Anton Kuzmin. All rights reserved.
//

#ifndef ExceptionCatcher_h
#define ExceptionCatcher_h

#import <Foundation/Foundation.h>

NS_INLINE NSException * _Nullable tryBlock(void(^_Nonnull tryBlock)(void)) {
  @try {
    tryBlock();
  }
  @catch (NSException *exception) {
    return exception;
  }
  return nil;
}

#endif /* ExceptionCatcher_h */
