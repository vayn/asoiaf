//
//  PortalNavigationDelegate.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/12.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "PortalNavigationDelegate.h"

#import "PortalNavigationAnimator.h"
#import "PortalNavigationInteraction.h"

@interface PortalNavigationDelegate ()

@property (nonatomic, strong) PortalNavigationAnimator *portalNavigationAnimator;
@property (nonatomic, strong) PortalNavigationInteraction *portalNavigationInteraction;

@end

@implementation PortalNavigationDelegate

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.portalNavigationAnimator = [[PortalNavigationAnimator alloc] init];
        self.portalNavigationInteraction = [[PortalNavigationInteraction alloc] init];
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
