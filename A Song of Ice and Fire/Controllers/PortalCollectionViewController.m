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
#import "DataManager.h"
#import "PortalModel.h"
#import "CatListViewController.h"

static NSString * const reuseCell = @"PortalCell";
static NSString * const reuseHeader = @"PortalCollectionHeaderView";
                 
@interface PortalCollectionViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray<PortalModel *> *portals;

@end

@implementation PortalCollectionViewController

- (instancetype)init
{
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setHeaderReferenceSize:CGSizeMake(320, 50)];

    self = [super initWithCollectionViewLayout:flowLayout];
    if (self) {
        /* Portals which are from getPortal API lack of many important categories,
         * so I decide to use hard-coded portal list.

        [[DataManager sharedManager] getPortals:^(id responseObject) {
            self.portals = [(NSArray *)responseObject copy];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }];
         */
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
                             @"link": @"Category:POV人物",
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
        PortalModel *pm = [[PortalModel alloc] initWithTitle:portal[@"title"]
                                                      pageId:portal[@"pageid"]
                                                        link:portal[@"link"]];
        [tempArray addObject:pm];
    }

    _portals = [tempArray copy];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.collectionView.scrollEnabled = NO;

    // Uncomment the following lide to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;

    UINib *cellNib = [UINib nibWithNibName:@"PortalCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:reuseCell];

    UINib *headerNib = [UINib nibWithNibName:@"PortalCollectionHeaderView" bundle:nil];
    [self.collectionView registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeader];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.portals count];
}

- (PortalCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PortalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseCell forIndexPath:indexPath];
    PortalModel *portal = self.portals[indexPath.row];

    [cell.loadingIndicator startAnimating];
    
    // Configure the cell
    cell.titleLabel.text = portal.title;

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
    }];

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

#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize retVal = CGSizeMake(100, 85);
    return retVal;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(0, 42);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 10, 5, 10);
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PortalModel *portal =  self.portals[indexPath.row];
    NSLog(@"Selected: %@", portal.title);

    CatListViewController *catListVC = [[CatListViewController alloc] initWithStyle:UITableViewStylePlain];
    catListVC.parentCategory = portal;
    
    [self.navigationController pushViewController:catListVC animated:YES];
}

@end
