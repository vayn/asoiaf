//
//  Spinner.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/23.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "Spinner.h"

@interface Spinner ()

@end

@implementation Spinner

+ (Spinner *)makeSpinner:(NSString *)spinnerPath
{
    FLAnimatedImage *spinnerImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:spinnerPath]];
    FLAnimatedImageView *spinnerImageView = [[FLAnimatedImageView alloc] init];
    spinnerImageView.animatedImage = spinnerImage;
    spinnerImageView.frame = CGRectMake(0, 0, 32, 32);

    return (Spinner *)spinnerImageView;
}

+ (Spinner *)cubeSpinner
{
    NSString *spinnerPath = [[NSBundle mainBundle] pathForResource:@"cubic_spinner" ofType:@"gif"];
    Spinner *spinner = [Spinner makeSpinner:spinnerPath];
    return spinner;
}

+ (Spinner *)knightSpinner
{
    NSString *spinnerPath = [[NSBundle mainBundle] pathForResource:@"knight_spinner" ofType:@"gif"];
    Spinner *spinner = [Spinner makeSpinner:spinnerPath];
    return spinner;
}
@end
