//
//  PortalModel.m
//  ice
//
//  Created by Vicent Tsai on 15/11/7.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "PortalModel.h"

@implementation PortalModel

-(instancetype)initWithTitle:(NSString *)aTitle
{
    return [self initWithTitle:aTitle pageId:nil];
}

- (instancetype)initWithTitle:(NSString *)aTitle pageId:(NSNumber *)aPageId
{
    return [self initWithTitle:aTitle pageId:aPageId link:nil];
}

- (instancetype)initWithTitle:(NSString *)aTitle pageId:(NSNumber *)aPageId link:(NSString *)aLink
{

    self = [super init];
    if (self) {
        _title = aTitle;
        _pageId = aPageId;
        _link = aLink;
    }
    return self;
}

@end
