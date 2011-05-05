//
//  DDDynamicStorageObject.m
//  EmptyiPhone
//
//  Created by Dave DeLong on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DDDynamicStorageObject.h"
#import <objc/runtime.h>

static char valueKey = 1;

@implementation DDDynamicStorageObject

- (id)init {
    self = [super init];
    if (self) {
        _storage = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (void)dealloc {
    [_storage release];
    [super dealloc];
}
- (NSMutableDictionary *)storage {
    return _storage;
}
- (void)_printStorage {
    NSMutableDictionary *tmpStorage = [NSMutableDictionary dictionaryWithCapacity:[_storage count]];
    for (NSString *propertyName in _storage) {
        NSObject *objectHolder = [_storage objectForKey:propertyName];
        id propertyValue = objc_getAssociatedObject(objectHolder, &valueKey);
        if (propertyValue == nil) {
            propertyValue = [NSNull null];
        }
        [tmpStorage setObject:propertyValue forKey:propertyName];
    }
    NSLog(@"%@", tmpStorage);
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    const char *rawName = sel_getName(sel);
    NSString *name = NSStringFromSelector(sel);
    
    NSString *propertyName = nil;
    
    if ([name hasPrefix:@"set"]) {
        propertyName = [NSString stringWithFormat:@"%c%s", tolower(rawName[3]), (rawName+4)];
    } else if ([name hasPrefix:@"is"]) {
        propertyName = [NSString stringWithFormat:@"%c%s", tolower(rawName[2]), (rawName+3)];
    } else {
        propertyName = name;
    }
    propertyName = [propertyName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    
    Class cls = self;
    objc_property_t property = class_getProperty(self, [propertyName UTF8String]);
    if (property == NULL) {
        //unable to find property
        //let's see if we can brute-force find it
        while (cls != nil) {
            unsigned int count = 0;
            objc_property_t *allProperties = class_copyPropertyList(cls, &count);
            for (int i = 0; i < count; ++i) {
                objc_property_t aProperty = allProperties[i];
                NSString *propertyInfo = [NSString stringWithUTF8String:property_getAttributes(aProperty)];
                if ([propertyInfo rangeOfString:name].location != NSNotFound) {
                    property = aProperty;
                    break;
                }
            }
            if (allProperties) {
                free(allProperties);
            }
            if (property != NULL) { break; }
        }
    }
    
    if (property == NULL) {
        IMP imp = class_getMethodImplementation(self, sel);
        return (imp != NULL);
    }
    
    const char *rawPropertyName = property_getName(property);
    propertyName = [NSString stringWithUTF8String:rawPropertyName];
    
    NSString *getterName = nil;
    NSString *setterName = nil;
    NSString *propertyType = nil;
    BOOL isReadonly = NO;
    BOOL isAtomic = YES;
    objc_AssociationPolicy policy = OBJC_ASSOCIATION_ASSIGN;
    
    NSString *propertyInfo = [NSString stringWithUTF8String:property_getAttributes(property)];
    NSArray *propertyAttributes = [propertyInfo componentsSeparatedByString:@","];
    for (NSString *attribute in propertyAttributes) {
        if ([attribute hasPrefix:@"G"] && getterName == nil) {
            getterName = [attribute substringFromIndex:1];
        } else if ([attribute hasPrefix:@"S"] && setterName == nil) {
            setterName = [attribute substringFromIndex:1];
        } else if ([attribute hasPrefix:@"t"] && propertyType == nil) {
            propertyType = [attribute substringFromIndex:1];
        } else if ([attribute isEqualToString:@"N"]) {
            isAtomic = NO;
        } else if ([attribute isEqualToString:@"R"]) {
            isReadonly = YES;
        } else if ([attribute isEqualToString:@"C"]) {
            policy = OBJC_ASSOCIATION_COPY;
        } else if ([attribute isEqualToString:@"&"]) {
            policy = OBJC_ASSOCIATION_RETAIN;
        }
    }
    
    if (isAtomic) {
        NSLog(@"unable to generate truly atomic accessors for \"%@.%@\".  Sorry!", NSStringFromClass(cls), propertyName);
    } else {
        if (policy == OBJC_ASSOCIATION_COPY) {
            policy = OBJC_ASSOCIATION_COPY_NONATOMIC;
        } else if (policy == OBJC_ASSOCIATION_RETAIN) {
            policy = OBJC_ASSOCIATION_RETAIN_NONATOMIC;
        }
    }
    
    if (getterName == nil) {
        getterName = propertyName;
    }
    if (setterName == nil) {
        setterName = [NSString stringWithFormat:@"set%c%s:", toupper(rawPropertyName[0]), (rawPropertyName+1)];
    }
    
    id(^getterBlock)(id) = ^id(id _s) {
        NSObject *v = [[_s storage] objectForKey:propertyName];
        return objc_getAssociatedObject(v, &valueKey);
    };
    void(^setterBlock)(id,id) = ^(id _s, id _v) {
        NSObject *o = [[NSObject alloc] init];
        objc_setAssociatedObject(o, &valueKey, _v, policy);
        [[_s storage] setObject:o forKey:propertyName];
        [o release];
    };
    
    IMP getterIMP = imp_implementationWithBlock((void*)getterBlock);
    IMP setterIMP = imp_implementationWithBlock((void*)setterBlock);
    
    BOOL getterAdded = NO;
    BOOL setterAdded = NO;
    
    if (getterIMP != NULL) {
        getterAdded = class_addMethod(cls, NSSelectorFromString(getterName), getterIMP, "@@:");
    }
        
    if (isReadonly == NO) {
        if (setterIMP != NULL) {
            setterAdded = class_addMethod(cls, NSSelectorFromString(setterName), setterIMP, "v@:@");
        }
    } else {
        imp_removeBlock(setterIMP);
        setterAdded = YES;
    }
    
    if (!getterAdded || !setterAdded) {
        NSLog(@"====================");
        NSLog(@"error adding methods");
        NSLog(@"class: %@", NSStringFromClass(cls));
        NSLog(@"setter: %@ => added?:%d", setterName, setterAdded);
        NSLog(@"getter: %@ => added?:%d", getterName, getterAdded);
    }
    
    return YES;
}

@end
