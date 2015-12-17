//
//  CubeNavigationAnimation.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/9.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "CubeNavigationAnimator.h"

@implementation CubeNavigationAnimator

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isReversed = NO;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning delegate

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];

    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    UIView *toView = toVC.view;
    UIView *fromView = fromVC.view;

    CGFloat direction = self.isReversed ? -1 : 1;
    CGFloat factor = -0.005;

    toView.layer.anchorPoint = CGPointMake(direction == 1 ? 0 : 1, 0.5);
    fromView.layer.anchorPoint = CGPointMake(direction == 1 ? 1 : 0, 0.5);

    CATransform3D viewFromTransform = CATransform3DMakeRotation(direction * M_PI_2, 0, 1, 0);
    CATransform3D viewToTransform = CATransform3DMakeRotation(-direction * M_PI_2, 0, 1, 0);

    // Add perspective in the z-axis
    viewFromTransform.m34 = factor;
    viewToTransform.m34 = factor;

    containerView.transform = CGAffineTransformMakeTranslation(direction * containerView.frame.size.width / 2, 0);
    toView.layer.transform = viewToTransform;

    [containerView insertSubview:toView belowSubview:fromView];

    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                     animations:^{
                         containerView.transform = CGAffineTransformMakeTranslation(-direction * containerView.frame.size.width / 2, 0);
                         fromView.layer.transform = viewFromTransform;
                         toView.layer.transform = CATransform3DIdentity;
                     } completion:^(BOOL finished) {
                         containerView.transform = CGAffineTransformIdentity;
                         fromView.layer.transform = CATransform3DIdentity;
                         toView.layer.transform = CATransform3DIdentity;
                         fromView.layer.anchorPoint = CGPointMake(0.5, 0.5);
                         toView.layer.anchorPoint = CGPointMake(0.5, 0.5);

                         if ([transitionContext transitionWasCancelled]) {
                             [toView removeFromSuperview];
                         } else {
                             [fromView removeFromSuperview];
                         }

                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}

@end
