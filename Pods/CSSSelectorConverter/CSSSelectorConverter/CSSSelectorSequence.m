//
//  CSSSelectorSequence.m
//  CSSSelectorConverter
//
//  Created by Francis Chong on 7/1/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "DDLog.h"
#import "NUIParse.h"

#undef LOG_LEVEL_DEF
#define LOG_LEVEL_DEF cssSelectorLogLevel
static const int cssSelectorLogLevel = LOG_LEVEL_VERBOSE;

#import "CSSSelectorSequence.h"
#import "CSSUniversalSelector.h"
#import "CSSNamedSelector.h"
#import "CSSTypeSelector.h"
#import "CSSIDSelector.h"
#import "CSSClassSelector.h"
#import "CSSSelectorAttribute.h"
#import "CSSPseudoClass.h"
#import "CSSCombinator.h"

@implementation CSSSelectorSequence

- (id)initWithSyntaxTree:(NUIPSyntaxTree *)syntaxTree {
    self = [self init];
    if (self) {
        NSArray* selectors = nil;
        if ([syntaxTree valueForTag:@"universal"]) {
            self.universalOrTypeSelector = [syntaxTree valueForTag:@"universal"];
            NSArray* subtree = [syntaxTree valueForTag:@"selectorsWithType"];
            selectors = [subtree valueForKeyPath:@"@unionOfArrays.self"];

        } else if ([syntaxTree valueForTag:@"type"]) {
            self.universalOrTypeSelector = [syntaxTree valueForTag:@"type"];
            NSArray* subtree = [syntaxTree valueForTag:@"selectorsWithType"];
            selectors = [subtree valueForKeyPath:@"@unionOfArrays.self"];

        } else {
            NSArray* subtree = [syntaxTree valueForTag:@"selectorsWithoutType"];
            selectors = [subtree valueForKeyPath:@"@unionOfArrays.self"];

        }

        if (selectors && [selectors isKindOfClass:[NSArray class]]) {
            [selectors enumerateObjectsUsingBlock:^(CSSBaseSelector* selector, NSUInteger idx, BOOL *stop) {
                [self addSelector:selector];
            }];
        } else {
            [NSException raise:NSInvalidArgumentException format:@"expected NSArray, receive: %@", syntaxTree];
        }
    }
    return self;
}

-(instancetype) init {
    self = [super init];
    self.universalOrTypeSelector = nil;
    self.otherSelectors = [[NSMutableArray alloc] init];
    return self;
}

-(NSString*) description {
    return [NSString stringWithFormat:@"<CSSSelectorSequence %@ %@>", self.universalOrTypeSelector, [self.otherSelectors componentsJoinedByString:@" "]];
}

-(void) addSelector:(CSSBaseSelector*)selector {
    if ([selector isKindOfClass:[CSSIDSelector class]] ||
        [selector isKindOfClass:[CSSClassSelector class]] ||
        [selector isKindOfClass:[CSSSelectorAttribute class]]) {
        [self.otherSelectors addObject:selector];

    } else if ([selector isKindOfClass:[CSSPseudoClass class]]) {
        self.pseudoClass = (CSSPseudoClass*) selector;

    } else {
        DDLogError(@"attempt to add unknown selector to sequence: %@", selector);
        [NSException raise:NSInternalInconsistencyException format:@"attempt to add unknown selector to sequence: %@", selector];
    }
}

@end
