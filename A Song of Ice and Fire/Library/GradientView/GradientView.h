//
//  GradientView.h
//  GradientView
//
//  Created by xun yanan on 14-6-14.
//  Copyright (c) 2014年 xun yanan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GradientType) {
    TransparentGradientType        = 1,
    ColorGradientType              = 1 >> 2,
    TransparentGradientTwiceType   = 1 >> 3,
    TransparentAnotherGradientType = 1 >> 4,
};

@interface GradientView : UIView

- (instancetype)initWithFrame:(CGRect)frame type:(GradientType)type;
- (void) insertTwiceTransparentGradient;
- (void) insertTransparentGradient;

@end
