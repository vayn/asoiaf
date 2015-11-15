//
//  WikipediaHelper.m
//  Naturvielfalt
//
//  Created by Robin Oster on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WikipediaHelper.h"
#import "AFNetworking.h"
#import "IGHTMLQuery.h"

@interface WikipediaHelper ()

@property (nonatomic, strong) NSString *wikicss;

@end

@implementation WikipediaHelper
@synthesize apiUrl, imageBlackList, delegate, fetchedArticle;

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Standard values for the api URL
        apiUrl = @"http://asoiaf.huiji.wiki";

        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *cssPath = [mainBundle pathForResource:@"wikiview" ofType:@"css"];
        _wikicss = [NSString stringWithContentsOfFile:cssPath encoding:NSUTF8StringEncoding error:nil];
        _wikicss = [NSString stringWithFormat:@"<style>%@</style>", _wikicss];
        _wikicss = [_wikicss stringByAppendingString:
                    @"<meta name='viewport' content='width=device-width, user-scalable=no initial-scale=1.0'/>"];

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

#pragma mark - Data Source

- (void)fetchArticle:(NSString *)name
{
    NSString *str = [[NSString alloc] initWithFormat:@"%@/api.php?action=query&prop=revisions&titles=%@&rvprop=content&rvparse&format=json&redirects", apiUrl, name];
    NSString *url = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    [manager GET:url parameters:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSArray *htmlTemp = [[[responseObject objectForKey:@"query"] objectForKey:@"pages"] allValues];
        fetchedArticle = [[[[htmlTemp objectAtIndex:0] objectForKey:@"revisions"] objectAtIndex:0] objectForKey:@"*"];

        [delegate dataLoaded:[self formatHTMLPage:fetchedArticle] withUrlMainImage:[self getUrlOfMainImage:fetchedArticle]];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [delegate dataLoaded:@"请联网后重新打开应用" withUrlMainImage:@"test"];
    }];
}

#pragma mark - HTML Formatter

- (NSString *)formatHTMLPage:(NSString *)htmlSrc
{
    NSString *wikiString = [NSString stringWithFormat:@"%@/wiki/", apiUrl];
    NSString *ahrefWikiString = [NSString stringWithFormat:@"<a href=\"%@/wiki\"", apiUrl];
    NSString *ahrefWikiStringReplacement = [NSString stringWithFormat:@"<a target=\"blank\" href=\"%@/wiki\"", apiUrl];
    
    NSString *formatedHtmlSrc = [htmlSrc stringByReplacingOccurrencesOfString:@"/wiki/" withString:wikiString];
    formatedHtmlSrc = [formatedHtmlSrc stringByReplacingOccurrencesOfString:ahrefWikiString withString:ahrefWikiStringReplacement];
    
    formatedHtmlSrc = [formatedHtmlSrc stringByReplacingOccurrencesOfString:@"//upload.wikimedia.org" withString:@"http://upload.wikimedia.org"];
    formatedHtmlSrc = [formatedHtmlSrc stringByReplacingOccurrencesOfString:@"class=\"editsection\"" withString:@"style=\"visibility: hidden\""];

    // Clean the html page
    formatedHtmlSrc = [self cleanHTMLPage:formatedHtmlSrc];

    formatedHtmlSrc = [self.wikicss stringByAppendingString:formatedHtmlSrc];

    return formatedHtmlSrc;
}

- (NSString *)cleanHTMLPage:(NSString *)htmlSrc
{
    NSString *pattern = @"<h2><span class=\"mw-headline\" id=\".E5.BC.95.E7.94.A8.E4.B8.8E.E6.B3.A8.E9.87.8A";
    NSRange range = [htmlSrc rangeOfString:pattern];

    if (range.location != NSNotFound) {
        htmlSrc = [htmlSrc substringToIndex:range.location];
    }

    NSMutableArray *cleanedHtmlSrcList = [[NSMutableArray alloc] init];

    IGHTMLDocument* node = [[IGHTMLDocument alloc] initWithHTMLString:htmlSrc error:nil];
    IGXMLNodeSet* contents = [node children];

    // There are some bugs in IGHTMLQuery on iOS (works fine on OSX),
    // so we use try-catch block to prevent app crashing.
    @try {
        [[contents queryWithXPath:@"//table[@class='infobox']"] remove];
    }
    @catch (NSException *exception) {
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
    }

    @try {
        [[contents queryWithXPath:@"//span[@class='mw-editsection']"] remove];
        [[contents queryWithXPath:@"//table[@style='margin: 0px 0px 5px 0px; border: 1px solid #aaa; background:#fbfbfb;']"] remove];
    }
    @catch (NSException *exception) {
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
    }

    // Append copyright to the end of article
    NSString *copyright = @"<div id=\"copyright\">\
版权信息 2015\
</div>";
    IGHTMLDocument *copyrightNode = [[IGHTMLDocument alloc] initWithHTMLString:copyright error:nil];
    [contents appendWithNode:copyrightNode];

    [contents enumerateNodesUsingBlock:^(IGXMLNode* content, NSUInteger idx, BOOL *stop){
        [cleanedHtmlSrcList addObject:content.xml];
    }];

    NSString *cleanedHtmlSrc = [cleanedHtmlSrcList componentsJoinedByString:@""];

    return cleanedHtmlSrc;
}

#pragma mark - Main Image Generator

- (NSString *)getUrlOfMainImage:(NSString *)htmlSrc
{
    
    // Otherwise images have an incorrect url
    NSString *formatedHtmlSrc = [htmlSrc stringByReplacingOccurrencesOfString:@"//upload.wikimedia.org" withString:@"http://upload.wikimedia.org"];
    
    if([htmlSrc isEqualToString:@""])
        return htmlSrc;

    NSArray *splitonce = [formatedHtmlSrc componentsSeparatedByString:@"src=\""];
    NSUInteger length =  [splitonce count];
    if (length > 1) {
        NSString *finalSplitString = [[NSString alloc] initWithString:[splitonce objectAtIndex:1]];
        NSArray *finalSplit = [finalSplitString componentsSeparatedByString:@"\""];

        NSString *imageURL = [[NSString alloc] initWithString:[finalSplit objectAtIndex:0]];
        imageURL = [imageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

        int i = 0;
        
        while([self isOnBlackList:imageURL] || [imageURL hasPrefix:@"<"]) {
            // Get the next image tag
            finalSplitString = [[NSString alloc] initWithString:[splitonce objectAtIndex:i]];

            finalSplit = [finalSplitString componentsSeparatedByString:@"\""];
            
            imageURL = [[NSString alloc] initWithString:[finalSplit objectAtIndex:0]];
            imageURL = [imageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            i++;
        }

        imageURL = [imageURL stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    
        return imageURL;
    } else {
        return nil;
    }
}

- (BOOL)isOnBlackList:(NSString *)imageURL
{
    // Check if its not the correct image (Sometimes there are articles where the first image is an icon..)
    for(NSString *img in imageBlackList) {
        if([imageURL containsString:img]) {
            return true;
        }
    }
    
    return false;
}

@end
