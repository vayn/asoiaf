//
//  ImageManager.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/13.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "BaseManager.h"

@interface ImageManager : BaseManager

+ (instancetype)sharedManager;

- (void)getPageThumbnailWithPageId:(NSNumber *)pageId completionBlock:(ManagerCompletionBlock)completionBlock;
- (void)getPortalThumbnailWithPageId:(NSNumber *)pageId completionBlock:(ManagerCompletionBlock)completionBlock;
- (void)getPageThumbnailWithPageId:(NSNumber *)pageId thumbWidth:(NSNumber *)thumbWidth completionBlock:(ManagerCompletionBlock)completionBlock;

@end
