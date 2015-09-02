//
//  ViewController.m
//  Mapppzzz
//
//  Created by Alex Antonyuk on 8/31/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import "MapViewController.h"
@import CoreLocation;
@import MapKit;

#import "BookmarksListViewController.h"
#import "BookmarksViewModel.h"
#import "BookmarkViewModel.h"
#import "BookmarkViewModel+MapKit.h"
#import "CoreDataStack.h"
#import <YOLOKit/YOLO.h>
#import "BookmarkDetailsViewController.h"

static NSString *const kShowBookmarksListSegueIdentifier = @"ShowBookmarksList";
static NSString *const kShowBookmarkDetailsSegueIdentifier = @"ShowBookmarkDetails";

@interface MapViewController ()
	<CLLocationManagerDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *routeBarItem;

@property (nonatomic, strong) BookmarksViewModel *viewModel;
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) NSFetchedResultsController *fetchController;

@end

@implementation MapViewController

#pragma mark - Init & Dealloc


#pragma mark - Lifecycle (Setup/Update)

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	self.viewModel = [[BookmarksViewModel alloc] initWithCoreDataStack:[CoreDataStack sharedStack]];
	[self setupLocationManager];
	[self setupData];
	[self updateAnnotationsOnMap];
}

- (void)setupData
{
	self.fetchController = [self.viewModel bookmarksFetchedresultController];
	self.fetchController.delegate = self;
	[self.fetchController performFetch:nil];
}

#pragma mark - Properties Getters


#pragma mark - Properties Setters


#pragma mark - Public Interface


#pragma mark - Private methods

- (void)setupLocationManager
{
	self.locationManager = [CLLocationManager new];
	self.locationManager.delegate = self;

	CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
	if (status == kCLAuthorizationStatusNotDetermined) {
		[self.locationManager requestWhenInUseAuthorization];
	} else if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Hooray" message:@"NSA can't track you. You can enable location service in settings" preferredStyle:UIAlertControllerStyleAlert];
		[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
		[alert addAction:[UIAlertAction actionWithTitle:@"Settings..." style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
		}]];
		[self presentViewController:alert animated:YES completion:nil];
	}
}

- (void)
updateAnnotationsOnMap
{
	[self.mapView removeAnnotations:self.mapView.annotations];

	NSArray *annotations = self.fetchController.fetchedObjects.map(^(Bookmark *bookmark){
		return [[BookmarkViewModel alloc] initWithModel:bookmark];
	});
	[self.mapView addAnnotations:annotations];
}

#pragma mark - UI Actions

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:kShowBookmarksListSegueIdentifier]) {
		BookmarksListViewController *vc = segue.destinationViewController;
		vc.viewModel = self.viewModel;
	} else if ([segue.identifier isEqualToString:kShowBookmarkDetailsSegueIdentifier]) {
		BookmarkDetailsViewController *vc = segue.destinationViewController;
		vc.unwindDestination = UnwindToMap;
		vc.viewModel = sender;
	}
}

- (void)showBookmarkDetails:(UIButton *)sender
{
	BookmarkViewModel *viewModel = [self.mapView.selectedAnnotations firstObject];
	if (viewModel) {
		[self performSegueWithIdentifier:kShowBookmarkDetailsSegueIdentifier sender:viewModel];
	}
}

- (IBAction)unwindToMapController:(UIStoryboardSegue *)segue
{
	
}

- (IBAction)onMapLongTap:(UILongPressGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateBegan) {
		CGPoint tapPoint = [gesture locationInView:self.mapView];
		CLLocationCoordinate2D coordinates = [self.mapView convertPoint:tapPoint toCoordinateFromView:self.mapView];
		CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinates
															 altitude:0
												   horizontalAccuracy:0
													 verticalAccuracy:0
															timestamp:[NSDate date]];
		[self.viewModel addBookmarkWithName:nil atLocation:location];
	}
}

- (IBAction)onRouteButtonTap:(id)sender
{
	NSLog(@"show popup");
}

#pragma mark - LocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
	NSLog(@"did change %d", status);
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
		MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Bookmark"];
		if (!pinView) {
			pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Bookmark"];
			pinView.canShowCallout = YES;
			pinView.animatesDrop = YES;
			pinView.pinColor = MKPinAnnotationColorRed;
			pinView.rightCalloutAccessoryView = ({
				UIButton *details = [UIButton buttonWithType:UIButtonTypeInfoDark];
				[details addTarget:self action:@selector(showBookmarkDetails:) forControlEvents:UIControlEventTouchUpInside];
				details;
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
	}
}

#pragma mark - Fetched Result Controller

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	switch (type) {
		case NSFetchedResultsChangeInsert: {
			Bookmark *bookmark = [self.fetchController objectAtIndexPath:newIndexPath];
			BookmarkViewModel *viewModel = [[BookmarkViewModel alloc] initWithModel:bookmark];
			[self.mapView addAnnotation:viewModel];
			break;
		}
		case NSFetchedResultsChangeDelete: {
			Bookmark *bookmark = [self.fetchController objectAtIndexPath:newIndexPath];
			BookmarkViewModel *viewModel = [[BookmarkViewModel alloc] initWithModel:bookmark];
			[self.mapView removeAnnotation:viewModel];
			break;
		}
		case NSFetchedResultsChangeUpdate: {

			break;
		}
		default: {
			break;
		}
	}
}

//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//	[self updateAnnotationsOnMap];
//}

@end
