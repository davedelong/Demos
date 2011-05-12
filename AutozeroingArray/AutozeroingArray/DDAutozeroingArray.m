//
//  DDAutozeroingArray.m
//  AutozeroingArray
//
//  Created by Dave DeLong on 5/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DDAutozeroingArray.h"
#import <objc/runtime.h>

static char DDAutozeroingObserverKey = 1;
static NSString *DDAutozeroingObjectDidDeallocateNotification = @"DDAutozeroingObjectDidDeallocateNotification";

//this is an object that gets attached to an object in an AutozeroingArray
//when the attachee is deallocated/finalized, the associated objects are also cleaned up
//this causes the DeallocationObserver to be released (and deallocated/finalized)
//and when that happens, it posts an "object did deallocate" notification
//the object pointer (now stale) is posted in the notification, wrapped in an NSValue
@interface DDAutozeroingArrayDeallocationObserver : NSObject {
@private
    NSValue *objectWrapper;
}
@property (readonly) NSValue *objectWrapper;
- (id)initWithObject:(id)anObject;
@end

@implementation DDAutozeroingArrayDeallocationObserver
@synthesize objectWrapper;

- (id)initWithObject:(id)anObject {
    self = [super init];
    if (self) {
        objectWrapper = [[NSValue valueWithNonretainedObject:anObject] retain];
    }
    return self;
}

- (void)finalize {
    [[NSNotificationCenter defaultCenter] postNotificationName:DDAutozeroingObjectDidDeallocateNotification object:self userInfo:nil];
    [super finalize];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] postNotificationName:DDAutozeroingObjectDidDeallocateNotification object:self userInfo:nil];
    [objectWrapper release];
    [super dealloc];
}

@end

@implementation DDAutozeroingArray

- (id)initWithObjects:(const id *)objects count:(NSUInteger)cnt {
    self = [self init];
    if (self) {
        CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
        callbacks.retain = NULL;
        callbacks.release = NULL;
        storage = (NSMutableArray *)CFArrayCreateMutable(NULL, 0, &callbacks);
        
        for (NSUInteger i = 0; i < cnt; ++i) {
            id object = objects[i];
            [self addObject:object];
        }
    }
    return self;
}

#pragma mark Memory Management

- (void)finalize {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super finalize];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [storage release];
    [super dealloc];
}

#pragma mark Autozeroing

- (void)observeObject:(id)anObject {
    id observer = objc_getAssociatedObject(anObject, &DDAutozeroingObserverKey);
    if (observer == nil) {
        observer = [[DDAutozeroingArrayDeallocationObserver alloc] initWithObject:anObject];
        objc_setAssociatedObject(anObject, &DDAutozeroingObserverKey, observer, OBJC_ASSOCIATION_RETAIN);
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(objectDeallocated:) 
                                                     name:DDAutozeroingObjectDidDeallocateNotification 
                                                   object:observer];
        [observer release];
    }
    
}

- (void)stopObservingObject:(id)anObject {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DDAutozeroingObjectDidDeallocateNotification object:anObject];
}

- (void)objectDeallocated:(NSNotification *)note {
    NSValue *wrapper = [[note object] objectWrapper];
    id pointer = [wrapper nonretainedObjectValue];
    [storage removeObject:pointer];
}

#pragma mark NS(Mutable)Array overrides

- (NSUInteger)count {
    return [storage count];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [storage objectAtIndex:index];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    [self observeObject:anObject];
    [storage insertObject:anObject atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [self stopObservingObject:[self objectAtIndex:index]];
    [storage removeObjectAtIndex:index];
}

- (void)addObject:(id)anObject {
    [self observeObject:anObject];
    [storage addObject:anObject];
}

- (void)removeLastObject {
    [self stopObservingObject:[self lastObject]];
    [storage removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [self stopObservingObject:[self objectAtIndex:index]];
    [self observeObject:anObject];
    [storage replaceObjectAtIndex:index withObject:anObject];
}

- (NSString *)description {
    return [storage description];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
    return [storage countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
