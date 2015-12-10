//
//  PortalNavigationInteraction.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/9.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "PortalNavigationInteraction.h"

@implementation PortalNavigationInteraction

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.shouldCompleteTransition = NO;
        self.transitionInProgress = NO;
        self.completionSpeed = 1 - self.percentComplete;
    }
    return self;
}

- (void)attachToViewController:(UIViewController *)vc
{
    self.navigationController = vc.navigationController;
    [self setupGestureRecognizer:vc.view];
}

- (void)setupGestureRecognizer:(UIView *)view
{
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [view addGestureRecognizer:panGesture];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint viewTranslation = [gestureRecognizer translationInView:gestureRecognizer.view.superview];

    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan: {
            self.transitionInProgress = YES;
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }

        case UIGestureRecognizerStateChanged: {
            CGFloat factor = MIN(MAX(viewTranslation.x / 200, 0), 1);
            self.shouldCompleteTransition = (factor > 0.5);
            [self updateInteractiveTransition:factor];
            break;
        }

        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            self.transitionInProgress = NO;
            if (!self.shouldCompleteTransition || (gestureRecognizer.state == UIGestureRecognizerStateCancelled)) {
                [self cancelInteractiveTransition];
            } else {
                [self finishInteractiveTransition];
            }
            break;
        }
        default: {
            break;
        }
    }
}

@end
