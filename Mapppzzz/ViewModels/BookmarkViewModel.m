//
//  BookmarkViewModel.m
//  Mapppzzz
//
//  Created by Alex Antonyuk on 8/31/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import "BookmarkViewModel.h"
#import "BookmarksViewModel.h"
#import "CoreDataStack.h"

@interface BookmarkViewModel ()

@property (nonatomic, strong) Bookmark *model;

@end

@implementation BookmarkViewModel

#pragma mark - Init & Dealloc

- (instancetype)initWithModel:(Bookmark *)model
{
	if (self = [self init]) {
		_model = model;
	}

	return self;
}

#pragma mark - Lifecycle (Setup/Update)


#pragma mark - Properties Getters

- (NSString *)name
{
	return self.model.name ?: @"Unnamed";
}

- (CLLocation *)location
{
	return self.model.location;
}

#pragma mark - Properties Setters


#pragma mark - Public Interface

- (void)deleteModel
{
	NSManagedObjectContext *context = [CoreDataStack sharedStack].context;
	[context performBlockAndWait:^{
		[context deleteObject:self.model];
		[context save:nil];
	}];
}

#pragma mark - Private methods


#pragma mark - Equal

- (BOOL)isEqual:(id)other
{
	if (other == self) {
		return YES;
	} else if ([other isKindOfClass:[BookmarkViewModel class]]) {
		BookmarkViewModel *obj = (BookmarkViewModel *)other;
		return [self.location isEqual:obj.location];
	}

	return NO;
}

- (NSUInteger)hash
{
	return self.location.hash;
}

@end
