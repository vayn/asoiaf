//
//  MJRefreshAutoSpinneFooter.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/4.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "MJRefreshAutoStateFooter.h"

@class Spinner;

@interface MJRefreshAutoSpinnerFooter : MJRefreshAutoStateFooter

- (void)setSpinner:(Spinner *)spinner forState:(MJRefreshState)state;

@end
