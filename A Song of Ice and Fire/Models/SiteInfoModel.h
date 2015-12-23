//
//  SiteInfoModel.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/23.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SiteInfoModel : NSObject

@property (nonatomic, strong) NSNumber *pages;
@property (nonatomic, strong) NSNumber *articles;
@property (nonatomic, strong) NSNumber *edits;
@property (nonatomic, strong) NSNumber *images;
@property (nonatomic, strong) NSNumber *users;
@property (nonatomic, strong) NSNumber *activeUsers;
@property (nonatomic, strong) NSNumber *admins;

@end
