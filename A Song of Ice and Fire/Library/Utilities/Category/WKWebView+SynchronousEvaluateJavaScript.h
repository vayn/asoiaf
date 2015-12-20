//
//  WKWebView+SynchronousEvaluateJavaScript.h
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/12.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKWebView (SynchronousEvaluateJavaScript)

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;

@end
