//
//  DataStore.h
//  ice
//
//  Created by Vicent Tsai on 15/10/30.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

@import Foundation;

@interface DataStore : NSObject

@property (nonatomic, strong) NSArray *category;

+ (instancetype)sharedStore;
- (NSArray *)dataForCategory:(NSString *)category;

@end
