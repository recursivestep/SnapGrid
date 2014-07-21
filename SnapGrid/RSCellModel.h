//
//  RSCellModel.h
//  SnapGrid
//
//  Created by Mark Williams on 21/07/2014.
//  Copyright (c) 2014 Recustive Step. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSCellModel : NSObject

@property(nonatomic, strong) NSMutableArray *cellOrder;
@property(nonatomic, strong) NSMutableArray *cellColors;
@property(nonatomic, strong) NSMutableArray *cellText;

- (instancetype)initWithCellCount:(NSInteger)cellCount;

@end
