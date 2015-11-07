//
//  PortalModel.m
//  ice
//
//  Created by Vicent Tsai on 15/11/7.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "PortalModel.h"

@implementation PortalModel

- (instancetype)initWithTitle:(NSString *)title pageId:(NSInteger)pageId
{
    self = [super init];
    if (self) {
        _title = title;
        _pageId = pageId;
    }
    return self;
}

@end
