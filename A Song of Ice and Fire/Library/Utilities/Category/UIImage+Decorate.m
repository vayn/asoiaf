//
//  UIImage+Decorate.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 16/1/1.
//  Copyright © 2016年 HeZhi Corp. All rights reserved.
//

#import "UIImage+Decorate.h"

@implementation UIImage (Decorate)

- (UIImage *)makeThumbnailOfSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);

    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return newImage;
}

- (UIImage *)makeRoundCornerOfRadius:(CGFloat)radius
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);

    CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
    [[UIBezierPath bezierPathWithRoundedRect:imageRect cornerRadius:radius] addClip];
    [self drawInRect:imageRect];

    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return newImage;
}

@end
