//
//  QQActivity.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/28.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "BaseActivity.h"

@interface QQActivity : BaseActivity <BaseActivityDelegate>

@property (nonatomic, strong) NSString *successMessage;
@property (nonatomic, strong) NSString *failureMessage;

@end
