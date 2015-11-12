//
//  WikiViewController.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/12.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "WikiViewController.h"
#import "WikipediaHelper.h"

@interface WikiViewController () <WikipediaHelperDelegate, UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imgView;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingActivity;

@property (nonatomic ,strong) WikipediaHelper *wikiHelper;
@property (nonatomic, strong) UIImage *defaultImage;

@end

@implementation WikiViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.wikiHelper = [[WikipediaHelper alloc] init];
        self.wikiHelper.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.webView.delegate = self;
    self.defaultImage = self.imgView.image;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.titleLabel.text = self.pageTitle;
    [self.wikiHelper fetchArticle:self.pageTitle];

    [self.loadingActivity startAnimating];
    [self.loadingActivity setHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    self.imgView.image = self.defaultImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPageTitle:(NSString *)pageTitle
{
    _pageTitle = pageTitle;
}

- (void)dataLoaded:(NSString *)htmlPage withUrlMainImage:(NSString *)urlMainImage
{
    if(![urlMainImage isEqualToString:@""] && urlMainImage != nil) {
        NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: urlMainImage]];
        UIImage *image = [UIImage imageWithData:imageData];
        self.imgView.image = image;
    }

    [self.loadingActivity stopAnimating];
    [self.loadingActivity setHidden:YES];

    [self.webView loadHTMLString:htmlPage baseURL:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        return NO;
    }
    return YES;
}

@end
