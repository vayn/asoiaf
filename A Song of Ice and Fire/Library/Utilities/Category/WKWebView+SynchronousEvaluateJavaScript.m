//
//  WKWebView+SynchronousEvaluateJavaScript.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/12.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "WKWebView+SynchronousEvaluateJavaScript.h"

@implementation WKWebView (SynchronousEvaluateJavaScript)

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script
{
    __block NSString *resultString = nil;
    __block BOOL finished = NO;

    [self evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
        if (error == nil) {
            if (result != nil) {
                resultString = [NSString stringWithFormat:@"%@", result];
            }
        } else {
            NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
        }
        finished = YES;
    }];

    while (!finished)
    {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }

    return resultString;
}

@end
