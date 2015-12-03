//
//  PageViewController.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/23.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "PageViewController.h"
#import "WikiViewController.h"

#import "Models.h"
#import "DataManager.h"

#import "MJRefresh.h"

@interface PageViewController ()

@property (nonatomic, strong) NSArray<CategoryMemberModel *> *pages;
@property (nonatomic, assign) BOOL isHeaderRefreshing;

@end

@implementation PageViewController

- (void)setParentCategory:(CategoryMemberModel *)parentCategory
{
    self.navigationItem.title = parentCategory.title;
    _parentCategory = parentCategory;

    _nextContinue = [@[] mutableCopy];
    _previousContinue = [@[] mutableCopy];

    [[DataManager sharedManager] getPagesWithCategory:parentCategory.link parameters:nil completionBlock:^(CategoryMembersModel *members) {
        _pages = members.members;

        if (members.cmcontinue) {
            [_nextContinue addObject:members.cmcontinue];
        }

        if (_pages.count > 0) {
            [self.tableView reloadData];
        }
    }];
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
    return self.pages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    CategoryMemberModel *page = self.pages[indexPath.row];
    cell.textLabel.text = page.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryMemberModel *page = self.pages[indexPath.row];

    WikiViewController *wikiVC = [[WikiViewController alloc] init];
    wikiVC.title = page.title;

    [self.parentVC.navigationController pushViewController:wikiVC animated:YES];
}

/* *
 * Get notified when UITableView has finished asking for data
 *
 * Reference: http://dwz.cn/reloaddata
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.row == self.pages.count-1) && self.isHeaderRefreshing) {
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

        [[DataManager sharedManager]
         getPagesWithCategory:self.parentCategory.link parameters:parameters completionBlock:^(CategoryMembersModel *members) {
             if (members.cmcontinue) {
                 [self.nextContinue addObject:members.cmcontinue];
             }

             NSArray *pages = members.members;
             if (pages.count > 0) {
                 self.pages = pages;
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
            NSDictionary *paramerters = @{@"cmcontinue": continueString};

            [[DataManager sharedManager]
             getPagesWithCategory:self.parentCategory.link parameters:paramerters completionBlock:^(CategoryMembersModel *members) {
                 if (members.cmcontinue) {
                     [self.nextContinue addObject:members.cmcontinue];
                 }

                 NSArray *pages = members.members;
                 if (pages.count > 0) {
                     self.pages = pages;
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
