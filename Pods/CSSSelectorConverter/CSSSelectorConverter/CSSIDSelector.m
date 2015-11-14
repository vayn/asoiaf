//
//  CSSIDSelector.m
//  CSSSelectorConverter
//
//  Created by Francis Chong on 7/1/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "CSSIDSelector.h"
#import "NUIParse.h"

@implementation CSSIDSelector

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
    return [NSString stringWithFormat:@"<IDSelector %@>", self.name];
}

@end
