//
//  main.m
//  GrandSuper
//
//  Created by Dave DeLong on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDSuperProxy.h"
@interface A : NSObject @end
@implementation A

- (void)doFoo {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end

@interface B : A @end
@implementation B

- (void)doFoo {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [super doFoo];
}

@end

@interface C : B @end
@implementation C

- (void)doFoo {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [super doFoo];
}

@end

@interface D : C @end
@implementation D

- (void)doFoo {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [grandsuper doFoo];
}

@end

@interface E : D @end
@implementation E

- (void)doFoo {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    // parent(3) = B's implementation of doFoo
    // parent(0) = self
    // parent(1) = D
    // parent(2) = C
    // parent(3) = B
    [parent(3) doFoo];
}

@end

int main (int argc, const char * argv[])
{

    @autoreleasepool {
        
        E *e = [[E alloc] init];
        [e doFoo];
        [e release];
        
    }
    return 0;
}

