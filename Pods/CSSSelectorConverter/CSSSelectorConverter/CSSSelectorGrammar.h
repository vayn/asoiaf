//
//  CSSSelectorGrammar.h
//  CSSSelectorConverter
//
//  Created by Francis Chong on 1/20/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "NUIPGrammar.h"

@interface CSSSelectorGrammar : NUIPGrammar

/**
 * Create a Grammar object using the grammar file in the bundle.
 */
-(instancetype) init;

/**
 * Create a Grammar object using the grammar file supplied.
 * @param path Path to the grammar defintion
 */
-(instancetype) initWithPath:(NSString*)path;

@end
