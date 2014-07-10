//
//  RSDraggableFlowLayout.m
//  SnapGrid
//
//  Created by Mark Williams on 09/04/2014.
//  Copyright (c) 2014 Recustive Step. All rights reserved.
//

#import "RSDraggableFlowLayout.h"
#import "RSSnapBehavior.h"


// Private properties
@interface RSDraggableFlowLayout ()

@property(nonatomic, strong) UILongPressGestureRecognizer *dragGestureRecognizer;	// To detect drag action
@property(nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;				// Pins dragging cell to touch position
@property(nonatomic, strong) UIDynamicAnimator *dragAnimator;						// Animator for attachment behavior
@property(nonatomic, strong) NSMutableDictionary *snapAnimators;					// Animators for snapping cells
@property(nonatomic, strong) NSMutableArray *originalCellLocations;					// We need to know these and can't rely on dynamic values once drags have started
@property(nonatomic, strong) NSMutableArray *currentSlotContents;					// Need to know which cells are in which slots while drag is in progress
@property(nonatomic, assign) NSInteger selectedPath;								// Path of cell that drag started on
@property(nonatomic, assign) NSInteger currentPath;									// Path of cell slot that touch is currently over

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

	// Need to initialise the gesture recogniser somewhere but can't do in init functions
	// as the view object isn't instansiated at that stage.
	// Would be better to hook in to viewDidLoad or similar but would require extra logic in
	// code using this.

	// This method is called more than once so guard against setting these values multiple times.
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

	// Start dragging cell on long touch
	if (longPressRecognizer.state == UIGestureRecognizerStateBegan) {
		[self startDraggingfromPoint:p];
    }
	// Move cell that is being dragged to latest touch position
    if (longPressRecognizer.state == UIGestureRecognizerStateChanged) {
		[self updateDragLocation:p];
    }
	// Stop dragging
	else if (longPressRecognizer.state == UIGestureRecognizerStateEnded || longPressRecognizer.state == UIGestureRecognizerStateCancelled) {
		[self stopDragging:p];
		[self invalidateLayout];
	}
}

- (void)populateCellOrigins
{
	// Record origin of all the cells so we can snap them back as required.
	self.originalCellLocations = [NSMutableArray array];
	for (int i = 0; i < [self.collectionView numberOfItemsInSection:0]; i++) {
		NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:0];
		UICollectionViewLayoutAttributes *cell = [self layoutAttributesForItemAtIndexPath:path];
		[self.originalCellLocations addObject:[NSValue valueWithCGPoint:cell.center]];
	}

	// Current slot contents starts off the same
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
	// Currently only supports a single section
	return [NSIndexPath indexPathForItem:self.selectedPath inSection:0];
}

- (NSIndexPath *)pathForCellInSlotIndex:(NSInteger)slotIndex
{
	// Cells that have been dragged no longer reside in their original slot
	NSNumber *index = [self.currentSlotContents objectAtIndex:slotIndex];
	NSIndexPath *path = [NSIndexPath indexPathForItem:[index intValue] inSection:0];
	return path;
}

- (NSInteger)getClosestSlotPathForPoint:(CGPoint)p
{
	// Get the path for the slot - need to use original cell locations as these
	// may have been updated by animators etc.
	for (int i = 0; i < self.originalCellLocations.count; i++) {
		CGPoint point = [[self.originalCellLocations objectAtIndex:i] CGPointValue];
		if ([self distanceFrom:p to:point] < 30) {	// TODO: Make this relative to cell size
			return i;
		}
	}
	return NSNotFound;
}

- (void)startDraggingfromPoint:(CGPoint)p
{
	// Need to know where everything starts off
	[self populateCellOrigins];

	// Check with delegate that we're allowed to move the cell at this point
	NSIndexPath *pathForObjectAtPoint = [self.collectionView indexPathForItemAtPoint:p];
	if (![self.delegate flowLayout:self canMoveItemAtIndex:pathForObjectAtPoint.row]) {
		return;
	}

	// Need to know the path of the cell we're moving
	self.selectedPath = pathForObjectAtPoint.row;
	// the path of the cell we're currently over
	self.currentPath = self.selectedPath;

	// Animator for attachment behavior
	self.dragAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];

	// Get the cell we're going to drag and change it's appearance so user can see it is selected
	UICollectionViewLayoutAttributes *selectedCell = [self layoutAttributesForItemAtIndexPath:[self selectedIndexPath]];
	[self prepareSelectedCellAppearanceForDrag:selectedCell animated:YES];

	// Attath the cell we're dragging to the touch (drag) point
	self.attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:selectedCell attachedToAnchor:p];
	[self.dragAnimator addBehavior:self.attachmentBehavior];

	// Animator for each cell that moves. Simplifies things elsewhere.
	self.snapAnimators = [NSMutableDictionary dictionary];
}

-(void)prepareSelectedCellAppearanceForDrag:(UICollectionViewLayoutAttributes *)selectedCell animated:(BOOL)animated
{
	// Make a few changes to the cell that is being dragged so that user can tell.

	// Make it top
	selectedCell.zIndex = 3;

	// Increase size a little bit
	// TODO: Make the size change relative to cell size
	CGRect cellBounds = selectedCell.bounds;
	cellBounds.size.width += 10;
	cellBounds.size.height += 10;

	__weak UICollectionViewCell *cellToChangeSize = [self.collectionView cellForItemAtIndexPath:[self selectedIndexPath]];

	// Apply size change
	if (animated) {
		void (^animateChangeSize)() = ^()
		{
			cellToChangeSize.frame = cellBounds;
			selectedCell.bounds = cellBounds;
		};

		[UIView transitionWithView:cellToChangeSize duration:0.05f options: UIViewAnimationOptionCurveLinear animations:animateChangeSize completion:nil];
	} else {
		cellToChangeSize.frame = cellBounds;
		selectedCell.bounds = cellBounds;
	}
}

- (void)updateDragLocation:(CGPoint)p
{
	// Touch point has moved to move the item we're dragging to match it
	self.attachmentBehavior.anchorPoint = p;

	// We're dragging a cell around and we want to use the center of that as the location for testing
	// whether we should swap cells around (as opposed to raw touch point).
	UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[self selectedIndexPath]];
	CGPoint testPoint = CGPointMake(CGRectGetMidX(cell.frame), CGRectGetMidY(cell.frame));

	// Which slot are we hovering over
	NSInteger toSlotIndex = [self getClosestSlotPathForPoint:testPoint];
	NSInteger fromSlotIndex = self.currentPath;

	// Nothing to do if we're not over a slot
	if (NSNotFound == toSlotIndex) {
		return;
	}

	// Nothing to do if we're over a cell that can't be moved
	if (![self.delegate flowLayout:self canMoveItemAtIndex:toSlotIndex]) {
		return;
	}

	// If we've moved to a new slot then snap cells to new positions as appropriate
	if (toSlotIndex != fromSlotIndex) {
		self.currentPath = toSlotIndex;
		[self snapItemsToReorderPositionsFromIndex:fromSlotIndex toIndex:toSlotIndex];
	}
}

- (void)snapItemsToReorderPositionsFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
	// Move  current position and all earlier ones to the position above
	if (toIndex > fromIndex) {
		for (NSInteger pos = toIndex; pos > fromIndex; pos--) {
			if (pos != fromIndex) {
				[self doSnapFromPosition:pos direction:-1];
			}
		}
	} else { // or current position and all subsequent ones to position below
		for (NSInteger pos = toIndex; pos < fromIndex; pos++) {
			if (pos != fromIndex) {
				[self doSnapFromPosition:pos direction:+1];
			}
		}
	}
	// Update current slot contents
	[self updateSlotContentsOfSlotsFromIndex:fromIndex toIndex:toIndex];
}

- (void)doSnapFromPosition:(NSInteger)pos direction:(NSInteger)direction
{
	// Snap individual cell

	// Get cell
	NSIndexPath *pathOfCellInSlot = [self pathForCellInSlotIndex:pos];
	UICollectionViewLayoutAttributes *fromCell = [self layoutAttributesForItemAtIndexPath:pathOfCellInSlot];

	// Get points to snap from and to
	CGPoint snapPoint = [[self.originalCellLocations objectAtIndex:pos+direction] CGPointValue];
	CGPoint fromPoint = [[self.originalCellLocations objectAtIndex:pos] CGPointValue];

	// This clause is in case a cell was already being snapped and had it's position updated
	if (CGPointEqualToPoint(snapPoint, fromCell.center)) {
		fromCell.center = fromPoint;
	}

	// Get animator
	UIDynamicAnimator *snapAnimator = [self snapAnimatorForPath:pathOfCellInSlot];
	// And update the point to which it is snapping
	[self updateSnapPointForCell:fromCell animator:snapAnimator snapToPoint:snapPoint];
}

- (void)updateSlotContentsOfSlotsFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
	// Update current slot contents
	if (fromIndex < toIndex) {
		NSNumber *startValue = [self.currentSlotContents objectAtIndex:fromIndex];
		for (NSInteger index = fromIndex; index < toIndex; index++) {
			[self.currentSlotContents replaceObjectAtIndex:index withObject:[self.currentSlotContents objectAtIndex:index+1]];
		}
		[self.currentSlotContents replaceObjectAtIndex:toIndex withObject:startValue];
	} else {
		NSNumber *endValue = [self.currentSlotContents objectAtIndex:fromIndex];
		for (NSInteger index = fromIndex; index > toIndex ; index--) {
			[self.currentSlotContents replaceObjectAtIndex:index withObject:[self.currentSlotContents objectAtIndex:index-1]];
		}
		[self.currentSlotContents replaceObjectAtIndex:toIndex withObject:endValue];
	}
}

- (UIDynamicAnimator *)snapAnimatorForPath:(NSIndexPath *)path
{
	// Get an animator for cell at path from dictionary or create if it doesn't already
	UIDynamicAnimator *snapAnimator = [self.snapAnimators objectForKey:path];
	if (!snapAnimator) {
		snapAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
		[self.snapAnimators setObject:snapAnimator forKey:path];
	}
	return snapAnimator;
}

- (void)updateSnapPointForCell:(UICollectionViewLayoutAttributes *)cell animator:(UIDynamicAnimator *)snapAnimator snapToPoint:(CGPoint)point
{
	// Get snap behavior - should only be one per snap animator
	RSSnapBehavior *snapBehavior = nil;
	if (snapAnimator.behaviors.count) {
		snapBehavior = [snapAnimator.behaviors objectAtIndex:0];
	}
	
	// If there is no snap behavior or it is not snapping to correct point already
	if (!snapBehavior || !CGPointEqualToPoint(snapBehavior.snapPoint, point)) {
		// Create snap behavior to correct point (not possible to update snap point of existing behavior so always create a new one)
		RSSnapBehavior *snapBehavior = [[RSSnapBehavior alloc] initWithItem:cell snapToPoint:point];
		[snapAnimator removeAllBehaviors];	// Again, can't update existing so remove any
		[snapAnimator addBehavior:snapBehavior];	// Add new behavior

		// Default snap behavior has rotation. Some people prefer that but it looks cleaner without
		// TODO: allow user to pass in dynamic behavior to customise animation effects.
		UIDynamicItemBehavior * dynamicItem = [[UIDynamicItemBehavior alloc] initWithItems:@[cell]];
		dynamicItem.allowsRotation = NO;
		[snapAnimator addBehavior:dynamicItem];
	} // else if snap behavior already points at correct place there's nothing to do
}

- (void)removeSnapBehaviors
{
	// Remove all snap behaviors and animators (called when we stop dragging)
	NSArray *snapAnimators = [self.snapAnimators allValues];
	for (UIDynamicAnimator *snapAnimator in snapAnimators) {
		[snapAnimator removeAllBehaviors];
	}
	[self.snapAnimators removeAllObjects];
}

- (void)stopDragging:(CGPoint)p
{
	// Stop dragging so tell the owner so it can update it's model to match
	[self.delegate flowLayout:self updatedCellSlotContents:self.currentSlotContents];
	[self.collectionView reloadData];

	// Clean up all the mechanisms we used to enable the drag / snapping
	[self removeSnapBehaviors];
	self.snapAnimators = nil;
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
	// Overidden from base class
	
	// Array of attributes to return
	NSMutableArray *allAttributes = [NSMutableArray new];

	// Get the default layout attributes from super class
	NSArray *existingAttributes = [super layoutAttributesForElementsInRect:rect];

	// Add items from existing attributes that aren't duplicated by items owned by animators
	for (UICollectionViewLayoutAttributes *a in existingAttributes) {
		NSArray *snapCells = [self.snapAnimators allKeys];
		if ((![snapCells containsObject:a.indexPath]) && (![a.indexPath isEqual:[self selectedIndexPath]])) {
			[allAttributes addObject:a];
		}
	}

	// If cells are being managed by animators then get the layout attributes from them instead
	[allAttributes addObjectsFromArray:[self.dragAnimator itemsInRect:rect]];	// That is drag animator
	NSArray *snapAnimators = [self.snapAnimators allValues];					// plus all the snap animators
	for (UIDynamicAnimator *snapAnimator in snapAnimators) {
		[allAttributes addObjectsFromArray:[snapAnimator itemsInRect:rect]];
	}
	return allAttributes;
}

@end
