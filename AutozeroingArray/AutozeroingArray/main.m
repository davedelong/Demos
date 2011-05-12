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
    
    DDAutozeroingArray *array = [DDAutozeroingArray array];
    
    NSObject *o = [[NSObject alloc] init];
    [array addObject:o];
    NSLog(@"%@", array);
    [o release];
    NSLog(@"%@", array);

    [pool drain];
    return 0;
}

