//
//  BookmarksViewModel.m
//  Mapppzzz
//
//  Created by Alex Antonyuk on 8/31/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import "BookmarksViewModel.h"
#import "CoreDataStack.h"
#import "NSManagedObject+Additions.h"

@interface BookmarksViewModel ()

@property (nonatomic, strong) CoreDataStack *coreDataStack;
@property (nonatomic, strong, readonly) NSManagedObjectContext *context;

@end

@implementation BookmarksViewModel

#pragma mark - Init & Dealloc

- (instancetype)initWithCoreDataStack:(CoreDataStack *)coreDataStack
{
	if (self = [self init]) {
		_coreDataStack = coreDataStack;
	}

	return self;
}

#pragma mark - Lifecycle (Setup/Update)


#pragma mark - Properties Getters

- (NSManagedObjectContext *)context
{
	return self.coreDataStack.context;
}

#pragma mark - Properties Setters


#pragma mark - Public Interface

- (Bookmark *)addBookmarkWithName:(NSString *)name atLocation:(CLLocation *)location
{
	__block Bookmark *bookmark;
	[self.context performBlockAndWait:^{
		bookmark = [Bookmark insertObjectIntoContext:self.context];
		bookmark.identifier = [[NSUUID UUID] UUIDString];
		bookmark.name = name;
		bookmark.location = location;
		NSError *error;
		[self.context save:&error];
	}];
	return bookmark;
}

- (NSFetchRequest *)bookmarksFetchRequest
{
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[Bookmark entityName]];
	request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
	return request;
}

- (NSFetchedResultsController *)bookmarksFetchedresultController
{
	return [[NSFetchedResultsController alloc] initWithFetchRequest:[self bookmarksFetchRequest]
											   managedObjectContext:self.coreDataStack.context
												 sectionNameKeyPath:nil
														  cacheName:nil];
}

#pragma mark - Private methods



@end
