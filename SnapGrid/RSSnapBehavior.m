//
//  RSSnapBehavior.m
//  SnapGrid
//
//  Created by Mark Williams on 01/05/2014.
//  Copyright (c) 2014 Recustive Step. All rights reserved.
//

#import "RSSnapBehavior.h"

@implementation RSSnapBehavior

- (instancetype)initWithItem:(id <UIDynamicItem>)item snapToPoint:(CGPoint)point indexPath:(NSIndexPath *)indexPath
{
	self = [super initWithItem:item snapToPoint:point];
	if (self) {
		self.snapPoint = point;
		self.indexPath = indexPath;
	}
	return self;
}

@end
