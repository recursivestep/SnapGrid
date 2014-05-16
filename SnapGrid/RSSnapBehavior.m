//
//  RSSnapBehavior.m
//  SnapGrid
//
//  Created by Mark Williams on 01/05/2014.
//  Copyright (c) 2014 Recustive Step. All rights reserved.
//

#import "RSSnapBehavior.h"

@implementation RSSnapBehavior

- (instancetype)initWithItem:(id <UIDynamicItem>)item snapToPoint:(CGPoint)point
{
	self = [super initWithItem:item snapToPoint:point];
	if (self) {
		self.item = item;
		self.snapPoint = point;
	}
	return self;
}

@end