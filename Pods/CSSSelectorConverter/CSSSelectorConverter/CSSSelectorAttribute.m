//
//  CSSSelectorAttribute.m
//  CSSSelectorConverter
//
//  Created by Chong Francis on 14年1月8日.
//  Copyright (c) 2014年 Ignition Soft. All rights reserved.
//

#import "CSSSelectorParser.h"
#import "CSSSelectorAttribute.h"
#import "NUIParse.h"

@implementation CSSSelectorAttribute

- (id)initWithSyntaxTree:(NUIPSyntaxTree *)syntaxTree {
    self = [self init];
    if (self) {
        self.attributeOperator = [syntaxTree valueForTag:@"op"];
        self.name = [[syntaxTree valueForTag:@"attrName"] identifier];
        
        NSArray* valChildren = [[syntaxTree valueForTag:@"attrValue"] children];
        if (valChildren) {
            if ([valChildren count] == 1 && [valChildren[0] isQuotedToken]) {
                self.value = [valChildren[0] content];
            }
        }
    }
    return self;
}

-(NSString*) description {
    return [NSString stringWithFormat:@"<CSSSelectorAttribute %@%@'%@'>", self.name, self.attributeOperator.name, self.value];
}

@end
