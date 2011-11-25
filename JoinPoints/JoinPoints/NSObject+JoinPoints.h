//
//  NSObject+JoinPoints.h
//  JoinPoints
//
//  Created by Dave DeLong on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JoinPoints)

/**
 
 Calling these on instances will cause the blocks to be run only when that particular instance receives the designated message.
 Calling these on classes will cause the blocks to be run when any instance receives the designated message.
 Does not work on class methods.
 
 **/
- (void)before:(SEL)selector do:(dispatch_block_t)block;
- (void)during:(SEL)selector do:(dispatch_block_t)block; // block is executed on a background queue
- (void)after:(SEL)selector do:(dispatch_block_t)block;

@end
