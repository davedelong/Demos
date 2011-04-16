//
//  ValueTransformers.m
//  ScreenShot Detector
//
//  Created by Dave DeLong on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ValueTransformers.h"


@implementation ImagePathValueTransformer

+ (Class)transformedValueClass { return [NSImage class]; }
+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue:(id)value {
    return [[[NSImage alloc] initWithContentsOfFile:value] autorelease];
}

@end


@implementation NSURLBoxerValueTransformer

+ (Class)transformedValueClass { return [NSURL class]; }
+ (BOOL)allowsReverseTransformation { return NO; }

- (id)transformedValue:(id)value {
    if (value == nil) { return nil; }
    return [NSURL fileURLWithPath:value];
}

@end
