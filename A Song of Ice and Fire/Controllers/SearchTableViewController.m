//
//  SearchTableViewController.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/27.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "SearchTableViewController.h"

static NSString * const kCellIdentifier = @"Cell";

@interface SearchTableViewController ()
<UISearchBarDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSArray *allCities;
@property (strong, nonatomic) NSMutableArray *filteredCities;

@end

@implementation SearchTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _allCities = @[@"New York, NY", @"Los Angeles, CA", @"Chicago, IL", @"Houston, TX",
                       @"Philadelphia, PA", @"Phoenix, AZ", @"San Diego, CA", @"San Antonio, TX",
                       @"Dallas, TX", @"Detroit, MI", @"San Jose, CA", @"Indianapolis, IN",
                       @"Jacksonville, FL", @"San Francisco, CA", @"Columbus, OH", @"Austin, TX",
                       @"Memphis, TN", @"Baltimore, MD", @"Charlotte, ND", @"Fort Worth, TX"];
        _filteredCities = [_allCities mutableCopy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.contentInset = UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height, 0, 0, 0);
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;

    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar sizeToFit];

    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.searchController setActive:YES];

    // Become first responder but in the next run loop
    // Ref: http://stackoverflow.com/questions/22176773/dismiss-keyboard-when-pressing-x-in-uisearchbar
    [self.searchController.searchBar performSelector:@selector(becomeFirstResponder)
                                          withObject:nil
                                          afterDelay:0.0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (self.searchController.active) {
        self.searchController.active = NO;
        [self.searchController.searchBar removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.searchController.active) {
        return 1;
    } else {
        return self.filteredCities.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (self.searchController.active) {
        cell.textLabel.text = self.filteredCities[indexPath.row];
    } else {
        cell.textLabel.text = @"";
    }

    return cell;
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    [self.filteredCities removeAllObjects];

    NSString *searchString = searchController.searchBar.text;
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", searchString];
    self.filteredCities = [[self.allCities filteredArrayUsingPredicate:searchPredicate] mutableCopy];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
