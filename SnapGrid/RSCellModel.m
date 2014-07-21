//
//  RSCellModel.m
//  SnapGrid
//
//  Created by Mark Williams on 21/07/2014.
//  Copyright (c) 2014 Recustive Step. All rights reserved.
//

#import "RSCellModel.h"

@implementation RSCellModel

- (instancetype)initWithCellCount:(NSInteger)cellCount
{
	self = [super init];
	if (self) {
		// Cell model
		self.cellOrder = [NSMutableArray array];
		for (int i = 0; i < cellCount; i++) {
			[self.cellOrder addObject:[NSNumber numberWithInt:i]];
		}
		
		// Cell attributes
		self.cellColors = [NSMutableArray arrayWithCapacity:cellCount];
		self.cellText = [NSMutableArray arrayWithCapacity:cellCount];
		for (int i = 0; i < cellCount; i++) {
			[self.cellColors addObject:[self randomColor]];
			[self.cellText addObject:[NSString stringWithFormat:@"%i", i]];
		}
	}
	return self;
}

- (UIColor *)randomColor
{
	int r = arc4random() % 255;
	int g = arc4random() % 255;
	int b = arc4random() % 255;
	return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
}

@end
