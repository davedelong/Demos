//
//  DDDynamicStorageObject.h
//  EmptyiPhone
//
//  Created by Dave DeLong on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DDDynamicStorageObject : NSObject {
    @private
    NSMutableDictionary *_storage;
}

- (void)_printStorage;

@end
