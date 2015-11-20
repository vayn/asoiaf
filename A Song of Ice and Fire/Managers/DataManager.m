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

#define ERR_INTERNET_DISCONNECTED @"ERR_INTERNET_DISCONNECTED"

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

- (void)getFeaturedQuotes:(ManagerCompletionBlock)completionBlock
{
    NSString *API = [NSString stringWithFormat:@"%@/api.php?action=expandtemplates&text={{Featured Quote}}&prop=wikitext&format=json",
                     self.siteURL];
    NSString *URL = [API stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    [_manager GET:URL
       parameters:nil
          success:^(NSURLSessionTask *task, id responseObject) {
              NSString *wikitext = responseObject[@"expandtemplates"][@"wikitext"];

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
              NSLog(@"Error: %@", error);
          }
    ];
}

- (void)getKnowTip:(ManagerCompletionBlock)completionBlock
{
    NSString *API = [NSString stringWithFormat:@"%@/api.php?action=expandtemplates&text={{Do You Know}}&prop=wikitext&format=json",
                     self.siteURL];
    NSString *URL = [API stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    [_manager GET:URL
       parameters:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
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
              NSLog(@"Error: %@", error);
          }];
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
                  NSNumber *pageId = portalObject[@"pageid"];

                  // Hack: 306 和 5480 都是「人物」，只要 306
                  if ([pageId isEqualToNumber:@(5480)]) {
                      continue;
                  }

                  NSString *title = portalObject[@"title"];

                  if ([title rangeOfString:@":"].location != NSNotFound) {
                      NSArray *temp = [title componentsSeparatedByString:@":"];
                      title = temp[1];
                  }

                  PortalModel *portalModel = [[PortalModel alloc] initWithTitle:title pageId:pageId];
                  [portals addObject:portalModel];
              }

              completionBlock(portals);

              dispatch_async(dispatch_get_main_queue(), ^{
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"getPortals" object:nil];
              });
          } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
              NSLog(@"Error: %@", error);
          }];
}

- (void)getPageThumbnailWithPageId:(NSNumber *)pageId completionBlock:(ManagerCompletionBlock)completionBlock
{
    NSString *API = [NSString stringWithFormat:@"%@/api.php?action=query&pageids=%@&prop=pageimages&format=json&pithumbsize=120",
                     self.siteURL, [pageId stringValue]];
    NSString *URL = [API stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    [_manager GET:URL
       parameters:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
              NSURL *sourceURL;
              NSDictionary *page = responseObject[@"query"][@"pages"][[pageId stringValue]];
              NSDictionary *thumbnail = [page objectForKey:@"thumbnail"];

              if (thumbnail != nil) {
                  NSString *thumbnailSource = thumbnail[@"source"];
                  sourceURL = [NSURL URLWithString:thumbnailSource];
              } else {
                  switch ([pageId integerValue]) {
                      case 5483: { // 文化
                          sourceURL = [NSURL URLWithString:@"http://cdn.huijiwiki.com/asoiaf/thumb.php?f=Faith_by_thegryph.jpg&width=120"];
                          break;
                      }

                      case 2780: { // 理论推测
                          sourceURL = [NSURL URLWithString:@"http://cdn.huijiwiki.com/asoiaf/thumb.php?f=Morgaine_le_Fee_Rhaego_TargaryenIIII.jpg&width=118"];
                          break;
                      }

                      case 306: { // 人物
                          sourceURL = [NSURL URLWithString:@"http://cdn.huijiwiki.com/asoiaf/thumb.php?f=John_Picacio_Daenerys_Targaryen.jpg&width=100"];
                          break;
                      }

                      default:
                          break;
                  }
              }

              NSData *imageData = [NSData dataWithContentsOfURL:sourceURL options:0 error:nil];
              completionBlock(imageData);
          } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
              NSLog(@"Error: %@", error);
          }];
}

- (void)getRandomTitle:(ManagerCompletionBlock)completionBlock
{
    NSString *URL = [NSString stringWithFormat:@"%@/api.php?action=query&list=random&rnlimit=1&format=json", self.siteURL];
    [_manager GET:URL
       parameters:nil
          success:^(NSURLSessionDataTask *task, id responseObject) {
              NSArray *blacklist = @[@"File:", @"Category:", @"Talk:", @"User:", @"MediaWiki"];
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
                  completionBlock(random);
              }
          } failure:^(NSURLSessionDataTask *task, NSError *error) {
              NSLog(@"getRandomPage Error: %@", error);
          }];
}

@end
