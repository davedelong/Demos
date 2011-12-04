//
//  DDSuperProxy.m
//  GrandSuper
//
//  Created by Dave DeLong on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DDSuperProxy.h"
#import <objc/runtime.h>

@interface NSInvocation (PrivateMethod)

- (void)invokeUsingIMP:(IMP)imp;

@end

@implementation DDSuperProxy

- (id)initWithProxy:(id)proxyTarget superLevel:(int)level originalContext:(const char *)oContext {
    if ((oContext[0] != '-' && oContext[0] != '+') ||
        (level < 0) ||
        (proxyTarget == nil) ||
        (oContext == NULL)) {
        
        [self release];
        return nil;
    }
    
    const char* classNameStr = oContext+2; // +2 to skip the -[ or +[
    NSString *tmp = [NSString stringWithCString:classNameStr encoding:NSUTF8StringEncoding];
    NSRange r = [tmp rangeOfString:@" "];
    NSString *className = [tmp substringToIndex:r.location];
    
    NSLog(@"executing in context: %@", className);
    
    if (oContext[0] == '+') {
        _context = objc_getMetaClass([className UTF8String]);
    } else {
        _context = objc_getClass([className UTF8String]);
    }
    
    if (_context == nil) {
        [self release];
        return nil;
    }
    
    _level = level;
    _target = [proxyTarget retain];
    return self;
}

- (void)dealloc {
    [_target release];
    [super dealloc];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [_target methodSignatureForSelector:sel];
}

- (IMP)impForSelector:(SEL)selector {
    Class currentClass = _context;
    IMP imp = NULL;
    int level = -1;
    while (level != _level && currentClass != nil) {
        IMP thisImp = class_getMethodImplementation(currentClass, selector);
        currentClass = class_getSuperclass(currentClass);
        if (imp != thisImp) {
            imp = thisImp;
            level++;
        }
    }
    
    return imp;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if (![_target respondsToSelector:[invocation selector]]) {
        [_target doesNotRecognizeSelector:[invocation selector]];
        return;
    }
    
    IMP appropriateImp = [self impForSelector:[invocation selector]];
    if (appropriateImp != NULL) {
        [invocation invokeUsingIMP:appropriateImp];
    }
}

@end
