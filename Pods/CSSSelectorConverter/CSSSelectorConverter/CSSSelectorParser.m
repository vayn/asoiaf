#import "CSSSelectorParser.h"
#import "CSSSelectorGrammar.h"
#import "CSSSelectorTokeniser.h"
#import "NUIParse.h"
#import "DDLog.h"

#undef LOG_LEVEL_DEF
#define LOG_LEVEL_DEF cssSelectorLogLevel
static const int cssSelectorLogLevel = LOG_LEVEL_ERROR;

NSString* const CSSSelectorParserException = @"CSSSelectorParserException";
NSString* const CSSSelectorParserErrorDomain = @"CSSSelectorParserErrorDomain";
NSString* const CSSSelectorParserErrorInputStreamKey = @"input stream";
NSString* const CSSSelectorParserErrorAcceptableTokenKey = @"acceptable token";

enum {
    CSSSelectorParserRuleQuotedString = 1
};

@interface CSSSelectorParser ()
@property (nonatomic, strong) CSSSelectorTokeniser *tokeniser;
@property (nonatomic, strong) NUIPParser* parser;
@end

@implementation CSSSelectorParser

- (id)init {
    NUIPLALR1Parser* parser = [NUIPLALR1Parser parserWithGrammar:[[CSSSelectorGrammar alloc] initWithPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"CSSSelectorGrammar" ofType:@"txt"]]];
    return [self initWithParser:parser];
}

-(instancetype) initWithParser:(NUIPParser*)parser
{
    self = [super init];
    self.tokeniser = [[CSSSelectorTokeniser alloc] init];
    self.tokeniser.delegate = self;
    self.parser = parser;
    self.parser.delegate = self;
    return self;
}

- (CSSSelectorGroup*)parse:(NSString *)css error:(NSError*__autoreleasing*)error
{
    NUIPTokenStream *tokenStream = [self.tokeniser tokenise:css];
    CSSSelectorGroup* result = [self.parser parse:tokenStream];
    if (!result) {
        if (error) {
            *error = self.lastError;
        } else {
            DDLogError(@"CSSSelectorParser: parse error: %@", self.lastError);
        }
    }
    return result;
}

#pragma mark - CPParserDelegate

- (id)parser:(NUIPParser *)parser didProduceSyntaxTree:(NUIPSyntaxTree *)syntaxTree
{
    switch ([[syntaxTree rule] tag]) {
        case CSSSelectorParserRuleQuotedString: {
            NSArray* children = [syntaxTree children];
            if ([children count] == 1 && [children[0] isQuotedToken]) {
                return [children[0] content];
            } else {
                [NSException raise:CSSSelectorParserException
                            format:@"unexpected token: should be a quoted token, now: %@", syntaxTree];
            }
        }
            break;
            
        default:
            break;
    }
    return syntaxTree;
}

- (NUIPRecoveryAction *)parser:(NUIPParser *)parser didEncounterErrorOnInput:(NUIPTokenStream *)inputStream expecting:(NSSet *)acceptableTokens
{
    NSError* error = [NSError errorWithDomain:CSSSelectorParserErrorDomain
                                         code:1
                                     userInfo:@{CSSSelectorParserErrorInputStreamKey: inputStream, CSSSelectorParserErrorAcceptableTokenKey: acceptableTokens}];
    self.lastError = error;
    return [NUIPRecoveryAction recoveryActionStop];
}

#pragma mark - CPTokeniserDelegate

- (BOOL)tokeniser:(NUIPTokeniser *)tokeniser shouldConsumeToken:(NUIPToken *)token
{
    return YES;
}

@end