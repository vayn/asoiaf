//
//  Utilities.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/30.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (NSString *)appNameAndVersionNumberDisplayString
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appDisplayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];

    return [NSString stringWithFormat:@"%@ Version %@ (%@)", appDisplayName, majorVersion, minorVersion];
}

@end
