//
//  PlaceModel.m
//  Mapppzzz
//
//  Created by Alex Antonyuk on 9/3/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import "PlaceModel.h"

@implementation PlaceModel

#pragma mark - Init & Dealloc

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	if (self = [self init]) {
		_name = dictionary[@"name"];
		_coordinates = CLLocationCoordinate2DMake([[dictionary valueForKeyPath:@"location.lat"] doubleValue], [[dictionary valueForKeyPath:@"location.lng"] doubleValue]);
	}

	return self;
}

#pragma mark - Lifecycle (Setup/Update)


#pragma mark - Properties Getters


#pragma mark - Properties Setters


#pragma mark - Public Interface


#pragma mark - Private methods

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@: %@ (%f, %f)", [super description], self.name, self.coordinates.latitude, self.coordinates.longitude];
}

@end
