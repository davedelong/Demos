//
//  DynamicStorageAppDelegate.h
//  DynamicStorage
//
//  Created by Dave DeLong on 5/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DynamicStorageViewController;

@interface DynamicStorageAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet DynamicStorageViewController *viewController;

@end
