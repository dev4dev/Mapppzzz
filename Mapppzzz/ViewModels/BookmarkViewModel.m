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
#import "PlaceModel.h"
#import "Constants.h"

@interface BookmarkViewModel ()

@property (nonatomic, strong) Bookmark *model;

@end

@implementation BookmarkViewModel

#pragma mark - Init & Dealloc

- (instancetype)initWithModel:(Bookmark *)model
{
	if (self = [self init]) {
		_model = model;

		_identifier = [model.identifier copy];
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

- (BOOL)isNamed
{
	return self.model.name.length > 0;
}

#pragma mark - Properties Setters


#pragma mark - Public Interface

- (void)deleteModel
{
	NSManagedObjectContext *context = [CoreDataStack sharedStack].context;
	[context performBlockAndWait:^{
		[context deleteObject:self.model];
		[context save:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:kBookmarkDeletedNotification object:self];
	}];
}

- (void)updateBookmarkWithPlace:(PlaceModel *)place
{
	NSManagedObjectContext *context = [CoreDataStack sharedStack].context;
	[context performBlockAndWait:^{
		self.model.name = place.name;
		[context save:nil];
	}];
}

#pragma mark - Private methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@: %@ %@", [super description], self.name, self.identifier];
}


#pragma mark - Equal

- (BOOL)isEqual:(id)other
{
	if (other == self) {
		return YES;
	} else if ([other isKindOfClass:[BookmarkViewModel class]]) {
		BookmarkViewModel *obj = (BookmarkViewModel *)other;
		return [self.identifier isEqualToString:obj.identifier];
	}

	return NO;
}

- (NSUInteger)hash
{
	return self.identifier.hash;
}

@end
