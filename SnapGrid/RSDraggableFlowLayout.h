//
//  RSDraggableFlowLayout.h
//  SnapGrid
//
//  Created by Mark Williams on 09/04/2014.
//  Copyright (c) 2014 Recustive Step. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RSDraggableFlowLayout;

@protocol UIDraggableFlowLayoutProtocol
@required
- (void)flowLayout:(RSDraggableFlowLayout *)flowLayout updatedCellSlotContents:(NSArray *)slotContents;
- (BOOL)flowLayout:(RSDraggableFlowLayout *)flowLayout canMoveItemAtIndex:(int)index;
@end



@interface RSDraggableFlowLayout : UICollectionViewFlowLayout

@property(nonatomic, assign) id<UIDraggableFlowLayoutProtocol> delegate;

@end
