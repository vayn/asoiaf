//
//  WikipediaHelper.m
//  Naturvielfalt
//
//  Created by Robin Oster on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WikipediaHelper.h"
#import "AFNetworking.h"

@implementation WikipediaHelper
@synthesize apiUrl, imageBlackList, delegate, fetchedArticle;

- (id)init {
    self = [super init];
    if (self) {
        // Standard values for the api URL
        apiUrl = @"http://asoiaf.huiji.wiki";

        imageBlackList = [[NSMutableArray alloc] init];
        [imageBlackList addObject:@"http://cdn.huijiwiki.com/asoiaf/uploads/6/69/Disambig.png"];
        [imageBlackList addObject:@"http://cdn.huijiwiki.com/asoiaf/thumb.php?f=Disambig.png"];
        [imageBlackList addObject:@"http://cdn.huijiwiki.com/asoiaf/thumb.php?f=Outdated_content.png"];
        [imageBlackList addObject:@"http://cdn.huijiwiki.com/asoiaf/thumb.php?f=Mbox_notice.png"];
        [imageBlackList addObject:@"http://cdn.huijiwiki.com/asoiaf/uploads/0/07/Headlogo.png"];
        [imageBlackList addObject:@"http://cdn.huijiwiki.com/asoiaf/uploads/6/61/Dots.png"];
    }
    return self;
}

- (void) fetchArticle:(NSString *)name {
    NSString *str = [[NSString alloc] initWithFormat:@"%@/api.php?action=query&prop=revisions&titles=%@&rvprop=content&rvparse&format=json&redirects", apiUrl, name];
    NSString *url = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    [manager GET:url parameters:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSArray *htmlTemp = [[[responseObject objectForKey:@"query"] objectForKey:@"pages"] allValues];
        fetchedArticle = [[[[htmlTemp objectAtIndex:0] objectForKey:@"revisions"] objectAtIndex:0] objectForKey:@"*"];
        
        [delegate dataLoaded:[self formatHTMLPage:fetchedArticle] withUrlMainImage:[self getUrlOfMainImage:fetchedArticle]];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [delegate dataLoaded:@"test" withUrlMainImage:@"test"];
    }];
}

- (NSString *) formatHTMLPage:(NSString *)htmlSrc {
    NSString *wikiString = [NSString stringWithFormat:@"%@/wiki/", apiUrl];
    NSString *ahrefWikiString = [NSString stringWithFormat:@"<a href=\"%@/wiki\"", apiUrl];
    NSString *ahrefWikiStringReplacement = [NSString stringWithFormat:@"<a target=\"blank\" href=\"%@/wiki\"", apiUrl];
    
    NSString *formatedHtmlSrc = [htmlSrc stringByReplacingOccurrencesOfString:@"/wiki/" withString:wikiString];
    formatedHtmlSrc = [formatedHtmlSrc stringByReplacingOccurrencesOfString:ahrefWikiString withString:ahrefWikiStringReplacement];
    
    formatedHtmlSrc = [formatedHtmlSrc stringByReplacingOccurrencesOfString:@"//upload.wikimedia.org" withString:@"http://upload.wikimedia.org"];
    formatedHtmlSrc = [formatedHtmlSrc stringByReplacingOccurrencesOfString:@"class=\"editsection\"" withString:@"style=\"visibility: hidden\""];
    
    // Append html and body tags, Add some style
    formatedHtmlSrc = [NSString stringWithFormat:@"<body style=\"font-size: 13px; font-family: Helvetica, Verdana\">%@<br/><br/><br/>The article above is based on this article of the free encyclopedia Wikipedia and it is licensed under „Creative Commons Attribution/Share Alike“. Here you find versions/authors.</body>", formatedHtmlSrc];
    
    return formatedHtmlSrc;
}

- (NSString *) getUrlOfMainImage:(NSString *)htmlSrc {
    
    // Otherwise images have an incorrect url
    NSString *formatedHtmlSrc = [htmlSrc stringByReplacingOccurrencesOfString:@"//upload.wikimedia.org" withString:@"http://upload.wikimedia.org"];
    
    if([htmlSrc isEqualToString:@""])
        return htmlSrc;

    NSArray *splitonce = [formatedHtmlSrc componentsSeparatedByString:@"src=\""];
    NSUInteger length =  [splitonce count];
    if (length > 1) {
        NSString *finalSplitString = [[NSString alloc] initWithString:[splitonce objectAtIndex:1]];
        NSArray *finalSplit = [finalSplitString  componentsSeparatedByString:@"\""];

        NSString *imageURL = [[NSString alloc] initWithString:[finalSplit objectAtIndex:0]];
        imageURL = [imageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        int i = 1;
        
        while([self isOnBlackList:imageURL]) { 
            // Get the next image tag
            finalSplitString = [[NSString alloc] initWithString:[splitonce objectAtIndex:i]];
            
            finalSplit = [finalSplitString  componentsSeparatedByString:@"\""];
            
            imageURL = [[NSString alloc]  initWithString:[finalSplit objectAtIndex:0]];
            imageURL = [imageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            i++;
        }

        imageURL = [imageURL stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    
        return imageURL;
    } else {
        return nil;
    }
}

- (BOOL) isOnBlackList:(NSString *)imageURL {
    // Check if its not the correct image (Sometimes there are articles where the first image is an icon..)
    for(NSString *img in imageBlackList) {
        if([imageURL containsString:img]) {
            return true;
        }
    }
    
    return false;
}

@end
