//
//  ForwardingClass.m
//  JoinPoints
//
//  Created by Jim Turner on 2/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ForwardingClass.h"

@interface PrivateInternalClass : NSObject
@end

@interface ForwardingClass ()
{
    PrivateInternalClass *_internal;
}
@end

@implementation ForwardingClass

-(id) init {
    self = [super init];
    if( self != nil ){
        _internal = [[PrivateInternalClass alloc] init];
    }
    
    return( self );
}

-(void) aMethod {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

-(NSMethodSignature *) methodSignatureForSelector:(SEL)selector {
    NSMethodSignature *methodSignature = [super methodSignatureForSelector:selector];
    if( !methodSignature ) {
        methodSignature = [_internal methodSignatureForSelector:selector];
    }
    
    return( methodSignature );
}

-(void) forwardInvocation:(NSInvocation *)invocation {
    [invocation setTarget:_internal];
    [invocation invoke];
}

@end


@implementation PrivateInternalClass

-(void) voodooMethod {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end