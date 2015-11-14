//
//  CSSToXPathConverter.h
//  CSSSelectorConverter
//
//  Created by Francis Chong on 7/1/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSSSelectorParser;

/**
 * Convert a CSS Selector to XPath.
 *
 * @see CSSSelectorParser
 * @see CSSSelectorXPathVisitor
 */
@interface CSSSelectorToXPathConverter : NSObject

@property (nonatomic, strong) CSSSelectorParser* parser;

+(instancetype) sharedConverter;

-(id) init;

-(id) initWithParser:(CSSSelectorParser*)parser;

/**
 * Parse a CSS Selector and return a XPath string.
 *
 *
 * @param css The css selector
 * @param error If the parse failed and parser return nil, error is set to last known error.
 * @return XPath representation of the given CSS Selector.
 */
-(NSString*)xpathWithCSS:(NSString*)css error:(NSError*__autoreleasing*)error;

@end
