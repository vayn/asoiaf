//
//  SharedManager.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/13.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

@import Foundation;

#import "Models.h"
#import "AFNetworking.h"
#import "RegexKitLite.h"

@class CategoryMembersModel;

#define NSStringMultiline(...) @#__VA_ARGS__

#define ERR_INTERNET_DISCONNECTED @"ERR_INTERNET_DISCONNECTED"
#define INTERNET_TIMEOUT 15;

NS_ASSUME_NONNULL_BEGIN

static NSString * const kSiteUrl = @"http://asoiaf.huiji.wiki";

typedef void (^ManagerCompletionBlock)(__nullable id responseObject);

@interface BaseManager : NSObject

@property (nonatomic, strong) AFHTTPSessionManager *manager;

+ (void)processImageDataWithURL:(NSURL *)url andBlock:(void (^)(NSData *imageData))processImage;
+ (NSString *)getAbsoluteUrl:(NSString *)url;

- (instancetype)initManager;

@end

NS_ASSUME_NONNULL_END
