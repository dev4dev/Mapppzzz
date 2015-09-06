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
#import <DXPopover/DXPopover.h>
#import <MMProgressHUD/MMProgressHUD.h>

static NSString *const kShowBookmarksListSegueIdentifier = @"ShowBookmarksList";
static NSString *const kShowBookmarkDetailsSegueIdentifier = @"ShowBookmarkDetails";

@interface MapViewController ()
	<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *routeBarItem;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) BookmarksViewModel *viewModel;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) DXPopover *popover;

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
	typeof(self) __weak wSelf = self;
	self.viewModel = [[BookmarksViewModel alloc] initWithCoreDataStack:[CoreDataStack sharedStack]];
	self.viewModel.bookmarksChangedBlock = ^{
		[wSelf.tableView reloadData];
	};
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
	self.mapViewDataSource.changesBlock = ^(MapViewDataSourceOperation operation, id<MKAnnotation> annotation) {
		[wSelf.tableView reloadData];
	};
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

- (IBAction)onRouteButtonTap:(id)sender event:(UIEvent *)event
{
	if (self.mapViewDataSource.inRouteMode) {
		[self.mapViewDataSource clearRoute];
	} else {
		UITouch *touch = [event.allTouches anyObject];
		[self.popover showAtView:touch.view withContentView:self.tableView];
	}
}

- (void)onBookmarkDeleteNotification:(NSNotification *)notification
{
	BookmarkViewModel *viewModel = notification.object;
	[self.mapViewDataSource removeAnnotation:viewModel];
}

#pragma mark - TableView DD

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.mapViewDataSource.annotations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [tableView dequeueReusableCellWithIdentifier:@"BookmarkCell" forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([cell isKindOfClass:[BookmarksTableViewCell class]]) {
		BookmarksTableViewCell *bCell = (BookmarksTableViewCell *)cell;
		bCell.viewModel = self.mapViewDataSource.annotations[indexPath.row];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self buildRouteToAnnotation:self.mapViewDataSource.annotations[indexPath.row]];
	[self.popover dismiss];
}

@end
