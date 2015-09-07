//
//  MapViewDataSource.m
//  Mapppzzz
//
//  Created by Alex Antonyuk on 9/6/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import "MapViewDataSource.h"
#import <YOLOKit/YOLO.h>

@interface MapViewDataSource ()
	<MKMapViewDelegate>

@property (nonatomic, weak) MKMapView *mapView;
@property (nonatomic, strong) NSMutableOrderedSet *annotations;

@property (nonatomic, strong) MKRoute *currentRoute;

@end

@implementation MapViewDataSource

#pragma mark - Init & Dealloc

- (instancetype)initWithMapView:(MKMapView *)mapView
{
	if (self = [self init]) {
		_mapView = mapView;
		_mapView.delegate = self;

		_annotations = [NSMutableOrderedSet orderedSet];
	}

	return self;
}

#pragma mark - Lifecycle (Setup/Update)


#pragma mark - Properties Getters

- (BOOL)inRouteMode
{
	return self.currentRoute != nil;
}

#pragma mark - Properties Setters


#pragma mark - Public Interface

- (void)addAnnotation:(id<MKAnnotation>)annotation
{
	NSAssert([annotation conformsToProtocol:@protocol(MKAnnotation)], @"annotation doesn't conform to protocol MKAnnotation");

	[self.annotations addObject:annotation];
	[self.mapView addAnnotation:annotation];
}

- (void)addAnnotations:(NSArray *)annotations
{
	[annotations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		[self addAnnotation:obj];
	}];
}

- (void)removeAnnotation:(id<MKAnnotation>)annotation
{
	[self.annotations removeObject:annotation];
	if ([self.mapView.annotations containsObject:annotation]) {
		[self clearRoute];
	}
	[self.mapView removeAnnotation:annotation];
}

- (void)updateAnnotationsOnMap
{
	[self.mapView removeAnnotations:self.mapView.annotations];
	[self.mapView addAnnotations:[self.annotations array]];
}

- (void)centerMapAtLocation:(CLLocation *)location
{
	CGFloat regionSideSize = 100000; // 100km
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, regionSideSize, regionSideSize);
	[self.mapView setRegion:region animated:YES];
}

- (void)buildRouteToAnnotation:(id<MKAnnotation>)annotation completion:(void (^)(BOOL))completion
{
	NSAssert([annotation conformsToProtocol:@protocol(MKAnnotation)], @"annotation doesn't conform to MKAnnotation protocol");

	void (^wrapCompletion)(BOOL status) = ^(BOOL status) {
		if (completion) {
			completion(status);
		}
	};

	[self clearRoute]; // clear out any existing route
	[self removeAnnotationsOnMapExceptThis:annotation];

	MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
	directionsRequest.source = [MKMapItem mapItemForCurrentLocation];

	MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:[annotation coordinate] addressDictionary:nil];
	directionsRequest.destination = [[MKMapItem alloc] initWithPlacemark:placemark];
	directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;

	MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
	[directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
		if (error) {
			[self clearRoute];
			wrapCompletion(NO);
		} else {
			[self setActiveRoute:response.routes.lastObject];
			wrapCompletion(YES);
		}
	}];
}

- (void)setActiveRoute:(MKRoute *)route
{
	self.currentRoute = route;
	[self.mapView addOverlay:self.currentRoute.polyline];
	if (self.routeStatusBlock) {
		self.routeStatusBlock(YES);
	}
}

- (void)clearRoute
{
	[self.mapView removeOverlay:self.currentRoute.polyline];
	self.currentRoute = nil;
	[self updateAnnotationsOnMap];
	if (self.routeStatusBlock) {
		self.routeStatusBlock(NO);
	}
}

- (void)removeAnnotationsOnMapExceptThis:(id<MKAnnotation>)aAnnotation
{
	NSArray *annotations = self.mapView.annotations.reject(^BOOL(id<MKAnnotation> annotation){
		return [annotation isEqual:aAnnotation];
	});
	[self.mapView removeAnnotations:annotations];
}

#pragma mark - Private methods

- (void)onShowBookmarkDetails:(UIButton *)sender
{
	id<MKAnnotation> annotation = [self.mapView.selectedAnnotations firstObject];
	if (annotation && self.annotationOnDetailsBlock) {
		self.annotationOnDetailsBlock(annotation);
	}
	[self.mapView deselectAnnotation:annotation animated:YES];
}

- (void)onBuildRouteToBookmark:(UIButton *)sender
{
	id<MKAnnotation> annotation = [self.mapView.selectedAnnotations firstObject];
	if (annotation && self.annotationOnRouteBlock) {
		self.annotationOnRouteBlock(annotation);
	}
	[self.mapView deselectAnnotation:annotation animated:YES];
}

#pragma mark - MapView Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
		MKAnnotationView *userLocation = [mapView dequeueReusableAnnotationViewWithIdentifier:@"User"];
		if (!userLocation) {
			userLocation = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"User"];
			userLocation.image = [UIImage imageNamed:@"icon_user"];
		} else {
			userLocation.annotation = annotation;
		}
		return userLocation;
	} else {
		MKAnnotationView *pinView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Bookmark"];
		if (!pinView) {
			pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Bookmark"];
			pinView.canShowCallout = YES;
			pinView.image = [UIImage imageNamed:@"icon_bookmark"];
			pinView.centerOffset = CGPointMake(0.0, -8.0);
			pinView.rightCalloutAccessoryView = ({
				UIButton *details = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
				[details addTarget:self action:@selector(onShowBookmarkDetails:) forControlEvents:UIControlEventTouchUpInside];
				details;
			});
			pinView.leftCalloutAccessoryView = ({
				UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
				[button setImage:[UIImage imageNamed:@"icon_route_to"] forState:UIControlStateNormal];
				[button addTarget:self action:@selector(onBuildRouteToBookmark:) forControlEvents:UIControlEventTouchUpInside];
				[button sizeToFit];
				button;
			});
		} else {
			pinView.annotation = annotation;
		}
		return pinView;
	}
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	if (userLocation) {
		[mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
		[self centerMapAtLocation:userLocation.location];
	}
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
	MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:self.currentRoute.polyline];
	renderer.strokeColor = [UIColor blueColor];
	renderer.lineWidth = 3;
	return renderer;
}

@end
