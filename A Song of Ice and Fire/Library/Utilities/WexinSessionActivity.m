//
//  WeChatActivity.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/27.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "WexinSessionActivity.h"

#import "OpenShareHeader.h"
#import "MBProgressHUD.h"

static CGFloat const kHUD_SHOW_TIME = 2.18;

@implementation WexinSessionActivity

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (NSString *)activityType
{
    return NSStringFromClass([self class]);
}

- (NSString *)activityTitle
{
    return @"微信朋友圈";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"wechat_timeline"];
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
    NSLog(@"%s", __FUNCTION__);
    return YES;
}

- (UIViewController *)activityViewController
{
    NSLog(@"%s",__FUNCTION__);
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

    [OpenShare shareToWeixinTimeline:msg Success:^(OSMessage *message) {
        MBProgressHUD *hud = [self messageHUD:@"微信分享到朋友圈成功"];
        [hud hide:YES afterDelay:kHUD_SHOW_TIME];
    } Fail:^(OSMessage *message, NSError *error) {
        MBProgressHUD *hud = [self messageHUD:@"微信分享到朋友圈失败"];
        [hud hide:YES afterDelay:kHUD_SHOW_TIME];
    }];

    [self activityDidFinish:YES];
}

#pragma mark - Private Helper Function

- (MBProgressHUD *)messageHUD:(NSString *)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:hudScene animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    hud.labelText = message;

    return hud;
}

@end
