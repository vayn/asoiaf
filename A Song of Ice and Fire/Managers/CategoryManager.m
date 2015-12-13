//
//  CategoryManager.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/13.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "CategoryManager.h"

@implementation CategoryManager

+ (instancetype)sharedManager
{
    static CategoryManager *sharedManager = nil;

    @synchronized(self) {
        if (!sharedManager) {
            sharedManager = [[self alloc] initManager];
        }
    }

    return sharedManager;
}

- (void)getCategories:(ManagerCompletionBlock)completionBlock
{
    NSString *Api = [BaseManager getAbsoluteUrl:@"api.php?action=query&list=categorymembers&cmtitle=Category:Portal&cmnamespace=0&format=json"];

    [self.manager GET:Api parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSArray *categoryMembersArray = responseObject[@"query"][@"categorymembers"];
        NSMutableArray *portals = [@[] mutableCopy];

        for (id cmObject in categoryMembersArray) {
            NSNumber *pageId = cmObject[@"pageid"];

            // Hack: 306 和 5480 都是「人物」，只要 5480
            if ([pageId isEqualToNumber:@306]) {
                continue;
            }

            NSString *title = cmObject[@"title"];

            CategoryMemberModel *categoryMember = [[CategoryMemberModel alloc] initWithTitle:title pageId:pageId];
            [portals addObject:categoryMember];
        }

        completionBlock(portals);

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getPortals" object:nil];
        });
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"%s: %@", __FUNCTION__, error);
    }];
}

- (void)getPagesWithCategory:(NSString *)categoryLink
                  parameters:(nullable NSDictionary *)parameters
             completionBlock:(void (^)(CategoryMembersModel *))completionBlock
{
    return [self getCategoryMember:categoryLink memberType:CMPageType parameters:parameters completionBlock:completionBlock];
}

- (void)getSubCategoriesWithCategory:(NSString *)categoryLink
                          parameters:(nullable NSDictionary *)parameters
                     completionBlock:(void (^)(CategoryMembersModel *))completionBlock
{
    return [self getCategoryMember:categoryLink memberType:CMCategoryType parameters:parameters completionBlock:completionBlock];
}

- (void)getCategoryMember:(NSString *)categoryLink
               memberType:(CategoryMemberType)memberType
               parameters:(nullable NSDictionary *)parameters
          completionBlock:(void (^)(CategoryMembersModel *))completionBlock
{
    NSString *Api = nil;

    switch (memberType) {
        case CMPageType:
            Api = [BaseManager getAbsoluteUrl:@"api.php?action=query&list=categorymembers&cmtitle=%@&cmnamespace=0&format=json&continue"];
            break;
        case CMCategoryType:
            Api = [BaseManager getAbsoluteUrl:@"api.php?action=query&list=categorymembers&cmtype=subcat&cmtitle=%@&format=json&continue"];
            break;

        default:
            break;
    }

    [self.manager GET:Api parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *cmcontinue = responseObject[@"continue"][@"cmcontinue"];
        NSMutableArray<CategoryMemberModel *> *membersArray = [@[] mutableCopy];

        for (NSDictionary *categoryMember in responseObject[@"query"][@"categorymembers"]) {
            [membersArray addObject:[[CategoryMemberModel alloc] initWithTitle:categoryMember[@"title"]
                                                                        pageId:categoryMember[@"pageid"]]];
        }

        CategoryMembersModel *members = [[CategoryMembersModel alloc] initWithMembers:[membersArray copy] cmcontinue:cmcontinue];
        completionBlock(members);

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getCategoryMember" object:nil];
        });
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%s: %@", __FUNCTION__, error);
    }];
}

@end
