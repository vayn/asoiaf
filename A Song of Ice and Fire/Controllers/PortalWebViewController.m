//
//  PortalWebViewController.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/12/19.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <WebKit/WebKit.h>

#import "PortalWebViewController.h"
#import "CategoryMemberModel.h"
#import "DataManager.h"
#import "Spinner.h"
#import "UINavigationController+TransparentNavigationBar.h"

@interface PortalWebViewController ()

@property (nonatomic, strong) Spinner *cubeSpinner;

@end

@implementation PortalWebViewController

- (instancetype)initWithCategory:(CategoryMemberModel *)category
{
    self = [super init];
    if (self) {
        _category = category;
        _cubeSpinner = [Spinner cubeSpinner];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.cubeSpinner.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view addSubview:self.cubeSpinner];
    [self.cubeSpinner startAnimating];

    [self setupWebView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setTransparentNavigationBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController restoreDefaultNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupWebView
{
    // Main bundle
    NSBundle *mainBundle = [NSBundle mainBundle];

#ifdef DEBUG
    NSString *cssPath = [mainBundle pathForResource:@"wikiview" ofType:@"css"];
#else
    NSString *cssPath = [mainBundle pathForResource:@"wikiview-min" ofType:@"css"];
#endif

    NSString *css = [NSString stringWithContentsOfFile:cssPath encoding:NSUTF8StringEncoding error:nil];

    NSString *portalTemplatePath = [mainBundle pathForResource:@"portal_template" ofType:@"html"];
    NSMutableString *portalTemplate = [NSMutableString stringWithContentsOfFile:portalTemplatePath encoding:NSUTF8StringEncoding error:nil];

    [portalTemplate replaceOccurrencesOfString:@"[[[css]]]"
                                    withString:css
                                       options:NSLiteralSearch
                                         range:NSMakeRange(0, portalTemplate.length)];

    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    NSString *link = [self.category.link stringByReplacingOccurrencesOfString:@"Category" withString:@"Portal"];

    [[MainManager sharedManager]getWikiEntry:link completionBlock:^(NSString *wikiEntry) {
        [portalTemplate replaceOccurrencesOfString:@"[[[content]]]"
                                        withString:wikiEntry
                                           options:NSLiteralSearch
                                             range:NSMakeRange(0, portalTemplate.length)];

        [self.cubeSpinner stopAnimating];
        [self.cubeSpinner setHidden:YES];
        [self.cubeSpinner removeFromSuperview];

        [webView loadHTMLString:portalTemplate baseURL:[NSURL fileURLWithPath:cssPath]];
        [self.view addSubview:webView];
    }];
}

@end
