//
//  BookmarkDetailsViewController.m
//  Mapppzzz
//
//  Created by Alex Antonyuk on 8/31/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import "BookmarkDetailsViewController.h"
#import "BookmarkViewModel.h"
#import "Constants.h"
#import "FoursquareClient.h"
#import "PlaceModel.h"

@interface BookmarkDetailsViewController ()
	<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) DetailsAction action;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UIView *tableContainer;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, strong) NSArray *places;

@end

@implementation BookmarkDetailsViewController

#pragma mark - Init & Dealloc

- (instancetype)init
{
	if (self = [super init]) {
		_action = DetailsActionNone;
	}

	return self;
}

#pragma mark - Lifecycle (Setup/Update)

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self setupView];
	[self updateView];

	if (![self.viewModel isNamed]) {
		[self loadNearbyPlace];
	}
}

#pragma mark - Properties Getters


#pragma mark - Properties Setters

- (void)setPlaces:(NSArray *)places
{
	_places = places;
	[self.tableView reloadData];
}

#pragma mark - Public Interface


#pragma mark - Private methods

- (void)
configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row < self.places.count) {
		PlaceModel *place = self.places[indexPath.row];
		cell.textLabel.text = place.name;
	}
}

- (void)setupView
{
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"PlaceCell"];

	UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
																				  target:self
																				  action:@selector(onDeleteBookmark:)];

	UIBarButtonItem *actionsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																				   target:self
																				   action:@selector(onActions:)];
	self.navigationItem.rightBarButtonItems = @[deleteButton, actionsButton];
}

- (void)updateView
{
	self.title = self.viewModel.name;
	self.nameLabel.text = self.viewModel.name;
	self.tableContainer.hidden = [self.viewModel isNamed];
}

- (void)loadNearbyPlace
{
	self.tableContainer.hidden = YES;
	[self.loadingIndicator startAnimating];
	[[FoursquareClient sharedClient] searchPlacesNearLocation:self.viewModel.location completion:^(NSArray *places, NSError *error) {
		self.places = places;
		self.tableContainer.hidden = NO;
		[self.loadingIndicator stopAnimating];
	}];
}

- (void)centerMapToBookmark
{
	self.action = DetailsActionCenterMap;
	[self performSegueWithIdentifier:kToMapSegueIdentifier sender:self];
}

- (void)buildRouteToBookmark
{
	self.action = DetailsActionBuildRoute;
	[self performSegueWithIdentifier:kToMapSegueIdentifier sender:self];
}

#pragma mark - UI Actions

- (IBAction)onDeleteBookmark:(id)sender
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Do you really want to delete this nice bookmark?" preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
		[self.viewModel deleteModel];
		switch (self.unwindDestination) {
			case UnwindToMap: {
				[self performSegueWithIdentifier:kToMapSegueIdentifier sender:self];
				break;
			}
			case UnwindToList: {
				[self performSegueWithIdentifier:kToListSegueIdentifier sender:self];
				break;
			}
		}
	}]];
	[alert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)onLoadNearbyPlaces:(UIButton *)sender
{
	sender.hidden = YES;
	[self loadNearbyPlace];
}

- (IBAction)onActions:(UIBarButtonItem *)sender
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	[alert addAction:[UIAlertAction actionWithTitle:@"Center in map view" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[self centerMapToBookmark];
	}]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Build route to..." style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[self buildRouteToBookmark];
	}]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	[self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - TableView DD

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.places.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [tableView dequeueReusableCellWithIdentifier:@"PlaceCell" forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self configureCell:cell atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (indexPath.row < self.places.count) {
		PlaceModel *place = self.places[indexPath.row];
		if (![self.viewModel isNamed]) {
			[self.viewModel updateBookmarkWithPlace:place];
			[self updateView];
		}
	}
}

@end
