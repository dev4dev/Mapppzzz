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
#import "BookmarkDetailsViewController.h"
#import "Constants.h"
#import "MapViewDataSource.h"
#import "MKMapView+Additions.h"

#import <YOLOKit/YOLO.h>
#import <MMProgressHUD/MMProgressHUD.h>
#import <WYPopoverController/WYPopoverController.h>

static NSString *const kShowBookmarksListSegueIdentifier = @"ShowBookmarksList";
static NSString *const kShowBookmarkDetailsSegueIdentifier = @"ShowBookmarkDetails";

@interface MapViewController ()

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *routeBarItem;

@property (nonatomic, strong) BookmarksViewModel *viewModel;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) WYPopoverController *popover;

@property (nonatomic, strong) MapViewDataSource *mapViewDataSource;

@end

@implementation MapViewController

#pragma mark - Init & Dealloc

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onBookmarkDeleteNotification:) name:kBookmarkDeletedNotification object:nil];
	}

	return self;
}

#pragma mark - Lifecycle (Setup/Update)

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	[self setupBookmarksViewModel];
	[self setupMapViewDataSource];

	[self setupLocationManager];
	[self setupData];
}

- (void)setupData
{
	NSArray *annotations = [self.viewModel bookmarks].map(^(Bookmark *bookmark){
		return [[BookmarkViewModel alloc] initWithModel:bookmark];
	});
	[self.mapViewDataSource addAnnotations:annotations];
	[self.mapViewDataSource updateAnnotationsOnMap];
}

- (void)setupBookmarksViewModel
{
	self.viewModel = [[BookmarksViewModel alloc] initWithCoreDataStack:[CoreDataStack sharedStack]];
}

- (void)setupMapViewDataSource
{
	typeof(self) __weak wSelf = self;
	self.mapViewDataSource = [[MapViewDataSource alloc] initWithMapView:self.mapView];
	self.mapViewDataSource.annotationOnDetailsBlock = ^(id<MKAnnotation> annotation) {
		[wSelf performSegueWithIdentifier:kShowBookmarkDetailsSegueIdentifier sender:annotation];
	};
	self.mapViewDataSource.annotationOnRouteBlock = ^(id<MKAnnotation> annotation) {
		[wSelf buildRouteToAnnotation:annotation];
	};
	self.mapViewDataSource.routeStatusBlock = ^(BOOL status) {
		if (status) {
			wSelf.routeBarItem.title = @"Clear Route";
		} else {
			wSelf.routeBarItem.title = @"Route";
		}
	};
}

#pragma mark - Properties Getters


#pragma mark - Properties Setters


#pragma mark - Public Interface


#pragma mark - Private methods

- (void)setupLocationManager
{
	self.locationManager = [CLLocationManager new];

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

- (void)buildRouteToAnnotation:(id<MKAnnotation>)annotation
{
	typeof(self) __weak wSelf = self;
	[MMProgressHUD showWithTitle:@"Building route to..." status:[annotation title]];
	[self.mapViewDataSource buildRouteToAnnotation:annotation completion:^(BOOL status) {
		[MMProgressHUD dismiss];
		if (!status) {
			UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Error while getting directions..." preferredStyle:UIAlertControllerStyleAlert];
			[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
			[wSelf presentViewController:alert animated:YES completion:nil];
		}
	}];
}

- (void)showPopoverWithBookmarksFromBarItem:(UIBarButtonItem *)barItem
{
	typeof(self) __weak wSelf = self;
	BookmarksListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"BookmarksListViewController"];
	vc.viewModel = self.viewModel;
	vc.bookmarkSelectedBlock = ^(BookmarkViewModel *viewModel) {
		[wSelf.popover dismissPopoverAnimated:YES completion:^{
			[wSelf buildRouteToAnnotation:viewModel];
		}];
	};
	self.popover = [[WYPopoverController alloc] initWithContentViewController:vc];
	[self.popover presentPopoverFromBarButtonItem:barItem permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
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
				[self.mapViewDataSource centerMapAtLocation:viewModel.location];
				break;
			}
			case DetailsActionBuildRoute: {
				[self buildRouteToAnnotation:viewModel];
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
		if (self.mapViewDataSource.inRouteMode) {
			return;
		}
		BookmarkViewModel *viewModel = [self.viewModel addBookmarkWithName:nil atLocation:[self.mapView locationFromGesture:gesture]];
		[self.mapViewDataSource addAnnotation:viewModel];
	}
}

- (IBAction)onRouteButtonTap:(id)sender
{
	if (self.mapViewDataSource.inRouteMode) {
		[self.mapViewDataSource clearRoute];
	} else {
		[self showPopoverWithBookmarksFromBarItem:sender];
	}
}

- (void)onBookmarkDeleteNotification:(NSNotification *)notification
{
	BookmarkViewModel *viewModel = notification.object;
	[self.mapViewDataSource removeAnnotation:viewModel];
}

@end
