//
//  DataStore.m
//  ice
//
//  Created by Vicent Tsai on 15/10/30.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "DataStore.h"
#import "AFNetworking.h"

@interface DataStore ()

@property (nonatomic, strong) AFURLSessionManager *sessionManager;

@property (nonatomic, strong) NSArray *wiki;
@property (nonatomic, strong) NSMutableDictionary *dictionary;

@end

@implementation DataStore

+ (instancetype)sharedStore
{
    static DataStore *sharedStore = nil;

    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    return sharedStore;
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
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:config];

        [self fetchData];
    }

    return self;
}

- (NSArray *)dataForCategory:(NSString *)category
{
    return [self.dictionary objectForKey:category];
}

#pragma mark - Private methods

- (void)fetchData
{
    NSString *requestString = @"http://zh.asoiaf.wikia.com/wikia.php?controller=NavigationApi&method=getData";
    NSURL *URL = [NSURL URLWithString:requestString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            _wiki = responseObject[@"navigation"][@"wiki"];
            _dictionary = [[NSMutableDictionary alloc] init];
            NSMutableArray *category = [[NSMutableArray alloc] init];

            [_wiki enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx > 3) {
                    *stop = YES;
                    return;
                } else {
                    [category addObject:obj[@"text"]];
                    [_dictionary setObject:(NSArray *)obj[@"children"] forKey:(NSString *)obj[@"text"]];
                }
            }];
            _category = [category copy];

            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"dataFetched" object:nil];
            });
        }
    }];
    [dataTask resume];
}

@end
