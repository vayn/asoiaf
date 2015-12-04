//
//  MJRefreshSpinnerFooter.h
//
//

#import "MJRefreshAutoStateFooter.h"

@class Spinner;

@interface MJRefreshSpinnerFooter : MJRefreshAutoStateFooter

- (void)setSpinner:(Spinner *)spinner forState:(MJRefreshState)state;

@end
