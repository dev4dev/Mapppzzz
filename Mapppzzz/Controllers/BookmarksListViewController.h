//
//  BookmarksListViewController.h
//  Mapppzzz
//
//  Created by Alex Antonyuk on 8/31/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BookmarksViewModel;
@class BookmarkViewModel;

typedef void(^BookmarksListBookmarkBlock)(BookmarkViewModel	*viewModel);

@interface BookmarksListViewController : UIViewController

@property (nonatomic, strong) BookmarksViewModel *viewModel;
@property (nonatomic, copy) BookmarksListBookmarkBlock bookmarkSelectedBlock;

@end
