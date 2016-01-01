//
//  SlideMenuViewController.m
//  ice
//
//  Created by Vicent Tsai on 15/10/25.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "SlideMenuViewController.h"
#import "CategoryViewController.h"
#import "WikiViewController.h"
#import "SearchTableViewController.h"

#import "PortalTypes.h"
#import "DataManager.h"
#import "Models.h"

#import "UIImage+Decorate.h"

@interface SlideMenuViewController ()
<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UITableView *myTableView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *logoButton;

@property (nonatomic, strong) NSString *randomTitle;

@property (nonatomic, strong) NSMutableArray<CategoryMemberModel *> *CMembers;
@property (nonatomic, strong) NSArray<NSDictionary *> *rawCMembers;

@end

@implementation SlideMenuViewController

#pragma mark - Initializer

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self setupCMembers];
    }
    return self;
}

- (void)setupCMembers
{
    _rawCMembers = @[@{@"pageid": @5480,
                       @"link": @"Category:人物",
                       @"title": @"人物介绍",
                       @"type": [NSNumber numberWithInteger:PortalCharacterType],
                       @"icon": [UIImage imageNamed:@"slide_icon_character"],
                       },
                     @{@"pageid": @46711,
                       @"link": @"Category:贵族家族",
                       @"title": @"各大家族",
                       @"type": [NSNumber numberWithInteger:PortalHouseType],
                       @"icon": [UIImage imageNamed:@"slide_icon_house"],
                       },
                     @{@"pageid": @5481,
                       @"link": @"Category:历史",
                       @"title": @"七国历史",
                       @"type": [NSNumber numberWithInteger:PortalHistoryType],
                       @"icon": [UIImage imageNamed:@"slide_icon_history"],
                       },
                     @{@"pageid": @5483,
                       @"link": @"Category:文化",
                       @"title": @"文化风俗",
                       @"type": [NSNumber numberWithInteger:PortalCultureType],
                       @"icon": [UIImage imageNamed:@"slide_icon_culture"],
                       },
                     @{@"pageid": @5482,
                       @"link": @"Category:维斯特洛地点",
                       @"title": @"地理信息",
                       @"type": [NSNumber numberWithInteger:PortalGeoType],
                       @"icon": [UIImage imageNamed:@"slide_icon_geo"],
                       },
                     @{@"pageid": @5484,
                       @"link": @"Category:剧集",
                       @"title": @"剧集相关",
                       @"type": [NSNumber numberWithInteger:PortalTVType],
                       @"icon": [UIImage imageNamed:@"slide_icon_tv_black"],
                       },
                     @{@"pageid": @2780,
                       @"link": @"Category:理论推测",
                       @"title": @"理论推测",
                       @"type": [NSNumber numberWithInteger:PortalTheoryType],
                       @"icon": [UIImage imageNamed:@"slide_icon_theory"],
                       },
                     @{@"pageid": @303,
                       @"link": @"Category:书籍",
                       @"title": @"分卷介绍",
                       @"type": [NSNumber numberWithInteger:PortalBookType],
                       @"icon": [UIImage imageNamed:@"slide_icon_book"],
                       },
                     @{@"pageid": @46724,
                       @"link": @"Category:冰与火之歌章节",
                       @"title": @"章节梗概",
                       @"type": [NSNumber numberWithInteger:PortalChapterType],
                       @"icon": [UIImage imageNamed:@"slide_icon_chapter"],
                       }
                     ];

    _CMembers = [@[] mutableCopy];

    for (NSDictionary *portal in _rawCMembers) {
        CategoryMemberModel *cm = [[CategoryMemberModel alloc] initWithTitle:portal[@"title"]
                                                                        link:portal[@"link"]
                                                                      pageId:portal[@"pageid"]];
        [_CMembers addObject:cm];
    }
}

#pragma mark - View Manager

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self.myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"myTableViewCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[MainManager sharedManager] getRandomTitle:^(NSString *title) {
        self.randomTitle = title;
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    NSIndexPath *indexPath = self.myTableView.indexPathForSelectedRow;
    if (indexPath) {
        [self.myTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
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
    return [self.CMembers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myTableViewCell" forIndexPath:indexPath];
    CategoryMemberModel *category = self.CMembers[indexPath.row];
    UIImage *iconImage = self.rawCMembers[indexPath.row][@"icon"];

    if (iconImage) {
        CGFloat targetWidth = 25.0;
        cell.imageView.image = [iconImage makeThumbnailOfWidth:targetWidth];
    }

    cell.textLabel.text = category.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.myTableView deselectRowAtIndexPath:indexPath animated:YES];

    CategoryViewController *categoryVC = [[CategoryViewController alloc] init];
    categoryVC.category = self.CMembers[indexPath.row];
    categoryVC.portalType = (PortalType)[self.rawCMembers[indexPath.row][@"type"] integerValue];

    [self.navigationController pushViewController:categoryVC animated:YES];
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
    label.text = [Utilities appNameAndVersionNumberDisplayString];
    label.textAlignment = NSTextAlignmentCenter;
    [footer addSubview:label];

    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15.0;
}

#pragma mark - UISearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    SearchTableViewController *searchTableVC = [[SearchTableViewController alloc] init];
    [self presentViewController:searchTableVC animated:YES completion:nil];
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
        [[MainManager sharedManager] getRandomTitle:^(NSString *title) {
            WikiViewController *wikiVC = [[WikiViewController alloc] init];
            wikiVC.title = title;
            [self.navigationController pushViewController:wikiVC animated:YES];
        }];
    }
}

@end
