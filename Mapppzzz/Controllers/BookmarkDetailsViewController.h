//
//  BookmarkDetailsViewController.h
//  Mapppzzz
//
//  Created by Alex Antonyuk on 8/31/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BookmarkViewModel;

typedef NS_ENUM(NSInteger, DetailsAction) {
	DetailsActionNone,
	DetailsActionCenterMap,
	DetailsActionBuildRoute
};

typedef NS_ENUM(NSInteger, UnwindTo) {
	UnwindToMap,
	UnwindToList
};

@interface BookmarkDetailsViewController : UIViewController

@property (nonatomic, strong) BookmarkViewModel *viewModel;
@property (nonatomic, assign) UnwindTo unwindDestination;
@property (nonatomic, assign, readonly) DetailsAction action;

@end
