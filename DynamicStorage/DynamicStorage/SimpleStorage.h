//
//  SimpleStorage.h
//  DynamicStorage
//
//  Created by Dave DeLong on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDDynamicStorageObject.h"

@interface SimpleStorage : DDDynamicStorageObject {
    
}

@property (nonatomic, retain) NSString *stringValue;
@property (nonatomic, readonly) NSNumber *numberValue;
@property (assign) id delegate;
@property (setter=setCustomly:,getter=customly, retain) NSDate *date;
@property (copy) NSArray *copiedArray;

@end
