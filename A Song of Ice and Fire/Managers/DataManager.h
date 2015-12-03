//
//  DataManager.h
//  ice
//
//  Created by Vicent Tsai on 15/10/30.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

@import Foundation;

@class CategoryMembersModel;

NS_ASSUME_NONNULL_BEGIN

typedef void (^ManagerCompletionBlock)(id responseObject);

@interface DataManager : NSObject

+ (instancetype)sharedManager;

- (void)getFeaturedQuotes:(ManagerCompletionBlock)completionBlock;
- (void)getCategories:(ManagerCompletionBlock)completionBlock;
- (void)getPageThumbnailWithPageId:(NSNumber *)pageId completionBlock:(ManagerCompletionBlock)completionBlock;
- (void)getKnowTip:(ManagerCompletionBlock)completionBlock;
- (void)getRandomTitle:(void (^)(NSString *title))completionBlock;

- (void)getPagesUsingGeneratorAPIWithCategory:(NSString *)categoryLink completionBlock:(void (^)(NSArray *members))completionBlock;

- (void)getPagesWithCategory:(NSString *)categoryLink
                  parameters:(nullable NSDictionary *)parameters
             completionBlock:(void (^)(CategoryMembersModel *members))completionBlock;
- (void)getSubCategoriesWithCategory:(NSString *)categoryLink
                          parameters:(nullable NSDictionary *)parameters
                     completionBlock:(void (^)(CategoryMembersModel *))completionBlock;
@end

NS_ASSUME_NONNULL_END