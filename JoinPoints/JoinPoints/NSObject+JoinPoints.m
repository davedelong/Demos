//
//  NSObject+JoinPoints.m
//  JoinPoints
//
//  Created by Dave DeLong on 11/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSObject+JoinPoints.h"
#import <objc/runtime.h>
#import <objc/message.h>

static char JP_BeforeBlocks;
static char JP_DuringBlocks;
static char JP_AfterBlocks;

static NSArray* JP_GetBlocks(id self, SEL _cmd, const void *key);

typedef struct {
    Class klass;
    IMP forwardInvocationImp;
    IMP methodSignatureForSelectorImp;
} ClassOriginalForwardingInfo;
typedef ClassOriginalForwardingInfo *ClassOriginalForwardingInfoPtr;

static ClassOriginalForwardingInfoPtr originalClassForwardingInfo = NULL;
static int originalClassForwardingInfoIndex = 0;
static IMP originalForwardInvocationImp = NULL;

// given a selector, this returns a new selector that corresponds to the "shadow" method
static SEL JP_SelectorMunge(SEL selector) {
    return NSSelectorFromString([NSString stringWithFormat:@"JP_%@", NSStringFromSelector(selector)]);
}

// Returns the appropriate signature for a method from a class that's over-ridden forwardInvocation: and methodSignatureForSelector:
static NSMethodSignature *nsobject_methodSignatureForSelector(id self, SEL _cmd, SEL selector) {
    int x;
    NSMethodSignature *signature = nil;
    SEL mungedSelector = JP_SelectorMunge(selector);
    Class thisClass = object_getClass(self);
    IMP originalMethodSignatureForSelectorImp = NULL;
    
    for( x=0; x<=originalClassForwardingInfoIndex; x++ ) {
        ClassOriginalForwardingInfo info = originalClassForwardingInfo[x];
        if( info.klass == thisClass ) {
            if( info.methodSignatureForSelectorImp != NULL ) {
                originalMethodSignatureForSelectorImp = info.methodSignatureForSelectorImp;
            }
            
            if( class_getInstanceMethod(thisClass, mungedSelector) || class_getClassMethod(thisClass, mungedSelector) ) {
                signature = [thisClass instanceMethodSignatureForSelector:mungedSelector];
            }
        }
        
        if( signature ) {
            break;
        }
    }

    // If we found no munged selector, see if the class has an implemetation for this method and get a signature from that. If we can't find an implementation, call the original implementation and return that answer.
    if( !signature ) {
        if( class_getInstanceMethod(thisClass, selector) || class_getClassMethod(thisClass, selector) ) {
            signature = [thisClass instanceMethodSignatureForSelector:selector];
        }
        
        if( !signature ) {
            NSAssert( originalMethodSignatureForSelectorImp != NULL, @"originalMethodSignatureForSelectorImp is NULL... that's bad");
            signature = originalMethodSignatureForSelectorImp(self, _cmd, selector);
        }
    }
    
    return( signature );
}

// this is the heart of the code. here is where we invoke the blocks and run the original method
static void nsobject_forwardInvocation(id self, SEL _cmd, NSInvocation *invocation) {
    // at this point, we have the invocation
    // TODO: WHAT DO WE DO WITH IT??
    //    NSLog(@"we found this invocation: %@", invocation);
    
    // It is entirely possible to get here legimitately (e.g., a class depends on forwardInvocation: to communicate to a private class). If we can't find a munged selector, we need to invoke the original forwardInvocation: and send the message on its way.
    SEL selector = [invocation selector];
    SEL mungedSelector = JP_SelectorMunge(selector);
    if( !class_getInstanceMethod(object_getClass(self), mungedSelector) && !class_getClassMethod(object_getClass(self), mungedSelector) ) {
        if( originalClassForwardingInfo != NULL ) {
            int x;
            for( x=0; x<=originalClassForwardingInfoIndex; x++ ) {
                ClassOriginalForwardingInfo info = originalClassForwardingInfo[x];
                if( info.klass == object_getClass(self) ) {
                    // Forwarding to class original forwardInvocation:
                    info.forwardInvocationImp(self, _cmd, invocation);
                    return;
                }
            }
        }
        
        // forwarding to NSObject original forwardInvocation:
        originalForwardInvocationImp(self, _cmd, invocation);
        return;
    }

    NSArray *before = JP_GetBlocks(self, selector, &JP_BeforeBlocks);
    NSArray *during = JP_GetBlocks(self, selector, &JP_DuringBlocks);
    NSArray *after = JP_GetBlocks(self, selector, &JP_AfterBlocks);
    
    for (id block in before) {
        dispatch_block_t b = block;
        b();
    }
    
    //alter the selector to point to the shadow methods
    [invocation setSelector:mungedSelector];
    
    dispatch_group_t group = dispatch_group_create();
    for (id block in during) {
        dispatch_group_async(group, dispatch_get_global_queue(0, 0), block);
    }
    [invocation invoke];
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    dispatch_release(group);
    
    for (id block in after) {
        dispatch_block_t b = block;
        b();
    }
    
}

// we have to replace -[NSObject forwardInvocation:] with our own version
// the original implementation calls -doesNotRecognizeSelector:
// when the invocation is invoked, it will call -doesNotRecognizeSelector: if invocation fails
static void JP_InstallNSObjectForwardInvocationReplacement(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class nsobject = objc_getClass("NSObject");
        if (!nsobject) { return; }
        
        SEL forwardInvocation = @selector(forwardInvocation:);
        originalForwardInvocationImp = class_replaceMethod(nsobject, forwardInvocation, (IMP)nsobject_forwardInvocation, "v@:@");
    });
}

// save the block that we want to run
static void JP_AddBlock(id self, SEL _cmd, const void *key, dispatch_block_t block) {
    if (block == nil) { return; }
    
    NSMutableDictionary *mappings = objc_getAssociatedObject(self, key);
    if (mappings == nil) {
        mappings = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, key, mappings, OBJC_ASSOCIATION_RETAIN);
    }
    NSMutableArray *blocksForSelector = [mappings objectForKey:NSStringFromSelector(_cmd)];
    if (blocksForSelector == nil) {
        blocksForSelector = [NSMutableArray array];
        [mappings setObject:blocksForSelector forKey:NSStringFromSelector(_cmd)];
    }
    
    block = Block_copy(block);
    [blocksForSelector addObject:block];
    Block_release(block);
}

// get all the blocks that correspond to a particular selector
static NSArray* JP_GetBlocks(id self, SEL _cmd, const void *key) {
    NSMutableArray *blocks = [NSMutableArray array];
    
    if (self) {
        NSDictionary *mappings = objc_getAssociatedObject(self, key);
        NSArray *blocksForSelector = [mappings objectForKey:NSStringFromSelector(_cmd)];
        if (blocksForSelector) {
            [blocks addObjectsFromArray:blocksForSelector];
        }
        
        Class isa = object_getClass(self);
        if (class_isMetaClass(isa)) {
            // self was a Class already
            // walk up the superclass chain
            [blocks addObjectsFromArray:JP_GetBlocks(class_getSuperclass(self), _cmd, key)];
        } else {
            // self was an instance
            [blocks addObjectsFromArray:JP_GetBlocks(isa, _cmd, key)];
        }
    }
    return blocks;
}

// move the original method aside as a "shadow"
static void JP_Shadow(Class self, SEL _cmd) {
    if (self == nil) { return; }
    
    NSMethodSignature *sig = [self instanceMethodSignatureForSelector:_cmd];
    
    IMP forwardingIMP = _objc_msgForward;
    if ([sig methodReturnLength] > sizeof(id)) {
        // gotta use the _stret stuff
        forwardingIMP = (IMP)_objc_msgForward_stret;
    }
    
    SEL shadowedSel = JP_SelectorMunge(_cmd);
    Method m = class_getInstanceMethod(self, _cmd);
    // If the class does not implement the method, we shouldn't add an implementation
    if (m && method_getImplementation(m) != forwardingIMP) {
        class_addMethod(self, shadowedSel, method_getImplementation(m), method_getTypeEncoding(m));
        method_setImplementation(m, forwardingIMP);
    }
    
    SEL forwardInvocation = @selector(forwardInvocation:);
    if( [self instancesRespondToSelector:forwardInvocation] && 
       (class_getMethodImplementation(self, forwardInvocation) != (IMP)nsobject_forwardInvocation) ) {
        
        IMP classOriginalForwardInvocationImp = class_replaceMethod(self, forwardInvocation, (IMP)nsobject_forwardInvocation, "v@:@");
        
        ClassOriginalForwardingInfo info;
        info.klass = self;
        info.forwardInvocationImp = classOriginalForwardInvocationImp;
        
        SEL methodSignatureForSelector = @selector(methodSignatureForSelector:);
        if( [self instancesRespondToSelector:methodSignatureForSelector] ) {
            info.methodSignatureForSelectorImp = class_replaceMethod(self, methodSignatureForSelector, (IMP)nsobject_methodSignatureForSelector, "@@::");
        }
        
        if( originalClassForwardingInfo == NULL ) {
            originalClassForwardingInfo = malloc( sizeof(ClassOriginalForwardingInfo) );
            memcpy(originalClassForwardingInfo, &info, sizeof(ClassOriginalForwardingInfo));
        }
        else {
            originalClassForwardingInfoIndex++;
            originalClassForwardingInfo = realloc(originalClassForwardingInfo, originalClassForwardingInfoIndex+1);
            memcpy(&originalClassForwardingInfo[originalClassForwardingInfoIndex], &info, sizeof(ClassOriginalForwardingInfo));
        }
    }
    
    JP_Shadow(class_getSuperclass(self), _cmd);
}

// there are some methods we won't touch
static BOOL JP_IsSafeSelector(SEL _cmd) {
    // messing with memory management is asking for trouble
    if (_cmd == @selector(retain)) { return NO; }
    if (_cmd == @selector(release)) { return NO; }
    if (_cmd == @selector(autorelease)) { return NO; }
    if (_cmd == @selector(dealloc)) { return NO; }
    
    // for safety, don't mess with anything that POCOs respond to
    return ![NSObject instancesRespondToSelector:_cmd];
}

static void JP_InstallJoinPoint(id self, SEL _cmd, const void *key, dispatch_block_t block) {
    if (JP_IsSafeSelector(_cmd) && block != nil) {
        JP_InstallNSObjectForwardInvocationReplacement();
        JP_AddBlock(self, _cmd, key, block);
        
        Class c = object_getClass(self);
        if (class_isMetaClass(c)) { c = (Class)self; }
        JP_Shadow(c, _cmd);
    }
}

@implementation NSObject (JoinPoints)

- (void)before:(SEL)selector do:(dispatch_block_t)block {
    JP_InstallJoinPoint(self, selector, &JP_BeforeBlocks, block);
}

- (void)during:(SEL)selector do:(dispatch_block_t)block {
    JP_InstallJoinPoint(self, selector, &JP_DuringBlocks, block);
}

- (void)after:(SEL)selector do:(dispatch_block_t)block {
    JP_InstallJoinPoint(self, selector, &JP_AfterBlocks, block);
}

@end
