//
//  CubicSpinner.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/23.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "CubicSpinner.h"

@implementation CubicSpinner

+ (CubicSpinner *)spinner
{
    NSString *spinnerPath = [[NSBundle mainBundle] pathForResource:@"cubic_spinner" ofType:@"gif"];
    FLAnimatedImage *spinnerImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:spinnerPath]];
    FLAnimatedImageView *spinnerImageView = [[FLAnimatedImageView alloc] init];
    spinnerImageView.animatedImage = spinnerImage;
    spinnerImageView.frame = CGRectMake(0, 0, 32, 32);

    return (CubicSpinner *)spinnerImageView;
}

@end
