//
//  AppDelegate_iPad.h
//  OlympicRings
//
//  Created by Dave DeLong on 10/14/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RingLayer.h"

@interface AppDelegate_iPad : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	
	NSMutableArray * rings;
	
	RingLayer * red;
	RingLayer * green;
	RingLayer * blue;
	RingLayer * black;
	RingLayer * yellow;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

