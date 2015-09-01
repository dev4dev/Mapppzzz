//
//  BookmarkViewModel+MapKit.m
//  Mapppzzz
//
//  Created by Alex Antonyuk on 9/1/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import "BookmarkViewModel+MapKit.h"

@implementation BookmarkViewModel (MapKit)

#pragma mark - Annotation

- (CLLocationCoordinate2D)coordinate
{
	return self.location.coordinate;
}

- (NSString *)title
{
	return self.name;
}

@end
