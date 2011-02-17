//
//  AppDelegate_iPad.m
//  OlympicRings
//
//  Created by Dave DeLong on 10/14/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "AppDelegate_iPad.h"
#import "RingLayer.h"

@implementation AppDelegate_iPad

@synthesize window;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
    [self.window makeKeyAndVisible];
	
	CGRect frame = [[self window] frame];
	CGFloat oneThird = frame.size.width/3;
	
	CGSize ringSize = CGSizeMake(oneThird-30, oneThird-30);
	
	blue = [RingLayer layer];
	[blue setFrame:CGRectMake(0, 0, ringSize.width, ringSize.height)];
	[blue setForegroundColor:[[UIColor blueColor] CGColor]];
	[[window layer] addSublayer:blue];
	
	yellow = [RingLayer layer];
	CGRect y = [blue frame];
	y.origin.x = oneThird/2;
	y.origin.y = oneThird/2;
	[yellow setFrame:y];
	[yellow setForegroundColor:[[UIColor yellowColor] CGColor]];
	[[window layer] addSublayer:yellow];
	
	black = [RingLayer layer];
	CGRect r = [blue frame];
	r.origin.x += oneThird;
	[black setFrame:r];
	[black setForegroundColor:[[UIColor blackColor] CGColor]];
	[[window layer] addSublayer:black];
	
	green = [RingLayer layer];
	y = [yellow frame];
	y.origin.x += oneThird;
	[green setFrame:y];
	[green setForegroundColor:[[UIColor greenColor] CGColor]];
	[[window layer] addSublayer:green];
	
	red = [RingLayer layer];
	r = [black frame];
	r.origin.x += oneThird;
	[red setFrame:r];
	[red setForegroundColor:[[UIColor redColor] CGColor]];
	[[window layer] addSublayer:red];
	
	rings = [[NSMutableArray alloc] initWithObjects:red, green, blue, yellow, black, nil];
	
	NSTimer * t = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(doSomething:) userInfo:nil repeats:YES];
    
    return YES;
}

- (CGPoint) randomPoint {
	
	CGRect windowFrame = [window frame];
	return CGPointMake(arc4random() % (int)windowFrame.size.width,
					   arc4random() % (int)windowFrame.size.height);
}

- (void) doSomething:(NSTimer *)timer {
	for (CALayer * layer in rings) {
		CABasicAnimation * a = [CABasicAnimation animationWithKeyPath:@"position"];
		[a setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
		[a setFromValue:[NSValue valueWithCGPoint:[layer position]]];
		[a setToValue:[NSValue valueWithCGPoint:[self randomPoint]]];
		[a setAutoreverses:YES];
		[a setDuration:1.0];
		[layer addAnimation:a forKey:nil];
	}
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
