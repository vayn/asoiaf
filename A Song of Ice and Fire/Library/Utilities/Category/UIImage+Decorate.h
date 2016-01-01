//
//  UIImage+Decorate.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 16/1/1.
//  Copyright © 2016年 HeZhi Corp. All rights reserved.
//

@import UIKit;

@interface UIImage (Decorate)

- (UIImage *)makeThumbnailOfSize:(CGSize)size;
- (UIImage *)makeRoundCornerOfRadius:(CGFloat)radius;

@end
