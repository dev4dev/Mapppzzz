//
//  BookmarkDetailsViewController.m
//  Mapppzzz
//
//  Created by Alex Antonyuk on 8/31/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import "BookmarkDetailsViewController.h"
#include "BookmarkViewModel.h"

static NSString *const kToMapSegueIdentifier = @"ToMap";
static NSString *const kToListSegueIdentifier = @"ToList";

@interface BookmarkDetailsViewController ()

@end

@implementation BookmarkDetailsViewController

#pragma mark - Init & Dealloc


#pragma mark - Lifecycle (Setup/Update)

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.title = self.viewModel.name;
}

#pragma mark - Properties Getters


#pragma mark - Properties Setters


#pragma mark - Public Interface


#pragma mark - Private methods


#pragma mark - UI Actions

- (IBAction)onDeleteBookmark:(id)sender
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Do you really want to delete this nice bookmark?" preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		[self.viewModel deleteModel];
		switch (self.unwindDestination) {
			case UnwindToMap: {
				[self performSegueWithIdentifier:kToMapSegueIdentifier sender:self];
				break;
			}
			case UnwindToList: {
				[self performSegueWithIdentifier:kToListSegueIdentifier sender:self];
				break;
			}
		}
	}]];
	[alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:alert animated:YES completion:nil];
}

@end
