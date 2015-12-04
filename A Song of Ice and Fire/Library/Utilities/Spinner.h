//
//  Spinner.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/23.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <FLAnimatedImage/FLAnimatedImage.h>

@interface Spinner : FLAnimatedImageView

+ (Spinner *)makeSpinner:(NSString *)spinnerPath;

+ (Spinner *)cubeSpinner;
+ (Spinner *)knightSpinner;

@end
