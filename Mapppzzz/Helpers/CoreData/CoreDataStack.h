//
//  CoreDataStack.h
//  Mapppzzz
//
//  Created by Alex Antonyuk on 8/31/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

@import Foundation;
@import CoreData;

@interface CoreDataStack : NSObject

@property (nonatomic, strong, readonly) NSManagedObjectContext *context;

+ (instancetype)sharedStack;

@end
