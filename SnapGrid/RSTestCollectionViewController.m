//
//  RSTestCollectionViewController.m
//  SnapGrid
//
//  Created by Mark Williams on 09/04/2014.
//  Copyright (c) 2014 Recustive Step. All rights reserved.
//

#import "RSTestCollectionViewController.h"

@interface RSTestCollectionViewController ()

@property(nonatomic, strong) NSMutableArray *cellOrder;
@property(nonatomic, strong) NSMutableArray *cellColors;
@property(nonatomic, strong) NSMutableArray *cellText;
@end




@implementation RSTestCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super initWithCoder:decoder];
	if (self) {
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

	// Set up collection view
	[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
	self.collectionView.backgroundColor = [UIColor whiteColor];
	self.edgesForExtendedLayout = UIRectEdgeAll;
	self.automaticallyAdjustsScrollViewInsets = YES;

	// Set layout delegate
	RSDraggableFlowLayout *layout = (RSDraggableFlowLayout *)self.collectionViewLayout;
	layout.delegate = self;

	// Cell model
	self.cellOrder = [NSMutableArray array];
	for (int i = 0; i < self.numberOfCells; i++) {
		[self.cellOrder addObject:[NSNumber numberWithInt:i]];
	}

	// Cell attributes
	self.cellColors = [NSMutableArray arrayWithCapacity:self.numberOfCells];
	self.cellText = [NSMutableArray arrayWithCapacity:self.numberOfCells];
	for (int i = 0; i < self.numberOfCells; i++) {
		[self.cellColors addObject:[self randomColor]];
		[self.cellText addObject:[NSString stringWithFormat:@"%i", i]];
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.collectionViewLayout invalidateLayout];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.numberOfCells;
}

- (UIColor *)randomColor
{
	int r = arc4random() % 255;
	int g = arc4random() % 255;
	int b = arc4random() % 255;
	return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *identifier = @"cellIdentifier";
	
	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];

	int mappedRow = [[self.cellOrder objectAtIndex:indexPath.row] intValue];
	if (!cell.contentView.subviews.count) {
		UILabel *label = [[UILabel alloc] initWithFrame:cell.bounds];
		label.text = [self.cellText objectAtIndex:mappedRow];
		label.textColor = [UIColor whiteColor];
		label.textAlignment = NSTextAlignmentCenter;
		[cell.contentView addSubview:label];
		cell.backgroundColor = [self.cellColors objectAtIndex:mappedRow];
	} else {
		UILabel *label = cell.contentView.subviews.firstObject;
		label.text = [self.cellText objectAtIndex:mappedRow];
		label.textColor = [UIColor whiteColor];
		label.textAlignment = NSTextAlignmentCenter;
		cell.backgroundColor = [self.cellColors objectAtIndex:mappedRow];
	}
	return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return CGSizeMake(self.widthOfCells, self.heightOfCells);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
	return self.spacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
	return self.spacing;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
	self.view = nil;
	self.cellOrder = nil;
	self.cellText = nil;
}

#pragma mark UIDraggableFlowLayoutProtocol

- (void)flowLayout:(RSDraggableFlowLayout *)flowLayout updatedCellSlotContents:(NSArray *)slotContents;
{
	[flowLayout indexOfAccessibilityElement:nil];
	NSMutableArray *newOrder = [NSMutableArray array];
	for (int i = 0; i < slotContents.count; i++) {
		int indexOfOldSlot = [[slotContents objectAtIndex:i] intValue];
		int newSlotIndex = [[self.cellOrder objectAtIndex:indexOfOldSlot] intValue];
		[newOrder addObject:[NSNumber numberWithInt:newSlotIndex]];
	}
	self.cellOrder = newOrder;
}

- (BOOL)flowLayout:(RSDraggableFlowLayout *)flowLayout canMoveItemAtIndex:(int)index
{
	if (index == self.numberOfCells - 1) {
		return NO;
	}
	return YES;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	UIViewController *vc = [[UIViewController alloc] init];
	UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
	vc.view.backgroundColor = cell.backgroundColor;
	[self.view addSubview:vc.view];

	CGRect rect = CGRectMake(CGRectGetMidX(cell.frame), CGRectGetMidY(cell.frame), 0, 0);
	vc.view.frame = rect;
	
	[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
				vc.view.frame = self.view.frame;
			}
			completion:^(BOOL finished) {
				[vc.view removeFromSuperview];
				[self.navigationController pushViewController:vc animated:NO];
			}];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
