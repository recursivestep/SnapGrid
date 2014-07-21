//
//  RSSnapBehavior.h
//  SnapGrid
//
//  Created by Mark Williams on 01/05/2014.
//  Copyright (c) 2014 Recustive Step. All rights reserved.
//

#import <UIKit/UIKit.h>

//
// Custom snap behavior because it doesn't seem possible to
// query the snap point of the base type.
//

@interface RSSnapBehavior : UISnapBehavior

- (instancetype)initWithItem:(id <UIDynamicItem>)item snapToPoint:(CGPoint)point indexPath:(NSIndexPath *)indexPath;
@property(nonatomic, assign) CGPoint snapPoint;
@property(nonatomic, strong) NSIndexPath *indexPath;

@end
