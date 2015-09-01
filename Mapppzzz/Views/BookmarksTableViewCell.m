//
//  BookmarksTableViewCell.m
//  Mapppzzz
//
//  Created by Alex Antonyuk on 8/31/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import "BookmarksTableViewCell.h"
#import "BookmarkViewModel.h"

@implementation BookmarksTableViewCell

- (void)prepareForReuse
{
	[super prepareForReuse];

	self.textLabel.text = @"";
}

- (void)
setViewModel:(BookmarkViewModel *)viewModel
{
	_viewModel = viewModel;
	[self updateView];
}

- (void)updateView
{
	self.textLabel.text = self.viewModel.name;
	self.detailTextLabel.text = [NSString stringWithFormat:@"lat=%f lon=%f", self.viewModel.location.coordinate.latitude, self.viewModel.location.coordinate.longitude];
}

@end
