//
//  UIParallelogramButton.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/19.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIParallelogramButton : UIButton

@property CGFloat offset;

- (void)parallelogramButtonWithButton:(UIButton *)button withSkewX:(CGFloat)skewX withSkewY:(CGFloat)skewY;

@end
