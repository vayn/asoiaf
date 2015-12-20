//
//  ImageManager.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/13.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "BaseManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ImageManagerBlock)( NSData * _Nullable imageData);

@interface ImageManager : BaseManager

+ (instancetype)sharedManager;

- (void)getPageThumbnailWithPageId:(NSNumber *)pageId completionBlock:(ImageManagerBlock)completionBlock;
- (void)getPageThumbnailWithPageId:(NSNumber *)pageId thumbWidth:(NSNumber *)thumbWidth completionBlock:(ImageManagerBlock)completionBlock;

- (void)getRandomImage:(void (^)(UIImage *image))completionBlock;

@end

NS_ASSUME_NONNULL_END
