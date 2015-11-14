//
//  CSSSelectorAttribute.h
//  CSSSelectorConverter
//
//  Created by Chong Francis on 14年1月8日.
//  Copyright (c) 2014年 Ignition Soft. All rights reserved.
//

#import "CSSBaseSelector.h"
#import "CSSSelectorAttributeOperator.h"
#import "NUIPParser.h"

@interface CSSSelectorAttribute : CSSBaseSelector <NUIPParseResult>

@property (nonatomic, strong) CSSSelectorAttributeOperator* attributeOperator;
@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSString* value;

@end
