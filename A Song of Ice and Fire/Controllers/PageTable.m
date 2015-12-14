//
//  PageTable.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/4.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "PageTable.h"

@interface PageTable () <CMBaseTableDelegate>

@end

@implementation PageTable

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [super setDelegate:self];
    }
    return self;
}

- (void)setParentCategory:(CategoryMemberModel *)parentCategory
{
    [super setParentCategory:parentCategory];

    [[CategoryManager sharedManager]
     getCategoryMember:parentCategory.link memberType:CMPageType parameters:nil completionBlock:^(CategoryMembersModel *members) {
         self.members = members.members;

        if (members.cmcontinue) {
            [self.nextContinue addObject:members.cmcontinue];
        }

        if (self.members.count > 0) {
            [self.tableView reloadData];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupTableHeaderView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 68, 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryMemberModel *member = self.members[indexPath.row];

    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];

    // Transitioning animation of content transition
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [cell.layer addAnimation:transition forKey:nil];

    cell.imageView.image = [UIImage imageNamed:@"placeholder_unknown"];
    [self cellImageViewLayerConfig:cell];

    if (member.backgroundImage) {
        cell.imageView.image = member.backgroundImage;
    } else {
        [[ImageManager sharedManager] getPageThumbnailWithPageId:member.pageId completionBlock:^(id responseObject) {
            NSData *imageData = (NSData *)responseObject;

            if (imageData) {
                UIImage *thumbnail = [UIImage imageWithData:imageData];

                CGSize thumbnailSize = CGSizeMake(35, 23);

                UIGraphicsBeginImageContext(thumbnailSize);

                CGRect imageRect = CGRectMake(0, 0, thumbnailSize.width, thumbnailSize.height);
                [[UIBezierPath bezierPathWithRoundedRect:imageRect cornerRadius:1.5] addClip];

                [thumbnail drawInRect:imageRect];
                member.backgroundImage = UIGraphicsGetImageFromCurrentImageContext();

                UIGraphicsEndImageContext();

                cell.imageView.image = member.backgroundImage;
            }
        }];
    }

    return cell;
}

- (void)cellImageViewLayerConfig:(UITableViewCell *)cell
{
    cell.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.imageView.layer.shadowOpacity = 0.4;
    cell.imageView.layer.shadowRadius = 1.5;
    cell.imageView.layer.shadowOffset = CGSizeZero;

    cell.imageView.layer.shouldRasterize = YES;
    cell.imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryMemberModel *member = self.members[indexPath.row];

    WikiViewController *wikiVC = [[WikiViewController alloc] init];
    wikiVC.title = member.title;

    UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:wikiVC];
    wikiVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_button"]
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(homeButtonPressed:)];

    [self.parentVC.navigationController presentViewController:navigationVC animated:YES completion:nil];
}

#pragma mark - CMBaseTableDelegate

- (void)getMembersWithCategory:(NSString *)categoryLink
                    parameters:(NSDictionary *)parameters
               completionBlock:(void (^)(CategoryMembersModel * _Nonnull))completionBlock
{
    [[CategoryManager sharedManager] getCategoryMember:categoryLink
                                            memberType:CMPageType
                                            parameters:parameters
                                       completionBlock:completionBlock];
}

#pragma mark - Controller Actions

- (void)homeButtonPressed:(id)sender
{
    [self.parentVC.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private methods

- (void)setupTableHeaderView
{
    CGRect headerFrame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y - 20,
                                    self.tableView.frame.size.width, 180);
    UIView *headerView = [[UIView alloc] initWithFrame:headerFrame];
    UIView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"h1"]];
    imageView.frame = headerFrame;
    [headerView addSubview:imageView];

    self.tableView.tableHeaderView = headerView;
}

@end
