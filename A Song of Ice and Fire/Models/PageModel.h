//
//  PageModel.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/2.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PageModel : NSObject

@property (nonatomic, strong) NSNumber *pageId;
@property (nonatomic, strong) NSString *title;

- (instancetype)initWithTitle:(NSString *)aTitle pageId:(NSNumber *)aPageId;

@end
