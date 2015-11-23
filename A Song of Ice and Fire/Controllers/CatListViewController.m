//
//  CatListViewController.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/23.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "CatListViewController.h"
#import "DataManager.h"
#import "WikiViewController.h"

@interface CatListViewController ()

@property (nonatomic, strong) NSArray *categoryList;

@end

@implementation CatListViewController

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

    [[DataManager sharedManager] getCategoryList:_parentCategory.link completionBlock:^(NSArray *categoryList) {
        if (categoryList.count > 0) {
            _categoryList = categoryList;

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
    return self.categoryList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    NSDictionary *category = self.categoryList[indexPath.row];

    NSString *title = category[@"title"];

    if ([title rangeOfString:@":"].location != NSNotFound) {
        NSArray *temp = [title componentsSeparatedByString:@":"];
        title = temp[1];
    }

    cell.textLabel.text = title;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSDictionary *category = self.categoryList[indexPath.row];

    NSString *title = category[@"title"];

    WikiViewController *wikiVC = [[WikiViewController alloc] init];
    wikiVC.title = title;

    [self.navigationController pushViewController:wikiVC animated:YES];
}

@end
