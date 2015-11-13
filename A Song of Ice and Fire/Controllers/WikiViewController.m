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

    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    self.imageView.image = nil;
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

        // Restore UIWebBrowserView's position
        [UIView animateWithDuration:1.0 animations:^{
            CGRect f = self.webBrowserView.frame;
            f.origin.y = 0;
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
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        return NO;
    }
    return YES;
}

#pragma mark - Setup Views

- (void)setupHeaderView
{
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 223)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.imageView.frame.size.height - 88,
                                                               self.imageView.frame.size.width, 88)];

    self.titleLabel.backgroundColor = [UIColor colorWithRed:42/255.0 green:196/255.0 blue:234/255.0 alpha:0.7];
    self.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:21.0];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.shadowColor = [UIColor blackColor];
    self.titleLabel.shadowOffset = CGSizeMake(0, 1);
    self.titleLabel.textAlignment = UIControlContentHorizontalAlignmentLeft|UIControlContentVerticalAlignmentBottom;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.text = _pageTitle;

    [self.imageView addSubview:self.titleLabel];

    CGRect f = self.webBrowserView.frame;
    f.origin.y = self.imageView.frame.size.height;
    self.webBrowserView.frame = f;

    [self.webView.scrollView addSubview:self.imageView];
}

@end
