//
//  BookmarksTableViewCell.h
//  Mapppzzz
//
//  Created by Alex Antonyuk on 8/31/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BookmarkViewModel;

@interface BookmarksTableViewCell : UITableViewCell

@property (nonatomic, strong) BookmarkViewModel *viewModel;

@end
