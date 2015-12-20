//
//  CategoryMemberModel.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/2.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "CategoryMemberModel.h"

@implementation CategoryMemberModel

- (instancetype)initWithTitle:(NSString *)aTitle
{
    return [self initWithTitle:aTitle pageId:nil];
}

- (instancetype)initWithTitle:(NSString *)aTitle pageId:(NSNumber *)aPageId
{
    return [self initWithTitle:aTitle link:nil pageId:aPageId];
}

- (instancetype)initWithTitle:(NSString *)aTitle link:(NSString *)aLink pageId:(NSNumber *)aPageId
{
    return [self initWithTitle:aTitle link:aLink pageId:aPageId backgroundImage:nil];
}

// Designated Intializer
- (instancetype)initWithTitle:(NSString *)aTitle link:(NSString *)aLink pageId:(NSNumber *)aPageId backgroundImage:(UIImage *)aImage
{
    self = [super init];

    if (self) {
        if ([aTitle rangeOfString:@":"].location != NSNotFound) {
            NSArray *temp = [aTitle componentsSeparatedByString:@":"];
            _title = temp[1];
        } else {
            _title = aTitle;
        }

        if (aLink) {
            _link = aLink;
        } else {
            _link = aTitle;
        }

        _pageId = aPageId;
        _backgroundImage = aImage;
    }

    return self;
}

@end