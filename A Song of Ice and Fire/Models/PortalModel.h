//
//  PortalModel.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/20.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "CategoryMemberModel.h"
#import "PortalTypes.h"

@interface PortalModel : CategoryMemberModel

@property (nonatomic, assign) PortalType portalType;

- (instancetype)initWithTitle:(NSString *)aTitle
                         link:(NSString *)aLink
                       pageId:(NSNumber *)aPageId
              backgroundImage:(UIImage *)aImage
                   portalType:(PortalType)aPortalType;
@end
