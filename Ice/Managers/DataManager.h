//
//  DataManager.h
//  ice
//
//  Created by Vicent Tsai on 15/10/30.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

@import Foundation;

typedef void (^ManagerCompletionBlock)(NSArray *result);

@interface DataManager : NSObject

+ (instancetype)sharedManager;

- (void)getFeaturedQuotes:(ManagerCompletionBlock)completionBlock;
- (void)getPortals:(ManagerCompletionBlock)completionBlock;

@end
