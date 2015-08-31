//
//  CoreDataStack.m
//  Mapppzzz
//
//  Created by Alex Antonyuk on 8/31/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import "CoreDataStack.h"

@interface CoreDataStack ()

@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation CoreDataStack

#pragma mark - Init & Dealloc

+ (instancetype)sharedStack
{
	static dispatch_once_t once;
	static CoreDataStack *instance;
	dispatch_once(&once, ^ {
		instance = [[CoreDataStack alloc] init];
	});
	return instance;
}

- (instancetype)init
{
	if (self = [super init])
	{
		NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];

		NSPersistentStoreCoordinator *storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
		NSURL *dbURL = [[[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil] URLByAppendingPathComponent:@"Bookmarks.db"];
		[storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:dbURL options:nil error:nil];

		self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
		self.context.persistentStoreCoordinator = storeCoordinator;
	}

	return self;
}

#pragma mark - Lifecycle (Setup/Update)


#pragma mark - Properties Getters


#pragma mark - Properties Setters


#pragma mark - Public Interface


#pragma mark - Private methods



@end
