//
//  PortalTypes.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/17.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PortalType) {
    PortalBookType = 0,
    PortalChapterType,
    PortalCharacterType,
    PortalHouseType,
    PortalHistoryType,
    PortalCultureType,
    PortalGeoType,
    PortalTVType,
    PortalInferenceType
};

@interface PortalTypes : NSObject

@end
