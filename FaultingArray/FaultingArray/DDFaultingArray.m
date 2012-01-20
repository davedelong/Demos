//
//  DDFaultingArray.m
//  FaultingArray
//
//  Created by Dave DeLong on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DDFaultingArray.h"

@implementation DDFaultingArray {
    NSMutableArray *_storage;
}

@synthesize faulter=_faulter;

- (id)initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (self) {
        _storage = [[NSMutableArray alloc] initWithCapacity:capacity];
        for (NSUInteger i = 0; i < capacity; ++i) {
            [_storage addObject:[NSNull null]];
        }
    }
    return self;
}

- (void)dealloc {
    [_faulter release];
    [super dealloc];
}

- (NSUInteger)count {
    return [_storage count];
}

- (id)objectAtIndex:(NSUInteger)index {
    id obj = [_storage objectAtIndex:index];
    if (obj == [NSNull null]) {
        // ask someone for our object
        
        if (!_faulter) {
            [NSException raise:NSInternalInconsistencyException format:@"Can't fault without a faulter!  This is your fault!"];
        }
        
        obj = _faulter(index);
        
        if (obj == nil) {
            [NSException raise:NSInternalInconsistencyException format:@"May not return nil for a faulted object"];
        }
        
        [_storage replaceObjectAtIndex:index withObject:obj];
    }
    return obj;
}

@end
