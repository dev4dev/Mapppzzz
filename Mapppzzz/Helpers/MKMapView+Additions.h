//
//  MKMapView+Additions.h
//  Mapppzzz
//
//  Created by Alex Antonyuk on 9/6/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import <MapKit/MapKit.h>
@import CoreLocation;

@interface MKMapView (Additions)

- (CLLocation *)locationFromGesture:(UIGestureRecognizer *)gesture;

@end
