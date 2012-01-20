//
//  DDFaultingArray.h
//  FaultingArray
//
//  Created by Dave DeLong on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^DDFaultingArrayFaulter)(NSUInteger idx);

@interface DDFaultingArray : NSArray

@property (nonatomic, copy) DDFaultingArrayFaulter faulter;

- (id)initWithCapacity:(NSUInteger)capacity;

@end
