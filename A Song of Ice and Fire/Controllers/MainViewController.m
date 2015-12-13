//
//  MainViewController.m
//  ice
//
//  Created by Vicent Tsai on 15/10/25.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NSArray+Random.h"

#import "MainViewController.h"
#import "SlideMenuViewController.h"
#import "CarrouselViewController.h"
#import "portalCollectionViewController.h"
#import "KnowTipTableViewController.h"

#import "DataManager.h"
#import "Models.h"
#import "Spinner.h"

static CGFloat const kSlideTiming = 0.25;
static CGFloat const kOverlayAlphaBegan = 0.0;
static CGFloat const kOverlayAlphaEnd = 0.7;
               
@interface MainViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *featuredQuoteView;
@property (weak, nonatomic) IBOutlet UILabel *quoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIView *portalView;
@property (weak, nonatomic) IBOutlet UIView *knowTipView;

@property (nonatomic, strong) CarrouselViewController *carrouselViewController;
@property (nonatomic, strong) PortalCollectionViewController *portalCollectionViewController;
@property (nonatomic, strong) KnowTipTableViewController *knowTipTableViewController;

@property (nonatomic, strong) SlideMenuViewController *slideMenuViewController;
@property (nonatomic, assign) BOOL showingSlideMenu;
@property (nonatomic, assign) BOOL showMenu;
@property (nonatomic, assign) CGPoint preVelocity;

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, assign) CGFloat overlayAlphaSpeed;

@end

@implementation MainViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        UINavigationItem *navItem = self.navigationItem;
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"\u2630"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(btnMoveMenuRight:)];
        bbi.tag = 1;
        navItem.leftBarButtonItem = bbi;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    [self setupOverlayView];
    [self setupCarrouselView];
    [self setupFeaturedQuoteLabel];
    [self setupPortalView];
    [self setupKnowTipView];

    [self setupGestures];

    // Test if the network is disconnected
    [[NSNotificationCenter defaultCenter]
     addObserverForName:@"ERR_INTERNET_DISCONNECTED"
                 object:nil
                 queue:nil
            usingBlock:^(NSNotification * _Nonnull note) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"应用未联网"
                                                                               message:@"请联网后重新打开应用"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * _Nonnull action) { }];
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self moveMenuToOriginalPosition];
}

#pragma mark - Button Actions

- (void)btnMoveMenuRight:(id)sender
{
    UIButton *button = sender;
    switch (button.tag) {
        case 0: {
            [self moveMenuToOriginalPosition];
            break;
        }

        case 1: {
            [self moveMenuRight];
            break;
        }

        default:
            break;
    }
}

#pragma mark - Menu Actions

- (void)moveMenuToOriginalPosition
{
    UIView *childView = [self getSlideMenuView];

    [UIView animateWithDuration:kSlideTiming delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         childView.frame = CGRectOffset(childView.frame, -childView.frame.size.width, 0);
                         self.overlayView.alpha = kOverlayAlphaBegan;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [self resetMainView];
                         }
                     }];
}

- (void)moveMenuRight
{
    UIView *childView = [self getSlideMenuView];

    [UIView animateWithDuration:kSlideTiming delay:0 options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         childView.frame = CGRectMake(0, 0,
                                                      childView.frame.size.width, childView.frame.size.height);
                         self.overlayView.alpha = kOverlayAlphaEnd;
                     } completion:^(BOOL finished) {
                         if (finished) {
                             self.navigationItem.leftBarButtonItem.tag = 0;
                         }
                     }];
}

#pragma mark - Setup View

- (void)resetMainView
{
    if (self.slideMenuViewController != nil) {
        [self.slideMenuViewController.view removeFromSuperview];
        self.slideMenuViewController = nil;

        // Restore scrolling
        self.scrollView.scrollEnabled = YES;

        [self.overlayView removeFromSuperview];

        self.navigationItem.leftBarButtonItem.tag = 1;
        self.showingSlideMenu = NO;
    }
}

- (UIView *)getSlideMenuView
{
    if (self.slideMenuViewController == nil) {
        self.slideMenuViewController = [[SlideMenuViewController alloc] initWithNibName:@"SlideMenuViewController" bundle:nil];

        [self.view addSubview:self.slideMenuViewController.view];

        // Stop scrolling when slide menu slides out
        self.scrollView.scrollEnabled = NO;

        [self addChildViewController:self.slideMenuViewController];
        [self.slideMenuViewController didMoveToParentViewController:self];

        self.slideMenuViewController.view.frame = CGRectOffset(self.slideMenuViewController.view.frame,
                                                               -self.slideMenuViewController.view.frame.size.width, 0);

        CGFloat slideMenuWidth = self.slideMenuViewController.view.frame.size.width;
        self.overlayAlphaSpeed = fabs(kOverlayAlphaBegan - kOverlayAlphaEnd) / slideMenuWidth;

        [self setupSlideMenuGestures:self.slideMenuViewController.view];
    }

    self.showingSlideMenu = YES;

    UIView *view = self.slideMenuViewController.view;

    [self.view addSubview:self.overlayView];
    [self.view bringSubviewToFront:view];

    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOpacity = 0.8;
    view.layer.shadowOffset = CGSizeMake(.2, .2);

    return view;
}

- (void)setupOverlayView
{
    self.overlayView = [[UIView alloc] initWithFrame:self.navigationController.view.frame];
    self.overlayView.backgroundColor = [UIColor blackColor];
    self.overlayView.alpha = kOverlayAlphaBegan;
}

- (void)setupCarrouselView
{
    self.carrouselViewController = [[CarrouselViewController alloc] init];

    [self.containerView addSubview:self.carrouselViewController.view];
    [self addChildViewController:self.carrouselViewController];
    [self didMoveToParentViewController:self.carrouselViewController];
}

- (void)setupFeaturedQuoteLabel
{
    [self.quoteLabel setHidden:YES];
    [self.authorLabel setHidden:YES];

    // Use custom loading spinner instead of UIActivityIndicatorView
    Spinner *cubeSpinner = [Spinner cubeSpinner];

    [self.featuredQuoteView addSubview:cubeSpinner];
    cubeSpinner.center = CGPointMake(self.featuredQuoteView.frame.size.width/2,
                                 self.featuredQuoteView.frame.size.height/2);
    [cubeSpinner startAnimating];

    [[MainManager sharedManager] getFeaturedQuotes:^(NSArray *featuredQuotes) {
        FeaturedQuoteModel *featuredQuote = [featuredQuotes randomObject];
        self.quoteLabel.text = featuredQuote.quote;
        self.authorLabel.text = [NSString stringWithFormat:@"——%@", featuredQuote.author];
    }];

    [[NSNotificationCenter defaultCenter] addObserverForName:@"getFeaturedQuotes"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      CATransition *animation = [CATransition animation];
                                                      animation.type = kCATransitionFade;
                                                      animation.duration = 0.4;
                                                      
                                                      [self.quoteLabel.layer addAnimation:animation forKey:nil];
                                                      [self.authorLabel.layer addAnimation:animation forKey:nil];

                                                      [self.quoteLabel setHidden:NO];
                                                      [self.authorLabel setHidden:NO];

                                                      [cubeSpinner removeFromSuperview];
                                                  }];
}

- (void)setupPortalView
{
    self.portalCollectionViewController = [[PortalCollectionViewController alloc] init];
    self.portalCollectionViewController.view.frame = self.portalView.bounds;
    self.portalCollectionViewController.collectionView.backgroundColor = [UIColor whiteColor];

    [self.portalView addSubview:self.portalCollectionViewController.view];
    [self addChildViewController:self.portalCollectionViewController];
    [self didMoveToParentViewController:self.portalCollectionViewController];
}

- (void)setupKnowTipView
{
    self.knowTipTableViewController = [[KnowTipTableViewController alloc] init];
    self.knowTipTableViewController.view.frame = self.knowTipView.frame;

    [self.containerView addSubview:self.knowTipTableViewController.view];
    [self addChildViewController:self.knowTipTableViewController];
    [self didMoveToParentViewController:self.knowTipTableViewController];
}

- (void)hideLoadingActivity
{
}

#pragma mark - Swipe Gesture Setup/Actions
#pragma mark - setup

- (void)setupGestures
{
    UIScreenEdgePanGestureRecognizer *edgePanRecognizer = [[UIScreenEdgePanGestureRecognizer alloc]
                                                           initWithTarget:self
                                                           action:@selector(screenEdgeSwiped:)];
    edgePanRecognizer.edges = UIRectEdgeLeft;
    [self.view addGestureRecognizer:edgePanRecognizer];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(mainViewTapped:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)setupSlideMenuGestures:(UIView *)menuView
{
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(movelMenu:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];

    [menuView addGestureRecognizer:panRecognizer];
}

- (void)movelMenu:(UIGestureRecognizer *)sender
{
    [[[(UITapGestureRecognizer *)sender view] layer] removeAllAnimations];

    CGPoint translatedPoint = [(UIPanGestureRecognizer *)sender translationInView:self.containerView];
    CGPoint velocity = [(UIPanGestureRecognizer *)sender velocityInView:self.containerView];

    if (sender.state == UIGestureRecognizerStateEnded) {
        /*
        if (velocity.x > 0) {
            NSLog(@"gesture went right");
        } else {
            NSLog(@"gesture went left");
        }
         */

        if (!self.showMenu) {
            [self moveMenuToOriginalPosition];
        } else if (self.showingSlideMenu) {
            [self moveMenuRight];
        }
    }

    if (sender.state == UIGestureRecognizerStateChanged) {
        self.showMenu = sender.view.center.x > 0;

        [sender view].center = CGPointMake([sender view].center.x + translatedPoint.x, [sender view].center.y);
        [(UIPanGestureRecognizer *)sender setTranslation:CGPointZero inView:self.containerView];

        self.overlayView.alpha += self.overlayAlphaSpeed * translatedPoint.x;
        if (self.overlayView.alpha > kOverlayAlphaEnd) {
            self.overlayView.alpha = kOverlayAlphaEnd;
        }

        self.preVelocity = velocity;

        CGFloat newX =  MAX(-sender.view.frame.size.width, MIN(0, sender.view.frame.origin.x));

        sender.view.frame = CGRectMake(newX, sender.view.frame.origin.y,
                                       sender.view.frame.size.width, sender.view.frame.size.height);
    }

}

- (void)screenEdgeSwiped:(UIGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized) {
        if (!self.showingSlideMenu) {
            [self moveMenuRight];
        }
    }
}

- (void)mainViewTapped:(UIGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:self.view];
    if (self.showingSlideMenu) {
        if (CGRectContainsPoint(self.view.frame, location) &&
            !CGRectContainsPoint(self.slideMenuViewController.view.frame, location)) {
            [self moveMenuToOriginalPosition];
        }
    }
}

@end