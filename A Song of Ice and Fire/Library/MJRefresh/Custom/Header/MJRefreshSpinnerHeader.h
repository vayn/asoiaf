//
//  MJRefreshAutoSpinneHeader.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/4.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "MJRefreshStateHeader.h"

@class Spinner;

@interface MJRefreshSpinnerHeader : MJRefreshStateHeader

- (void)setSpinner:(Spinner *)spinner forState:(MJRefreshState)state;

@end
