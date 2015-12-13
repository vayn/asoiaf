//
//  DataManager.h
//  ice
//
//  Created by Vicent Tsai on 15/10/30.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

@import Foundation;

@class CategoryMembersModel;

typedef NS_ENUM(NSUInteger, CategoryMemberType) {
    CMCategoryType,
    CMPageType,
};

NS_ASSUME_NONNULL_BEGIN

typedef void (^ManagerCompletionBlock)(__nullable id responseObject);

@interface DataManager : NSObject

+ (instancetype)sharedManager;
+ (void)processImageDataWithURL:(NSURL *)url andBlock:(void (^)(NSData *imageData))processImage;

- (void)getFeaturedQuotes:(ManagerCompletionBlock)completionBlock;
- (void)getCategories:(ManagerCompletionBlock)completionBlock;
- (void)getPageThumbnailWithPageId:(NSNumber *)pageId completionBlock:(ManagerCompletionBlock)completionBlock;
- (void)getKnowTip:(ManagerCompletionBlock)completionBlock;
- (void)getRandomTitle:(void (^)(NSString *title))completionBlock;

- (void)getCategoryMember:(NSString *)categoryLink
               memberType:(CategoryMemberType)memberType
               parameters:(NSDictionary * _Nullable)parameters
          completionBlock:(void (^)(CategoryMembersModel *))completionBlock;

- (void)getPagesWithCategory:(NSString *)categoryLink
                  parameters:(nullable NSDictionary *)parameters
             completionBlock:(void (^)(CategoryMembersModel *members))completionBlock DEPRECATED_ATTRIBUTE;

- (void)getSubCategoriesWithCategory:(NSString *)categoryLink
                          parameters:(nullable NSDictionary *)parameters
                     completionBlock:(void (^)(CategoryMembersModel *))completionBlock DEPRECATED_ATTRIBUTE;
@end

NS_ASSUME_NONNULL_END