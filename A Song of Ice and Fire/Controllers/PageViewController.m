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

@interface PageViewController ()

@property (nonatomic, strong) NSArray *pages;

@end

@implementation PageViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)setParentCategory:(PortalModel *)parentCategory
{
    _parentCategory = parentCategory;

    self.navigationItem.title = _parentCategory.title;

    [[DataManager sharedManager] getPagesWithCate:_parentCategory.link completionBlock:^(NSArray *pages) {
        if (pages.count > 0) {
            _pages = pages;

            [self.tableView reloadData];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
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
    
    PageModel *page = self.pages[indexPath.row];

    NSString *title = page.title;

    if ([title rangeOfString:@":"].location != NSNotFound) {
        NSArray *temp = [title componentsSeparatedByString:@":"];
        title = temp[1];
    }

    cell.textLabel.text = title;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    PageModel *page = self.pages[indexPath.row];

    WikiViewController *wikiVC = [[WikiViewController alloc] init];
    wikiVC.title = page.title;

    [self.parentVC.navigationController pushViewController:wikiVC animated:YES];
}

@end
