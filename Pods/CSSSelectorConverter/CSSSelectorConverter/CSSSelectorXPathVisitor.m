//
//  CSSSelectorXPathVisitor.m
//  CSSSelectorConverter
//
//  Created by Francis Chong on 1/22/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "CSSSelectorXPathVisitor.h"

#import "CSSUniversalSelector.h"
#import "CSSNamedSelector.h"
#import "CSSTypeSelector.h"
#import "CSSIDSelector.h"
#import "CSSClassSelector.h"
#import "CSSSelectorSequence.h"
#import "CSSSelectors.h"
#import "CSSSelectorGroup.h"
#import "CSSSelectorParser.h"
#import "CSSSelectorAttribute.h"
#import "CSSNamedSelector.h"
#import "CSSCombinator.h"
#import "CSSNamedSelector.h"
#import "CSSPseudoClass.h"

@interface CSSSelectorXPathVisitor()
@property (nonatomic, strong) NSMutableString* output;
@end

@implementation CSSSelectorXPathVisitor

-(instancetype) init {
    self = [super init];
    self.output = [[NSMutableString alloc] init];
    return self;
}

#pragma mark - Public

-(void) visit:(CSSBaseSelector*)object {
    Class class = [object class];
    while (class && class != [NSObject class])
    {
        NSString *methodName = [NSString stringWithFormat:@"visit%@:", class];
        SEL selector = NSSelectorFromString(methodName);
        if ([self respondsToSelector:selector])
        {
            IMP imp = [self methodForSelector:selector];
            void (*func)(id, SEL, id) = (void *)imp;
            func(self, selector, object);
            return;
        }
        class = [class superclass];
    };
    [NSException raise:NSInvalidArgumentException format:@"Not a acceptable CSSBaseSelector subclasses"];
}


-(NSString*) xpathString
{
    return [_output copy];
}

-(void) appendXPath:(NSString*)string
{
    [self.output appendString:string];
}

#pragma mark - Visitors

-(void) visitCSSSelectorGroup:(CSSSelectorGroup*)node
{
    NSArray* sequence = [node.selectors copy];
    [sequence enumerateObjectsUsingBlock:^(CSSBaseSelector* selector, NSUInteger idx, BOOL *stop) {
        [self visit:selector];
        if (idx < sequence.count-1) {
            [self appendXPath:@" | "];
        }
    }];
}

-(void) visitCSSUniversalSelector:(CSSUniversalSelector*)node
{
    [self appendXPath:@"*"];
}

-(void) visitCSSTypeSelector:(CSSTypeSelector*)node
{
    [self appendXPath:[NSString stringWithFormat:@"%@", node.name]];
}

-(void) visitCSSIDSelector:(CSSIDSelector*)node
{
    [self appendXPath:[NSString stringWithFormat:@"@id = '%@'", node.name]];
}

-(void) visitCSSClassSelector:(CSSClassSelector*)node
{
    [self appendXPath:[NSString stringWithFormat:@"contains(concat(' ', normalize-space(@class), ' '), ' %@ ')", node.name]];
}

-(void) visitCSSSelectorSequence:(CSSSelectorSequence*)node
{
    if (!node.universalOrTypeSelector) {
        node.universalOrTypeSelector = [CSSUniversalSelector selector];
    }
    
    if (node.pseudoClass) {
        node.pseudoClass.parent = node.universalOrTypeSelector;
        [self visit:node.pseudoClass];
    } else {
        [self visit:node.universalOrTypeSelector];
    }
    
    if ([node.otherSelectors count] > 0) {
        [self appendXPath:@"["];
        [node.otherSelectors enumerateObjectsUsingBlock:^(CSSBaseSelector* selector, NSUInteger idx, BOOL *stop) {
            [self visit:selector];
            if (idx < node.otherSelectors.count - 1) {
                [self appendXPath:@" and "];
            }
        }];
        [self appendXPath:@"]"];
    }
}

-(void) visitCSSCombinator:(CSSCombinator*)node
{
    switch (node.type) {
        case CSSCombinatorTypeNone:
        {
            [self appendXPath:@"//"];
        }
            break;
        case CSSCombinatorTypeDescendant:
        {
            [self appendXPath:@"/"];
        }
            break;
        case CSSCombinatorTypeAdjacent:
        {
            [self appendXPath:@"/following-sibling::*[1]/self::"];
        }
            break;
        case CSSCombinatorTypeGeneralSibling:
        {
            [self appendXPath:@"/following-sibling::"];
        }
            break;
    }
}

-(void) visitCSSSelectors:(CSSSelectors*)node
{
    [node.selectors enumerateObjectsUsingBlock:^(CSSBaseSelector* selector, NSUInteger idx, BOOL *stop) {
        // added NSStringFromClass() to work around for isKindOfClass: match error in unit test
        BOOL isSequence = [selector isKindOfClass:[CSSSelectorSequence class]] || [NSStringFromClass([selector class]) isEqualToString:NSStringFromClass([CSSSelectorSequence class])];
        BOOL hasCombinator = idx == 0 || (![[node.selectors objectAtIndex:idx - 1] isKindOfClass:[CSSCombinator class]] && ![NSStringFromClass([[node.selectors objectAtIndex:idx - 1] class]) isEqualToString:NSStringFromClass([CSSCombinator class])]);

        if (isSequence && hasCombinator) {
            [self visit:[CSSCombinator noneCombinator]];
        }
        [self visit:selector];
    }];
}

-(void) visitCSSSelectorAttribute:(CSSSelectorAttribute*)node
{
    if (node.value) {
        switch (node.attributeOperator.attributeOperator) {
            case CSSSelectorAttributeOperatorTypeEqual: {
                [self appendXPath:[NSString stringWithFormat:@"@%@ = \"%@\"", node.name, node.value]];
            }
                break;
            case CSSSelectorAttributeOperatorTypeIncludes: {
                [self appendXPath:[NSString stringWithFormat:@"contains(concat(\" \", @%@, \" \"),concat(\" \", \"%@\", \" \"))", node.name, node.value]];
            }
                break;
            case CSSSelectorAttributeOperatorTypeDash: {
                [self appendXPath:[NSString stringWithFormat:@"@%@ = \"%@\" or starts-with(@%@, concat(\"%@\", '-'))", node.name, node.value, node.name, node.value]];
            }
                break;
            case CSSSelectorAttributeOperatorTypeNone: {
                [self appendXPath:[NSString stringWithFormat:@"@%@", node.name]];
            }
                break;
        }
    } else {
        [self appendXPath:[NSString stringWithFormat:@"@%@", node.name]];
    }

}

-(void) visitCSSPseudoClass:(CSSPseudoClass*)node
{
    NSString* parentName = node.parent ? node.parent.name : @"*";
    NSString* mapping = [[self class] pseudoClassXPathMapping][node.name];
    if (mapping) {
        [self appendXPath:[NSString stringWithFormat:mapping, parentName]];
    }
}

#pragma mark - 


+(NSArray*) supportedPseudoClass {
    return [[self pseudoClassXPathMapping] allKeys];
}

+(NSDictionary*) pseudoClassXPathMapping {
    static NSDictionary* _pseudoClassXPathMapping;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pseudoClassXPathMapping = @{
                                     @"first-child": @"*[position() = 1 and self::%@]",
                                     @"last-child": @"*[position() = last() and self::%@]",
                                     @"first-of-type": @"%@[position() = 1]",
                                     @"last-of-type":@"%@[position() = last()]",
                                     @"only-child": @"*[last() = 1 and self::%@]",
                                     @"only-of-type": @"%@[last() = 1]",
                                     @"empty": @"%@[not(node())]"
                                     };
    });
    return _pseudoClassXPathMapping;
}

@end
