//
//  DataManager.m
//  ice
//
//  Created by Vicent Tsai on 15/10/30.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "DataManager.h"
#import "AFNetworking.h"
#import "RegexKitLite.h"

#import "FeaturedQuoteModel.h"
#import "PortalModel.h"

@interface DataManager ()

@property (nonatomic, strong) NSString *siteURL;
@property (nonatomic, strong) AFHTTPSessionManager *manager;

@end

@implementation DataManager

+ (instancetype)sharedManager
{
    static DataManager *sharedManager = nil;

    @synchronized(self) {
        if (!sharedManager) {
            sharedManager = [[self alloc] initPrivate];
        }
    }

    return sharedManager;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[DataStore sharedStore]"
                                 userInfo:nil];
    return nil;
}

- (instancetype)initPrivate
{
    self = [super init];

    if (self) {
        _siteURL = @"http://asoiaf.huiji.wiki";
        _manager = [AFHTTPSessionManager manager];
    }

    return self;
}

- (void)getFeaturedQuotes:(ManagerCompletionBlock)completionBlock
{
    NSString *API = [[NSString alloc] initWithFormat:@"%@/api.php?action=expandtemplates&text={{Featured Quote}}&prop=wikitext&format=json",
                     self.siteURL];
    NSString *URL = [API stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    [_manager GET:URL
       parameters:nil
          success:^(NSURLSessionTask *task, id responseObject) {
              NSString *wikitext = responseObject[@"expandtemplates"][@"wikitext"];

              // Parse featured quote into key-value pairs
              NSString *regex = @"(?<=quote\\|)(.*?)(?=\\|)(?:\\|\\[\\[)(.*?)(?=\\]\\])";

              NSMutableArray *featuredQuotes = [[NSMutableArray alloc] init];

              [wikitext enumerateStringsMatchedByRegex:regex usingBlock:^(NSInteger captureCount,
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
          }
          failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
              NSLog(@"Error: %@", error);
          }
    ];
}

- (void)getPortals:(ManagerCompletionBlock)completionBlock
{
    NSString *API = [[NSString alloc] initWithFormat:@"%@/api.php?action=query&list=categorymembers&cmtitle=Category:Portal&cmnamespace=0&format=json",
                     self.siteURL];
    NSString *URL = [API stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    [_manager GET:URL
       parameters:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
              NSArray *portalObjects = responseObject[@"query"][@"categorymembers"];
              NSMutableArray *portals = [@[] mutableCopy];

              for (id portalObject in portalObjects) {
                  PortalModel *portalModel = [[PortalModel alloc] initWithTitle:portalObject[@"title"]
                                                                         pageId:(NSInteger)portalObject[@"pageid"]];
                  [portals addObject:portalModel];
              }

              completionBlock(portals);

              dispatch_async(dispatch_get_main_queue(), ^{
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"getPortals" object:nil];
              });
          }
          failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
              NSLog(@"Error: %@", error);
          }];
}

@end
