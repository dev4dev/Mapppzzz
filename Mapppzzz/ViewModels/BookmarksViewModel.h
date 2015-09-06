//
//  BookmarksViewModel.h
//  Mapppzzz
//
//  Created by Alex Antonyuk on 8/31/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Bookmark.h"
#import "CoreDataStack.h"

typedef void(^BookmarksViewModelVoidBlock)(void);

@class BookmarkViewModel;

@interface BookmarksViewModel : NSObject

@property (nonatomic, copy) BookmarksViewModelVoidBlock bookmarksChangedBlock;

- (instancetype)initWithCoreDataStack:(CoreDataStack *)coreDataStack;

/**
 *	Add New Bookmarks to Storage
 *
 *	@param name			Bookmark name (Optional
 *	@param location		Bookmark's Location
 *
 *	@return BookmarkViewModel object
 */
- (BookmarkViewModel *)addBookmarkWithName:(NSString *)name atLocation:(CLLocation *)location;

/**
 *	Returns Fetch Request for all Bookmarks
 *
 *	@return Fetch Request
 */
- (NSFetchRequest *)bookmarksFetchRequest;

/**
 *	FetchedResultsController for Bookmarks
 *
 *	@return Results Controller
 */
- (NSFetchedResultsController *)bookmarksFetchedresultController;

/**
 *	Returns all bookmarks
 *
 *	@return Array of bookmarks
 */
- (NSArray *)bookmarks;

@end
