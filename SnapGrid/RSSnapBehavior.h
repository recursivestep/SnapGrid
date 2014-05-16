//
//  RSSnapBehavior.h
//  SnapGrid
//
//  Created by Mark Williams on 01/05/2014.
//  Copyright (c) 2014 Recustive Step. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSSnapBehavior : UISnapBehavior
- (instancetype)initWithItem:(id <UIDynamicItem>)item snapToPoint:(CGPoint)point;
@property(nonatomic, assign) id<UIDynamicItem> item;
@property(nonatomic, assign) CGPoint snapPoint;
@end
