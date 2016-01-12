//
//  KnowTipModel.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/11.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "KnowTipModel.h"

@implementation KnowTipModel

- (instancetype)initWithTip:(NSString *)tip link:(NSString *)link
{
    self = [super init];
    if (self) {
        _tip = tip;
        _link = link;
    }
    return self;
}

@end
