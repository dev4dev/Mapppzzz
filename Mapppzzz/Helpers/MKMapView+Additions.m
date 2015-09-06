//
//  MKMapView+Additions.m
//  Mapppzzz
//
//  Created by Alex Antonyuk on 9/6/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import "MKMapView+Additions.h"

@implementation MKMapView (Additions)

- (CLLocation *)locationFromGesture:(UIGestureRecognizer *)gesture
{
	CGPoint tapPoint = [gesture locationInView:self];
	CLLocationCoordinate2D coordinates = [self convertPoint:tapPoint toCoordinateFromView:self];
	return [[CLLocation alloc] initWithCoordinate:coordinates
										 altitude:0
							   horizontalAccuracy:0
								 verticalAccuracy:0
										timestamp:[NSDate date]];
}

@end
