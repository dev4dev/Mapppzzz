//
//  NSManagedObject+Additions.m
//  Mapppzzz
//
//  Created by Alex Antonyuk on 8/31/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import "NSManagedObject+Additions.h"

@implementation NSManagedObject (Additions)

+ (instancetype)insertObjectIntoContext:(NSManagedObjectContext *)context
{
	return [NSEntityDescription insertNewObjectForEntityForName:[self entityName]
										 inManagedObjectContext:context];
}

+ (NSString *)entityName
{
	return NSStringFromClass([self class]);
}

@end
