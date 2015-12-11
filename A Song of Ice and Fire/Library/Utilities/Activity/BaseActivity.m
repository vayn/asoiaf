//
//  BaseActivity.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/27.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "BaseActivity.h"

@implementation BaseActivity

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (NSString *)activityType
{
    return NSStringFromClass([self class]);
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[UIImage class]]) {
            image = activityItem;
        }
        if ([activityItem isKindOfClass:[NSURL class]]) {
            url = activityItem;
        }
        if ([activityItem isKindOfClass:[NSString class]]) {
            title = activityItem;
        }
        if ([activityItem isKindOfClass:[UIView class]]) {
            hudScene = activityItem;
        }
    }
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    //NSLog(@"%s", __FUNCTION__);
    return YES;
}

- (UIViewController *)activityViewController
{
    //NSLog(@"%s",__FUNCTION__);
    return nil;
}

- (void)performActivity
{
    // This is where you can do anything you want, and is the whole reason for creating a custom
    // UIActivity

    OSMessage *msg = [[OSMessage alloc] init];
    msg.title = [NSString stringWithFormat:@"冰与火之歌 - %@", title];
    msg.desc = title;
    msg.link = [url absoluteString];

    if (image) {
        msg.image = image;
    } else {
        msg.image = [UIImage imageNamed:@"Launch Background"];
    }

    [self.delegate shareMessage:msg];

    [self activityDidFinish:YES];
}

#pragma mark - Public Helper Function

- (MBProgressHUD *)messageHUD:(NSString *)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:hudScene animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    hud.labelText = message;

    return hud;
}

@end
