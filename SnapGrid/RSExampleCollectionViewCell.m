//
//  RSExampleCollectionViewCell.m
//  SnapGrid
//
//  Created by Mark Williams on 18/07/2014.
//  Copyright (c) 2014 Recustive Step. All rights reserved.
//

#import "RSExampleCollectionViewCell.h"

@interface RSExampleCollectionViewCell ()
@property(nonatomic, weak) IBOutlet UILabel *label;
@end

@implementation RSExampleCollectionViewCell

- (void)setText:(NSString *)text
{
	self.label.text = text;
}

- (NSString *)text
{
	return self.label.text;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
	self.label.backgroundColor = backgroundColor;
	self.contentView.backgroundColor = backgroundColor;
}

- (UIColor *)backgroundColor
{
	return self.label.backgroundColor;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)prepareForReuse
{
	
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
