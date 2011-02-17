//
//  RingLayer.m
//  OlympicRings
//
//  Created by Dave DeLong on 10/14/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "RingLayer.h"


@implementation RingLayer

- (id) init {
	if (self = [super init]) {
		[self setBackgroundColor:[[UIColor clearColor] CGColor]];
	}
	return self;
}

- (void) drawInContext:(CGContextRef)ctx {
	CGFloat lineWidth = 15;
	CGRect circleRect = CGRectInset([self bounds], lineWidth, lineWidth);
	
	CGContextSetStrokeColorWithColor(ctx, [self foregroundColor]);
	CGContextSetLineWidth(ctx, lineWidth);
	CGContextStrokeEllipseInRect(ctx, circleRect);
}

@end
