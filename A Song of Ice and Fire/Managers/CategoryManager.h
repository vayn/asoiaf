//
//  CategoryManager.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/13.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "BaseManager.h"

typedef NS_ENUM(NSUInteger, CategoryMemberType) {
    CMCategoryType,
    CMPageType,
};

NS_ASSUME_NONNULL_BEGIN

@interface CategoryManager : BaseManager

+ (instancetype)sharedManager;

- (void)getCategories:(ManagerCompletionBlock)completionBlock;

- (void)getPagesWithCategory:(NSString *)categoryLink
                  parameters:(nullable NSDictionary *)parameters
             completionBlock:(void (^)(CategoryMembersModel *members))completionBlock DEPRECATED_ATTRIBUTE;

- (void)getSubCategoriesWithCategory:(NSString *)categoryLink
                          parameters:(nullable NSDictionary *)parameters
                     completionBlock:(void (^)(CategoryMembersModel *))completionBlock DEPRECATED_ATTRIBUTE;

- (void)getCategoryMember:(NSString *)categoryLink
               memberType:(CategoryMemberType)memberType
               parameters:(NSDictionary * _Nullable)parameters
          completionBlock:(void (^)(CategoryMembersModel *))completionBlock;

@end

NS_ASSUME_NONNULL_END