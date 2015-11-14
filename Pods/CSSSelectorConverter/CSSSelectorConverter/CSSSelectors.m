//
//  CSSSelectors.m
//  CSSSelectorConverter
//
//  Created by Francis Chong on 7/1/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//
#import "NUIParse.h"
#import "CSSSelectors.h"
#import "CSSCombinator.h"
#import "CSSSelectorSequence.h"

@implementation CSSSelectors

- (id)initWithSyntaxTree:(NUIPSyntaxTree *)syntaxTree {
    self = [self init];
    if (self) {
        CSSSelectorSequence* seq = [syntaxTree valueForTag:@"firstSequence"];
        if (seq) {
            [self addSelector:seq];
        }
        
        NSArray* otherSequences = [syntaxTree valueForTag:@"otherSequences"];
        [otherSequences enumerateObjectsUsingBlock:^(NSArray* sequence, NSUInteger idx, BOOL *stop) {
            [sequence enumerateObjectsUsingBlock:^(CSSBaseSelector* selector, NSUInteger idx, BOOL *stop) {
                [self addSelector:selector];
            }];
        }];
    }
    return self;
}

-(instancetype) init {
    self = [super init];
    self.selectors = [[NSMutableArray alloc] init];
    return self;
}

-(void) addSelector:(CSSBaseSelector*)selector {
    if (![selector isKindOfClass:[CSSSelectorSequence class]] && ![selector isKindOfClass:[CSSCombinator class]]) {
        [NSException raise:NSInvalidArgumentException format:@"Only allowed to add selector of type CSSSelectorSequence or CSSCombinator, given: %@", [selector class]];
    }

    [self.selectors addObject:selector];
}

-(NSString*) description {
    return [NSString stringWithFormat:@"<CSSSelectors %@>", self.selectors];
}

@end
