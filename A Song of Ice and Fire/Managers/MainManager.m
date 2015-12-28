//
//  MainManager.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/13.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "MainManager.h"

@implementation MainManager

+ (instancetype)sharedManager
{
    static MainManager *sharedManager = nil;

    @synchronized(self) {
        if (!sharedManager) {
            sharedManager = [[self alloc] initManager];
        }
    }

    return sharedManager;
}

- (void)getSiteInfo:(void (^)(SiteInfoModel *model))completionBlock;
{
    NSString *Api = [BaseManager getAbsoluteUrl:@"api.php?action=query&meta=siteinfo&siprop=statistics&format=json"];

    [self.manager GET:Api parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *statistics = responseObject[@"query"][@"statistics"];
        SiteInfoModel *siteInfoModel = [[SiteInfoModel alloc] init];

        siteInfoModel.pages = statistics[@"pages"];
        siteInfoModel.articles = statistics[@"articles"];
        siteInfoModel.edits = statistics[@"edits"];
        siteInfoModel.images = statistics[@"images"];
        siteInfoModel.users = statistics[@"users"];
        siteInfoModel.activeUsers = statistics[@"activeusers"];
        siteInfoModel.admins = statistics[@"admins"];

        completionBlock(siteInfoModel);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%s: %@", __FUNCTION__, error);
    }];
}

- (void)getRandomTitle:(void (^)(NSString *title))completionBlock
{
    NSString *Api = [BaseManager getAbsoluteUrl:@"api.php?action=query&list=random&rnlimit=1&format=json"];
    Api = [Api stringByAppendingString:[NSString stringWithFormat:@"&%f", CFAbsoluteTimeGetCurrent()]];

    [self.manager GET:Api parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *blacklist = @[@"File:", @"Category:", @"Talk:", @"User:", @"MediaWiki:", @"Template:"];
        BOOL isOnBlackList = NO;

        NSDictionary *random = responseObject[@"query"][@"random"][0];
        NSString *title = random[@"title"];

        for (NSString *prefix in blacklist) {
            if ([title hasPrefix:prefix]) {
                isOnBlackList = YES;
                break;
            }
        }

        if (isOnBlackList) {
            [self getRandomTitle:completionBlock];
        } else {
            completionBlock(title);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"%s: %@", __FUNCTION__, error);
    }];
}

- (void)getFeaturedQuotes:(ManagerCompletionBlock)completionBlock
{
    NSString *Api = [BaseManager getAbsoluteUrl:@"api.php?action=expandtemplates&text={{Featured Quote}}&prop=wikitext&format=json"];

    [self.manager GET:Api parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSString *wikitext = responseObject[@"expandtemplates"][@"wikitext"];
        wikitext = [wikitext stringByReplacingOccurrencesOfString: @"<br>" withString: @"\n"];

        // Parse featured quote into key-value pairs
        NSString *pattern = @"(?<=quote\\|)(.*?)(?=\\|)(?:\\|\\[\\[)(.*?)(?=\\]\\])";

        NSMutableArray *featuredQuotes = [[NSMutableArray alloc] init];

        [wikitext enumerateStringsMatchedByRegex:pattern usingBlock:^(NSInteger captureCount,
                                                                      NSString *const __unsafe_unretained *capturedStrings,
                                                                      const NSRange *capturedRanges, volatile BOOL *const stop) {
            FeaturedQuoteModel *featuredQuote = [[FeaturedQuoteModel alloc] initWithQuote:capturedStrings[1]
                                                                                   author:capturedStrings[2]];
            [featuredQuotes addObject:featuredQuote];
        }];

        completionBlock(featuredQuotes);

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getFeaturedQuotes" object:nil];
        });
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"%s: %@", __FUNCTION__, error);
    }];
}

- (void)getKnowTip:(ManagerCompletionBlock)completionBlock
{
    NSString *Api = [BaseManager getAbsoluteUrl:@"api.php?action=expandtemplates&text={{Do You Know}}&prop=wikitext&format=json"];

    [self.manager GET:Api parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSString *wikitext = responseObject[@"expandtemplates"][@"wikitext"];
        NSMutableArray *options = [@[] mutableCopy];

        // Parse "Do You Know" into key-value pairs
        NSString *pattern = @"<option>(.*?)</option>";

        [wikitext enumerateStringsMatchedByRegex:pattern
                                     options:RKLDotAll
                                     inRange:NSMakeRange(0, [wikitext length])
                                       error:nil
                          enumerationOptions:RKLRegexEnumerationNoOptions
                                  usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
                                      [options addObject:capturedStrings[1]];
                                  }];

        completionBlock(options);

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"getKnowTip" object:nil];
        });
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"%s: %@", __FUNCTION__, error);
    }];
}

- (void)getWikiEntry:(NSString *)title completionBlock:(void (^)(NSString *wikiEntry))completionBlock
{
    NSString *Api = [BaseManager getAbsoluteUrl:NSStringMultiline(api.php?action=query&prop=revisions&
                                                                  rvprop=content&rvparse&format=json&redirects)];
    NSDictionary *paramters = @{@"titles": title};

    [self.manager GET:Api parameters:paramters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        NSArray *htmlTemp = [[[responseObject objectForKey:@"query"] objectForKey:@"pages"] allValues];
        NSString *wikiEntry = [[[[htmlTemp objectAtIndex:0] objectForKey:@"revisions"] objectAtIndex:0] objectForKey:@"*"];

        completionBlock(wikiEntry);

    } failure:^(NSURLSessionDataTask *task, NSError *error) {

        NSLog(@"%s: %@", __FUNCTION__, error);

    }];
}

- (void)searchWikiEntry:(NSString *)term completionBlock:(void (^)(NSArray *searchResults))completionBlock;
{
    if (!term || term.length == 0) {
        completionBlock(@[]);
        return;
    }

    NSString *Api = [BaseManager getAbsoluteUrl:NSStringMultiline(api.php?action=query&list=search&srprop=snippet&
                                                                  srlimit=10&format=json&continue)];
    NSDictionary *parameters = @{@"srsearch": term};

    [self.manager GET:Api parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {

        NSArray *searchResults = [[responseObject objectForKey:@"query"] objectForKey:@"search"];
        completionBlock(searchResults);

    } failure:^(NSURLSessionDataTask *task, NSError *error) {

        NSLog(@"%s: %@", __FUNCTION__, error);

    }];

}

@end
