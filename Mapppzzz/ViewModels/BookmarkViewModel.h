//
//  BookmarkViewModel.h
//  Mapppzzz
//
//  Created by Alex Antonyuk on 8/31/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@class Bookmark;

@interface BookmarkViewModel : NSObject

@property (nonatomic, strong, readonly) Bookmark *model;

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, strong, readonly) CLLocation *location;

- (instancetype)initWithModel:(Bookmark *)model;

- (void)deleteModel;

@end
