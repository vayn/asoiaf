//
//  KnowTipModel.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/11.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KnowTipModel : NSObject

@property (nonatomic, strong) NSString *tip;
@property (nonatomic, strong) NSString *link;

- (instancetype)initWithTip:(NSString *)tip link:(NSString *)link;

@end
