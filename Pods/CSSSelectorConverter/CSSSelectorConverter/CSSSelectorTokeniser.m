//
//  CSSSelectorTokeniser.m
//  CSSSelectorConverter
//
//  Created by Francis Chong on 1/20/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "CSSSelectorTokeniser.h"
#import "NUIPNumberRecogniser.h"
#import "NUIPWhiteSpaceRecogniser.h"
#import "NUIPQuotedRecogniser.h"
#import "NUIPKeywordRecogniser.h"
#import "NUIPIdentifierRecogniser.h"
#import "NUIPRegexpRecogniser.h"

@implementation CSSSelectorTokeniser
    
-(id) init {
    self = [super init];

    [self addTokenRecogniser:[NUIPIdentifierRecogniser identifierRecogniser]];
    [self addTokenRecogniser:[NUIPNumberRecogniser numberRecogniser]];
    [self addTokenRecogniser:[NUIPQuotedRecogniser quotedRecogniserWithStartQuote:@"\""
                                                                       endQuote:@"\""
                                                                           name:@"String"]];
    [self addTokenRecogniser:[NUIPQuotedRecogniser quotedRecogniserWithStartQuote:@"\'"
                                                                       endQuote:@"\'"
                                                                           name:@"String"]];
    
    NUIPRegexpKeywordRecogniserMatchHandler trimSpaceHandler = ^(NSString* tokenString, NSTextCheckingResult* match){
        NSString* matched = [tokenString substringWithRange:match.range];
        return [NUIPKeywordToken tokenWithKeyword:[matched stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    };
    
    [self addTokenRecogniser:[NUIPRegexpRecogniser recogniserForRegexp:[NSRegularExpression regularExpressionWithPattern:@"[ \t\r\n\f]*(\\~\\=)[ \t\r\n\f]*" options:0 error:nil]
                                                        matchHandler:trimSpaceHandler]];
    [self addTokenRecogniser:[NUIPRegexpRecogniser recogniserForRegexp:[NSRegularExpression regularExpressionWithPattern:@"[ \t\r\n\f]*(\\|\\=)[ \t\r\n\f]*" options:0 error:nil]
                                                        matchHandler:trimSpaceHandler]];
    [self addTokenRecogniser:[NUIPRegexpRecogniser recogniserForRegexp:[NSRegularExpression regularExpressionWithPattern:@"[ \t\r\n\f]*(\\=)[ \t\r\n\f]*" options:0 error:nil]
                                                        matchHandler:trimSpaceHandler]];
    [self addTokenRecogniser:[NUIPRegexpRecogniser recogniserForRegexp:[NSRegularExpression regularExpressionWithPattern:@"[ \t\r\n\f]*(\\~)[ \t\r\n\f]*" options:0 error:nil]
                                                        matchHandler:trimSpaceHandler]];
    [self addTokenRecogniser:[NUIPRegexpRecogniser recogniserForRegexp:[NSRegularExpression regularExpressionWithPattern:@"[ \t\r\n\f]*(\\+)[ \t\r\n\f]*" options:0 error:nil]
                                                        matchHandler:trimSpaceHandler]];
    [self addTokenRecogniser:[NUIPRegexpRecogniser recogniserForRegexp:[NSRegularExpression regularExpressionWithPattern:@"[ \t\r\n\f]*(\\>)[ \t\r\n\f]*" options:0 error:nil]
                                                        matchHandler:trimSpaceHandler]];
    [self addTokenRecogniser:[NUIPRegexpRecogniser recogniserForRegexp:[NSRegularExpression regularExpressionWithPattern:@"[ \t\r\n\f]*(\\,)[ \t\r\n\f]*" options:0 error:nil]
                                                        matchHandler:trimSpaceHandler]];

    [self addTokenRecogniser:[NUIPWhiteSpaceRecogniser whiteSpaceRecogniser]];
    [self addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@":"]];
    [self addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"."]];
    [self addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"#"]];
    [self addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"-"]];
    [self addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"("]];
    [self addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@")"]];
    [self addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"["]];
    [self addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"]"]];
    [self addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"*"]];
    [self addTokenRecogniser:[NUIPKeywordRecogniser recogniserForKeyword:@"@"]];

    return self;
}

@end
