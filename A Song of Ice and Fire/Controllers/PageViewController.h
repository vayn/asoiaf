//
//  PageViewController.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/23.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategoryMemberModel;

@interface PageViewController : UITableViewController

@property (nonatomic, strong) CategoryMemberModel *parentCategory;
@property (nonatomic, strong) NSMutableArray *previousContinue;
@property (nonatomic, strong) NSMutableArray *nextContinue;

@property (nonatomic, strong) UIViewController *parentVC;

@end
