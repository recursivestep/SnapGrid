//
//  RSDraggableFlowLayout.h
//  SnapGrid
//
//  Created by Mark Williams on 09/04/2014.
//  Copyright (c) 2014 Recustive Step. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIDraggableFlowLayoutProtocol

- (NSArray *)cellSlotContents;
- (void)updatedCellSlotContents:(NSArray *)slotContents;

@end



@interface RSDraggableFlowLayout : UICollectionViewFlowLayout

@property(nonatomic, assign) id<UIDraggableFlowLayoutProtocol> delegate;

@end
