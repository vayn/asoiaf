//
//  NSArray+Random.m
//  ice
//
//  Created by Vicent Tsai on 15/11/1.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "NSArray+Random.h"

@implementation NSArray (Random)

- (id)randomObject
{
    NSUInteger myCount = [self count];
    if (myCount) {
        return [self objectAtIndex:arc4random_uniform((unsigned int)myCount)];
    } else {
        return nil;
    }
}

@end
