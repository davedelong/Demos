//
//  ScreenShot_DetectorAppDelegate.h
//  ScreenShot Detector
//
//  Created by Dave DeLong on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ScreenShot_DetectorAppDelegate : NSObject <NSApplicationDelegate, NSMetadataQueryDelegate> {
@private
    NSWindow *window;
    NSMetadataQuery *query;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, copy) NSArray *queryResults;

@end
