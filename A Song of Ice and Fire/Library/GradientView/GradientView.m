//
//  GradientView.m
//  GradientView
//
//  Created by xun yanan on 14-6-14.
//  Copyright (c) 2014年 xun yanan. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView

- (instancetype)initWithFrame:(CGRect)frame type:(GradientType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        if (type == TransparentGradientType) {
            [self insertTransparentGradient];
        } else if (type == ColorGradientType) {
            [self insertColorGradient];
        } else if (type == TransparentGradientTwiceType) {
            [self insertTwiceTransparentGradient];
        } else if (type == TransparentAnotherGradientType) {
            [self insertAnotherTransparentGradient];
        } else {
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Transparent Gradient Layer
- (void) insertTransparentGradient
{
    UIColor *colorOne = [UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:0.0];
    UIColor *colorTwo = [UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:1.0];

    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];

    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];

    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];

    // Create gradient layer
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    headerLayer.frame = self.bounds;
    
    [self.layer insertSublayer:headerLayer atIndex:0];
}

// Transparent Gradient Layer
- (void) insertAnotherTransparentGradient
{
    UIColor *colorOne = [UIColor colorWithRed:(19/255.0) green:(26/255.0) blue:(32/255.0) alpha:0.0];
    UIColor *colorTwo = [UIColor colorWithRed:(19/255.0) green:(26/255.0) blue:(32/255.0) alpha:1.0];

    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];

    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];

    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];

    // Create gradient layer
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    headerLayer.frame = self.bounds;
    
    [self.layer insertSublayer:headerLayer atIndex:0];
}

// Transparent Gradient Layer
- (void) insertTwiceTransparentGradient
{
    UIColor *colorOne = [UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:0.70];
    UIColor *colorTwo = [UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:0.15];
    UIColor *colorThree = [UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:0.15];
    UIColor *colorFour = [UIColor colorWithRed:(0/255.0) green:(0/255.0) blue:(0/255.0) alpha:0.75];

    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, colorThree.CGColor, colorFour.CGColor, nil];
    
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:0.20];
    NSNumber *stopThree = [NSNumber numberWithFloat:0.50];
    NSNumber *stopFour = [NSNumber numberWithFloat:1.0];

    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, stopThree, stopFour, nil];
    
    // Create gradient layer
    CAGradientLayer *headerLayer = [CAGradientLayer layer];
    
    headerLayer.colors = colors;
    headerLayer.locations = locations;
    headerLayer.frame = self.bounds;
    
    [self.layer insertSublayer:headerLayer atIndex:0];
}

// Color Gradient Layer
- (void) insertColorGradient
{
    
    UIColor *colorOne = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithRed:(33/255.0) green:(33/255.0) blue:(33/255.0) alpha:1.0];
    
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];

    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];

    // Create gradient layer
    CAGradientLayer *headerLayer = [CAGradientLayer layer];

    headerLayer.colors = colors;
    headerLayer.locations = locations;
    headerLayer.frame = self.bounds;
    
    [self.layer insertSublayer:headerLayer above:0];
}

@end
