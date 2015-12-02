//
//  CategoryMemberModel.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/2.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "CategoryMemberModel.h"

@implementation CategoryMemberModel

// Designated Intializer
- (instancetype)initWithTitle:(NSString *)aTitle pageId:(NSNumber *)aPageId
{
    self = [super init];
    if (self) {
        _title = aTitle;
        _pageId = aPageId;
    }
    return self;
}

- (instancetype)init
{
    self = [self initWithTitle:nil pageId:nil];
    return self;
}

@end