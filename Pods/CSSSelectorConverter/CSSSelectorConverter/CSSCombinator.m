//
//  CSSCombinator.m
//  CSSSelectorConverter
//
//  Created by Chong Francis on 14年1月8日.
//  Copyright (c) 2014年 Ignition Soft. All rights reserved.
//

#import "CSSCombinator.h"
#import "NUIParse.h"

@implementation CSSCombinator

- (id)initWithSyntaxTree:(NUIPSyntaxTree *)syntaxTree {
    self = [self init];
    NSArray *components = [syntaxTree children];
    if ([components count] >= 1) {
        id component = components[0];
        if ([component isWhiteSpaceToken]) {
            self.type = CSSCombinatorTypeNone;
        } else if ([component isSyntaxTree]) {
            id token = [component children][0];
            if ([token isKeywordToken]) {
                NSString* keyword = [token keyword];
                if ([keyword isEqualToString:@">"]) {
                    self.type = CSSCombinatorTypeDescendant;
                } else if ([keyword isEqualToString:@"+"]) {
                    self.type = CSSCombinatorTypeAdjacent;
                } else if ([keyword isEqualToString:@"~"]) {
                    self.type = CSSCombinatorTypeGeneralSibling;
                } else {
                    [NSException raise:NSInvalidArgumentException format:@"Unexpected keyword: %@", keyword];
                }
            } else {
                [NSException raise:NSInvalidArgumentException format:@"Unexpected token, not a keyword: %@", token];
            }
        } else if ([component isKeywordToken]) {
            NSString* keyword = [component keyword];
            if ([keyword isEqualToString:@">"]) {
                self.type = CSSCombinatorTypeDescendant;
            } else if ([keyword isEqualToString:@"+"]) {
                self.type = CSSCombinatorTypeAdjacent;
            } else if ([keyword isEqualToString:@"~"]) {
                self.type = CSSCombinatorTypeGeneralSibling;
            } else {
                [NSException raise:NSInvalidArgumentException format:@"Unexpected keyword: %@", keyword];
            }
        }

    }
    return self;
}

+(CSSCombinator*) noneCombinator {
    CSSCombinator* combinator = [[CSSCombinator alloc] init];
    combinator.type = CSSCombinatorTypeNone;
    return combinator;
}

+(NSArray*) combinatorStrings {
    static dispatch_once_t onceToken;
    static NSArray* _combinatorStrings;
    dispatch_once(&onceToken, ^{
        _combinatorStrings = @[@">", @"+", @"~"];
    });
    return _combinatorStrings;
}

-(NSString*) description {
    return [NSString stringWithFormat:@"<CSSCombinator %@>", self.typeString];
}

-(NSString*) typeString {
    switch (self.type) {
        case CSSCombinatorTypeNone:
        {
            return @"(none)";
        }
            break;
        case CSSCombinatorTypeDescendant:
        {
            return @">";
        }
        case CSSCombinatorTypeAdjacent:
        {
            return @"+";
        }
        case CSSCombinatorTypeGeneralSibling:
        {
            return @"~";
        }
    }
    return nil;
}

@end
