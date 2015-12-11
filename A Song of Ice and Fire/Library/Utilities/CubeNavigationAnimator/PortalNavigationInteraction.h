//
//  PortalNavigationInteraction.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/9.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PortalNavigationInteraction : UIPercentDrivenInteractiveTransition <UIViewControllerInteractiveTransitioning>

@property (nonatomic, strong) UINavigationController *navigationController;

@property (nonatomic, assign) BOOL shouldCompleteTransition;
@property (nonatomic, assign) BOOL transitionInProgress;

- (void)attachToViewController:(UIViewController *)vc;

@end
