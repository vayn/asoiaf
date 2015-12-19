//
//  PortalCollectionViewController.m
//  ice
//
//  Created by Vicent Tsai on 15/11/7.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "PortalCollectionViewController.h"
#import "PortalCollectionHeaderView.h"
#import "PortalLayout.h"
#import "PortalCell.h"
#import "PortalWebViewController.h"

#import "CategoryViewController.h"

#import "DataManager.h"
#import "Models.h"

static NSString * const reuseCell = @"PortalCell";
static NSString * const reuseHeader = @"PortalCollectionHeaderView";

@interface PortalCollectionViewController ()

@property (nonatomic, strong) NSArray<CategoryMemberModel *> *portals;
@property (nonatomic, getter=isIntialized) BOOL intialized;

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

#pragma mark - Setup data source

- (void)setupPortals
{
    NSArray *rawPortals = @[@{@"pageid": @46720,
                              @"link": @"Portal:历史",
                              @"title": @"七国历史",
                              @"portrait": [UIImage imageNamed:@"portal_portrait_history"],
                              },
                            @{@"pageid": @46722,
                              @"link": @"Portal:文化",
                              @"title": @"文化风俗",
                              @"portrait": [UIImage imageNamed:@"portal_portrait_culture"],
                              },
                            @{@"pageid": @46721,
                              @"link": @"Portal:地理",
                              @"title": @"地理信息",
                              @"portrait": [UIImage imageNamed:@"portal_portrait_geo"],
                              },
                            @{@"pageid": @46732,
                              @"link": @"Portal:电视剧",
                              @"title": @"剧集相关",
                              @"portrait": [UIImage imageNamed:@"portal_portrait_tv"],
                              },
                            @{@"pageid": @2780,
                              @"link": @"理论推测",
                              @"title": @"理论推测",
                              @"portrait": [UIImage imageNamed:@"portal_portrait_inference"],
                              },
                            @{@"pageid": @46710,
                              @"link": @"Portal:书",
                              @"title": @"分卷介绍",
                              @"portrait": [UIImage imageNamed:@"portal_portrait_book"],
                              },
                            @{@"pageid": @46724,
                              @"link": @"Portal:章节",
                              @"title": @"章节梗概",
                              @"portrait": [UIImage imageNamed:@"portal_portrait_chapter"],
                              },
                            @{@"pageid": @46719,
                              @"link": @"Portal:人物",
                              @"title": @"人物介绍",
                              @"portrait": [UIImage imageNamed:@"portal_portrait_character"],
                              },
                            @{@"pageid": @46711,
                              @"link": @"Portal:家族",
                              @"title": @"各大家族",
                              @"portrait": [UIImage imageNamed:@"portal_portrait_house"],
                              }];
    NSMutableArray *workingArray = [@[] mutableCopy];

    for (NSDictionary *portal in rawPortals) {
        CategoryMemberModel *cm = [[CategoryMemberModel alloc] initWithTitle:portal[@"title"]
                                                                        link:portal[@"link"]
                                                                      pageId:portal[@"pageid"]];
        cm.backgroundImage = portal[@"portrait"];
        [workingArray addObject:cm];
    }

    /* *
     *
     * Grab references to the first and last items
     * They're typed as id so you don't need to worry about what kind
     * of objects the original array is holding
     *
     */
    id firstItem = [workingArray firstObject];
    id lastItem = [workingArray lastObject];

    // Add the copy of the last item to the beginning
    [workingArray insertObject:lastItem atIndex:0];

    // Add the copy of the first item to the end
    [workingArray addObject:firstItem];

    _portals = [workingArray copy];
}

#pragma mark - View Manager

- (void)viewDidLoad {
    [super viewDidLoad];

    UINib *cellNib = [UINib nibWithNibName:@"PortalCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:reuseCell];

    UINib *headerNib = [UINib nibWithNibName:@"PortalCollectionHeaderView" bundle:nil];
    [self.collectionView registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseHeader];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Scroll to the 2nd item, which is showing the first item.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:0];
        [self snapItemToCenterAtIndexPath:indexPath animated:NO];

        self.intialized = YES;
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.portals count];
}

- (PortalCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PortalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseCell forIndexPath:indexPath];
    CategoryMemberModel *portal = self.portals[indexPath.row];

    // Configure the cell
    cell.titleLabel.text = portal.title;

    if (portal.backgroundImage) {
        cell.portalImageView.image = portal.backgroundImage;
    } else {
        [cell.loadingIndicator startAnimating];

        CATransition *transition = [CATransition animation];
        transition.duration = 1.0;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionFade;
        [cell.layer addAnimation:transition forKey:nil];

        cell.portalImageView.image = portal.backgroundImage;

        [cell.loadingIndicator stopAnimating];
        [cell.loadingIndicator removeFromSuperview];
    }

    // Add rounded corners and shadow
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
    NSIndexPath *centralIndexPath = [self centralIndexPath];

    if (centralIndexPath && (centralIndexPath == indexPath)) {
        CategoryMemberModel *category = self.portals[indexPath.row];
        PortalWebViewController *webVC = [[PortalWebViewController alloc] initWithCategory:category];

        [self.navigationController pushViewController:webVC animated:YES];
    } else {
        [self snapItemToCenterAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

    CGFloat currentOffset = scrollView.contentOffset.x;
    //NSLog(@"[DEBUG] Current PortalCollection offset: %.3f", currentOffset);

    /* *
     *
     * Keynote:
     *
     * Find the position of disappeared half left/right cell, which is
     * kItemSizeWidth / 2
     *
     */
    CGFloat contentOffsetWhenFullyScrolledRight = 1502.5;
    CGFloat contentOffsetWhenFullyscrolledLeft = 72.5;

    if (currentOffset > contentOffsetWhenFullyScrolledRight) {

        // user is scrolling to the right from the last item to the 'fake' item 1.
        // reposition offset to show the 'real' item 1 at the left-hand end of the collection view

        scrollView.contentOffset = (CGPoint){contentOffsetWhenFullyscrolledLeft, 0};

    } else if ((currentOffset < contentOffsetWhenFullyscrolledLeft) && self.isIntialized) {

        // user is scrolling to the left from the first item to the fake 'item N'.
        // reposition offset to show the 'real' item N at the right end end of the collection view

        scrollView.contentOffset = (CGPoint){contentOffsetWhenFullyScrolledRight, 0};

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

- (void)snapItemToCenterAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    UICollectionView *cv = self.collectionView;

    CGFloat collectionViewWidth = CGRectGetWidth(cv.bounds);
    
    UICollectionViewCell *cell = [cv cellForItemAtIndexPath:indexPath];
    CGPoint offset = CGPointMake(cell.center.x - collectionViewWidth / 2, 0);
    [cv setContentOffset:offset animated:animated];
}

@end
