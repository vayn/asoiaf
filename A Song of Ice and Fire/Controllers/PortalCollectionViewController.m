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
#import "DataManager.h"
#import "PortalModel.h"

@interface PortalCollectionViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray *portals;

@end

@implementation PortalCollectionViewController

static NSString * const reuseIdentifier = @"PortalCell";

- (instancetype)init
{
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];

    self = [super initWithCollectionViewLayout:flowLayout];
    if (self) {
        [[DataManager sharedManager] getPortals:^(id responseObject) {
            self.portals = [(NSArray *)responseObject copy];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;

    UINib *nib = [UINib nibWithNibName:@"PortalCell" bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:reuseIdentifier];
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
    PortalCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    PortalModel *portal = self.portals[indexPath.row];

    [cell.loadingIndicator startAnimating];
    
    // Configure the cell
    cell.titleLabel.text = portal.title;
    //cell.portalImageView.image = [UIImage imageNamed:@"collect_test_100x70"];

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

    /*
    if (kind == UICollectionElementKindSectionHeader) {
        <#statements#>
    }
     */

    return reusableView;
}

#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize retVal = CGSizeMake(100, 85);
    return retVal;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
