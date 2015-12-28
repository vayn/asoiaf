//
//  SearchTableViewController.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/27.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "SearchTableViewController.h"
#import "WikiViewController.h"

#import "DataManager.h"

static NSString * const kCellIdentifier = @"Cell";

@interface SearchTableViewController ()
<UISearchBarDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;

@end

@implementation SearchTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _searchResults = [@[] mutableCopy];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.textLabel.text = self.searchResults[indexPath.row][@"title"];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = self.searchResults[indexPath.row][@"title"];
    WikiViewController *wikiVC = [[WikiViewController alloc] init];
    wikiVC.title = title;
    wikiVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_button"]
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(homeButtonPressed:)];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:wikiVC];
    [self.searchController presentViewController:nav animated:YES completion:nil];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    if (searchController.searchBar.text.length == 0) {
        [self.searchResults removeAllObjects];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{

    [self.searchResults removeAllObjects];

    NSString *searchTerm = searchBar.text;

    [[MainManager sharedManager] searchWikiEntry:searchTerm completionBlock:^(NSArray *searchResults) {

        _searchResults = [searchResults mutableCopy];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });

    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Controller Actions

- (void)homeButtonPressed:(id)sender
{
    [self.searchController dismissViewControllerAnimated:YES completion:nil];
}

@end
