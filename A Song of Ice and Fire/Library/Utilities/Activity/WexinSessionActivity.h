//
//  WexinSessionActivity.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/27.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "BaseActivity.h"

@interface WexinSessionActivity : BaseActivity <BaseActivityDelegate>

@property (nonatomic, strong) NSString *successMessage;
@property (nonatomic, strong) NSString *failureMessage;

@end
