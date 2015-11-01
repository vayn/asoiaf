//
//  DataManager.h
//  ice
//
//  Created by Vicent Tsai on 15/10/30.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

@import Foundation;

@interface DataManager : NSObject

+ (instancetype)sharedManager;

- (void)getFeaturedQuotes:(void (^)(NSArray *featuredQuotes))completion;

@end
