//
//  WikiViewController.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/12.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "WikiViewController.h"
#import "WikipediaHelper.h"
#import "ParallaxHeaderView.h"
#import "GradientView.h"
#import "UIImageViewAligned.h"
#import "JTSImageViewController.h"

#define TITLE_LABEL_HEIGHT 58

@interface WikiViewController () <WikipediaHelperDelegate, UIWebViewDelegate, UIScrollViewDelegate, ParallaxHeaderViewDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingActivity;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageViewAligned *imageView;
@property (nonatomic, strong) UIView *webBrowserView;
@property (nonatomic, strong) GradientView *blurView;
@property (nonatomic, strong) ParallaxHeaderView *parallaxHeaderView;

@property (nonatomic, strong) WikipediaHelper *wikiHelper;
@property (nonatomic, strong) UIImage *defaultImage;
@property (nonatomic, assign) CGFloat originalHeight;

@end

@implementation WikiViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.wikiHelper = [[WikipediaHelper alloc] init];
        self.wikiHelper.delegate = self;

        UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(homePressed:)];
        self.navigationItem.rightBarButtonItem = homeButton;

        self.defaultImage = [UIImage imageNamed:@"huiji_white_logo"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    self.webBrowserView = [[self.webView.scrollView subviews] objectAtIndex:0];

    [self.wikiHelper fetchArticle:self.title];

    [self.loadingActivity startAnimating];
    [self.loadingActivity setHidden:NO];

    [self setupParallaxHeaderView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup Views

- (void)resetView
{

    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    [self.webView.scrollView setContentOffset:CGPointMake(0, -self.webView.scrollView.contentInset.top) animated:NO];

    self.imageView.image = nil;
    [self.titleLabel removeFromSuperview];
}

- (void)setupHeaderView
{
    self.imageView = [[UIImageViewAligned alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 223)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.imageView.frame.size.height - TITLE_LABEL_HEIGHT,
                                                               self.imageView.frame.size.width, TITLE_LABEL_HEIGHT)];

    self.titleLabel.text = self.title;
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

- (void)setupParallaxHeaderView
{
    self.imageView = [[UIImageViewAligned alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 223)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;

    self.originalHeight = self.imageView.frame.size.height;

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, self.originalHeight - 80, self.imageView.frame.size.width - 30, 60)];

    self.titleLabel.text = [NSString stringWithFormat:@"  %@", self.title];
    self.titleLabel.text = [NSString stringWithFormat:@"  %@", self.title];
    self.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:21.0];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.shadowColor = [UIColor blackColor];
    self.titleLabel.shadowOffset = CGSizeMake(0, 1);
    self.titleLabel.textAlignment = UIControlContentHorizontalAlignmentLeft|UIControlContentVerticalAlignmentBottom;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.5;

    [self.imageView addSubview:self.titleLabel];

    self.blurView = [[GradientView alloc] initWithFrame:CGRectMake(0, -85, self.view.frame.size.width, self.originalHeight + 85)
                                                   type:TransparentGradientTwiceType];
    
    [self.imageView addSubview:self.blurView];
    [self.imageView bringSubviewToFront:self.titleLabel];

    self.parallaxHeaderView = [ParallaxHeaderView parallaxWebHeaderViewWithSubView:self.imageView
                                                                           forSize:CGSizeMake(self.view.frame.size.width, 223)];
    self.parallaxHeaderView.delegate = self;

    // We set _parallaxHeaderView's origin.y as -20, and _imageView is subview of it,
    // so we should set _webBrowerView's origin.y is -20 smaller than it of _imageView.
    CGRect f = self.webBrowserView.frame;
    f.origin.y = self.imageView.frame.size.height - 20;
    self.webBrowserView.frame = f;
    
    [self.webView.scrollView addSubview:self.parallaxHeaderView];
}

#pragma mark - WikipediaHelperDelegate

- (void)dataLoaded:(NSString *)htmlPage withUrlMainImage:(NSString *)urlMainImage
{
    if(![urlMainImage isEqualToString:@""] && urlMainImage != nil) {
        NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: urlMainImage]];
        UIImage *image = [UIImage imageWithData:imageData];
        self.imageView.image = image;
    } else {
        /**
         * When use ParallaxHeaderView, we don't need to reset header view
         *
         * // Reset subviews of self.webView if there is no image in the wiki page
         *
         * // Remove UIImageView
         * [self.imageView removeFromSuperview];
         *
         * CGRect titleFrame = self.titleLabel.frame;
         * titleFrame.origin.y = 0;
         * self.titleLabel.frame = titleFrame;
         *
         * [self.webView.scrollView addSubview:self.titleLabel];
         *
         * // Restore UIWebBrowserView's position
         * [UIView animateWithDuration:1.0 animations:^{
         *     CGRect f = self.webBrowserView.frame;
         *     f.origin.y = TITLE_LABEL_HEIGHT;
         *     self.webBrowserView.frame = f;
         * }];
         *
         */
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
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(jpg|png|gif)"
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:nil];
            NSInteger matchNum =  [regex numberOfMatchesInString:url
                                                         options:NSMatchingWithTransparentBounds
                                                           range:NSMakeRange(0, [url length])];
            if (matchNum > 0) {
                // Create image info
                JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
                imageInfo.imageURL = [NSURL URLWithString:url];
                imageInfo.referenceRect = self.webView.frame;
                imageInfo.referenceView = self.webView.superview;

                // Setup view controller
                JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                                       initWithImageInfo:imageInfo
                                                       mode:JTSImageViewControllerMode_Image
                                                       backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];

                // Present the view controller.
                [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
            } else {
                WikiViewController *nextWikiVC = [[WikiViewController alloc] init];

                NSString *title = [[url substringFromIndex:[prefix length]] stringByRemovingPercentEncoding];
                nextWikiVC.title = title;

                [self.navigationController pushViewController:nextWikiVC animated:YES];
            }
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat incrementY = scrollView.contentOffset.y;
    if (incrementY < 0) {
        // 不断设置 titleLabel 以保证 frame 正确
        self.titleLabel.frame = CGRectMake(15, self.originalHeight - 80 - incrementY, self.view.frame.size.width - 30, 60);

        // 不断添加删除 blurView.layer.sublayers![0] 以保证 frame 正确
        self.blurView.frame = CGRectMake(0, -85 - incrementY, self.view.frame.size.width, self.originalHeight + 85);
        [self.blurView.layer.sublayers[0] removeFromSuperlayer];
        [self.blurView insertTwiceTransparentGradient];

        // 使 Label 不被遮挡
        [self.imageView bringSubviewToFront:self.titleLabel];
    }

    [self.parallaxHeaderView layoutWebHeaderViewForScrollViewOffset:scrollView.contentOffset];
}

#pragma mark - ParallaxHeaderViewDelegate

/**
 * 设置滑动极限
 * 修改该值需要一并更改 layoutWebHeaderViewForScrollViewOffset 中的对应值
 */
- (void)lockDirection
{
    CGPoint offset = self.webView.scrollView.contentOffset;
    self.webView.scrollView.contentOffset = CGPointMake(offset.x, -154);
}

#pragma mark - Private methods

- (void)homePressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
