//
//  EmptyDataSetDelegate.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/13.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIColor+Hexadecimal.h"
#import "UIScrollView+EmptyDataSet.h"

@interface EmptyDataSetDelegate : NSObject <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (nonatomic, getter=isLoading) BOOL loading;

@end
