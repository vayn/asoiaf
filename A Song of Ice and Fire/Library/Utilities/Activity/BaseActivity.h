//
//  BaseActivity.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/27.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OpenShareHeader.h"
#import "MBProgressHUD.h"

static CGFloat const kHUDShowtime = 2.18;

@protocol BaseActivityDelegate <NSObject>

@required
- (void)shareMessage:(OSMessage *)message;
@property (nonatomic, strong) NSString *successMessage;
@property (nonatomic, strong) NSString *failureMessage;

@end

@interface BaseActivity : UIActivity {
    NSString *title;
    UIImage *image;
    NSURL *url;
    UIView *hudScene;
}

@property (nonatomic, weak) id<BaseActivityDelegate> delegate;

- (MBProgressHUD *)messageHUD:(NSString *)message;

@end
