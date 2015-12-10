//
//  CategoryViewController.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/30.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "CategoryViewController.h"
#import "PageTable.h"
#import "SubCategoryTable.h"

#import "Models.h"
#import "CAPSPageMenu.h"

@interface CategoryViewController ()

@property (nonatomic, strong) CAPSPageMenu *pageMenu;

@end

@implementation CategoryViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                                                    target:self
                                                                                    action:@selector(homeButtonPressed:)];
        self.navigationItem.rightBarButtonItem = homeButton;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = _category.title;

    PageTable *pageTable = [[PageTable alloc] initWithStyle:UITableViewStylePlain];
    pageTable.title = @"页面";
    pageTable.parentCategory = _category;
    pageTable.parentVC = (UIViewController *)self;

    SubCategoryTable *subCategoryTable = [[SubCategoryTable alloc] initWithStyle:UITableViewStylePlain];
    subCategoryTable.title = @"子分类";
    subCategoryTable.parentCategory = _category;
    subCategoryTable.parentVC = (UIViewController *)self;

    NSArray *controllerArray = @[pageTable, subCategoryTable];

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
                                                        frame:CGRectMake(0.0, 62.0, self.view.frame.size.width, self.view.frame.size.height)
                                                      options:parameters];
    [self.view addSubview:_pageMenu.view];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.delegate = self.originalDelegate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Control Action

- (void)homeButtonPressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
