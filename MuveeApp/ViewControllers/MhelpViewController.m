//
//  MhelpViewController.m
//  MuveeApp
//
//  Created by iApp on 27/03/15.
//  Copyright (c) 2015 iApp. All rights reserved.
//

#import "MhelpViewController.h"

@interface MhelpViewController ()<UIScrollViewDelegate>
{
    UIScrollView *scrollVieW;
    NSMutableArray *arrayImages;
    UIPageControl *pageControl;
    UIImageView *imageViewScroll;
    CGRect rect;
    UIButton *btnSkip;
}

@end

@implementation MhelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
     rect = CGRectZero;
    rect.size.width = [UIScreen mainScreen].bounds.size.width;
    rect.size.height = [UIScreen mainScreen].bounds.size.height;
    
    
    arrayImages = [[NSMutableArray alloc]initWithCapacity:1];
    NSLog(@"%f",[UIScreen mainScreen].bounds.size.height);
    if([UIScreen mainScreen].bounds.size.height == 480)
    {
          arrayImages = [NSMutableArray arrayWithObjects:@"searchVideo4",@"searchResultUD4",@"searchResultLR4",@"managePlaylist4",@"kid4",@"lock_kid4",@"captcha4",@"contantFilter4", nil];
    }
    if([UIScreen mainScreen].bounds.size.height == 568)
    {
          arrayImages = [NSMutableArray arrayWithObjects:@"searchVideo5",@"searchResultUD5",@"searchResultLR5",@"managePlaylist5",@"kid5",@"lock_kid5",@"captcha5",@"contantFilter5", nil];
       // arrayImages = [NSMutableArray arrayWithObjects:@"searchVideo6",@"searchResultUD6",@"searchResultLR6",@"managePlaylist6",@"kid6",@"lock_kid6",@"captcha6",@"contantFilter6", nil];
    }
    if([UIScreen mainScreen].bounds.size.height == 667)
    {
          arrayImages = [NSMutableArray arrayWithObjects:@"searchVideo6",@"searchResultUD6",@"searchResultLR6",@"managePlaylist6",@"kid6",@"lock_kid6",@"captcha6",@"contantFilter6", nil];
    }
    if([UIScreen mainScreen].bounds.size.height == 736)
    {
          arrayImages = [NSMutableArray arrayWithObjects:@"searchVideo6+",@"searchResultUD6+",@"searchResultLR6+",@"managePlaylist6+",@"kid6+",@"lock_kid6+",@"captcha6+",@"contantFilter6+", nil];
    }
    if([UIScreen mainScreen].bounds.size.height == 768 ||[UIScreen mainScreen].bounds.size.height == 1024)
    {
          arrayImages = [NSMutableArray arrayWithObjects:@"searchVideo_ipad",@"searchResultUD_ipad",@"searchResultLR_ipad",@"managePlaylist_ipad",@"kid_ipad",@"lock_kid_ipad",@"captcha_ipad",@"contantFilter_ipad", nil];
    }
 
    
    scrollVieW = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
    scrollVieW.delegate = self;
    scrollVieW.contentSize = CGSizeMake([arrayImages count]*rect.size.width, rect.size.height);
    [self.view addSubview:scrollVieW];
    
  //  UILabel *lbl = [[UILabel alloc]init];
    
    btnSkip = [UIButton buttonWithType:UIButtonTypeCustom];
    btnSkip.frame = CGRectMake(rect.size.width-80, rect.size.height-60, 60, 50) ;
    if([UIScreen mainScreen].bounds.size.height == 768 || [UIScreen mainScreen].bounds.size.height == 1024)
    {
          btnSkip.frame = CGRectMake(rect.size.width-200, rect.size.height-80, 190, 140) ;
    }
    [btnSkip addTarget:self action:@selector(skipAction) forControlEvents:UIControlEventTouchUpInside];
    btnSkip.backgroundColor = [UIColor clearColor];
    [self.view addSubview:btnSkip];
    
    
    int x =0;
    pageControl = [[UIPageControl alloc]init];
    for (int i =0; i< [arrayImages count]; i++) {
        imageViewScroll = [[UIImageView alloc]initWithFrame:CGRectMake(x, 0, rect.size.width, rect.size.height)];
       
        imageViewScroll.image = [UIImage imageNamed:[arrayImages objectAtIndex:i]];
         [scrollVieW addSubview:imageViewScroll];
                x = x+rect.size.width;
    }
    
    pageControl.frame=CGRectMake((rect.size.width-150)/2, rect.size.height-40,150,50);
    pageControl.currentPage = 0;
    pageControl.numberOfPages = [arrayImages count];
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:196.0/255.0f green:32.0f/255.0f blue:55.0f/255.0f alpha:1];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.userInteractionEnabled = false;
    scrollVieW.bounces = NO;
    [self.view addSubview:pageControl];
  //  [pageControl bringSubviewToFront:self.view];
    
    scrollVieW.pagingEnabled =YES;
    
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Update the page when more than 50% of the previous/next page is visible
    
    CGFloat pageWidth = (rect.size.width);
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    NSLog(@"page%d",page);
    
}

-(void)skipAction
{
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
