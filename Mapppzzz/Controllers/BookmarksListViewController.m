//
//  BookmarksListViewController.m
//  Mapppzzz
//
//  Created by Alex Antonyuk on 8/31/15.
//  Copyright (c) 2015 Alex Antonyuk. All rights reserved.
//

#import "BookmarksListViewController.h"
#import "BookmarksViewModel.h"
#import "BookmarksTableViewCell.h"
#import "BookmarkDetailsViewController.h"
#import "BookmarkViewModel.h"

static NSString *const kDetailsSegueIdentifier = @"BookmarkDetails";

@interface BookmarksListViewController ()
	<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSFetchedResultsController *resultsController;

@end

@implementation BookmarksListViewController

#pragma mark - Init & Dealloc


#pragma mark - Lifecycle (Setup/Update)

- (void)viewDidLoad
{
	[super viewDidLoad];

	[self setupView];
	[self setupData];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)setupView
{
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)setupData
{
	self.resultsController = [self.viewModel bookmarksFetchedresultController];
	self.resultsController.delegate = self;
	[self.resultsController performFetch:nil];
}

#pragma mark - Properties Getters


#pragma mark - Properties Setters


#pragma mark - Public Interface


#pragma mark - Private methods

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
	[super setEditing:editing animated:animated];

	[self.tableView setEditing:editing animated:animated];
}

- (void)
configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	if ([cell isKindOfClass:[BookmarksTableViewCell class]]) {
		BookmarksTableViewCell *bCell = (BookmarksTableViewCell *)cell;
		Bookmark *bookmark = [self.resultsController objectAtIndexPath:indexPath];

		bCell.viewModel = [[BookmarkViewModel alloc] initWithModel:bookmark];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"BookmarkDetails"]) {
		NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
		BookmarksTableViewCell *cell = (BookmarksTableViewCell *)[self.tableView cellForRowAtIndexPath:selectedIndexPath];

		BookmarkDetailsViewController *detailsVC = segue.destinationViewController;
		detailsVC.unwindDestination = UnwindToList;
		detailsVC.viewModel = cell.viewModel;
	}
}

- (IBAction)unwindToBookmarksList:(UIStoryboardSegue *)segue
{
	
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	id<NSFetchedResultsSectionInfo> s = [self.resultsController.sections firstObject];
	return [s numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [tableView dequeueReusableCellWithIdentifier:@"BookmarkCell" forIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self configureCell:cell atIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		BookmarksTableViewCell *cell = (BookmarksTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
		[cell.viewModel deleteModel];
	}
}

#pragma mark - NSFetchedResultsController Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	switch (type) {
		case NSFetchedResultsChangeInsert: {
			[self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
		}
		case NSFetchedResultsChangeDelete: {
			[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
		}
		case NSFetchedResultsChangeMove: {
			[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			[self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
		}
		case NSFetchedResultsChangeUpdate: {
			[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			break;
		}
		default: {
			break;
		}
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self.tableView endUpdates];
}

@end
