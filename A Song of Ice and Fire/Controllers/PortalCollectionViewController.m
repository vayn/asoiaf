//
//  PortalCollectionViewController.m
//  ice
//
//  Created by Vicent Tsai on 15/11/7.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "PortalCollectionViewController.h"
#import "PortalCell.h"
#import "PortalCollectionHeaderView.h"
#import "PortalLayout.h"

#import "CategoryViewController.h"

#import "DataManager.h"
#import "Models.h"

static NSString * const reuseCell = @"PortalCell";
static NSString * const reuseHeader = @"PortalCollectionHeaderView";
                 
@interface PortalCollectionViewController ()

@property (nonatomic, strong) NSArray<CategoryMemberModel *> *portals;
@property (nonatomic, strong) NSMutableArray<UIImage *> *portalImages;

@end

@implementation PortalCollectionViewController

- (instancetype)init
{
    PortalLayout *flowLayout = [[PortalLayout alloc] init];

    self = [super initWithCollectionViewLayout:flowLayout];
    if (self) {
        self.collectionView.scrollEnabled = YES;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        
        [self setupPortals];
    }
    return self;
}

- (void)setupPortals
{
    NSArray *portals = @[@{
                             @"pageid": @303,
                             @"link": @"Category:书籍",
                             @"title": @"分卷介绍"
                         },
                         @{
                             @"pageid": @46724,
                             @"link": @"Category:冰与火之歌章节",
                             @"title": @"章节梗概"
                         },
                         @{
                             @"pageid": @5480,
                             @"link": @"Category:人物",
                             @"title": @"人物介绍"
                         },
                         @{
                             @"pageid": @46711,
                             @"link": @"Category:贵族家族",
                             @"title": @"各大家族"
                         },
                         @{
                             @"pageid": @5481,
                             @"link": @"Category:历史",
                             @"title": @"七国历史"
                         },
                         @{
                             @"pageid": @5483,
                             @"link": @"Category:文化",
                             @"title": @"文化风俗"
                         },
                         @{
                             @"pageid": @5482,
                             @"link": @"Category:维斯特洛地点",
                             @"title": @"地理信息"
                         },
                         @{
                             @"pageid": @5484,
                             @"link": @"Category:剧集",
                             @"title": @"剧集相关"
                         },
                         @{
                             @"pageid": @2780,
                             @"link": @"Category:理论推测",
                             @"title": @"理论推测"
                         }];
    NSMutableArray *tempArray = [@[] mutableCopy];

    for (NSDictionary *portal in portals) {
        CategoryMemberModel *cm = [[CategoryMemberModel alloc] initWithTitle:portal[@"title"]
                                                                        link:portal[@"link"]
                                                                      pageId:portal[@"pageid"]];
        [tempArray addObject:cm];
    }

    _portals = [tempArray copy];
    _portalImages = [NSMutableArray arrayWithCapacity:_portals.count];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UINib *cellNib = [UINib nibWithNibName:@"PortalCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:reuseCell];

    UINib *headerNib = [UINib nibWithNibName:@"PortalCollectionHeaderView" bundle:nil];
    [self.collectionView registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeader];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.portals count];
}

- (PortalCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PortalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseCell forIndexPath:indexPath];
    CategoryMemberModel *portal = self.portals[indexPath.row];

    // Configure the cell
    cell.titleLabel.text = portal.title;

    if (indexPath.row >= self.portalImages.count) {
        [cell.loadingIndicator startAnimating];

        [[DataManager sharedManager] getPageThumbnailWithPageId:portal.pageId completionBlock:^(id responseObject) {
            NSData *imageData = (NSData *)responseObject;
            UIImage *thumbnailImage = [UIImage imageWithData:imageData];

            CATransition *transition = [CATransition animation];
            transition.duration = 1.0;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionFade;
            [cell.layer addAnimation:transition forKey:nil];

            cell.portalImageView.image = thumbnailImage;

            [cell.loadingIndicator stopAnimating];
            [cell.loadingIndicator removeFromSuperview];
            
            [self.portalImages addObject:thumbnailImage];
        }];
    } else {
        UIImage *thumbnailImage = [self.portalImages objectAtIndex:indexPath.row];
        cell.portalImageView.image = thumbnailImage;
    }

    // Add rounded corner and shadows
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.contentView.bounds
                                                   byRoundingCorners:(UIRectCornerTopRight|UIRectCornerBottomRight)
                                                         cornerRadii:CGSizeMake(12.0, 12.0)];

    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = cell.contentView.bounds;
    maskLayer.path = maskPath.CGPath;

    cell.contentView.layer.borderWidth = 0.0;
    cell.contentView.layer.borderColor = [UIColor clearColor].CGColor;
    cell.contentView.layer.mask = maskLayer;
    cell.contentView.layer.masksToBounds = YES;

    cell.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.layer.shadowOffset = CGSizeMake(0, 1.0);
    cell.layer.shadowRadius = 2.0;
    cell.layer.shadowOpacity = 1.0;
    cell.layer.shadowPath = maskPath.CGPath;
    cell.layer.masksToBounds = NO;

    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionHeader) {
        PortalCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                    withReuseIdentifier:reuseHeader
                                                                                           forIndexPath:indexPath];
        headerView.headerTitle.text = @"精选栏目";
        reusableView = headerView;
    }
    return reusableView;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *centraIndexPath = [self centralIndexPath];

    if (centraIndexPath && (centraIndexPath == indexPath)) {
        CategoryMemberModel *portal =  self.portals[indexPath.row];

        CategoryViewController *categoryVC = [[CategoryViewController alloc] init];
        categoryVC.category = portal;
        
        [self.navigationController pushViewController:categoryVC animated:YES];
    } else {
        CGFloat collectionViewWidth = CGRectGetWidth(self.collectionView.bounds);

        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        CGPoint offset = CGPointMake(cell.center.x - collectionViewWidth / 2, 0);
        [collectionView setContentOffset:offset animated:YES];
    }
}

#pragma mark - Helpers

- (NSIndexPath *)centralIndexPath
{
    UICollectionView *cv = self.collectionView;
    CGPoint point = CGPointMake(cv.contentOffset.x + cv.bounds.size.width / 2, cv.bounds.size.height / 2);
    NSIndexPath *indexPath = [cv indexPathForItemAtPoint:point];

    if (indexPath) {
        return indexPath;
    }

    return nil;
}

@end
