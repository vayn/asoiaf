//
//  PortalNavigationAnimation.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/9.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PortalNavigationAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isReversed;

@end
