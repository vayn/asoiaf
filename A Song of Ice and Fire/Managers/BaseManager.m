//
//  SharedManager.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/13.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "BaseManager.h"

@implementation BaseManager

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[DataStore sharedManager]"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initManager
{
    self = [super init];

    if (self) {
        _manager = [AFHTTPSessionManager manager];

        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            //NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
            
            if (status == AFNetworkReachabilityStatusNotReachable) {
              [[NSNotificationCenter defaultCenter] postNotificationName:ERR_INTERNET_DISCONNECTED object:nil];
            }
        }];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }

    return self;
}

#pragma mark - Helpers

+ (void)processImageDataWithURL:(NSURL *)url andBlock:(void (^)(NSData *imageData))processImage
{
    dispatch_queue_t callerQueue = dispatch_get_main_queue();
    dispatch_queue_t downloadQueue = dispatch_queue_create("li.hezhi.thumbnailprocessqueue", NULL);
    dispatch_async(downloadQueue, ^{
        NSData *imageData = [NSData dataWithContentsOfURL:url options:0 error:nil];

        dispatch_async(callerQueue, ^{
            processImage(imageData);
        });
    });
}

+ (NSString *)getAbsoluteUrl:(NSString *)url
{
    NSString *AbsoluteUrl = [NSString stringWithFormat:@"%@/%@", kSiteUrl, url];
    NSString *encodedUrl = [AbsoluteUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    return encodedUrl;
}

@end
