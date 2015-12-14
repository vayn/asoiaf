//
//  ImageManager.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/13.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "ImageManager.h"

@implementation ImageManager

+ (instancetype)sharedManager
{
    static ImageManager *sharedManager = nil;

    @synchronized(self) {
        if (!sharedManager) {
            sharedManager = [[self alloc] initManager];
        }
    }

    return sharedManager;
}

- (void)getPageThumbnailWithPageId:(NSNumber *)pageId completionBlock:(ManagerCompletionBlock)completionBlock
{
    return [self getPageThumbnailWithPageId:pageId thumbWidth:@300 completionBlock:completionBlock];
}

- (void)getPortalThumbnailWithPageId:(NSNumber *)pageId completionBlock:(ManagerCompletionBlock)completionBlock
{
    NSURLComponents *components = [NSURLComponents componentsWithString:@"http://cdn.huijiwiki.com/asoiaf/thumb.php"];

    NSString *portalThumbName = nil;

    switch ([pageId integerValue]) {
        case 46724: { // 章节梗概
            portalThumbName = @"LordOfLightProtectUs_JZee.jpg";
            break;
        }

        case 5480: { // 人物介绍
            portalThumbName = @"Katherine_Dinger_CLannister.jpg";
            break;
        }

        case 46711: { // 各大家族
            portalThumbName = @"Iron_Throne_by_thegryph.jpg";
            break;
        }

        case 5483: { // 文化风俗
            portalThumbName = @"Faith_by_thegryph.jpg";
            break;
        }

        case 2780: { // 理论推测
            portalThumbName = @"Morgaine_le_Fee_Rhaego_TargaryenIIII.jpg";
            break;
        }

        default:
            break;
    }

    if (portalThumbName) {
        NSURLQueryItem *f = [NSURLQueryItem queryItemWithName:@"f" value:portalThumbName];
        NSURLQueryItem *width = [NSURLQueryItem queryItemWithName:@"width" value:@"300"];
        [components setQueryItems:@[f, width]];

        [BaseManager processImageDataWithURL:[components URL] andBlock:^(NSData *imageData) {
            completionBlock(imageData);
        }];
    }
}

- (void)getPageThumbnailWithPageId:(NSNumber *)pageId thumbWidth:(NSNumber *)thumbWidth completionBlock:(ManagerCompletionBlock)completionBlock
{
    NSString *Api = [NSString stringWithFormat:@"api.php?action=query&pageids=%@&prop=pageimages&format=json&pithumbsize=%@",
                     [pageId stringValue], [thumbWidth stringValue]];
    Api = [BaseManager getAbsoluteUrl:Api];

    [self.manager GET:Api parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *page = responseObject[@"query"][@"pages"][[pageId stringValue]];
        NSDictionary *thumbnail = [page objectForKey:@"thumbnail"];

        if (thumbnail != nil) {
            NSString *thumbnailSource = thumbnail[@"source"];
            NSString *noPortraitUrl = @"http://cdn.huijiwiki.com/asoiaf/uploads/f/f3/No_Portrait.jpg";

            if ([thumbnailSource isEqualToString:noPortraitUrl]) {
                completionBlock(nil);
            } else {
                NSURL *sourceURL = [NSURL URLWithString:thumbnailSource];

                [BaseManager processImageDataWithURL:sourceURL andBlock:^(NSData *imageData) {
                    completionBlock(imageData);
                }];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"%s: %@", __FUNCTION__, error);
    }];
}

- (void)getRandomImage:(void (^)(UIImage *image))completionBlock
{
    NSString *Api = [BaseManager getAbsoluteUrl:NSStringMultiline(api.php?action=query&generator=random&grnnamespace=6
                                                                  &prop=imageinfo&iiprop=url&format=json&rawcontinue)];

    [self.manager GET:Api parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *pages = [[[responseObject objectForKey:@"query"] objectForKey:@"pages"] allValues];
        NSArray *imageInfo = [[pages objectAtIndex:0] objectForKey:@"imageinfo"];

        if (!imageInfo) {
            [self getRandomImage:completionBlock];
        } else {
            NSString *url = [[imageInfo firstObject] objectForKey:@"url"];
            NSString *imageName = [[url componentsSeparatedByString:@"/"] lastObject];

            NSString *imageThumb = [NSString stringWithFormat:@"http://cdn.huijiwiki.com/asoiaf/thumb.php?f=%@&width=300", imageName];
            NSURL *imageUrl = [NSURL URLWithString:imageThumb];

            [BaseManager processImageDataWithURL:imageUrl andBlock:^(NSData * _Nonnull imageData) {
                UIImage *image = [UIImage imageWithData:imageData];
                completionBlock(image);
            }];
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%s: %@", __FUNCTION__, error);
    }];
}

@end
