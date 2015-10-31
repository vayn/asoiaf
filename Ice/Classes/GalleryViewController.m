//
//  GalleryViewController.m
//  ice
//
//  Created by Vicent Tsai on 15/10/31.
//  Copyright © 2015年 HeZhi Corp. All rights reserved.
//

#import "GalleryViewController.h"
#import "SDCycleScrollView.h"

@interface GalleryViewController () <SDCycleScrollViewDelegate>

@end

@implementation GalleryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSArray *images = @[[UIImage imageNamed:@"h1.jpg"],
                        [UIImage imageNamed:@"h2.jpg"],
                        [UIImage imageNamed:@"h3.jpg"],
                        [UIImage imageNamed:@"h4.jpg"]
                        ];
    CGFloat width = self.view.bounds.size.width;
    SDCycleScrollView *galleryView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, width, 180)
                                                                     imagesGroup:images];

    galleryView.infiniteLoop = YES;
    galleryView.delegate = self;
    galleryView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;

    self.view = galleryView;
}

#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    NSLog(@"---点击了第%ld张图片", index);
}

@end
