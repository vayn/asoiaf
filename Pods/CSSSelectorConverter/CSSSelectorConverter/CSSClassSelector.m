//
//  CSSClassSelector.m
//  CSSSelectorConverter
//
//  Created by Francis Chong on 7/1/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "CSSClassSelector.h"
#import "NUIParse.h"

@implementation CSSClassSelector

- (id)initWithSyntaxTree:(NUIPSyntaxTree *)syntaxTree {
    self = [self init];
    if (self) {
        NSArray *components = [syntaxTree children];
        if ([components count] == 2) {
            NUIPIdentifierToken* token = components[1];
            if ([token isIdentifierToken]) {
                self.name = [token identifier];
            }
        }
    }
    return self;
}

-(NSString*) description {
    return [NSString stringWithFormat:@"<ClassSelector %@>", self.name];
}

@end
