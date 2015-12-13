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

    [[DataManager sharedManager]
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    CategoryMemberModel *member = self.members[indexPath.row];

    cell.imageView.image = [UIImage imageNamed:@"placeholder_default"];

    if (member.backgroundImage) {
        cell.imageView.image = member.backgroundImage;
    } else {
        [[DataManager sharedManager] getPageThumbnailWithPageId:member.pageId completionBlock:^(id responseObject) {
            NSData *imageData = (NSData *)responseObject;

            if (imageData) {
                UIImage *thumbnail = [UIImage imageWithData:imageData];

                CGSize thumbnailSize = CGSizeMake(100, 76);

                UIGraphicsBeginImageContextWithOptions(thumbnailSize, NO, 0);
                CGRect imageRect = CGRectMake(0, 0, thumbnailSize.width, thumbnailSize.height);
                [thumbnail drawInRect:imageRect];
                member.backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();

                CATransition *transition = [CATransition animation];
                transition.duration = 1.0;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionFade;
                [cell.layer addAnimation:transition forKey:nil];

                cell.imageView.image = member.backgroundImage;
            }
        }];
    }

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryMemberModel *member = self.members[indexPath.row];

    WikiViewController *wikiVC = [[WikiViewController alloc] init];
    wikiVC.title = member.title;

    [self.parentVC.navigationController pushViewController:wikiVC animated:YES];
}

#pragma mark - CMBaseTableDelegate

- (void)getMembersWithCategory:(NSString *)categoryLink parameters:(NSDictionary *)parameters completionBlock:(void (^)(CategoryMembersModel * _Nonnull))completionBlock
{
    [[DataManager sharedManager] getCategoryMember:categoryLink memberType:CMPageType parameters:parameters completionBlock:completionBlock];
}

@end
