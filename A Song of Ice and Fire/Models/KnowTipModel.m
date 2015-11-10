//
//  KnowTipModel.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/11.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "KnowTipModel.h"

@implementation KnowTipModel

- (instancetype)initWithTip:(NSString *)tip title:(NSString *)title
{
    self = [super init];
    if (self) {
        _tip = tip;
        _title = title;
    }
    return self;
}

@end
