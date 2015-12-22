//
//  KnowTipTableViewController.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/11.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "KnowTipTableViewController.h"
#import "WikiViewController.h"

#import "DataManager.h"
#import "Models.h"

#import "NSArray+Random.h"
#import "RegexKitLite.h"

@interface KnowTipTableViewController ()

@property (nonatomic, strong) NSMutableArray *tips;

@end

@implementation KnowTipTableViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tips = [@[] mutableCopy];

        [[MainManager sharedManager] getKnowTip:^(id responseObject) {
            NSString *bigTipString = [(NSArray *) responseObject randomObject];
            NSString *pattern = @"^\\*(.*?)……（\\[{2}(.*?)\\|";

            NSArray<NSString *> *tipList = [[bigTipString componentsSeparatedByString:@"\n"] filteredArrayUsingPredicate:
                                            [NSPredicate predicateWithFormat:@"length > 0"]];
            for (NSString *rawTip in tipList) {
                [rawTip enumerateStringsMatchedByRegex:pattern
                                               options:RKLNoOptions
                                               inRange:NSMakeRange(0, [rawTip length])
                                                 error:nil
                                    enumerationOptions:RKLRegexEnumerationNoOptions
                                            usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
                                                [_tips addObject:[[KnowTipModel alloc] initWithTip:capturedStrings[1]
                                                                                             title:capturedStrings[2]]];
                                            }];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tableViewCell"];
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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tips count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCell" forIndexPath:indexPath];

    KnowTipModel *tipModel = self.tips[indexPath.row];
    cell.textLabel.text = tipModel.tip;

    UIFont *myFont = [UIFont systemFontOfSize:14.0];
    cell.textLabel.font = myFont;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.numberOfLines = 0;

    CATransition *transition = [CATransition animation];
    transition.duration = 0.618;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [cell.layer addAnimation:transition forKey:nil];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 18)];
    label.font = [UIFont systemFontOfSize:17];
    label.text = [self tableView:tableView titleForHeaderInSection:section];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    [headerView addSubview:label];

    return headerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"你知道吗";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KnowTipModel *tipModel = self.tips[indexPath.row];

    WikiViewController *wikiVC = [[WikiViewController alloc] init];
    wikiVC.title = tipModel.title;

    [self.navigationController pushViewController:wikiVC animated:YES];
}

@end
