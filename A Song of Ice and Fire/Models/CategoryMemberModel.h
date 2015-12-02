//
//  CategoryMemeberModel.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/2.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoryMemberModel : NSObject

@property (nonatomic, strong) NSNumber *pageId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) UIImage *backgroundImage;

- (instancetype)initWithLink:(NSString *)aLink;
- (instancetype)initWithLink:(NSString *)aLink pageId:(NSNumber *)aPageId;

@end
