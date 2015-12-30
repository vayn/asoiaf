//
//  WikiViewController.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/12.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "WikiViewController.h"
@import SafariServices;

#import "DataManager.h"
#import "WikipediaHelper.h"
#import "ParallaxHeaderView.h"
#import "GradientView.h"
#import "UIImageViewAligned.h"
#import "Spinner.h"
#import "ShareActivity.h"

#import "JTSImageViewController.h"
#import "OpenShareHeader.h"
#import "GTScrollNavigationBar.h"

static NSInteger const kHeaderHeight = 223;
static NSInteger const kTitleLabelHeight = 58;
static NSInteger const kBlurViewOffset = 85;
                 
@interface WikiViewController ()
<
WikipediaHelperDelegate,
UIWebViewDelegate,
UIScrollViewDelegate,
ParallaxHeaderViewDelegate,
UIGestureRecognizerDelegate
>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageViewAligned *imageView;
@property (nonatomic, strong) UIView *webBrowserView;
@property (nonatomic, strong) GradientView *blurView;
@property (nonatomic, strong) ParallaxHeaderView *parallaxHeaderView;
@property (nonatomic, strong) Spinner *cubeSpinner;

@property (nonatomic, strong) WikipediaHelper *wikiHelper;

@end

@implementation WikiViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _wikiHelper = [[WikipediaHelper alloc] init];
        _wikiHelper.delegate = self;
        _cubeSpinner = [Spinner cubeSpinner];

        NSMutableArray *rightButtons = [@[] mutableCopy];
        UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply
                                                                                    target:self
                                                                                    action:@selector(homeButtonPressed:)];
        [rightButtons addObject:homeButton];

        if ([OpenShare isWeixinInstalled]) {
            UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                         target:self
                                                                                         action:@selector(shareButtonPressed:)];
            [rightButtons addObject:shareButton];
        }

        self.navigationItem.rightBarButtonItems = [rightButtons copy];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    self.webBrowserView = [[self.webView.scrollView subviews] objectAtIndex:0];

    self.cubeSpinner.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, self.view.frame.size.height/2);
    [self.view addSubview:self.cubeSpinner];
    [self.cubeSpinner startAnimating];

    [self setupParallaxHeaderView];
    [self setupGestures];

    // Start fetch article with page title
    [self.wikiHelper fetchArticle:self.title];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setValue:[GTScrollNavigationBar new] forKey:@"navigationBar"];
    self.navigationController.scrollNavigationBar.scrollView = self.webView.scrollView;
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.navigationController.scrollNavigationBar resetToDefaultPositionWithAnimation:NO];
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

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.imageView.frame.size.height - kTitleLabelHeight,
                                                               self.imageView.frame.size.width, kTitleLabelHeight)];

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
    self.imageView = [[UIImageViewAligned alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kHeaderHeight)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;

    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, kHeaderHeight - 80, self.imageView.frame.size.width - 30, 60)];

    self.titleLabel.text = self.title;
    self.titleLabel.font = [UIFont fontWithName:@"STHeitiSC-Medium" size:21.0];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.shadowColor = [UIColor blackColor];
    self.titleLabel.shadowOffset = CGSizeMake(0, 1);
    self.titleLabel.textAlignment = UIControlContentHorizontalAlignmentLeft|UIControlContentVerticalAlignmentBottom;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.5;

    [self.imageView addSubview:self.titleLabel];

    self.blurView = [[GradientView alloc] initWithFrame:
                     CGRectMake(0, -kBlurViewOffset, self.view.frame.size.width, kHeaderHeight + kBlurViewOffset)
                                                   type:TransparentGradientTwiceType];
    
    [self.imageView addSubview:self.blurView];
    [self.imageView bringSubviewToFront:self.titleLabel];

    self.parallaxHeaderView = [ParallaxHeaderView parallaxWebHeaderViewWithSubView:self.imageView
                                                                           forSize:CGSizeMake(self.view.frame.size.width, 223)];
    self.parallaxHeaderView.delegate = self;

    // ParallaxHeaderView's origin.y as -20 in ParallaxHeaderView class,
    // so we should set self.webBrowerView's origin.y is -20 smaller than it.
    CGRect f = self.webBrowserView.frame;
    f.origin.y = kHeaderHeight - 20;
    self.webBrowserView.frame = f;
    
    [self.webView.scrollView addSubview:self.parallaxHeaderView];
}


#pragma mark - Setup Gestures

- (void)setupGestures
{
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.webView addGestureRecognizer:singleTap];
    singleTap.delegate = self;
    singleTap.cancelsTouchesInView = NO;
}

-(void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    CGPoint pt = [sender locationInView:self.webView];
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", pt.x, pt.y];
    NSString *imageSource = [self.webView stringByEvaluatingJavaScriptFromString:imgURL];
    if (imageSource.length > 0) {
        // Create image info
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.imageURL = [NSURL URLWithString:imageSource];

        imageInfo.referenceRect = self.webView.frame;
        imageInfo.referenceView = self.webView.superview;

        // Setup view controller
        JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                               initWithImageInfo:imageInfo
                                               mode:JTSImageViewControllerMode_Image
                                               backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];

        // Present the view controller.
        [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    }
}

#pragma mark - WikipediaHelperDelegate

- (void)dataLoaded:(NSString *)htmlPage withUrlMainImage:(NSString *)urlMainImage
{
    if(![urlMainImage isEqualToString:@""] && urlMainImage != nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            // Perform long running process
            NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: urlMainImage]];
            UIImage *image = [UIImage imageWithData:imageData];

            /* *
             *
             * Check for imageView before dispatching to the main thread.
             *
             * This avoids the main queue dispatch if the network request took a long time and
             * the imageView is no longer there for one reason or another.
             *
             */
            if (!self.imageView) return;

            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                self.imageView.image = image;
            });
        });
    } else {
        [[ImageManager sharedManager] getRandomImage:^(UIImage *image) {
            if (!self.imageView) return;
            self.imageView.image = image;
        }];
    }

    // When the article is loaded, hide and remove spinner from self.view
    [self.cubeSpinner stopAnimating];
    [self.cubeSpinner setHidden:YES];
    [self.cubeSpinner removeFromSuperview];

    [self.webView loadHTMLString:htmlPage baseURL:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = [[request URL] absoluteString];
    NSString *prefix = @"http://asoiaf.huiji.wiki/wiki/";

    if (navigationType == UIWebViewNavigationTypeLinkClicked && [url hasPrefix:@"http"]) {
        // Check if the clicked link is a image or not
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\.(jpg|gif|png)"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSTextCheckingResult *match = [regex firstMatchInString:url options:0 range:NSMakeRange(0, [url length])];

        // All internal links except IMAGE could create new wiki view controller
        if ([url hasPrefix:prefix] && !match) {
            WikiViewController *nextWikiVC = [[WikiViewController alloc] init];

            NSString *title = [[url substringFromIndex:[prefix length]] stringByRemovingPercentEncoding];
            nextWikiVC.title = title;

            [self.navigationController pushViewController:nextWikiVC animated:YES];
        }
        else if (!match) {
            SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[request URL] entersReaderIfAvailable:YES];
            [self presentViewController:safariVC animated:YES completion:nil];
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
        self.titleLabel.frame = CGRectMake(15, kHeaderHeight - 80 - incrementY, self.view.frame.size.width - 30, 60);

        // 不断添加删除 blurView.layer.sublayers![0] 以保证 frame 正确
        self.blurView.frame = CGRectMake(0, -kBlurViewOffset - incrementY,
                                         self.view.frame.size.width, kHeaderHeight + kBlurViewOffset);
        [self.blurView.layer.sublayers[0] removeFromSuperlayer];
        [self.blurView insertTwiceTransparentGradient];

        // 使 Label 不被遮挡
        [self.imageView bringSubviewToFront:self.titleLabel];
    }

    [self.parallaxHeaderView layoutWebHeaderViewForScrollViewOffset:scrollView.contentOffset];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [self.navigationController.scrollNavigationBar resetToDefaultPositionWithAnimation:NO];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
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

#pragma mark - Control Action

- (void)homeButtonPressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)shareButtonPressed:(id)sender
{
    NSString *title = self.title;

    NSString *linkString = [[NSString stringWithFormat:@"http://asoiaf.huiji.wiki/wiki/%@", self.title]
                            stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *link = [NSURL URLWithString:linkString];

    UIImage *image = self.imageView.image;
    if (!image) {
        image = [UIImage imageNamed:@"launch_background"];
    }

    UIView *hudScene = self.view;

    NSArray *objectsToShare = @[title, link, image, hudScene];

    NSArray *activity = @[[[WexinSessionActivity alloc] init],
                          [[WexinTimelineActivity alloc] init],
                          [[QQActivity alloc] init]];

    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare
                                                                             applicationActivities:activity];

    NSArray *excludeActivities = @[UIActivityTypePostToFacebook,
                                   UIActivityTypeMessage,
                                   UIActivityTypeMail,
                                   UIActivityTypePrint,
                                   UIActivityTypeCopyToPasteboard,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo,
                                   UIActivityTypePostToTencentWeibo,
                                   UIActivityTypeAirDrop];

    activityVC.excludedActivityTypes = excludeActivities;

    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
