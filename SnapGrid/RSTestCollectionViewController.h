//
//  RSTestCollectionViewController.h
//  SnapGrid
//
//  Created by Mark Williams on 09/04/2014.
//  Copyright (c) 2014 Recustive Step. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSDraggableFlowLayout.h"

@interface RSTestCollectionViewController : UICollectionViewController <UIDraggableFlowLayoutProtocol>
@property (nonatomic, assign) int numberOfCells;
@property (nonatomic, assign) float widthOfCells;
@property (nonatomic, assign) float heightOfCells;
@property (nonatomic, assign) float spacing;
@end
