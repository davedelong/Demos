//
//  DDAutozeroingArray.h
//  AutozeroingArray
//
//  Created by Dave DeLong on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDAutozeroingArray : NSMutableArray {
    NSMutableArray *storage;
}

@end

typedef NSMutableArray NSAutozeroingMutableArray;

@interface NSMutableArray (DDAutozeroingArray)

+ (NSAutozeroingMutableArray *) autozeroingArray;
+ (NSAutozeroingMutableArray *) autozeroingArrayWithArray:(NSArray *)array;
+ (NSAutozeroingMutableArray *) autozeroingArrayWithObject:(id)object;
+ (NSAutozeroingMutableArray *) autozeroingArrayWithObjects:(id)object, ... NS_REQUIRES_NIL_TERMINATION;
+ (NSAutozeroingMutableArray *) autozeroingArrayWithObjects:(const id *)objects count:(NSUInteger)count;

- (id)initAutozeroingArray;
- (id)initAutozeroingArrayWithArray:(NSArray *)array;
- (id)initAutozeroingArrayWithObject:(id)object;
- (id)initAutozeroingArrayWithObjects:(id)object, ... NS_REQUIRES_NIL_TERMINATION;
- (id)initAutozeroingArrayWithObjects:(const id *)objects count:(NSUInteger)count;

@end
