//
//  CubeNavigationDelegate.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/12.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "CubeNavigationDelegate.h"

#import "CubeNavigationAnimator.h"
#import "CubeNavigationInteraction.h"

@interface CubeNavigationDelegate ()

@property (nonatomic, strong) CubeNavigationAnimator *portalNavigationAnimator;
@property (nonatomic, strong) CubeNavigationInteraction *portalNavigationInteraction;

@end

@implementation CubeNavigationDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.portalNavigationAnimator = [[CubeNavigationAnimator alloc] init];
        self.portalNavigationInteraction = [[CubeNavigationInteraction alloc] init];
    }
    return self;
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPush) {
        [self.portalNavigationInteraction attachToViewController:toVC];
    }

    self.portalNavigationAnimator.isReversed = (operation == UINavigationControllerOperationPop);

    return self.portalNavigationAnimator;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return self.portalNavigationInteraction.transitionInProgress ? self.portalNavigationInteraction : nil;
}


@end
