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

@class Bookmark;

@interface BookmarksViewModel : NSObject

- (instancetype)initWithCoreDataStack:(CoreDataStack *)coreDataStack;

/**
 *	Add New Bookmarks to Storage
 *
 *	@param name			Bookmark name (Optional
 *	@param location		Bookmark's Location
 *
 *	@return Bookmark object
 */
- (Bookmark *)addBookmarkWithName:(NSString *)name atLocation:(CLLocation *)location;

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

@end
