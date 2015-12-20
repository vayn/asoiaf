//
//  PortalModel.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/20.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "PortalModel.h"

@implementation PortalModel

- (instancetype)initWithTitle:(NSString *)aTitle
                         link:(NSString *)aLink
                       pageId:(NSNumber *)aPageId
              backgroundImage:(UIImage *)aImage
                   portalType:(PortalType)aPortalType
{
    self = [super initWithTitle:aTitle link:aLink pageId:aPageId backgroundImage:aImage];
    if (self) {
        _portalType = aPortalType;
    }
    return self;
}

@end
