//
//  CSSNamedSelector.h
//  CSSSelectorConverter
//
//  Created by Francis Chong on 7/1/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSSBaseSelector.h"

@interface CSSNamedSelector : CSSBaseSelector

@property (nonatomic, copy) NSString* name;

+(instancetype) selectorWithName:(NSString*)name;

@end
