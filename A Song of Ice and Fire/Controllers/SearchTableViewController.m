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
#import "UIColor+Hexadecimal.h"

static NSString * const kCellIdentifier = @"Cell";

@interface SearchTableViewController ()
<UISearchBarDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) UILabel *noResultsLabel;

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
    self.searchController.searchBar.placeholder = @"搜索";
    [self.searchController.searchBar setValue:@"取消" forKey:@"_cancelButtonText"];
    [self.searchController.searchBar sizeToFit];

    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;

    [self setupLoadingIndicator];
    [self.view addSubview:self.loadingIndicator];

    [self setupNoResultsLabel];
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

#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    headerView.backgroundColor = [UIColor colorWithHex:@"#f7f7f7"];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectOffset(headerView.frame, 10, 2)];
    label.font = [UIFont systemFontOfSize:13];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    [headerView addSubview:label];

    return headerView;

}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"搜索结果";
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    if (searchController.searchBar.text.length == 0) {
        [self.searchResults removeAllObjects];

        if ([self.tableView.subviews containsObject:self.noResultsLabel]) {
            [self.noResultsLabel removeFromSuperview];
        }

        [self.tableView reloadData];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.loadingIndicator startAnimating];
    [self.searchResults removeAllObjects];

    NSString *searchTerm = searchBar.text;

    [[MainManager sharedManager] searchWikiEntry:searchTerm completionBlock:^(NSArray *searchResults) {

        self.searchResults = [searchResults mutableCopy];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.searchResults.count > 0) {
                [self.tableView reloadData];
            } else {
                [self.tableView addSubview:self.noResultsLabel];
            }

            [self.loadingIndicator stopAnimating];
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

#pragma mark - Custom Views

- (void)setupLoadingIndicator
{
    CGRect loadingIndicatorFrame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2,
                                              [UIScreen mainScreen].bounds.size.height / 2,
                                              20, 20);
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:loadingIndicatorFrame];
    _loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    _loadingIndicator.hidesWhenStopped = YES;
}

- (void)setupNoResultsLabel
{
    CGRect labelFrame = CGRectMake(0, 122, self.tableView.bounds.size.width, 20);
    _noResultsLabel = [[UILabel alloc] initWithFrame:labelFrame];
    _noResultsLabel.textAlignment = NSTextAlignmentCenter;
    _noResultsLabel.textColor = [UIColor colorWithHex:@"#cccccc"];
    _noResultsLabel.text = @"没有结果";
}

@end
