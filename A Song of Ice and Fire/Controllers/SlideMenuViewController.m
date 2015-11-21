//
//  SlideMenuViewController.m
//  ice
//
//  Created by Vicent Tsai on 15/10/25.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "SlideMenuViewController.h"
#import "DataManager.h"
#import "WikiViewController.h"

@interface SlideMenuViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UITableView *myTableView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *logoButton;

@property (nonatomic, strong) NSArray *categoryArray;
@property (nonatomic, strong) NSString *randomTitle;

@end

@implementation SlideMenuViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.categoryArray = @[@"书籍",
                               @"章节",
                               @"人物",
                               @"家族",
                               @"历史",
                               @"文化",
                               @"地理",
                               @"电视剧",
                               @"理论推测"
                               ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self.myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"myTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[DataManager sharedManager] getRandomTitle:^(NSString *title) {
        self.randomTitle = title;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Datasource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.categoryArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myTableViewCell" forIndexPath:indexPath];

    NSString *categoryArray = self.categoryArray[indexPath.row];
    cell.textLabel.text = categoryArray;

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    CGRect frame = CGRectMake(0, 0, 185, 15);
    UIView *footer = [[UIView alloc] initWithFrame:frame];
    footer.backgroundColor = [UIColor clearColor];

    UILabel *label = [[UILabel alloc] initWithFrame:footer.frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor lightGrayColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue" size:9.0];
    label.text = @"Vayn♥诚意制作";
    label.textAlignment = NSTextAlignmentCenter;
    [footer addSubview:label];

    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15.0;
}

#pragma mark - UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"%@", searchBar.text);
}

#pragma mark - logoButton methods

// Easter Egg
- (IBAction)logoButtonPressed:(id)sender
{
    if (self.randomTitle) {
        WikiViewController *wikiVC = [[WikiViewController alloc] init];
        wikiVC.title = self.randomTitle;
        [self.navigationController pushViewController:wikiVC animated:YES];
    } else {
        [[DataManager sharedManager] getRandomTitle:^(NSString *title) {
            WikiViewController *wikiVC = [[WikiViewController alloc] init];
            wikiVC.title = title;
            [self.navigationController pushViewController:wikiVC animated:YES];
        }];
    }
}

@end
