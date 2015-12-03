//
//  CMBaseTableViewController.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/4.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WikiViewController.h"

#import "Models.h"
#import "DataManager.h"

#import "MJRefresh.h"

@class CategoryMemberModel;

NS_ASSUME_NONNULL_BEGIN

@protocol CMBaseTableDelegate <NSObject>

@required
- (void)getMembersWithCategory:(NSString *)categoryLink
                    parameters:(nullable NSDictionary *)parameters
               completionBlock:(void (^)(CategoryMembersModel *members))completionBlock;

@end

@interface CMBaseTableViewController : UITableViewController

@property (nonatomic, weak) id<CMBaseTableDelegate> delegate;

@property (nonatomic, strong) CategoryMemberModel *parentCategory;

@property (nonatomic, strong) NSMutableArray *previousContinue;
@property (nonatomic, strong) NSMutableArray *nextContinue;

@property (nonatomic, strong) NSArray<CategoryMemberModel *> *members;
@property (nonatomic, assign) BOOL isHeaderRefreshing;

@property (nonatomic, strong) UIViewController *parentVC;

@end

NS_ASSUME_NONNULL_END
