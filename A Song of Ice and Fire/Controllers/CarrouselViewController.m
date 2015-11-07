//
//  GalleryViewController.m
//  ice
//
//  Created by Vicent Tsai on 15/10/31.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "CarrouselViewController.h"
#import "SDCycleScrollView.h"

@interface CarrouselViewController () <SDCycleScrollViewDelegate>

@property (nonatomic, strong) NSArray *titles;

@end

@implementation CarrouselViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSArray *images = @[[UIImage imageNamed:@"h1.jpg"],
                        [UIImage imageNamed:@"h2.jpg"],
                        [UIImage imageNamed:@"h3.jpg"],
                        [UIImage imageNamed:@"h4.jpg"],
                        [UIImage imageNamed:@"h5.jpg"]
                        ];

    _titles = @[@"权力的游戏",
                @"列王的纷争",
                @"冰雨的风暴",
                @"群鸦的盛宴",
                @"魔龙的狂舞"
                ];

    CGFloat width = self.view.bounds.size.width;
    SDCycleScrollView *galleryView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, width, 180)
                                                                     imagesGroup:images];

    galleryView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
    galleryView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    galleryView.delegate = self;
    galleryView.infiniteLoop = YES;
    galleryView.titlesGroup = self.titles;

    self.view = galleryView;
}

#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSString *title = self.titles[index];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:title
                                                                      preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];

    [alertController addAction:defaultAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
