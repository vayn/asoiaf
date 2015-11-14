//
//  CSSBaseSelector.m
//  CSSSelectorConverter
//
//  Created by Francis Chong on 7/1/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "CSSBaseSelector.h"

@implementation CSSBaseSelector

-(NSString*) description {
    return @"<BaseSeletor>";
}

+(instancetype) selector {
    return [[self alloc] init];
}

@end
