//
//  CSSSelectorAttributeType.m
//  CSSSelectorConverter
//
//  Created by Chong Francis on 14年1月8日.
//  Copyright (c) 2014年 Ignition Soft. All rights reserved.
//
#import "DDLog.h"
#undef LOG_LEVEL_DEF
#define LOG_LEVEL_DEF cssSelectorLogLevel
static const int cssSelectorLogLevel = LOG_LEVEL_VERBOSE;
#import "NUIParse.h"

#import "CSSSelectorAttributeOperator.h"

@implementation CSSSelectorAttributeOperator

- (id)initWithSyntaxTree:(NUIPSyntaxTree *)syntaxTree {
    self = [self init];
    if (self) {
        NSArray *components = [syntaxTree children];
        if ([components count] == 1) {
            NUIPKeywordToken* token = [components[0] children][0];
            if ([token isKeywordToken]) {
                self.name              = [token keyword];
                self.attributeOperator = [[self class] operatorWithString:[token keyword]];
            }
        }
    }
    return self;
}

+(instancetype) selectorWithName:(NSString*)name {
    CSSSelectorAttributeOperator* attrType = [[self alloc] init];
    attrType.name = name;
    attrType.attributeOperator = [self operatorWithString:name];
    return attrType;
}

-(NSString*) description {
    return [NSString stringWithFormat:@"<CSSSelectorAttributeOperator %@>", self.name];
}

+(CSSSelectorAttributeOperatorType) operatorWithString:(NSString*) type {
    if ([type isEqualToString:@"="]) {
        return CSSSelectorAttributeOperatorTypeEqual;
    } else if ([type isEqualToString:@"~="]) {
        return CSSSelectorAttributeOperatorTypeIncludes;
    } else if ([type isEqualToString:@"|="]) {
        return CSSSelectorAttributeOperatorTypeDash;
    }

    DDLogError(@"operator must be =, ~= or |=, given: %@", type);
    [NSException raise:NSInvalidArgumentException format:@"operator must be =, ~= or |=, given: %@", type];
    return CSSSelectorAttributeOperatorTypeNone;
}

@end
