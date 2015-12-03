//
//  CMBaseTableViewController.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/4.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "CMBaseTableViewController.h"

@implementation CMBaseTableViewController

- (void)setParentCategory:(CategoryMemberModel *)parentCategory
{
    self.navigationItem.title = parentCategory.title;
    _parentCategory = parentCategory;

    _nextContinue = [@[] mutableCopy];
    _previousContinue = [@[] mutableCopy];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];

    // Remove empty cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    // Pull to refresh setting
    [self setupRefresh];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    CategoryMemberModel *member = self.members[indexPath.row];
    cell.textLabel.text = member.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryMemberModel *member = self.members[indexPath.row];

    WikiViewController *wikiVC = [[WikiViewController alloc] init];
    wikiVC.title = member.title;

    [self.parentVC.navigationController pushViewController:wikiVC animated:YES];
}

/* *
 * Get notified when UITableView has finished asking for data
 *
 * Reference: http://dwz.cn/reloaddata
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.row == self.members.count-1) && self.isHeaderRefreshing) {
        [self.tableView.mj_footer resetNoMoreData];
    }
}

#pragma mark - Private methods

- (void)setupRefresh
{
    // 下拉加载上一页
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.isHeaderRefreshing = YES;

        NSDictionary *parameters;

        if (self.previousContinue.count > 1) {
            NSString *continueString = [self.previousContinue lastObject];
            [self.previousContinue removeLastObject];
            parameters = @{@"cmcontinue": continueString};
        } else {
            if (self.previousContinue.count == 1) {
                [self.previousContinue removeLastObject];
            }
            parameters = @{@"cmcontinue": @""};
        }

        [self.delegate getMembersWithCategory:self.parentCategory.link parameters:parameters completionBlock:^(CategoryMembersModel *members) {
             if (members.cmcontinue) {
                 [self.nextContinue addObject:members.cmcontinue];
             }

             NSArray *membersArray = members.members;
             if (membersArray.count > 0) {
                 self.members = membersArray;
                 [self.tableView reloadData];
             }
        }];

        [self.tableView.mj_header endRefreshing];
    }];

    // 上拉加载下一页
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.isHeaderRefreshing = NO;

        if (self.nextContinue.count > 0) {
            NSString *continueString = [self.nextContinue lastObject];
            [self.nextContinue removeLastObject];

            [self.previousContinue addObject:continueString];
            NSDictionary *parameters = @{@"cmcontinue": continueString};

            [self.delegate getMembersWithCategory:self.parentCategory.link parameters:parameters completionBlock:^(CategoryMembersModel *members) {
                 if (members.cmcontinue) {
                     [self.nextContinue addObject:members.cmcontinue];
                 }

                 NSArray *membersArray = members.members;
                 if (membersArray.count > 0) {
                     self.members = membersArray;
                     [self.tableView reloadData];
                 }

                 if (self.nextContinue.count == 0) {
                     [self.tableView.mj_footer endRefreshingWithNoMoreData];
                 } else {
                     [self.tableView.mj_footer endRefreshing];
                 }
             }];
        } else {
            // 没有更多数据的状态
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    }];
}

@end
