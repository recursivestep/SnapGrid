//
//  RSViewController.m
//  SnapGrid
//
//  Created by Mark Williams on 09/04/2014.
//  Copyright (c) 2014 Recustive Step. All rights reserved.
//

#import "RSViewController.h"
#import "RSTestCollectionViewController.h"

@interface RSViewController ()
@property(nonatomic, weak) IBOutlet UISlider *numberOfCells;
@property(nonatomic, weak) IBOutlet UISlider *widthOfCells;
@property(nonatomic, weak) IBOutlet UISlider *heightOfCells;
@property(nonatomic, weak) IBOutlet UISlider *spacing;
@end

@implementation RSViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	// Make sure your segue name in storyboard is the same as this line
	if ([[segue identifier] isEqualToString:@"pushCollection"])
	{
		// Get reference to the destination view controller
		RSTestCollectionViewController *vc = [segue destinationViewController];

		// Pass any objects to the view controller here, like...
		vc.numberOfCells = self.numberOfCells.value;
		vc.widthOfCells = self.widthOfCells.value;
		vc.heightOfCells = self.heightOfCells.value;
		vc.spacing = self.spacing.value;
	}
}
@end
