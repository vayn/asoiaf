//
//  CategoryMembersModel.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/3.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CategoryMemberModel;

@interface CategoryMembersModel : NSObject

@property (nonatomic, strong) NSArray<CategoryMemberModel *> *members;
@property (nonatomic, strong) NSString *cmcontinue;

- (instancetype)initWithMembers:(NSArray<CategoryMemberModel *> *)members cmcontinue:(NSString *)cmcontinue;

@end
