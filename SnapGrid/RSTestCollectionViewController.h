//
//  RSTestCollectionViewController.h
//  SnapGrid
//
//  Created by Mark Williams on 09/04/2014.
//  Copyright (c) 2014 Recustive Step. All rights reserved.
//

//
// Basic collection view controller to test RSDraggableFlowLayout
//

#import <UIKit/UIKit.h>
#import "RSDraggableFlowLayout.h"

@class RSCellModel;

@interface RSTestCollectionViewController : UICollectionViewController <RSDraggableFlowLayoutDelegate, UICollectionViewDelegate>
@property (nonatomic, assign) int numberOfCells;
@property (nonatomic, assign) float widthOfCells;
@property (nonatomic, assign) float heightOfCells;
@property (nonatomic, assign) float spacing;
@property (nonatomic, strong) RSCellModel *model;
@end
