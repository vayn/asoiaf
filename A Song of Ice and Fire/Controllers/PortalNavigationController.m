//
//  PortalNavigationController.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/7.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "PortalNavigationController.h"

@interface PortalNavigationController () <UINavigationControllerDelegate>

@end

@implementation PortalNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPush) {
        return nil;
    }

    if (operation == UINavigationControllerOperationPop) {
        return nil;
    }

    return nil;
}

@end
