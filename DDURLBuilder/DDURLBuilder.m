//
//  DDURLBuilder.m
//  EmptyFoundation
//
//  Created by Dave DeLong on 2/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DDURLBuilder.h"

NSString *ddurlbuilder_percentEncode(NSString *string) {
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[string UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' || 
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

@implementation DDURLBuilder

@synthesize scheme;
@synthesize user;
@synthesize password;
@synthesize host;
@synthesize path;
@synthesize fragment;
@synthesize port;

@synthesize usesSchemeSeparators;

+ (id) URLBuilderWithURL:(NSURL *)url {
    return [[[self alloc] initWithURL:url] autorelease];
}

- (id) initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        queryValues = [[NSMutableDictionary alloc] init];
        [self setUsesSchemeSeparators:YES];
        if (url) {
            [self setURL:url];
        }
    }
    return self;
}

- (void)dealloc {
    [scheme release];
    [user release];
    [password release];
    [host release];
    [port release];
    [path release];
    [queryValues release];
    [fragment release];
    [super dealloc];
}

- (void) setURL:(NSURL *)URL {
    [self setScheme:[URL scheme]];
    [self setUser:[URL user]];
    [self setPassword:[URL password]];
    [self setPath:[URL path]];
    [self setHost:[URL host]];
    [self setFragment:[URL fragment]];
    [self setPort:[URL port]];
    
    NSString *absolute = [URL absoluteString];
    [self setUsesSchemeSeparators:([absolute hasPrefix:[NSString stringWithFormat:@"%@://", [self scheme]]])];
    
    [queryValues removeAllObjects];
    NSString *query = [URL query];
    NSArray *components = [query componentsSeparatedByString:@"&"];
    for (NSString *component in components) {
        NSArray *bits = [component componentsSeparatedByString:@"="];
        if ([bits count] != 2) {
            NSLog(@"illegal query string component: %@", component);
            continue;
        }
        
        NSString *key = [[components objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *value = [[components objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self addQueryValue:value forKey:key];
    }
}

- (NSURL *)URL {
    if ([self scheme] == nil || [self host] == nil) { return nil; }
    
    NSMutableString *url = [NSMutableString string];
    
    [url appendFormat:@"%@:", [self scheme]];
    if ([self usesSchemeSeparators]) {
        [url appendString:@"//"];
    }
    if ([self user]) {
        [url appendString:ddurlbuilder_percentEncode([self user])];
        if ([self password]) {
            [url appendFormat:@":%@", ddurlbuilder_percentEncode([self password])];
        }
        [url appendString:@"@"];
    }
    
    [url appendString:ddurlbuilder_percentEncode([self host])];
    if ([self port]) {
        [url appendFormat:@":%@", [self port]];
    }
    
    
    if ([self path]) {
        NSArray *pathComponents = [[self path] pathComponents];
        for (NSString *component in pathComponents) {
            if ([component isEqualToString:@"/"]) { continue; }
            [url appendFormat:@"/%@", ddurlbuilder_percentEncode(component)];
        }
    }
    
    if ([queryValues count] > 0) {
        NSMutableArray *components = [NSMutableArray array];
        for (NSString *key in queryValues) {
            NSArray *values = [queryValues objectForKey:key];
            key = ddurlbuilder_percentEncode(key);
            for (NSString *value in values) {
                value = ddurlbuilder_percentEncode(value);
                NSString *component = [NSString stringWithFormat:@"%@=%@", key, value];
                [components addObject:component];
            }
        }
        NSString *queryString = [components componentsJoinedByString:@"&"];
        [url appendFormat:@"?%@", queryString];
    }
    
    if ([self fragment]) {
        [url appendFormat:@"#%@", [self fragment]];
    }
    
    return [NSURL URLWithString:url];
}

- (NSArray *) queryValuesForKey:(NSString *)key {
    if (key == nil) { return nil; }
    return [[[queryValues objectForKey:key] copy] autorelease];
}

- (void) addQueryValue:(NSString *)value forKey:(NSString *)key {
    if (value == nil || key == nil) { return; }
    NSMutableArray *values = [queryValues objectForKey:key];
    if (values == nil) {
        values = [NSMutableArray array];
        [queryValues setObject:values forKey:key];
    }
    [values addObject:value];
}

- (void) removeQueryValue:(NSString *)value forKey:(NSString *)key {
    if (value == nil || key == nil) { return; }
    NSMutableArray *values = [queryValues objectForKey:key];
    if (values) {
        [values removeObject:value];
    }
}

- (void) removeQueryValuesForKey:(NSString *)key {
    if (key == nil) { return; }
    [queryValues removeObjectForKey:key];
}

@end
