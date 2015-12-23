//
//  UINavigationController+TransparentNavigationBar.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/12.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <objc/runtime.h>
#import "UINavigationController+TransparentNavigationBar.h"

static void *OriginalTintColor;

@implementation UINavigationController (TransparentNavigationBar)

- (void)setTransparentNavigationBar
{
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setTranslucent:YES];
    [self.navigationBar setShadowImage:[UIImage new]];

    UIColor *tintColor = self.navigationBar.tintColor;
    if (objc_getAssociatedObject(self, &OriginalTintColor) == nil) {
        objc_setAssociatedObject(self, &OriginalTintColor, tintColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [self.navigationBar setTintColor: [UIColor clearColor]];
}

- (void)restoreDefaultNavigationBar
{
    [self.navigationBar setBackgroundImage:[[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault]
                             forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[[UINavigationBar appearance] shadowImage]];

    [self.navigationBar setTintColor:objc_getAssociatedObject(self, &OriginalTintColor)];
}

@end
