//
//  CMBaseTableViewController.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/4.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "CMBaseTableViewController.h"
#import "EmptyDataSetDelegate.h"
#import "Spinner.h"

static NSString * const kCellIdentifier = @"Cell";

@interface CMBaseTableViewController ()

@property (nonatomic, strong) EmptyDataSetDelegate *emptyDataSetDelegate;

@end

@implementation CMBaseTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _emptyDataSetDelegate = [[EmptyDataSetDelegate alloc] init];

        [[NSNotificationCenter defaultCenter]
         addObserverForName:@"getCategoryMember" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {

             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                 _emptyDataSetDelegate.loading = NO;
             });

             [self.tableView reloadData];
        }];
    }
    return self;
}

- (void)setParentCategory:(CategoryMemberModel *)parentCategory
{
    self.navigationItem.title = parentCategory.title;
    _parentCategory = parentCategory;

    _nextContinue = [@[] mutableCopy];
    _previousContinue = [@[] mutableCopy];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];

    // Remove empty cells
    self.tableView.tableFooterView = [UIView new];

    // Pull to refresh setting
    [self setupPullToRefresh];

    // Show empty datasets whenever the view has no content to display
    self.tableView.emptyDataSetSource = self.emptyDataSetDelegate;
    self.tableView.emptyDataSetDelegate = self.emptyDataSetDelegate;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.emptyDataSetDelegate.isLoading) {
        return 0;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.members.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryMemberModel *member = self.members[indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }

    cell.textLabel.text = member.title;

    return cell;
}

/* *
 * Get notified when UITableView has finished asking for data
 *
 * Reference: http://dwz.cn/reloaddata
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.row == self.members.count - 1) && self.isHeaderRefreshing) {
        [self.tableView.mj_footer resetNoMoreData];
    }
}

#pragma mark - Private methods

- (void)setupPullToRefresh
{
    /* *
     * 下拉加载上一页
     */
    MJRefreshSpinnerHeader *header = [MJRefreshSpinnerHeader headerWithRefreshingBlock:^{
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

                 // Reload data with animation
                 NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.tableView]);
                 NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
                 [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
             }
        }];

        [self.tableView.mj_header endRefreshing];
    }];

    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;

    // 设置正在刷新状态的动画图片
    [header setSpinner:[Spinner knightSpinner] forState:MJRefreshStateRefreshing];

    // 设置文字
    [header setTitle:@"上拉返回上一页" forState:MJRefreshStateIdle];

    self.tableView.mj_header = header;

    /* *
     * 上拉加载下一页
     */
     MJRefreshAutoSpinnerFooter *footer = [MJRefreshAutoSpinnerFooter footerWithRefreshingBlock:^{
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

                     NSRange range = NSMakeRange(0, [self numberOfSectionsInTableView:self.tableView]);
                     NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
                     [self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
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

    // 设置刷新图片
    [footer setSpinner:[Spinner knightSpinner] forState:MJRefreshStateRefreshing];

    // 设置文字
    [footer setTitle:@"上拉加载下一页" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在加载数据……" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"已经到达最后一页" forState:MJRefreshStateNoMoreData];

    self.tableView.mj_footer = footer;
}

@end
