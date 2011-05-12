//
//  main.m
//  AutozeroingArray
//
//  Created by Dave DeLong on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDAutozeroingArray.h"

id object = nil;

int main (int argc, const char * argv[])
{

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    /**
     This shows that the array will automatically zero out items when they're deallocated via an ARP
     */
    NSAutoreleasePool *inner = [[NSAutoreleasePool alloc] init];
    NSMutableArray *tmp = [NSMutableArray array];
    for (int i = 0; i < 100; ++i) {
        [tmp addObject:[NSString stringWithFormat:@"string #%d", i+1]];
    }
    DDAutozeroingArray *arrayWithArray = [[DDAutozeroingArray alloc] initWithArray:tmp];
    NSLog(@"%@", arrayWithArray);
    [inner drain];
    NSLog(@"%@", arrayWithArray);
    [arrayWithArray release];
    
    /**
     This shows that the array will automatically zero out items when they're explicitly released
     */
    DDAutozeroingArray *array = [DDAutozeroingArray array];
    NSObject *o = [[NSObject alloc] init];
    [array addObject:o];
    NSLog(@"%@", array);
    [o release];
    NSLog(@"%@", array);
    
    /**
     This shows a true NSMutableArray that auto-zeros its objects
     */
    NSAutozeroingMutableArray *mArray = [NSMutableArray autozeroingArray];
    o = [[NSObject alloc] init];
    [mArray addObject:o];
    NSLog(@"%@", mArray);
    [o release];
    NSLog(@"%@", mArray);

    [pool drain];
    return 0;
}

