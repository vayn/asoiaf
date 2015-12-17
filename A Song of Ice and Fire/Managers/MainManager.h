//
//  MainManager.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/13.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "BaseManager.h"

@interface MainManager : BaseManager

+ (instancetype)sharedManager;

- (void)getFeaturedQuotes:(ManagerCompletionBlock)completionBlock;
- (void)getKnowTip:(ManagerCompletionBlock)completionBlock;
- (void)getRandomTitle:(void (^)(NSString *title))completionBlock;
- (void)getWikiEntry:(NSString *)title completionBlock:(void (^)(NSString *wikiEntry))completionBlock;

@end
