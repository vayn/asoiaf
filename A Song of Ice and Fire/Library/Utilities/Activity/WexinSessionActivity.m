//
//  WexinSessionActivity.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/27.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "WexinSessionActivity.h"

@implementation WexinSessionActivity

- (instancetype)init
{
    self = [super init];

    if (self) {
        _successMessage = @"微信分享到好友成功";
        _failureMessage = @"微信分享到好友失败";
        [super setDelegate:self];
    }
    
    return self;
}

- (NSString *)activityTitle
{
    return @"微信好友";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"wechat_session"];
}

- (void)shareMessage:(OSMessage *)message
{
    [OpenShare shareToWeixinSession:message Success:^(OSMessage *message) {
        MBProgressHUD *hud = [self messageHUD:_successMessage];
        [hud hide:YES afterDelay:kHUDShowtime];
    } Fail:^(OSMessage *message, NSError *error) {
        MBProgressHUD *hud = [self messageHUD:_failureMessage];
        [hud hide:YES afterDelay:kHUDShowtime];
    }];
}

@end