//
//  ScreenShot_DetectorAppDelegate.m
//  ScreenShot Detector
//
//  Created by Dave DeLong on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ScreenShot_DetectorAppDelegate.h"

@implementation ScreenShot_DetectorAppDelegate

@synthesize window;
@synthesize queryResults;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    query = [[NSMetadataQuery alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryUpdated:) name:NSMetadataQueryDidStartGatheringNotification object:query];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryUpdated:) name:NSMetadataQueryDidUpdateNotification object:query];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryUpdated:) name:NSMetadataQueryDidFinishGatheringNotification object:query];
    
    [query setDelegate:self];
    [query setPredicate:[NSPredicate predicateWithFormat:@"kMDItemIsScreenCapture = 1"]];
    [query startQuery];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [query stopQuery];
    [query setDelegate:nil];
    [query release], query = nil;
    
    [self setQueryResults:nil];
}

- (void)queryUpdated:(NSNotification *)note {
    [self setQueryResults:[query results]];
}

@end
