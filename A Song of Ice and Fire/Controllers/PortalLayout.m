//
//  PortalLayout.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/6.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "PortalLayout.h"

static CGFloat const kItemSizeWidth = 150;
static CGFloat const kItemSizeHeight = 170;

@interface PortalLayout ()

@end

@implementation PortalLayout

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.itemSize = CGSizeMake(kItemSizeWidth, kItemSizeHeight);
        self.minimumInteritemSpacing = 2;
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }

    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];

    // The rate at which we scroll the collection view.
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;

    self.collectionView.contentInset = UIEdgeInsetsMake(0, self.collectionView.bounds.size.width/2 - kItemSizeWidth/2,
                                                        0, self.collectionView.bounds.size.width/2 - kItemSizeWidth/2);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];

    for (UICollectionViewLayoutAttributes *attributes in array) {
        if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
            CGRect frame = attributes.frame;
            CGFloat distance = fabs(self.collectionView.contentOffset.x + self.collectionView.contentInset.left - frame.origin.x);
            CGFloat scale = 0.7 * (MIN(MAX(1 - distance / self.collectionView.bounds.size.width, 0.75), 1));
            attributes.transform = CGAffineTransformMakeScale(scale, scale);
        }
    }

    return array;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

@end
