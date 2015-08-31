//
//  LocationValueTransformer.m
//  Mapppzzz
//
//  Created by Alex Antonyuk on 8/31/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import "LocationValueTransformer.h"
@import CoreLocation;

@implementation LocationValueTransformer

+ (BOOL)allowsReverseTransformation
{
	return YES;
}

+(Class)transformedValueClass
{
	return [CLLocation class];
}

- (NSData *)transformedValue:(CLLocation *)value
{
	return [NSKeyedArchiver archivedDataWithRootObject:value];
}

- (CLLocation *)reverseTransformedValue:(NSData *)value
{
	return [NSKeyedUnarchiver unarchiveObjectWithData:value];
}

@end
