//
//  CSSNamedSelector.m
//  CSSSelectorConverter
//
//  Created by Francis Chong on 7/1/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "CSSNamedSelector.h"

@implementation CSSNamedSelector

+(instancetype) selectorWithName:(NSString*)name {
    CSSNamedSelector* selector = [[self alloc] init];
    selector.name = name;
    return selector;
}

-(NSString*) description {
    return [NSString stringWithFormat:@"<NamedSeletor %@>", _name];
}

@end
