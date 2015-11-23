//
//  PortalModel.h
//  ice
//
//  Created by Vicent Tsai on 15/11/7.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PortalModel : NSObject

@property (nonatomic, strong) NSNumber *pageId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) UIImage *backgroundImage;

- (instancetype)initWithTitle:(NSString *)aTitle;
- (instancetype)initWithTitle:(NSString *)aTitle pageId:(NSNumber *)aPageId;
- (instancetype)initWithTitle:(NSString *)aTitle pageId:(NSNumber *)aPageId link:(NSString *)aLink;

@end
