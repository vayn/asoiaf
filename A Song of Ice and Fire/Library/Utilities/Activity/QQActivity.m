//
//  QQActivity.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/28.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "QQActivity.h"

@implementation QQActivity

- (instancetype)init
{
    self = [super init];

    if (self) {
        _successMessage = @"分享到QQ好友成功";
        _failureMessage = @"分享到QQ好友失败";
        [super setDelegate:self];
    }
    
    return self;
}

- (NSString *)activityTitle
{
    return @"QQ好友";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"qq"];
}

- (void)shareMessage:(OSMessage *)message
{
    [OpenShare shareToQQFriends:message Success:^(OSMessage *message) {
        MBProgressHUD *hud = [self messageHUD:_successMessage];
        [hud hide:YES afterDelay:kHUDShowtime];
    } Fail:^(OSMessage *message, NSError *error) {
        MBProgressHUD *hud = [self messageHUD:_failureMessage];
        [hud hide:YES afterDelay:kHUDShowtime];
    }];
}

@end
