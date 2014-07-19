//
//  RSTestCollectionViewController.m
//  SnapGrid
//
//  Created by Mark Williams on 09/04/2014.
//  Copyright (c) 2014 Recustive Step. All rights reserved.
//



//
// Basic collection view controller to test RSDraggableFlowLayout
//



#import "RSTestCollectionViewController.h"
#import "RSExampleCollectionViewCell.h"


// Private properties - they form a simple model for the order, colour and text of each cell.
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
	self.collectionView.backgroundColor = [UIColor whiteColor];
	self.edgesForExtendedLayout = UIRectEdgeAll;
	self.automaticallyAdjustsScrollViewInsets = YES;


	// Set layout delegate
	RSDraggableFlowLayout *layout = (RSDraggableFlowLayout *)self.collectionViewLayout;
	layout.dragGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:layout action:@selector(gestureCallback:)];
	[self.collectionView addGestureRecognizer:layout.dragGestureRecognizer];
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

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	// Currently only supports a single section
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
	static NSString *identifier = @"ExampleCell";
	
	RSExampleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];

	int mappedRow = [[self.cellOrder objectAtIndex:indexPath.row] intValue];

	cell.text = [self.cellText objectAtIndex:mappedRow];
	cell.backgroundColor = [self.cellColors objectAtIndex:mappedRow];

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

- (BOOL)flowLayout:(RSDraggableFlowLayout *)flowLayout canMoveItemAtIndex:(NSInteger)index
{
	if (index == self.numberOfCells - 1) {
		return NO;
	}
	return YES;
}

- (void)flowLayout:(RSDraggableFlowLayout *)flowLayout prepareItemForDrag:(NSIndexPath *)indexPath
{
	UICollectionViewLayoutAttributes *dragCellAttributes = [self.collectionViewLayout layoutAttributesForItemAtIndexPath:indexPath];
	CGRect bounds = dragCellAttributes.bounds;
	bounds.size.width *= 1.2;
	bounds.size.height *= 1.2;
	dragCellAttributes.bounds = bounds;
}

#pragma mark UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	// If a cell is selected then navigate to new view controller with custom animation.
	// Set colour of new view to colour of cell that has been selected.

	UIViewController *vc = [[UIViewController alloc] init];
	UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
	vc.view.backgroundColor = cell.backgroundColor;
	[self.view addSubview:vc.view];

	CGRect rect = CGRectMake(CGRectGetMidX(cell.frame), CGRectGetMidY(cell.frame), 0, 0);
	vc.view.frame = rect;
	
	[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			vc.view.frame = self.view.frame;
		} completion:^(BOOL finished) {
			[vc.view removeFromSuperview];
			[self.navigationController pushViewController:vc animated:NO];
		}];
}

@end
