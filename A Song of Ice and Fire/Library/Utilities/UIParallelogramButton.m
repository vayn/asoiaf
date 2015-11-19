//
//  UIParallelogramButton.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/19.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "UIParallelogramButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIParallelogramButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _offset = 0.0;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *maskPath = [UIBezierPath bezierPath];
    [maskPath moveToPoint:CGPointMake(rect.origin.x + _offset, rect.origin.y)];
    [maskPath addLineToPoint:CGPointMake(rect.origin.x + rect.size.width, rect.origin.y)];
    [maskPath addLineToPoint:CGPointMake((rect.origin.x - _offset) + rect.size.width, rect.origin.y + rect.size.height)];
    [maskPath addLineToPoint:CGPointMake(rect.origin.x, rect.origin.y + rect.size.height)];
    [maskPath closePath];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

// Pass 0..1 value to either skewX if you want to compress along the X axis
// or skewY if you want to compress along the Y axis
- (void)parallelogramButtonWithButton:(UIButton *)button withSkewX:(CGFloat)skewX withSkewY:(CGFloat)skewY
{
    CGAffineTransform affineTransform =  CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMake(1, skewY, skewX, 1, 0, 0));
    button.layer.affineTransform = affineTransform;
}

@end
