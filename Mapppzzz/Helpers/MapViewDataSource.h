//
//  MapViewDataSource.h
//  Mapppzzz
//
//  Created by Alex Antonyuk on 9/6/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

typedef NS_ENUM(NSInteger, MapViewDataSourceOperation) {
	MapViewDataSourceOperationAdded,
	MapViewDataSourceOperationDeleted
};

typedef void(^MapViewDataSourceAnnotationBlock)(id<MKAnnotation> annotation);
typedef void(^MapViewDataSourceStatusBlock)(BOOL status);
typedef void(^MapViewDataSourceChangesBlock)(MapViewDataSourceOperation operation, id<MKAnnotation> annotation);

@interface MapViewDataSource : NSObject

@property (nonatomic, strong, readonly) NSMutableOrderedSet *annotations;
@property (nonatomic, assign, readonly) BOOL inRouteMode;

@property (nonatomic, copy) MapViewDataSourceAnnotationBlock annotationOnDetailsBlock;
@property (nonatomic, copy) MapViewDataSourceAnnotationBlock annotationOnRouteBlock;
@property (nonatomic, copy) MapViewDataSourceStatusBlock routeStatusBlock;
@property (nonatomic, copy) MapViewDataSourceChangesBlock changesBlock;

- (instancetype)initWithMapView:(MKMapView *)mapView;

#pragma mark - Annotations
- (void)addAnnotation:(id<MKAnnotation>)annotation;
- (void)addAnnotations:(NSArray *)annotations;
- (void)removeAnnotation:(id<MKAnnotation>)annotation;
- (void)removeAnnotationsOnMapExceptThis:(id<MKAnnotation>)aAnnotation;
- (void)updateAnnotationsOnMap;

- (void)centerMapAtLocation:(CLLocation *)location;

#pragma mark - Route
- (void)buildRouteToAnnotation:(id<MKAnnotation>)annotation completion:(void(^)(BOOL status))completion;
- (void)setActiveRoute:(MKRoute *)route;
- (void)clearRoute;

@end
