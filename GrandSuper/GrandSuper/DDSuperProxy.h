//
//  DDSuperProxy.h
//  GrandSuper
//
//  Created by Dave DeLong on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDSuperProxy : NSProxy {
    Class _context;
    int _level;
    id _target;
}

- (id)initWithProxy:(id)proxyTarget superLevel:(int)level originalContext:(const char *)oContext;

@end

static inline id __parent(id self, int level, const char *context) {
    if (level == 0) { return self; }
    return [[[DDSuperProxy alloc] initWithProxy:self superLevel:level originalContext:context] autorelease];
}

#define parent(_l) __parent(self, (_l), __PRETTY_FUNCTION__)
#define grandsuper parent(2)
