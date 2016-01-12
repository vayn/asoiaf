//
//  PageTable.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/4.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "PageTable.h"

#import "GradientView.h"
#import "DataManager.h"

#import "UIImage+Decorate.h"

static CGFloat const kThumbnailWidth = 40.0;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
                CGSize thumbnailSize = CGSizeMake(35, 23);
                UIImage *thumbnail = [[UIImage imageWithData:imageData] makeThumbnailOfSize:thumbnailSize];
                member.backgroundImage = [thumbnail makeRoundCornerOfRadius:1.5];
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
    WikiViewController *wikiVC = [[WikiViewController alloc] initWithTitle:member.title andLink:member.link];

    UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController:wikiVC];
    wikiVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_button"]
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(homeButtonPressed:)];

    [self.parentVC.navigationController presentViewController:navigationVC animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == ((NSIndexPath *)[tableView.indexPathsForVisibleRows lastObject]).row) {
        if (self.emptyDataSetDelegate.isLoading) {
            self.tableView.tableHeaderView = nil;
        } else {
            [self setupTableHeaderView];
        }

    }
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
    CGRect headerFrame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y - 40,
                                    self.tableView.frame.size.width, 90);
    UIView *headerView = [[UIView alloc] initWithFrame:headerFrame];
    headerView.clipsToBounds = YES;

    UIImage *backgroundImage = nil;
    UIImage *iconImage = nil;

    switch (self.parentVC.portalType) {
        case PortalChapterType:
        case PortalBookType: {
            backgroundImage = [UIImage imageNamed:@"portal_book_header"];
            break;
        }
        case PortalCharacterType: {
            backgroundImage = [UIImage imageNamed:@"portal_character_header"];
            break;
        }
        case PortalHouseType: {
            backgroundImage = [UIImage imageNamed:@"portal_house_bg"];
            break;
        }
        case PortalHistoryType: {
            backgroundImage = [UIImage imageNamed:@"portal_history_bg"];
            break;
        }
        case PortalCultureType: {
            backgroundImage = [UIImage imageNamed:@"portal_culture_bg"];
            break;
        }
        case PortalGeoType: {
            backgroundImage = [UIImage imageNamed:@"portal_geo_bg"];
            break;
        }
        case PortalTVType: {
            backgroundImage = [UIImage imageNamed:@"portal_tv_bg"];
            iconImage = [[UIImage imageNamed:@"slide_icon_tv_white"] makeThumbnailOfWidth:kThumbnailWidth];
            break;
        }
        case PortalTheoryType: {
            break;
        }
    }

    if (backgroundImage) {
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:headerFrame];
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        backgroundImageView.image = backgroundImage;
        backgroundImageView.clipsToBounds = YES;
        [headerView addSubview:backgroundImageView];
    } else {
        UIColor *patternColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_greyfloral"]];
        headerView.backgroundColor = patternColor;
    }

    GradientView *blurView = [[GradientView alloc] initWithFrame:headerFrame type:TransparentGradientType];
    blurView.alpha = 0.618;
    [headerView addSubview:blurView];

    CGRect titleFrame = CGRectMake(0, 0, headerFrame.size.width, 60);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];

    if (iconImage) {
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.bounds = CGRectMake(0, -1, iconImage.size.width, iconImage.size.height);
        attachment.image = iconImage;

        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        NSAttributedString *titleString = [[NSAttributedString alloc] initWithString:self.parentVC.title];

        NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
        [titleText appendAttributedString:titleString];

        titleLabel.attributedText = titleText;
    } else {
        titleLabel.text = self.parentVC.title;
    }

    titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:21.0];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.shadowColor = [UIColor blackColor];
    titleLabel.shadowOffset = CGSizeMake(0, 1);
    titleLabel.textAlignment = UIControlContentHorizontalAlignmentLeft|UIControlContentVerticalAlignmentBottom;
    titleLabel.numberOfLines = 0;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.5;
    titleLabel.center = headerView.center;
    titleLabel.frame = CGRectOffset(titleLabel.frame, 15, 0);

    [headerView addSubview:titleLabel];
    [headerView bringSubviewToFront:titleLabel];

    self.tableView.tableHeaderView = headerView;
}

@end
