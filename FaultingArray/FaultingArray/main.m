//
//  main.m
//  FaultingArray
//
//  Created by Dave DeLong on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDFaultingArray.h"

int main (int argc, const char * argv[])
{

    @autoreleasepool {
        
        
        DDFaultingArray *array = [[DDFaultingArray alloc] initWithCapacity:100];
        [array setFaulter:^(NSUInteger idx) {
            NSLog(@"requesting object at index: %lu", idx);
            return [NSNumber numberWithUnsignedInteger:(idx*idx)];
        }];
        
        NSLog(@"%@", array);
        
    }
    return 0;
}

