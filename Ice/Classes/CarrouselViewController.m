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

@end

@implementation CarrouselViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSArray *images = @[[UIImage imageNamed:@"h1.jpg"],
                        [UIImage imageNamed:@"h2.jpg"],
                        [UIImage imageNamed:@"h3.jpg"],
                        [UIImage imageNamed:@"h4.jpg"]
                        ];

    NSArray *titles = @[@"权力的游戏",
                        @"列王的纷争",
                        @"冰雨的风暴",
                        @"群鸦的盛宴"
                        ];

    CGFloat width = self.view.bounds.size.width;
    SDCycleScrollView *galleryView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, width, 180)
                                                                     imagesGroup:images];

    galleryView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
    galleryView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    galleryView.delegate = self;
    galleryView.infiniteLoop = YES;
    galleryView.titlesGroup = titles;

    self.view = galleryView;
}

#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"---点击了第%ld张图片", index);
}

@end
