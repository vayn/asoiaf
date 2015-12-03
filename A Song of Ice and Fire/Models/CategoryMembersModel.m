//
//  CategoryMembersModel.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/3.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "CategoryMembersModel.h"
#import "CategoryMemberModel.h"

@implementation CategoryMembersModel

- (instancetype)initWithMembers:(NSArray<CategoryMemberModel *> *)members cmcontinue:(NSString *)cmcontinue
{
    self = [super init];
    if (self) {
        _members = members;
        _cmcontinue = cmcontinue;
    }
    return self;
}

@end
