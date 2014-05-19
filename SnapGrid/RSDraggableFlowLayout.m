//
//  RSDraggableFlowLayout.m
//  SnapGrid
//
//  Created by Mark Williams on 09/04/2014.
//  Copyright (c) 2014 Recustive Step. All rights reserved.
//

#import "RSDraggableFlowLayout.h"
#import "RSSnapBehavior.h"


#ifdef DEBUG
#   define NSLog(...) NSLog(__VA_ARGS__)
#else
#   define NSLog(...)
#endif



@interface RSDraggableFlowLayout ()

@property(nonatomic, strong) UILongPressGestureRecognizer *dragGestureRecognizer;
@property(nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property(nonatomic, strong) UIDynamicAnimator *dragAnimator;
@property(nonatomic, strong) NSMutableDictionary *snapAnimators;
@property(nonatomic, strong) NSMutableArray *originalCellLocations;
@property(nonatomic, strong) NSMutableArray *currentSlotContents;
@property(nonatomic, assign) int selectedPath;
@property(nonatomic, assign) int currentPath;

@end





@implementation RSDraggableFlowLayout

- (id)init
{
	self = [super init];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self commonInit];
	}
	return self;
}

- (void)commonInit
{
}

- (void)prepareLayout
{
	[super prepareLayout];
	if (!self.dragGestureRecognizer) {
		self.selectedPath = NSNotFound;
		self.currentPath = NSNotFound;
		self.dragGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressCallback:)];
		[self.collectionView addGestureRecognizer:self.dragGestureRecognizer];
	}
}

- (void)longPressCallback:(UILongPressGestureRecognizer *)longPressRecognizer
{
	CGPoint p = [self.dragGestureRecognizer locationInView:self.collectionView];
	
	if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
		[self startDraggingfromPoint:p];
    }
    if (longPressRecognizer.state == UIGestureRecognizerStateChanged) {
		[self updateDragLocation:p];
    }
	else if (longPressRecognizer.state == UIGestureRecognizerStateEnded || longPressRecognizer.state == UIGestureRecognizerStateCancelled) {
		// Change the color and stop dragging
		[self stopDragging:p];
		[self invalidateLayout];
	}
}

- (void)logCurrentSlotContents
{
	NSLog(@"%@", @"---------CurrentSlotContents----------");
	for (int i = 0; i < self.currentSlotContents.count; i++) {
		CGPoint p = [[self.originalCellLocations objectAtIndex:i] CGPointValue];
		NSLog(@"Slot %i    Cell %i       x:%.2f       y:%.2f", i, [[self.currentSlotContents objectAtIndex:i] integerValue], p.x, p.y);
	}
	NSLog(@"%@", @"---------END CurrentSlotContents----------");
}

- (void)populateCellOrigins
{
	self.originalCellLocations = [NSMutableArray array];
	for (int i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++) {
		NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
		UICollectionViewLayoutAttributes *cell = [self layoutAttributesForItemAtIndexPath:path];
		[self.originalCellLocations addObject:[NSValue valueWithCGPoint:cell.center]];
	}

	self.currentSlotContents = [NSMutableArray array];
	for (int i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++) {
		[self.currentSlotContents addObject:[NSNumber numberWithInt:i]];
	}
}

- (float)distanceFrom:(CGPoint)point1 to:(CGPoint)point2
{
	CGFloat xDist = (point2.x - point1.x);
	CGFloat yDist = (point2.y - point1.y);
	return sqrt((xDist * xDist) + (yDist * yDist));
}

- (NSIndexPath *)selectedIndexPath
{
	return [NSIndexPath indexPathForItem:self.selectedPath inSection:0];
}

- (NSIndexPath *)pathForCellInSlotIndex:(int)slotIndex
{
	NSNumber *index = [self.currentSlotContents objectAtIndex:slotIndex];
	NSIndexPath *path = [NSIndexPath indexPathForItem:[index intValue] inSection:0];
	return path;
}

- (int)getClosestSlotPathForPoint:(CGPoint)p
{
	for (int i = 0; i < self.originalCellLocations.count; i++) {
		CGPoint point = [[self.originalCellLocations objectAtIndex:i] CGPointValue];
		if ([self distanceFrom:p to:point] < 20) {
			return i;
		}
	}
	return NSNotFound;
}

- (void)startDraggingfromPoint:(CGPoint)p
{
	[self populateCellOrigins];

	NSIndexPath *pathForObjectAtPoint = [self.collectionView indexPathForItemAtPoint:p];
	if (![self.delegate flowLayout:self canMoveItemAtIndex:pathForObjectAtPoint.row]) {
		return;
	}

	self.selectedPath = pathForObjectAtPoint.row;
	self.currentPath = self.selectedPath;
	self.dragAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];

	UICollectionViewLayoutAttributes *selectedCell = [self layoutAttributesForItemAtIndexPath:[self selectedIndexPath]];
	[self prepareSelectedCellAppearanceForDrag:selectedCell animated:YES];
	
	self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:selectedCell attachedToAnchor:p];
	[self.dragAnimator addBehavior:self.attachmentBehavior];

	self.snapAnimators = [NSMutableDictionary dictionary];
}

-(void)prepareSelectedCellAppearanceForDrag:(UICollectionViewLayoutAttributes *)selectedCell animated:(BOOL)animated
{
	// Make it top
	selectedCell.zIndex = 3;

	// Reduce Size
	CGRect cellBounds = selectedCell.bounds;
	cellBounds.size.width -= 10;
	cellBounds.size.height -= 10;

	__weak UICollectionViewCell *cellToChangeSize = [self.collectionView cellForItemAtIndexPath:[self selectedIndexPath]];
	// Apply size change
	if (animated) {
		void (^animateChangeSize)() = ^()
		{
			cellToChangeSize.frame = cellBounds;
			selectedCell.bounds = cellBounds;
		};

		[UIView transitionWithView:cellToChangeSize duration:0.1f options: UIViewAnimationOptionCurveLinear animations:animateChangeSize completion:nil];
	} else {
		cellToChangeSize.frame = cellBounds;
		selectedCell.bounds = cellBounds;
	}
}

- (void)updateDragLocation:(CGPoint)p
{
	self.attachmentBehavior.anchorPoint = p;

	UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[self selectedIndexPath]];
	CGPoint testPoint = CGPointMake(CGRectGetMidX(cell.frame), CGRectGetMidY(cell.frame));

	int toSlotIndex = [self getClosestSlotPathForPoint:testPoint];
	int fromSlotIndex = self.currentPath;

	if (NSNotFound == toSlotIndex) {
		return;
	}

	if (![self.delegate flowLayout:self canMoveItemAtIndex:toSlotIndex]) {
		return;
	}

	if (toSlotIndex != fromSlotIndex) {
		self.currentPath = toSlotIndex;
		[self snapItemsToReorderPositionsFromIndex:fromSlotIndex toIndex:toSlotIndex];
	}
}

- (void)snapItemsToReorderPositionsFromIndex:(int)fromIndex toIndex:(int)toIndex
{
	NSLog(@"snapItemsToReorderPositions from: %i to: %i \n\n", fromIndex, toIndex);
	// Move all current position and all earlier ones to the position above or vice versa
	if (toIndex > fromIndex) {
		for (int pos = toIndex; pos > fromIndex; pos--) {
			if (pos != fromIndex) {
				[self doSnapFromPosition:pos direction:-1];
			}
		}
	} else {
		for (int pos = toIndex; pos < fromIndex; pos++) {
			if (pos != fromIndex) {
				[self doSnapFromPosition:pos direction:+1];
			}
		}
	}
	[self updateSlotContentsOfSlotsFromIndex:fromIndex toIndex:toIndex];
	NSLog(@"\n\n");
}

- (void)doSnapFromPosition:(int)pos direction:(int)direction
{
	NSIndexPath *pathOfCellInSlot = [self pathForCellInSlotIndex:pos];
	UICollectionViewLayoutAttributes *fromCell = [self layoutAttributesForItemAtIndexPath:pathOfCellInSlot];

	CGPoint snapPoint = [[self.originalCellLocations objectAtIndex:pos+direction] CGPointValue];
	CGPoint fromPoint = [[self.originalCellLocations objectAtIndex:pos] CGPointValue];

	NSLog(@"snap item %i at (%f, %f) to item %i at (%f, %f)", pos, fromPoint.x, fromPoint.y, pos+direction, snapPoint.x, snapPoint.y);
	
	if (CGPointEqualToPoint(snapPoint, fromCell.center)) {
		fromCell.center = fromPoint;
	}
	
	UIDynamicAnimator *snapAnimator = [self snapAnimatorForPath:pathOfCellInSlot];
	[self updateSnapPointForCell:fromCell animator:snapAnimator snapToPoint:snapPoint];
}

- (void)updateSlotContentsOfSlotsFromIndex:(int)fromIndex toIndex:(int)toIndex
{
//	[self logCurrentSlotContents];
	if (fromIndex < toIndex) {
		NSNumber *startValue = [self.currentSlotContents objectAtIndex:fromIndex];
		for (int index = fromIndex; index < toIndex; index++) {
			[self.currentSlotContents replaceObjectAtIndex:index withObject:[self.currentSlotContents objectAtIndex:index+1]];
		}
		[self.currentSlotContents replaceObjectAtIndex:toIndex withObject:startValue];
	} else {
		NSNumber *endValue = [self.currentSlotContents objectAtIndex:fromIndex];
		for (int index = fromIndex; index > toIndex ; index--) {
			[self.currentSlotContents replaceObjectAtIndex:index withObject:[self.currentSlotContents objectAtIndex:index-1]];
		}
		[self.currentSlotContents replaceObjectAtIndex:toIndex withObject:endValue];
	}
//	[self logCurrentSlotContents];
}

- (UIDynamicAnimator *)snapAnimatorForPath:(NSIndexPath *)path
{
	UIDynamicAnimator *snapAnimator = [self.snapAnimators objectForKey:path];
	if (!snapAnimator) {
		snapAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
		[self.snapAnimators setObject:snapAnimator forKey:path];
	}
	return snapAnimator;
}

- (void)updateSnapPointForCell:(UICollectionViewLayoutAttributes *)cell animator:(UIDynamicAnimator *)snapAnimator snapToPoint:(CGPoint)point
{
	RSSnapBehavior *snapBehavior = nil;
	if (snapAnimator.behaviors.count) {
		snapBehavior = [snapAnimator.behaviors objectAtIndex:0];
	}
	
	if (!snapBehavior || !CGPointEqualToPoint(snapBehavior.snapPoint, point)) {
		RSSnapBehavior *snapBehavior = [[RSSnapBehavior alloc] initWithItem:cell snapToPoint:point];
		[snapAnimator removeAllBehaviors];
		[snapAnimator addBehavior:snapBehavior];
	}
}

- (void)removeSnapBehaviors
{
	NSArray *snapAnimators = [self.snapAnimators allValues];
	for (UIDynamicAnimator *snapAnimator in snapAnimators) {
		[snapAnimator removeAllBehaviors];
	}
	[self.snapAnimators removeAllObjects];
}

- (void)stopDragging:(CGPoint)p
{
	[self.delegate flowLayout:self updatedCellSlotContents:self.currentSlotContents];
	[self.collectionView reloadData];

	[self removeSnapBehaviors];
	[self.dragAnimator removeAllBehaviors];
	self.attachmentBehavior = nil;
	self.dragAnimator = nil;
	self.selectedPath = NSNotFound;
	self.currentPath = NSNotFound;
	self.originalCellLocations = nil;
	self.currentSlotContents = nil;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	// Find all the attributes, and replace the one for our indexPath
	NSArray *existingAttributes = [super layoutAttributesForElementsInRect:rect];
	NSMutableArray *allAttributes = [NSMutableArray new];

	// Add items from existing attributes that aren't duplicated by items owned by animators
	for (UICollectionViewLayoutAttributes *a in existingAttributes) {
		NSArray *snapCells = [self.snapAnimators allKeys];
		if ((![snapCells containsObject:a.indexPath]) && (![a.indexPath isEqual:[self selectedIndexPath]])) {
			[allAttributes addObject:a];
		}
	}

	// Add items from animators
	[allAttributes addObjectsFromArray:[self.dragAnimator itemsInRect:rect]];
	NSArray *snapAnimators = [self.snapAnimators allValues];
	for (UIDynamicAnimator *snapAnimator in snapAnimators) {
		[allAttributes addObjectsFromArray:[snapAnimator itemsInRect:rect]];
	}
	return allAttributes;
}

@end
