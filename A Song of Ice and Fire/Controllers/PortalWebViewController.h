//
//  PortalWebViewController.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/19.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategoryMemberModel;

@interface PortalWebViewController : UIViewController

@property (nonatomic, strong) CategoryMemberModel *category;

- (instancetype)initWithCategory:(CategoryMemberModel *)category;

@end
