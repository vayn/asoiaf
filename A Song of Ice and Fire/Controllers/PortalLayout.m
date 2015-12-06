//
//  PortalLayout.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/6.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "PortalLayout.h"

static CGFloat const kItemSizeWidth = 150;
static CGFloat const kItemSizeHeight = 200;
static CGFloat const kHeaderWidth = 100;
static CGFloat const kHeaderHeight = 50;

@interface PortalLayout ()

@end

@implementation PortalLayout

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.itemSize = CGSizeMake(kItemSizeWidth, kItemSizeHeight);
        self.minimumInteritemSpacing = 5;
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.headerReferenceSize = CGSizeMake(kHeaderWidth, kHeaderHeight);
    }

    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];

    // The rate at which we scroll the collection view.
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;

    // Section header will add it width to contentInset,
    // so we need to minus its width when we set contentInset as adjustment.
    self.collectionView.contentInset = UIEdgeInsetsMake(
                                        0, self.collectionView.bounds.size.width/2 - kItemSizeWidth/2 - kHeaderWidth,
                                        0, self.collectionView.bounds.size.width/2 - kItemSizeWidth/2);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[super layoutAttributesForElementsInRect:rect] copyItems:YES];

    /* *
     * UICollectionView Floating Headers on Top and Side
     *
     * Reference: http://bit.ly/uicollection_header
     */
    BOOL headerVisible = NO;

    for (UICollectionViewLayoutAttributes *attributes in array) {
        if (attributes.representedElementCategory == UICollectionElementCategoryCell) {
            CGRect frame = attributes.frame;

            // Calculate the distance between the portal image — that is, the cell — and the center of the screen.
            CGFloat distance = fabs(self.collectionView.contentOffset.x + self.collectionView.contentInset.left +
                                    kHeaderWidth - frame.origin.x);

            // Scale the portal image between a factor of 0.75 and 1 depending on the distance calculated above.
            // You then scale all images by 0.7 to keep them nice and small.
            CGFloat scale = 0.7 * (MIN(MAX(1 - distance / self.collectionView.bounds.size.width, 0.75), 1));

            attributes.transform = CGAffineTransformMakeScale(scale, scale);
        }
        if ([attributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            headerVisible = YES;
            attributes.frame = CGRectMake(self.collectionView.contentOffset.x, 0, self.headerReferenceSize.width, self.headerReferenceSize.height);
            attributes.alpha = 1.0;
            attributes.zIndex = 2;
        }
    }

    if (!headerVisible) {
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                            atIndexPath:[NSIndexPath
                                                                                                         indexPathForItem:0
                                                                                                         inSection:0]];
        attributes.frame = CGRectMake(self.collectionView.contentOffset.x, 0, self.headerReferenceSize.width, self.headerReferenceSize.height);
        [array addObject:attributes];
    }

    return array;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    /* *
     * Snap cells to centre
     */

    CGPoint newOffset = CGPointZero;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;

    // Get the total width of a cell
    CGFloat width = layout.itemSize.width + layout.minimumLineSpacing;

    // Calculate the current offset with respect to the center of the screen
    CGFloat offset = proposedContentOffset.x + self.collectionView.contentInset.left;

    // Think of offset/width as the portal you’d like to scroll to
    if (velocity.x > 0) { // The user is scrolling to the right
        // Ceil returns next biggest number
        offset = width * ceil(offset / width);
    } else if (velocity.x == 0) { // The user didn’t put enough oomph into scrolling
        // Rounds the argument
        offset = width * round(offset / width);
    } else if (velocity.x < 0) { // The user is scrolling left
        // Removes decimal part of argument
        offset = width * floor(offset / width);
    }
    // Update the new x offset and return.
    // This guarantees that a portal cell will always be centered in the middle.
    newOffset.x = offset - self.collectionView.contentInset.left;
    newOffset.y = proposedContentOffset.y; //y will always be the same...
    return newOffset;
}

@end
