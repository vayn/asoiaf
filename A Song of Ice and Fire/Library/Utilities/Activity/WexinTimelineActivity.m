//
//  WexinTimelineActivity.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/27.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "WexinTimelineActivity.h"

@implementation WexinTimelineActivity

- (instancetype)init
{
    self = [super init];

    if (self) {
        _successMessage = @"微信分享到朋友圈成功";
        _failureMessage = @"微信分享到朋友圈失败";
        [super setDelegate:self];
    }
    
    return self;
}

- (NSString *)activityTitle
{
    return @"微信朋友圈";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"wechat_timeline"];
}

- (void)shareMessage:(OSMessage *)message
{
    [OpenShare shareToWeixinTimeline:message Success:^(OSMessage *message) {
        MBProgressHUD *hud = [self messageHUD:_successMessage];
        [hud hide:YES afterDelay:kHUD_SHOW_TIME];
    } Fail:^(OSMessage *message, NSError *error) {
        MBProgressHUD *hud = [self messageHUD:_failureMessage];
        [hud hide:YES afterDelay:kHUD_SHOW_TIME];
    }];
}

@end
