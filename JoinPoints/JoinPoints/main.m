//
//  main.m
//  JoinPoints
//
//  Created by Dave DeLong on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+JoinPoints.h"
#import "ForwardingClass.h"

typedef struct {
    NSInteger a;
    CGFloat b;
    NSString *c;
} LongStruct;

@interface A : NSObject
@end
@implementation A

- (void)doFoo:(NSString *)foo {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (LongStruct)doBar:(LongStruct)s {
    s.a *= 2;
    s.b *= 2.0f;
    s.c = [NSString stringWithFormat:@"JP_%@", s.c];
    return s;
}

@end

@interface B : A
@end
@implementation B

- (void)doFoo:(NSString *)foo {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [super doFoo:foo];
}

@end

int main (int argc, const char * argv[])
{

    @autoreleasepool {
        NSLog(@" ");
        
        [A before:@selector(doFoo:) do:^{
            NSLog(@"before");
        }];
        [A during:@selector(doFoo:) do:^{
            NSLog(@"during");
        }];
        [A after:@selector(doFoo:) do:^{
            NSLog(@"after");
        }];
        
// uncommenting this currently causes an infinite loop        
//        [B before:@selector(doFoo:) do:^{
//            NSLog(@"b before");
//        }];
        
        [A before:@selector(dealloc) do:^{
            NSLog(@"dealloc!");
        }];
        
        LongStruct s;
        s.a = 21;
        s.b = 42;
        s.c = @"Tricky!";
        
        [A before:@selector(doBar:) do:^{
            NSLog(@"before doBar:");
        }];
        
        A *a = [A new];
        [a before:@selector(doFoo:) do:^{
            NSLog(@"this is specific to this instance");
        }];
        [a doFoo:@"blah"];
        
        NSLog(@"==================");
        
        NSLog(@"%@", s.c);
        s = [a doBar:s];
        NSLog(@"%@", s.c);
        [a release];
        
        NSLog(@"==================");
        
        B *b = [B new];
        [b doFoo:@"B"];
        
        NSLog(@"==================");
        
        NSLog(@"%@", s.c);
        s = [b doBar:s];
        NSLog(@"%@", s.c);
        
        [b release];
        
        NSLog(@"==================");
        [ForwardingClass before:@selector(aMethod) do:^{
            NSLog(@"before aMethod");
        }];

        [ForwardingClass during:@selector(aMethod) do:^{
            NSLog(@"during aMethod");
        }];

        [ForwardingClass after:@selector(aMethod) do:^{
            NSLog(@"after aMethod");
        }];

        // Attempting to shim a method a class does not implement does nothing
        [ForwardingClass before:@selector(voodooMethod) do:^{
            NSLog(@"before voodooMethod");
        }];
        
        ForwardingClass *fc = [ForwardingClass new];
        [fc aMethod];
        
        [fc performSelector:@selector(voodooMethod)];
    }
    return 0;
}

