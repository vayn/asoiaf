//
//  CSSSelectorXPathVisitor.h
//  CSSSelectorConverter
//
//  Created by Francis Chong on 1/22/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSSBaseSelector;

/**
 * Walk a tree of CSSBaseSelector subclasses, and build a XPath representation of the CSS.
 * 
 * Upon finish, invoke xpathString to get the XPath.
 */
@interface CSSSelectorXPathVisitor : NSObject


/**
 * Visit a selector node (CSSBaseSelector subclasses) and generate XPath representation of the CSS Selector.
 *
 * @param node A CSSBaseSelector subclasses.
 * @throw NSInvalidArgumentException if the class is not supported by the visitor.
 */
-(void) visit:(CSSBaseSelector*)node;

/**
 * @return Returns XPath representation of the CSS Selector.
 */
-(NSString*) xpathString;

@end
