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
NSString *DDAutozeroingObjectDidDeallocateNotification = @"DDAutozeroingObjectDidDeallocateNotification";

//this is an object that gets attached to an object in an AutozeroingArray
//when the attachee is deallocate, the associated objects are also cleaned up
//this causes the DeallocationObserver to be released (and deallocated)
//and when that happens, it posts an "object did deallocate" notification
//the object pointer (now stale) is posted in the notification, wrapped in an NSValue
@interface DDAutozeroingArrayDeallocationObserver : NSObject {
@private
    __weak id object;
}
- (id)initWithObject:(id)anObject;
@end

@implementation DDAutozeroingArrayDeallocationObserver

- (id)initWithObject:(id)anObject {
    self = [super init];
    if (self) {
        object = anObject;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] postNotificationName:DDAutozeroingObjectDidDeallocateNotification object:[NSValue valueWithNonretainedObject:object] userInfo:nil];
    object = nil;
    [super dealloc];
}

@end

@interface NSObject (DDAutozeroingArray)

- (void)requestDeallocationNotification;

@end

@implementation NSObject (DDAutozeroingArray)

- (void)requestDeallocationNotification {
    id observer = objc_getAssociatedObject(self, &DDAutozeroingObserverKey);
    if (observer == nil) {
        observer = [[DDAutozeroingArrayDeallocationObserver alloc] initWithObject:self];
        objc_setAssociatedObject(self, &DDAutozeroingObserverKey, observer, OBJC_ASSOCIATION_RETAIN);
        [observer release];
    }
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
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectDeallocated:) name:DDAutozeroingObjectDidDeallocateNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [storage release];
    [super dealloc];
}

- (void)objectDeallocated:(NSNotification *)note {
    NSValue *wrapper = [note object];
    id pointer = [wrapper nonretainedObjectValue];
    [storage removeObject:pointer];
}

- (NSUInteger)count {
    return [storage count];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [storage objectAtIndex:index];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    if ([anObject respondsToSelector:@selector(requestDeallocationNotification)]) {
        [anObject requestDeallocationNotification];
    }
    [storage insertObject:anObject atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [storage removeObjectAtIndex:index];
}

- (void)addObject:(id)anObject {
    if ([anObject respondsToSelector:@selector(requestDeallocationNotification)]) {
        [anObject requestDeallocationNotification];
    }
    [storage addObject:anObject];
}

- (void)removeLastObject {
    [storage removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if ([anObject respondsToSelector:@selector(requestDeallocationNotification)]) {
        [anObject requestDeallocationNotification];
    }
    [storage replaceObjectAtIndex:index withObject:anObject];
}

- (NSString *)description {
    return [storage description];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len {
    return [storage countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
