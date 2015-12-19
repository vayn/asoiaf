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

@interface PortalWebViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) Spinner *cubeSpinner;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIView *statusBackgroundView;

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

    [self setupWebView];
    [self setupStatusBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setTransparentNavigationBar];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.navigationController restoreDefaultNavigationBar];
    self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupWebView
{
    self.webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    self.webView.scrollView.delegate = self;
    self.webView.scrollView.bounces = NO;

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

    NSString *link = [self.category.link stringByReplacingOccurrencesOfString:@"Category" withString:@"Portal"];

    self.cubeSpinner.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view addSubview:self.cubeSpinner];
    [self.cubeSpinner startAnimating];

    [[MainManager sharedManager]getWikiEntry:link completionBlock:^(NSString *wikiEntry) {
        [portalTemplate replaceOccurrencesOfString:@"[[[content]]]"
                                        withString:wikiEntry
                                           options:NSLiteralSearch
                                             range:NSMakeRange(0, portalTemplate.length)];

        [self.cubeSpinner stopAnimating];
        [self.cubeSpinner setHidden:YES];
        [self.cubeSpinner removeFromSuperview];

        [self.webView loadHTMLString:portalTemplate baseURL:[NSURL fileURLWithPath:cssPath]];
        [self.view addSubview:self.webView];
    }];
}

- (void)setupStatusBar
{
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    CGRect frame = CGRectMake(0, 0, statusBarSize.width, statusBarSize.height);
    self.statusBackgroundView = [[UIView alloc] initWithFrame:frame];
    self.statusBackgroundView.backgroundColor = [UIColor whiteColor];
    self.statusBackgroundView.alpha = 0.0;
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    UIStatusBarStyle barStyle = (UIStatusBarStyle)self.navigationController.navigationBar.barStyle;

    if (offset.y >= 270 && barStyle == UIStatusBarStyleLightContent) {
        [self.view addSubview:self.statusBackgroundView];
        [UIView animateWithDuration:0.25 animations:^{
            self.navigationController.navigationBar.barStyle = UIStatusBarStyleDefault;
            self.statusBackgroundView.alpha = 1.0;
        }];
    } else if (offset.y < 270 && barStyle == UIStatusBarStyleDefault) {
        self.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
        self.statusBackgroundView.alpha = 0.0;
        [self.statusBackgroundView removeFromSuperview];
    }
}

@end
