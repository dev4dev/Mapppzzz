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
#import "BookmarksTableViewCell.h"
#import "CoreDataStack.h"
#import "BookmarkDetailsViewController.h"

#import <YOLOKit/YOLO.h>
#import <DXPopover/DXPopover.h>
#import <MMProgressHUD/MMProgressHUD.h>

static NSString *const kShowBookmarksListSegueIdentifier = @"ShowBookmarksList";
static NSString *const kShowBookmarkDetailsSegueIdentifier = @"ShowBookmarkDetails";

@interface MapViewController ()
	<CLLocationManagerDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *routeBarItem;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) BookmarksViewModel *viewModel;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) DXPopover *popover;
@property (nonatomic, assign) BOOL inRouteMode;

@property (nonatomic, strong) NSFetchedResultsController *fetchController;

@property (nonatomic, strong) MKRoute *currentRoute;

@end

@implementation MapViewController

#pragma mark - Init & Dealloc


#pragma mark - Lifecycle (Setup/Update)

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	_inRouteMode = NO;
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

- (UITableView *)tableView
{
	if (_tableView) {
		return _tableView;
	}

	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds) - 20.0, 250.0)];
	_tableView.tableFooterView = [UIView new];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[_tableView registerNib:[UINib nibWithNibName:@"BookmarksTableViewCell" bundle:nil] forCellReuseIdentifier:@"BookmarkCell"];
	return _tableView;
}

- (DXPopover *)popover
{
	if (_popover) {
		return _popover;
	}

	_popover = [DXPopover popover];
	return _popover;
}

#pragma mark - Properties Setters

- (void)setInRouteMode:(BOOL)inRouteMode
{
	_inRouteMode = inRouteMode;
	if (inRouteMode) {
		self.routeBarItem.title = @"Clear Route";
	} else {
		self.routeBarItem.title = @"Route";
	}
}

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

- (void)
removeAnnotationsOnMapExceptThis:(BookmarkViewModel *)bookmark
{
	NSArray *annotations = self.mapView.annotations.reject(^BOOL(BookmarkViewModel *annotation){
		return [annotation isEqual:bookmark];
	});
	[self.mapView removeAnnotations:annotations];
}

- (void)
configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	if ([cell isKindOfClass:[BookmarksTableViewCell class]]) {
		BookmarksTableViewCell *bCell = (BookmarksTableViewCell *)cell;
		Bookmark *bookmark = [self.fetchController objectAtIndexPath:indexPath];

		bCell.viewModel = [[BookmarkViewModel alloc] initWithModel:bookmark];
	}
}

- (void)buildRouteToBookmark:(BookmarkViewModel *)bookmark
{
	[self clearRoute]; // clear out any existing route

	[MMProgressHUD showWithTitle:@"Building route to..." status:bookmark.title];
	self.inRouteMode = YES;
	[self removeAnnotationsOnMapExceptThis:bookmark];

	MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
	directionsRequest.source = [MKMapItem mapItemForCurrentLocation];

	MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:bookmark.location.coordinate addressDictionary:nil];
	directionsRequest.destination = [[MKMapItem alloc] initWithPlacemark:placemark];
	directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;

	MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
	[directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
		[MMProgressHUD dismiss];
		if (error) {
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Error while getting directions..." preferredStyle:UIAlertControllerStyleAlert];
			[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
			[self presentViewController:alert animated:YES completion:nil];
			[self clearRoute];
		} else {
			self.currentRoute = response.routes.lastObject;
			[self.mapView addOverlay:self.currentRoute.polyline];
		}
	}];
}

- (void)clearRoute
{
	self.inRouteMode = NO;
	[self.mapView removeOverlay:self.currentRoute.polyline];
	[self updateAnnotationsOnMap];
}

- (void)centerMapAtLocation:(CLLocation *)location
{
	CGFloat regionSideSize = 100000; // 100km
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, regionSideSize, regionSideSize);
	[self.mapView setRegion:region animated:YES];
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

- (void)onShowBookmarkDetails:(UIButton *)sender
{
	BookmarkViewModel *viewModel = [self.mapView.selectedAnnotations firstObject];
	if (viewModel) {
		[self performSegueWithIdentifier:kShowBookmarkDetailsSegueIdentifier sender:viewModel];
	}
	[self.mapView deselectAnnotation:[self.mapView.selectedAnnotations firstObject] animated:YES];
}

- (void)onBuildRouteToBookmark:(UIButton *)sender
{
	BookmarkViewModel *viewModel = [self.mapView.selectedAnnotations firstObject];
	if (viewModel) {
		[self buildRouteToBookmark:viewModel];
	}
	[self.mapView deselectAnnotation:[self.mapView.selectedAnnotations firstObject] animated:YES];
}

- (IBAction)unwindToMapController:(UIStoryboardSegue *)segue
{
	if ([segue.sourceViewController isKindOfClass:[BookmarkDetailsViewController class]]) {
		BookmarkDetailsViewController *vc = segue.sourceViewController;
		BookmarkViewModel *viewModel = vc.viewModel;
		switch (vc.action) {
			case DetailsActionNone: {
				// do nothing
				break;
			}
			case DetailsActionCenterMap: {
				[self centerMapAtLocation:viewModel.location];
				break;
			}
			case DetailsActionBuildRoute: {
				[self buildRouteToBookmark:viewModel];
				break;
			}
			default: {
				break;
			}
		}
	}
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

- (IBAction)onRouteButtonTap:(id)sender event:(UIEvent *)event
{
	if (self.inRouteMode) {
		[self clearRoute];
	} else {
		UITouch *touch = [event.allTouches anyObject];
		[self.popover showAtView:touch.view withContentView:self.tableView];
	}
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
			Bookmark *bookmark = [self.fetchController objectAtIndexPath:indexPath];
			BookmarkViewModel *viewModel = [[BookmarkViewModel alloc] initWithModel:bookmark];
			if (self.inRouteMode && [self.mapView.annotations containsObject:viewModel]) {
				[self clearRoute];
			}
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

#pragma mark - TableView DD

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.fetchController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [tableView dequeueReusableCellWithIdentifier:@"BookmarkCell" forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self configureCell:cell atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	Bookmark *bookmark = [self.fetchController objectAtIndexPath:indexPath];
	[self buildRouteToBookmark:[[BookmarkViewModel alloc] initWithModel:bookmark]];
	[self.popover dismiss];
}

@end
