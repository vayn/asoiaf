//
//  SlideMenuViewController.m
//  ice
//
//  Created by Vicent Tsai on 15/10/25.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "SlideMenuViewController.h"
#import "DataStore.h"

@interface SlideMenuViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *myTableView;
@property (nonatomic, strong) NSArray *category;

@end

@implementation SlideMenuViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.category = @[@"Portal:书",
                          @"Portal:章节",
                          @"Portal:人物",
                          @"Portal:家族",
                          @"Portal:历史",
                          @"Portal:文化",
                          @"Portal:地理",
                          @"Portal:电视剧",
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
    return [self.category count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myTableViewCell" forIndexPath:indexPath];

    NSString *category = self.category[indexPath.row];
    cell.textLabel.text = category;

    return cell;
}

@end
