//
//  WikipediaHelper.m
//  Naturvielfalt
//
//  Created by Robin Oster on 23.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "WikipediaHelper.h"
#import "DataManager.h"

/* Pods */
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

        // Main bundle
        NSBundle *mainBundle = [NSBundle mainBundle];

#ifdef DEBUG
        NSString *cssPath = [mainBundle pathForResource:@"wikiview" ofType:@"css"];
#else
        NSString *cssPath = [mainBundle pathForResource:@"wikiview-min" ofType:@"css"];
#endif

        NSString *css = [NSString stringWithContentsOfFile:cssPath encoding:NSUTF8StringEncoding error:nil];
        _wikicss = [NSString stringWithFormat:@"<style>%@</style>", css];
        _wikicss = [_wikicss stringByAppendingString:
                    @"<meta name='viewport' content='width=device-width, user-scalable=no initial-scale=1.0'/>"];

        imageBlackList = [[NSMutableArray alloc] init];
        [imageBlackList addObject:@"http://cdn.huijiwiki.com/asoiaf/uploads/6/69/Disambig.png"];
        [imageBlackList addObject:@"http://cdn.huijiwiki.com/asoiaf/thumb.php?f=Disambig.png"];
        [imageBlackList addObject:@"http://cdn.huijiwiki.com/asoiaf/thumb.php?f=Outdated_content.png"];
        [imageBlackList addObject:@"http://cdn.huijiwiki.com/asoiaf/thumb.php?f=Mbox_notice.png"];
        [imageBlackList addObject:@"http://cdn.huijiwiki.com/asoiaf/uploads/0/07/Headlogo.png"];
        [imageBlackList addObject:@"http://cdn.huijiwiki.com/asoiaf/uploads/6/61/Dots.png"];
        [imageBlackList addObject:@"http://cdn.huijiwiki.com/asoiaf/thumb.php?f=Klipper.png"];
    }
    return self;
}

#pragma mark - Data Source

- (void)fetchArticle:(NSString *)name
{
    [[MainManager sharedManager] getWikiEntry:name completionBlock:^(NSString *wikiEntry) {
        [delegate dataLoaded:[self formatHTMLPage:wikiEntry] withUrlMainImage:[self getUrlOfMainImage:wikiEntry]];
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
    formatedHtmlSrc = [formatedHtmlSrc stringByReplacingOccurrencesOfString:@"class=\"mw-editsection\"" withString:@"style=\"visibility: hidden\""];

    // Clean the html page
    formatedHtmlSrc = [self cleanHTMLPage:formatedHtmlSrc];

    // Wrap html in DIV
    formatedHtmlSrc = [NSString stringWithFormat:NSStringMultiline(
                        <div id="wiki-outer-body" style="margin-top:20px">
                           <div id="wiki-body" class="container">
                               <div id="content">%@</div>
                           </div>
                       </div>), formatedHtmlSrc];

    // Add CSS style
    formatedHtmlSrc = [self.wikicss stringByAppendingString:formatedHtmlSrc];

    return formatedHtmlSrc;
}

- (NSString *)cleanHTMLPage:(NSString *)htmlSrc
{
    NSMutableArray *cleanedHtmlSrcList = [[NSMutableArray alloc] init];

    IGHTMLDocument* node = [[IGHTMLDocument alloc] initWithHTMLString:htmlSrc error:nil];
    IGXMLNodeSet* contents = [node children];

    // There are some bugs in IGHTMLQuery on iOS (works fine on OSX),
    // so we use try-catch block to prevent app crashing.
    @try {
        // Delete caption image
        [[contents queryWithXPath:@"//table[@class='infobox']//caption"] remove];
    }
    @catch (NSException *exception) {
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
    }

    @try {
        [[contents queryWithXPath:@"//table[@style='margin: 0px 0px 5px 0px; border: 1px solid #aaa; background:#fbfbfb;']"] remove];
    }
    @catch (NSException *exception) {
        NSLog( @"Name: %@", exception.name);
        NSLog( @"Reason: %@", exception.reason );
    }

    // Append copyright to the end of article
    NSString *copyright = @"<div id=\"copyright\">\
本站文字内容若未经特别声明，则遵循协议CC-BY-SA.此协议与百度百科不相容，请勿转载至百度百科，否则一经发现我们会通过灰机wiki平台维权投诉，责任自负。\
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
    NSString *formatedHtmlSrc = [htmlSrc stringByReplacingOccurrencesOfString:@"//upload.wikimedia.org"
                                                                   withString:@"http://upload.wikimedia.org"];
    
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
            @try {
                finalSplitString = [[NSString alloc] initWithString:[splitonce objectAtIndex:i]];
            }
            @catch (NSException *exception) {
                return nil;
            }

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
