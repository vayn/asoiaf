//
//  CategoryViewController.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/30.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "CategoryViewController.h"
#import "PageViewController.h"
#import "SubCatesViewController.h"

#import "Models.h"
#import "CAPSPageMenu.h"

@interface CategoryViewController ()

@property (nonatomic, strong) CAPSPageMenu *pageMenu;

@end

@implementation CategoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = _category.title;

    PageViewController *pagesVC = [[PageViewController alloc] initWithStyle:UITableViewStylePlain];
    pagesVC.title = @"页面";
    pagesVC.parentCategory = _category;
    pagesVC.parentVC = (UIViewController *)self;

    SubCatesViewController *subCatesVC = [[SubCatesViewController alloc] initWithStyle:UITableViewStylePlain];
    subCatesVC.title = @"子分类";
    subCatesVC.parentCategory = _category;
    subCatesVC.parentVC = (UIViewController *)self;

    NSArray *controllerArray = @[pagesVC, subCatesVC];

    NSDictionary *parameters = @{
                     CAPSPageMenuOptionSelectedMenuItemLabelColor: [UIColor colorWithRed:18.0/255.0 green:150.0/255.0 blue:225.0/255.0 alpha:1.0],
                     CAPSPageMenuOptionUnselectedMenuItemLabelColor: [UIColor colorWithRed:40.0/255.0 green:40.0/255.0 blue:40.0/255.0 alpha:1.0],
                     CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor whiteColor],
                     CAPSPageMenuOptionViewBackgroundColor: [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0],
                     CAPSPageMenuOptionSelectionIndicatorColor: [UIColor colorWithRed:18.0/255.0 green:150.0/255.0 blue:225.0/255.0 alpha:1.0],
                     CAPSPageMenuOptionBottomMenuHairlineColor: [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:0.1],
                     CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0],
                     CAPSPageMenuOptionMenuMargin: @(20.0),
                     CAPSPageMenuOptionMenuHeight: @(40.0),
                     CAPSPageMenuOptionMenuItemWidth: @(90.0),
                     CAPSPageMenuOptionMenuItemSeparatorWidth: @(4.3),
                     CAPSPageMenuOptionSelectionIndicatorHeight: @(2.0),
                     CAPSPageMenuOptionMenuItemSeparatorPercentageHeight: @(0.1),
                     CAPSPageMenuOptionCenterMenuItems: @(YES),
                     CAPSPageMenuOptionUseMenuLikeSegmentedControl: @YES,
                     CAPSPageMenuOptionMenuItemSeparatorRoundEdges: @YES
                     };

    _pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray
                                                        frame:CGRectMake(0.0, 58.0, self.view.frame.size.width, self.view.frame.size.height)
                                                      options:parameters];
    [self.view addSubview:_pageMenu.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
