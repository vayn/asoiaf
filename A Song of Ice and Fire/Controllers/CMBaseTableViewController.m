//
//  CMBaseTableViewController.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/4.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "CMBaseTableViewController.h"
#import "Spinner.h"

#import "UIColor+Hexadecimal.h"
#import "UIScrollView+EmptyDataSet.h"

@interface CMBaseTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, getter=isLoading) BOOL loading;

@end

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
    self.tableView.tableFooterView = [UIView new];

    // Pull to refresh setting
    [self setupRefresh];

    // Show empty datasets whenever the view has no content to display
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
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

#pragma mark - DZNEmptyDataSetSource Methods

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSMutableDictionary *attributes = [NSMutableDictionary new];

    NSString *text = @"暂无内容";
    UIFont *font = [UIFont systemFontOfSize:20.0];
    UIColor *textColor = [UIColor colorWithHex:@"808080"];

    [attributes setObject:font forKey:NSFontAttributeName];
    [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{

    NSMutableDictionary *attributes = [NSMutableDictionary new];

    NSString *text = @"你已到达阴影之地";
    UIFont *font = [UIFont systemFontOfSize:15.0];
    UIColor *textColor = [UIColor colorWithHex:@"989898"];

    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;

    [attributes setObject:font forKey:NSFontAttributeName];
    [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    [attributes setObject:paragraph forKey:NSParagraphStyleAttributeName];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];

    return attributedString;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *imageName = @"placeholder_emptydataset";

    return [UIImage imageNamed:imageName];
}

- (CAAnimation *)imageAnimationForEmptyDataSet:(UIScrollView *)scrollView
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D: CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0) ];
    animation.duration = 0.25;
    animation.cumulative = YES;
    animation.repeatCount = MAXFLOAT;
    
    return animation;
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIColor colorWithHex:@"f2f2f2"];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -48.0;
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView
{
    return 0.0;
}

#pragma mark - DZNEmptyDataSetDelegate Methods



- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

- (BOOL)emptyDataSetShouldAnimateImageView:(UIScrollView *)scrollView
{
    return self.isLoading;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view
{
    self.loading = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.loading = NO;
    });
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button
{
    self.loading = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.loading = NO;
    });
}

@end
