//
//  WikiViewController.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/12.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "WikiViewController.h"
#import "WikipediaHelper.h"

#define TITLE_LABEL_HEIGHT 58

@interface WikiViewController () <WikipediaHelperDelegate, UIWebViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingActivity;

@property (nonatomic, strong) UIView *webBrowserView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) WikipediaHelper *wikiHelper;
@property (nonatomic, strong) UIImage *defaultImage;
@property (nonatomic, assign) BOOL isUnloaded;

@end

@implementation WikiViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.wikiHelper = [[WikipediaHelper alloc] init];
        self.wikiHelper.delegate = self;

        self.defaultImage = [UIImage imageNamed:@"huiji_white_logo"];
        self.isUnloaded = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.webView.delegate = self;
    self.webBrowserView = [[self.webView.scrollView subviews] objectAtIndex:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.isUnloaded) {
        [self.wikiHelper fetchArticle:self.pageTitle];

        [self.loadingActivity startAnimating];
        [self.loadingActivity setHidden:NO];

        [self setupHeaderView];

        self.isUnloaded = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self resetView];

    self.isUnloaded = YES;
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
        self.imageView.image = image;
    } else {
        // Reset subviews of self.webView if there is no image in the wiki page

        // Remove UIImageView
        [self.imageView removeFromSuperview];

        CGRect titleFrame = self.titleLabel.frame;
        titleFrame.origin.y = 0;
        self.titleLabel.frame = titleFrame;

        [self.webView.scrollView addSubview:self.titleLabel];

        // Restore UIWebBrowserView's position
        [UIView animateWithDuration:1.0 animations:^{
            CGRect f = self.webBrowserView.frame;
            f.origin.y = TITLE_LABEL_HEIGHT;
            self.webBrowserView.frame = f;
        }];
    }

    [self.loadingActivity stopAnimating];
    [self.loadingActivity setHidden:YES];

    [self.webView loadHTMLString:htmlPage baseURL:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = [[request URL] absoluteString];
    NSString *prefix = @"http://asoiaf.huiji.wiki/wiki/";

    if (navigationType == UIWebViewNavigationTypeLinkClicked && [url hasPrefix:@"http"]) {
        if ([url hasPrefix:prefix]) {
            WikiViewController *nextWikiVC = [[WikiViewController alloc] init];

            NSString *pageTitle = [[url substringFromIndex:[url rangeOfString:prefix].length] stringByRemovingPercentEncoding];

            nextWikiVC.pageTitle = pageTitle;
            NSLog(@"%@", nextWikiVC.pageTitle);

            [self.navigationController pushViewController:nextWikiVC animated:YES];
        }
        return NO;
    }

    return YES;
}

/* Disable UIWebView horizontal scrolling */
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [webView.scrollView setContentSize: CGSizeMake(webView.frame.size.width, webView.scrollView.contentSize.height)];
}

#pragma mark - Setup Views

- (void)setupHeaderView
{
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 223)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.imageView.frame.size.height - TITLE_LABEL_HEIGHT,
                                                               self.imageView.frame.size.width, TITLE_LABEL_HEIGHT)];

    self.titleLabel.text = [NSString stringWithFormat:@"  %@", _pageTitle];
    self.titleLabel.backgroundColor = [UIColor colorWithRed:42/255.0 green:196/255.0 blue:234/255.0 alpha:0.7];
    self.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:21.0];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.shadowColor = [UIColor blackColor];
    self.titleLabel.shadowOffset = CGSizeMake(0, 1);
    self.titleLabel.textAlignment = UIControlContentHorizontalAlignmentLeft|UIControlContentVerticalAlignmentBottom;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.5;

    [self.imageView addSubview:self.titleLabel];

    CGRect f = self.webBrowserView.frame;
    f.origin.y = self.imageView.frame.size.height;
    self.webBrowserView.frame = f;

    [self.webView.scrollView addSubview:self.imageView];
}

- (void)resetView
{

    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    [self.webView.scrollView setContentOffset:CGPointMake(0, -self.webView.scrollView.contentInset.top) animated:NO];

    self.imageView.image = nil;
    [self.titleLabel removeFromSuperview];
}

@end
