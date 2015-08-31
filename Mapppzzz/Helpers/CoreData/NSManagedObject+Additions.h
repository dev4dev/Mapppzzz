//
//  NSManagedObject+Additions.h
//  Mapppzzz
//
//  Created by Alex Antonyuk on 8/31/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Additions)

+ (instancetype)insertObjectIntoContext:(NSManagedObjectContext *)context;
+ (NSString *)entityName;

@end
