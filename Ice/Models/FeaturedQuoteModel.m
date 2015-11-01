//
//  FeaturedQuote.m
//  ice
//
//  Created by Vicent Tsai on 15/11/1.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "FeaturedQuoteModel.h"

@implementation FeaturedQuoteModel

- (instancetype)initWithQuote:(NSString *)quote author:(NSString *)author
{
    self = [super init];

    if (self) {
        _quote = quote;
        _author = author;
    }

    return self;
}

@end
