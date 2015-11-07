//
//  FeaturedQuoteModel.h
//  ice
//
//  Created by Vicent Tsai on 15/11/1.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeaturedQuoteModel : NSObject

@property (nonatomic, strong) NSString *quote;
@property (nonatomic, strong) NSString *author;

- (instancetype)initWithQuote:(NSString *)quote author:(NSString *)author;

@end
