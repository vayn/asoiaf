//
//  CSSPseudoClass.m
//  CSSSelectorConverter
//
//  Created by Chong Francis on 14年1月8日.
//  Copyright (c) 2014年 Ignition Soft. All rights reserved.
//
#import "CSSPseudoClass.h"
#import "NUIParse.h"

@implementation CSSPseudoClass

- (id)initWithSyntaxTree:(NUIPSyntaxTree *)syntaxTree {
    self = [self init];
    
    id token = [syntaxTree valueForTag:@"className"];
    if ([token isIdentifierToken]) {
        self.name = [token identifier];
    }

    return self;
}

-(NSString*) description {
    return [NSString stringWithFormat:@"<CSSPseudoClass %@>", self.name];
}

@end
