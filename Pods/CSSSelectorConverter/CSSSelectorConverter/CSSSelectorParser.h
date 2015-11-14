#import <Foundation/Foundation.h>
#import "CSSSelectorGroup.h"
#import "NUIPParser.h"
#import "NUIPTokeniser.h"

extern NSString* const CSSSelectorParserException;
extern NSString* const CSSSelectorParserErrorDomain;
extern NSString* const CSSSelectorParserErrorInputStreamKey;
extern NSString* const CSSSelectorParserErrorAcceptableTokenKey;

@class CSSSelectorGroup;

/**
 * CSSSelectorParser parse a CSS Selector and return a CSSSelectorGroup.
 *
 * Use ``CSSSelectorXPathVisitor`` to convert the returned tree into a XPath.
 * @see CSSSelectorParser
 */
@interface CSSSelectorParser : NSObject <NUIPParserDelegate, NUIPTokeniserDelegate>

/**
 Last error encountered by the parser.
 */
@property (nonatomic, strong) NSError* lastError;

-(instancetype) init;

-(instancetype) initWithParser:(NUIPParser*)parser;

/**
 * Parse a CSS Selector and return a CSSSelectorGroup object.
 *
 *
 * @param css The css selector
 * @param error If the parse failed and parser return nil, error is set to last known error.
 * @return CSSSelectorGroup the parsed selector. Or nil if error occurred.
 */
- (CSSSelectorGroup*)parse:(NSString *)css error:(NSError**)error;

@end

