//
//  WikiViewController.m
//  A Song of Ice and Fire
//
//  Created by Vicent Tsai on 15/11/12.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "WikiViewController.h"
#import "WikipediaHelper.h"

@interface WikiViewController () <WikipediaHelperDelegate>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imgView;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingActivity;

@end

@implementation WikiViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    WikipediaHelper *wikiHelper = [[WikipediaHelper alloc] init];
    wikiHelper.delegate = self;

    [wikiHelper fetchArticle:_pageTitle];
    [self.loadingActivity startAnimating];
    self.loadingActivity.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPageTitle:(NSString *)pageTitle
{
    _pageTitle = pageTitle;
    self.titleLabel.text = pageTitle;
}

- (void)dataLoaded:(NSString *)htmlPage withUrlMainImage:(NSString *)urlMainImage
{
    if(![urlMainImage isEqualToString:@""]) {
        NSData *imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: urlMainImage]];
        UIImage *image = [UIImage imageWithData:imageData];
        self.imgView.image = image;
    }

    [self.loadingActivity stopAnimating];
    self.loadingActivity.hidden = YES;

    [self.webView loadHTMLString:htmlPage baseURL:nil];
}

@end
