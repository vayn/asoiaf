//
//  CategoryMemberModel.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/2.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "CategoryMemberModel.h"

@implementation CategoryMemberModel

- (instancetype)initWithLink:(NSString *)aLink
{
    return [self initWithLink:aLink pageId:nil];
}

// Designated Intializer
- (instancetype)initWithLink:(NSString *)aLink pageId:(NSNumber *)aPageId
{
    self = [super init];
    if (self) {
        _link = aLink;
        _pageId = aPageId;
    }
    return self;
}

- (void)setLink:(NSString *)link
{
    _link = link;

    if ([link rangeOfString:@":"].location != NSNotFound) {
        NSArray *temp = [link componentsSeparatedByString:@":"];
        _title = temp[1];
    } else {
        _title = link;
    }
}

@end