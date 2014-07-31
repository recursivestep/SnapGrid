//
//  RSDraggableFlowLayoutDelegate.h
//  SnapGrid
//
//  Created by Mark Williams on 31/07/2014.
//  Copyright (c) 2014 Recustive Step. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSDraggableFlowLayout;

//
// Interface for updating owner model when cells have been moved
//
@protocol RSDraggableFlowLayoutDelegate <NSObject>
@required
- (void)flowLayout:(RSDraggableFlowLayout *)flowLayout updatedCellSlotContents:(NSArray *)slotContents;
- (BOOL)flowLayout:(RSDraggableFlowLayout *)flowLayout canMoveItemAtIndex:(NSInteger)index;
- (void)flowLayout:(RSDraggableFlowLayout *)flowLayout prepareItemForDrag:(NSIndexPath *)indexPath;
@end
