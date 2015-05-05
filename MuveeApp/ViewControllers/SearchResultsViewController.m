//
//  SearchResultsViewController.m
//  Muvee
//
//  Created by iApp on 12/1/14.
//  Copyright (c) 2014 iAppTechnologies. All rights reserved.
//

#import "SearchResultsViewController.h"

#import "JSONModelLib.h"
#import "VideoModel.h"

#import "WebVideoViewController.h"

#import "SDWebImageManager.h"
#import "SDWebImageDownloader.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "ActivityView.h"
#import "MLoginViewController.h"
#import "VSWebHandler.h"
#import "MSPullToRefreshController.h"
#import "MRootViewController.h"
#import "MCaptchaViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface SearchResultsViewController ()<SDWebImageManagerDelegate,UIScrollViewDelegate,UIScrollViewAccessibilityDelegate>
{
    NSInteger numberOfThumbsInARow;
    CGSize screenSize ;
    
    CGSize screenSizeBeforeGoingToPlayerView;
    BOOL isSet;
    BOOL isComingFromMoviePlayer;
    
    CGFloat x,y,width,height,padding ;
    int videoStartNumber;
    ActivityView *activity;
    UIImageView *thumbnail;
    NSDictionary *json;
    int leftPressed,indexOfArray;
    UILabel *lblTime;
    ALAsset *Asset1;
    NSString *lastSearchTitle;
    NSInteger currentIndex;
    NSTimer *timerStart;
    UIAlertView *alertTimeOut;
    
    NSMutableArray *arraySearchedData,*arrayTableData,*arrayLocalVideo,*arrayReverse,*tempArrayManageListSRVC;
    NSString *nextPageToken; // Will retrieve next page videos. API v3 API gives max 50 videos at once.
    UIView *footerVieww;
    NSInteger numberOfItemsInTable;
    IBOutlet UIButton *btnTopArrow;
    
    IBOutlet UILabel *lblTitle;
    NSString *strLocalVideoCall;
    ALAssetsLibrary *library;
     CGFloat myOrigin;
    BOOL canCheckSuperView;
    BOOL canShowNextPage;
    BOOL canShowLocalVideos;
    BOOL canCheckLastScrollOffset; // for hide activity on last and first object
    IBOutlet UIScrollView *scrollViewSearch;
    UILabel *label;
}
@end

@implementation SearchResultsViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(412, 284, 200.0, 100.0)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:14.0];
    label.text = @"No results";
    label.textAlignment = NSTextAlignmentCenter;
    //label.center = self.view.center;
    [self.view addSubview:label];
    [label setHidden: YES];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishPlayback:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStart:) name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
    
    self.navigationController.navigationBarHidden = YES;
    
    //[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    
//    [self rotateController:self degrees:0];
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
//    //set it according to 3.5 and 4.0 inch screen in landscape mode
//    [self.view setBounds:CGRectMake(0, 0,768 , 1024)];
    
    library = [[ALAssetsLibrary alloc] init];
    lblTitle.text =[self.StrSearch uppercaseString];
    _ptr = [[CustomPullToRefresh alloc] initWithScrollView:tableViewSearch delegate:self];
    _ptrChild = [[CustomPullToRefresh alloc] initWithScrollView:tableViewChild delegate:self];
    //UIScrollView
    scrollViewSearch.clipsToBounds = YES;
    scrollViewSearch.pagingEnabled =YES;
    scrollViewSearch.scrollEnabled = YES;
    scrollViewSearch.bounces = NO;

    
  //edit by tijender
    screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        screenSize = CGSizeMake(1024, 768);
    }

   
//    if([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPad)
//    {
//        
    
        scrollViewSearch.frame = CGRectMake(0.0, 60.0, screenSize.width, screenSize.height-60);
        
    _arrayManageListSRVC = [AppDelegate sharedDelegate].playlist;
    tempArrayManageListSRVC = _arrayManageListSRVC;
    [tempArrayManageListSRVC removeObject:@"LOCAL VIDEOS"];
    
    if([[[AppDelegate sharedDelegate] settings] localVideos] == YES)
    {
        [tempArrayManageListSRVC addObject:@"LOCAL VIDEOS"];
        
    }
//        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
//            self.view.transform = CGAffineTransformIdentity;
//            self.view.transform = CGAffineTransformMakeRotation(degreesToRadian(90));
//        }
        
    for(int i =0; i<[tempArrayManageListSRVC count]; i++)
    {
        myOrigin = i * screenSize.width;
        UITableView *table;
        table = [[UITableView alloc]initWithFrame:CGRectMake(myOrigin, 0, screenSize.width, screenSize.height-40)];
             if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
         table = [[UITableView alloc]initWithFrame:CGRectMake(myOrigin, 0, screenSize.width, screenSize.height-60)];
        }
        
        table.delegate = self;
        table.dataSource = self;
        table.bounces = NO;
        table.tag = i+1;
        
        NSLog(@"%ld",(long)table.tag);
        
        [self setupTableViewFooterForTableView:table];
        [scrollViewSearch addSubview:table];
        
        
          //  indexOfArray = [tempArrayManageListSRVC indexOfObject:self.StrSearch];
        NSString *str = [tempArrayManageListSRVC objectAtIndex:i];
        if([str caseInsensitiveCompare:self.StrSearch] == NSOrderedSame)
        {
            
            indexOfArray = i;
            NSLog(@"indexOfArray = %d",indexOfArray);
            NSLog(@"%lu",(unsigned long)[[AppDelegate sharedDelegate].playlist count]);
            
            [scrollViewSearch setContentOffset:CGPointMake(screenSize.width*indexOfArray, screenSize.height-60) animated:YES];
        }
    }
     scrollViewSearch.contentSize = CGSizeMake([tempArrayManageListSRVC count]*screenSize.width, screenSize.height-40);
    //[scrollViewSearch setContentOffset:CGPointMake([[AppDelegate sharedDelegate].playlist count]*screenSize.width, screenSize.height) animated:YES];
      if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        scrollViewSearch.contentSize = CGSizeMake([tempArrayManageListSRVC count]*screenSize.width, screenSize.height-60);
    }
    
    //page control
//    pageControl = [[UIPageControl alloc] init];
//    pageControl.frame = CGRectMake(110,400,100,30);
//    pageControl.numberOfPages = [[AppDelegate sharedDelegate].playlist count];
//    pageControl.currentPage = indexOfArray;
//    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
//    
//    // [self.view addSubview:pageControl];
//    pageControl.backgroundColor = [UIColor redColor];
 //   }
    
    
    
    canCheckSuperView = YES;
    canShowLocalVideos = YES;
    
    //orientation Notification
//    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleOrientationChangeNotificationSearchresultView) name: UIApplicationDidChangeStatusBarOrientationNotification object: nil];
    
    arrayReverse =[NSMutableArray arrayWithCapacity:1];
    arrayLocalVideo =[NSMutableArray arrayWithCapacity:1];
    leftPressed = 0;
     _arrayManageListSRVC = [AppDelegate sharedDelegate].playlist;
    
    [self reset];
    
    NSDictionary *videosInfo = [[MDatabase sharedDatabase] videosInfoForKey:self.StrSearch];
    NSLog(@"%@",videosInfo);
    
    arraySearchedData = [[videosInfo objectForKey:@"videos"] mutableCopy];
    NSLog(@"%@",arraySearchedData);
    if (arraySearchedData == nil || [arraySearchedData count] == 0)
    {
        if ([[DataStorage sharedStorage] isInternetAvailable]) {
            [self performSelector:@selector(pageNumberCall) withObject:nil afterDelay:0.5];
        }
        else {
            SHOW_NO_INTERNET_ALERT(nil);
        }
    }
    else {
        nextPageToken = [videosInfo objectForKey:@"nextPageToken"];
        if (nextPageToken) {
            canShowNextPage = YES;
        }
        arrayTableData = [arraySearchedData mutableCopy];
        
        
        NSInteger x_offset = (scrollViewSearch.contentOffset.x);
        NSInteger width_table = scrollViewSearch.frame.size.width;
        
        NSLog(@"width_tabletttt%f",scrollViewSearch.contentOffset.x);
        NSLog(@"width_tablerrrr%f",scrollViewSearch.frame.size.width);
        
        
        NSInteger index = (x_offset/width_table) + 1;
        
        UITableView *tableView = nil;
        for (id obj in scrollViewSearch.subviews)
        {
            if([obj isKindOfClass:[UITableView class]] && [obj tag] == index)
                tableView = (UITableView *)obj;
            break;
        }
        if(tableView)
        {
            tableViewSearch = tableView;
            [tableViewSearch reloadData];
        }

//        [tableViewSearch reloadData];
//        [tableViewChild reloadData];
    }
    
    
   // screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

int indexCount;
-(void)startReloading {
    
    UITableView *tableView = nil;
    for (id obj in scrollViewSearch.subviews) {
        if ([obj isKindOfClass:[UITableView class]] && [obj tag] == indexCount) {
            tableView = (UITableView *)obj;
            break;
        }
    }
    NSDictionary *videosInfo = [[MDatabase sharedDatabase] videosInfoForKey:tempArrayManageListSRVC[indexCount-1]];
    if (videosInfo!=nil) {
        arrayTableData = [[videosInfo objectForKey:@"videos"] mutableCopy];
    }
    
       [self reloadTable:tableView withCompletionBlock:^{
        
        indexCount = indexCount + 1;
        if ((indexCount-1) < [tempArrayManageListSRVC count]) {
            [self startReloading];
        }
        else {
            [self hideActivity];
        }
    }];
}

-(void)reloadTable:(UITableView *)table withCompletionBlock:(void (^)(void))completion {
    NSInteger range = [tempArrayManageListSRVC indexOfObject:self.StrSearch];
    NSLog(@"range***%ld",range);
    NSLog(@"title***%@",self.StrSearch);
    //range=range+1;
  //  float offsetx=range*screenSize.width;
 //   float offsety=-0;
  //  scrollViewSearch.contentOffset=CGPointMake(offsetx, offsety);
    // [self reloadTable];
    [table reloadData];
    completion();
}


-(void)viewDidAppear:(BOOL)animated
{
//      screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *str = [defaults valueForKey:@"BecomeActivityCall"];
    [defaults synchronize];
    
    if([str isEqualToString:@"ActivityRunning"])
    {
        [[AppDelegate sharedDelegate] hideActivity];
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:@"ActivityNil" forKey:@"BecomeActivityCall"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    lastSearchTitle = self.StrSearch;
    lblTitle.text =[self.StrSearch uppercaseString];
     [AppDelegate sharedDelegate].isPlayer = @"Stop";
    
    
    if (!isComingFromMoviePlayer) {
        
        
      //  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                
                
                // Set all table frame again here
                // screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                    screenSize = CGSizeMake(1024, 768);
                }
                scrollViewSearch.frame = CGRectMake(0.0, 40.0, screenSize.width, screenSize.height-40);
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                scrollViewSearch.frame = CGRectMake(0.0, 60.0, screenSize.width, screenSize.height-60);
                }
                for(int i =0; i<[tempArrayManageListSRVC count]; i++)
                {
                    myOrigin = i * screenSize.width;
                    UITableView *table = nil;
                    for (id obj in scrollViewSearch.subviews) {
                        if ([obj isKindOfClass:[UITableView class]] && [obj tag] == i+1) {
                            table = (UITableView *)obj;
                            break;
                        }
                    }
                    if (table) {
                         table.frame = CGRectMake(myOrigin, 0, screenSize.width, screenSize.height-40);
                        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                        table.frame = CGRectMake(myOrigin, 0, screenSize.width, screenSize.height-60);
                        }
                        [[table viewWithTag:1000] removeFromSuperview];
                        [self setupTableViewFooterForTableView:table];
                    }
                    
                }
                scrollViewSearch.contentSize = CGSizeMake([tempArrayManageListSRVC count]*screenSize.width, screenSize.height-40);
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                     scrollViewSearch.contentSize = CGSizeMake([tempArrayManageListSRVC count]*screenSize.width, screenSize.height-60);
                }
                
                
                
            });
            
        //}
        
    }

    
}

-(void)viewWillAppear:(BOOL)animated
{
      [super viewWillAppear:YES];
    
    screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        screenSize = CGSizeMake(1024, 768);
    }

//    [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: UIInterfaceOrientationLandscapeRight] forKey:@"orientation"];
//    //|UIInterfaceOrientationLandscapeLeft add up
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
   

    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideRatingAlert) name:UIApplicationDidEnterBackgroundNotification object:nil];

    
    lastSearchTitle = self.StrSearch;

//    [AppDelegate sharedDelegate].lastSearchTitle = lblTitle.text;
//    NSLog(@"lastSearchTitle=%@",[AppDelegate sharedDelegate].lastSearchTitleStr);
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:lastSearchTitle forKey:@"lastSearchTitleStr"];
     NSString *lastSearchedKey = [defaults valueForKey:@"lastSearchTitleStr"];
    NSLog(@"%@",lastSearchedKey);
        [defaults synchronize];
    NSLog(@"willappear");

}
#pragma mark - Hide Status Bar
-(BOOL)prefersStatusBarHidden
{
    return  YES;
}

-(void)hideRatingAlert
{
    [alertTimeOut dismissWithClickedButtonIndex:0 animated:YES];
    alertTimeOut = nil;
}
#pragma mark-UITableViewDaraSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
         numberOfThumbsInARow = 2;
        
        // iPhone
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            
            // Portrait Mode
            numberOfThumbsInARow = 4;
        }
            NSInteger totalVideo = [arrayTableData count];
        if([strLocalVideoCall isEqualToString:@"YES"])
            {
                totalVideo = [arrayLocalVideo count];
            }
        if (totalVideo % numberOfThumbsInARow == 0) {
            return totalVideo/numberOfThumbsInARow;
        }
        else {
            return (totalVideo/numberOfThumbsInARow) + 1;
        }
    }
    else {
        
        // iPad
        numberOfThumbsInARow = 4;
        
        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
            
            // Portrait Mode
            numberOfThumbsInARow = 5;
        }
        
        NSInteger totalVideo = [arrayTableData count];
        if([strLocalVideoCall isEqualToString:@"YES"])
        {
            totalVideo = [arrayLocalVideo count];
        }

        if (totalVideo % numberOfThumbsInARow == 0) {
            return totalVideo/numberOfThumbsInARow;
        }
        else {
            return (totalVideo/numberOfThumbsInARow) + 1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  // screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    static NSString *CellIdentifier = @"Cell1";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    for (id obj in cell.contentView.subviews) {
        [obj removeFromSuperview];
    }

   // CGRect rectTopArrow;
//    if([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone)
//    {
//        rectTopArrow = CGRectMake((screenSize.width-40)/2, -4, 40, 20) ;
//    }
//    else
//    {
//        rectTopArrow = CGRectMake((screenSize.width-80)/2, 0, 80, 40) ;
//    }
//    btnTopArrow.frame = rectTopArrow;
//    [btnTopArrow setHidden:NO];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
            [self setIphoneImageSize];
            
            if([strLocalVideoCall isEqualToString:@"YES"])
            {
                {
                    NSInteger tag = indexPath.row * numberOfThumbsInARow;
                    
                    for (int i=0; i<numberOfThumbsInARow; i++) {
                        
                        
                        [self ThumbnailAdd];
                        thumbnail.tag = tag;
                        [cell.contentView addSubview:thumbnail];

                        
                        
                        // Play icon
                        [self PlayIconAdd];
                        
                        if (tag >= [arrayLocalVideo count]) {
                            thumbnail.hidden = TRUE;
                        }
                        else {
                            
                            ALAsset *videoInfo = [arrayLocalVideo objectAtIndex:tag];
                            
                            @try
                            {
                                
                                thumbnail.image = [UIImage imageWithCGImage:videoInfo.thumbnail];
                                
                            }
                            @catch (NSException *exception) {
                                NSLog(@"Error: %@", exception.description);
                            }
                            @finally {
                                
                            }
                        }
                
                        x = x + width + padding;
                        tag ++;
                    }
                }
            }
            else
            {
        
            NSInteger tag = indexPath.row * numberOfThumbsInARow;
                for (int i=0; i<numberOfThumbsInARow; i++) {
            
                    [self ThumbnailAdd];
                    thumbnail.tag = tag;
                    [cell.contentView addSubview:thumbnail];

            
            
            // Duration Label
            UILabel *duration = [[UILabel alloc] initWithFrame:CGRectMake(0.0, thumbnail.frame.size.height - (15.0 + 5.0), 0.0, 15.0)];
            duration.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
            duration.font = [UIFont systemFontOfSize:12.0];
            duration.textColor = [UIColor whiteColor];
            duration.tag = 100;
            duration.textAlignment = NSTextAlignmentCenter;
           // [thumbnail addSubview:duration];
            
            NSString * hello = @"2:20:45";
            duration.text = hello;
            
            // Play icon
            [self PlayIconAdd];
            
            
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:duration.font, NSFontAttributeName, nil];
            CGFloat width1 = [[[NSAttributedString alloc] initWithString:duration.text attributes:attributes] size].width;
            CGRect dRect = duration.frame;
            dRect.size.width = width1 + 6.0;
            dRect.origin.x = thumbnail.frame.size.width - (dRect.size.width + 5.0);
            duration.frame = dRect;
            
            
            if (tag >= [arrayTableData count]) {
                thumbnail.hidden = TRUE;
            }
            else {
                
                @try {
                    SDWebImageManager *manager      = [SDWebImageManager sharedManager];
                  
                    NSDictionary *videoInfo = [arrayTableData objectAtIndex:tag];
                    
                    NSString *thumbPath = [videoInfo objectForKey:videoThumbnail];
                    [thumbnail setImageWithURL:[NSURL URLWithString:thumbPath]];
                    
                    [manager downloadWithURL:[NSURL URLWithString:thumbPath] options:0 progress:^(NSUInteger receivedSize, long long expectedSize) {
                        
                    }
                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
                    {
                                       if (image) {
                                                                                 }
                                   }];
                }
                
                @catch (NSException *exception) {
                    NSLog(@"Error: %@", exception.description);
                }
                @finally {
                    
                }
            }
        
            x = x + width + padding;
            tag ++;
        }
            }
    }
    
    else
    {
        [self setIpadImageSize];
        
        if([strLocalVideoCall isEqualToString:@"YES"])
        {
            {
                    NSInteger tag = indexPath.row * numberOfThumbsInARow;
                    
                    for (int i=0; i<numberOfThumbsInARow; i++) {
                        
                        [self ThumbnailAdd];
                        thumbnail.tag = tag;
                        [cell.contentView addSubview:thumbnail];

                        [self PlayIconAdd];
                        
                        if (tag >= [arrayLocalVideo count]) {
                            thumbnail.hidden = TRUE;
                        }
                        else {
                            
                            ALAsset *videoInfo = [arrayLocalVideo objectAtIndex:tag];
                            
                            @try
                            {
                                
                                thumbnail.image = [UIImage imageWithCGImage:videoInfo.thumbnail];
                                
                            }
                            @catch (NSException *exception) {
                                NSLog(@"Error: %@", exception.description);
                            }
                            @finally {
                                
                            }
                        }
                        x = x + width + padding;
                        tag ++;
                    }
            }
        }
        else
        {
            NSInteger tag = indexPath.row * numberOfThumbsInARow;
            for (int i=0; i<numberOfThumbsInARow; i++) {
                
                [self ThumbnailAdd];
                thumbnail.tag = tag;
                [cell.contentView addSubview:thumbnail];

                
                // Duration Label
                UILabel *duration = [[UILabel alloc] initWithFrame:CGRectMake(0.0, thumbnail.frame.size.height - (15.0 + 5.0), 0.0, 15.0)];
                duration.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
                duration.font = [UIFont systemFontOfSize:12.0];
                duration.textColor = [UIColor whiteColor];
                duration.tag = 100;
                duration.textAlignment = NSTextAlignmentCenter;
                // [thumbnail addSubview:duration];
                
                NSString * hello = @"2:20:45";
                duration.text = hello;
                
                
                // Play icon
                [self PlayIconAdd];
                
                
                
                NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:duration.font, NSFontAttributeName, nil];
                CGFloat width1 = [[[NSAttributedString alloc] initWithString:duration.text attributes:attributes] size].width;
                CGRect dRect = duration.frame;
                dRect.size.width = width1 + 6.0;
                dRect.origin.x = thumbnail.frame.size.width - (dRect.size.width + 5.0);
                duration.frame = dRect;
                
                
                if (tag >= [arrayTableData count]) {
                    thumbnail.hidden = TRUE;
                }
                else {
                    
                    @try {
                        SDWebImageManager *manager      = [SDWebImageManager sharedManager];
                        
                        NSDictionary *videoInfo = [arrayTableData objectAtIndex:tag];
                        
                        NSString *thumbPath = [videoInfo objectForKey:videoThumbnail];
                        [thumbnail setImageWithURL:[NSURL URLWithString:thumbPath]];
                        
                        [manager downloadWithURL:[NSURL URLWithString:thumbPath] options:0 progress:^(NSUInteger receivedSize, long long expectedSize) {
                            
                        }
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished)
                         {
                             if (image) {
                             }
                         }];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"Error: %@", exception.description);
                    }
                    @finally {
                        
                    }
                }
            
                x = x + width + padding;
                tag ++;
            }
        }
    }
       return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        [self setIphoneImageSize];
        return height + padding;
    }
    else
    {
        [self setIpadImageSize];
        
        return height + padding;
    }
    
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

#pragma mark-Thumbnail
-(void)ThumbnailAdd
{
    thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    thumbnail.userInteractionEnabled = TRUE;
    [thumbnail setBackgroundColor:[UIColor blackColor]];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
    [thumbnail addGestureRecognizer:tapGesture];
}

#pragma mark Play icon
-(void)PlayIconAdd
{
    UIImageView *iconPlay = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 39, 29)];
    iconPlay.image = [UIImage imageNamed:@"play_icon"];
    CGRect iRect = iconPlay.frame;
    iRect.origin.x = (thumbnail.frame.size.width - iRect.size.width)/2.0;
    iRect.origin.y = (thumbnail.frame.size.height - iRect.size.height)/2.0;
    iconPlay.frame = iRect;
    [thumbnail addSubview:iconPlay];
}

#pragma mark UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView .tag ==11)
     {
         [self.navigationController popViewControllerAnimated:YES];
    }
    else if (alertView.tag == 65)
    {
        NSLog(@"%f",screenSize.width);
        NSLog(@"%f",screenSize.height-60);
        NSLog(@"%f",scrollViewSearch.contentOffset.x);
        NSLog(@"%f",([tempArrayManageListSRVC count]-1)*screenSize.width);
        NSLog(@"%f",([tempArrayManageListSRVC count]-2)*screenSize.width);
        [scrollViewSearch setContentOffset:CGPointMake(([tempArrayManageListSRVC count]-2)*screenSize.width, screenSize.height-40) animated:NO];
        if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
        [scrollViewSearch setContentOffset:CGPointMake(([tempArrayManageListSRVC count]-2)*screenSize.width, screenSize.height-60) animated:NO];
        }
        [self btnLeftTapped];
    }
   else if(alertTimeOut.tag == 123)
    {
        UIApplication *app = [UIApplication sharedApplication];
        [app performSelector:@selector(suspend)];
        
        //wait 2 seconds while app is going background
        [NSThread sleepForTimeInterval:2.0];
        
        //exit app when app is in background
        exit(0);    }
    
}


#pragma mark - CustomPullToRefresh Delegate Methods
- (void)customPullToRefreshShouldRefresh:(CustomPullToRefresh *)ptr
{
    if([strLocalVideoCall isEqualToString:@"YES"])
    {
        [NSThread sleepForTimeInterval:1];
        [self performSelectorOnMainThread:@selector(endSearch) withObject:nil waitUntilDone:NO];
    }
    else
    {
        [self performSelectorInBackground:@selector(findNextVideo) withObject:nil];
    }
}

- (void) endSearch {

    [_ptr endRefresh];
    [_ptrChild endRefresh];
    [tableViewSearch reloadData];
    [tableViewChild reloadData];
}

-(void)findNextVideo
{
    if ([arrayTableData count] <= 50 && [arrayTableData count] > 20) {
        if ([[DataStorage sharedStorage] isInternetAvailable]) {
            
            [self doLoadVideos];
        }
        else{
            SHOW_NO_INTERNET_ALERT(nil);
            [NSThread sleepForTimeInterval:1];
            [self performSelectorOnMainThread:@selector(endSearch) withObject:nil waitUntilDone:NO];
        }
    }
    else {
        
        if ([arrayTableData count] < 100) {
            @try {
                [self reloadTable];
            }
            @catch (NSException *exception) {
                
            }

        }
        else {
            [NSThread sleepForTimeInterval:1];
            [self performSelectorOnMainThread:@selector(endSearch) withObject:nil waitUntilDone:NO];
            
            
            NSInteger x_offset = (scrollViewSearch.contentOffset.x);
            NSInteger width_table = scrollViewSearch.frame.size.width;
            NSInteger index = (x_offset/width_table) + 1;
            
            NSLog(@"y5t%f",scrollViewSearch.contentOffset.x);
            NSLog(@"45ty%f",scrollViewSearch.frame.size.width);
            
            NSLog(@"%ld", (long)index);
            
            
            UITableView *tableView = nil;
            for (id obj in scrollViewSearch.subviews) {
                if ([obj isKindOfClass:[UITableView class]] && [obj tag] == index) {
                    tableView = (UITableView *)obj;
                    break;
                }
            }
            
            if (tableView) {
                
                UIView *footerView = [tableView viewWithTag:1000];
                UIActivityIndicatorView *activityIndicator = [self activityForFooter:footerView];
                if (activityIndicator) {
                    [activityIndicator stopAnimating];
                    
                }
            
                [tableView setContentOffset:CGPointMake(0.0, tableView.contentOffset.y - 50.0) animated:YES];
                
            }
            
        }    }
    
    
}

#pragma mark-Gesture
-(void)imageSwipeLeft:(UIGestureRecognizer *) sender
{
    
    [self btnLeftTapped];
}
-(void)imageSwipeRight:(UIGestureRecognizer *) gesture
{
    
    NSLog(@"%@",_arrayManageListSRVC);
    
    for (int i = 0; i<[_arrayManageListSRVC count]; i++)
    {
        NSString *str = [_arrayManageListSRVC objectAtIndex:i];
        if(i == [_arrayManageListSRVC count]-1)
        {
            NSLog(@"not");
            
            if([[AppDelegate sharedDelegate]settings] .localVideos  == YES)
            {
                if(canShowLocalVideos)
                {
          //          [self AnimationRightView];
                }
                [self localVideo];
                lblTitle.text = @"LOCAL VIDEOS";
                strLocalVideoCall = @"YES";
                canShowLocalVideos=NO;
            }
            
        }
        else if([str caseInsensitiveCompare:self.StrSearch] == NSOrderedSame)
        {
            [self reset];
         //   [self AnimationRightView];
            
            NSLog(@"%@",_arrayManageListSRVC[i]);
            
            self.StrSearch = _arrayManageListSRVC[i+1];
            lblTitle.text = [self.StrSearch uppercaseString];
            
            NSDictionary *videosInfo = [[MDatabase sharedDatabase] videosInfoForKey:self.StrSearch];
            
            arraySearchedData = [[videosInfo objectForKey:@"videos"] mutableCopy];
            if (arraySearchedData == nil || [arraySearchedData count] == 0)
            {
                [self showActivity];
                [self performSelector:@selector(doLoadVideos) withObject:nil afterDelay:0.5];
            }
            else {
                nextPageToken = [videosInfo objectForKey:@"nextPageToken"];
                if (nextPageToken) {
                    canShowNextPage = YES;
                }
                arrayTableData = [arraySearchedData mutableCopy];
                [tableViewSearch reloadData];
                [tableViewChild reloadData];
            }
            
            
            i=[_arrayManageListSRVC count];
            [tableViewSearch reloadData];
            [tableViewChild reloadData];
            
        }
    }
    
}

-(void)imageTapped:(UIGestureRecognizer *)recognizer {
    
    screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        screenSize = CGSizeMake(1024, 768);
    }
    
    if([strLocalVideoCall isEqualToString:@"YES"])
    {
        self.StrSearch = @"LOCAL VIDEOS";
        lblTitle.text = @"LOCAL VIDEOS";
        ALAsset *videoAsset = [arrayLocalVideo objectAtIndex:recognizer.view.tag];
        NSURL *videoURL = [[videoAsset defaultRepresentation] url];
        
        playerController = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
        playerController.controlStyle = MPMovieControlStyleFullscreen;

        [self.view addSubview:playerController.view];
        playerController.fullscreen = YES;
        [playerController prepareToPlay];
        [playerController play];
        
    }
    else
    {
        if ([[DataStorage sharedStorage] isInternetAvailable])
            {
        [self showActivityVideoPrepare];
        
        NSLog(@"%ld", (long)recognizer.view.tag);
        
        NSString *videoid = [[arrayTableData objectAtIndex:recognizer.view.tag] objectForKey:videoId];
        lbYoutubePlayerVC = [[LBYouTubePlayerViewController alloc]initWithYouTubeURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",videoid]] quality:LBYouTubeVideoQualityMedium];
        lbYoutubePlayerVC.delegate=self;

            }
        else
        {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"You need an internet connection to play this video." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    
    }
    
   }

-(void)playbackFinished:(NSNotification *)notification
{
    [playerController setFullscreen:NO animated:YES];
}

-(void)didFinishPlayback:(NSNotification *)notification
{
    NSLog(@"%@", notification.name);
    [playerController setFullscreen:NO animated:YES];
    [playerController.view removeFromSuperview];
    [playerController stop];
    playerController = nil;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && !isSet) {
        
        isSet = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            [AppDelegate sharedDelegate].isPlayerPlaying = NO;
            
            // Set all table frame again here
            // screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
            if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
            {
            screenSizeBeforeGoingToPlayerView.height = 768;
            screenSizeBeforeGoingToPlayerView.width = 1024;
            }
            
            scrollViewSearch.frame = CGRectMake(0.0, 60.0, screenSizeBeforeGoingToPlayerView.width, screenSizeBeforeGoingToPlayerView.height-60);
            for(int i =0; i<[tempArrayManageListSRVC count]; i++)
            {
                myOrigin = i * screenSizeBeforeGoingToPlayerView.width;
                UITableView *table = nil;
                for (id obj in scrollViewSearch.subviews) {
                    if ([obj isKindOfClass:[UITableView class]] && [obj tag] == i+1) {
                        table = (UITableView *)obj;
                        break;
                    }
                }
                if (table) {
                    table.frame = CGRectMake(myOrigin, 0, screenSizeBeforeGoingToPlayerView.width, screenSizeBeforeGoingToPlayerView.height-60);
                }
                
                [[table viewWithTag:1000] removeFromSuperview];
                [self setupTableViewFooterForTableView:table];
            }
            
            scrollViewSearch.contentSize = CGSizeMake([tempArrayManageListSRVC count]*screenSizeBeforeGoingToPlayerView.width, screenSizeBeforeGoingToPlayerView.height-60);
            
            
        });
        
    }

}

-(void)playbackStart:(NSNotification *)notification {
   // NSLog(@"%d", [[UIDevice currentDevice] orientation]);
    
    isComingFromMoviePlayer = YES;
    NSLog(@"playbackStart%f",screenSize.width);
    NSLog(@"playbackStart%f",screenSize.height);

    screenSizeBeforeGoingToPlayerView = CGSizeMake(screenSize.width, screenSize.height);
    [AppDelegate sharedDelegate].isPlayerPlaying = YES;
    isSet = NO;
}

#pragma mark - LBYouTubePlayerControllerDelegate methods

-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL
{
    [self hideActivity];

    playerController = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    [AppDelegate sharedDelegate].isPlayer = @"Start";
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackComplete:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayerController];
    playerController.controlStyle = MPMovieControlStyleFullscreen;
   
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishPlayback:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
    
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    NSError *error = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory:AVAudioSessionCategoryPlayback
                    error:&error];
    if (!success) {
        // Handle error here, as appropriate
    }

    
    
    [self.view addSubview:playerController.view];
    playerController.fullscreen = YES;
    [playerController prepareToPlay];
    [playerController play];
   // [self performSelector:@selector(PlayerStop) withObject:nil afterDelay:1];
  timerStart = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(PlayerRunning) userInfo:nil repeats:YES];
    
 
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:timerStart forMode: NSDefaultRunLoopMode];
}

-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller failedExtractingYouTubeURLWithError:(NSError *)error
{
    [self hideActivity];
    NSLog(@"URL extracting failed with error: %@", error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark-Orientation Notification
/*
-(void)handleOrientationChangeNotificationSearchresultView
{
    screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    
    tableViewSearch.frame = CGRectMake(0, 60, screenSize.width, screenSize.height-60);
    tableViewChild.frame = CGRectMake(0, 60, screenSize.width, screenSize.height-60);
    
    
     [tableViewSearch reloadData];
    [tableViewChild reloadData];
    
   // CGRect rectTopArrow = btnTopArrow.frame;
    activity.center = self.view.center;
    
//    if([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone)
//    {
//        rectTopArrow = CGRectMake((screenSize.width-40)/2, -4, 40, 20) ;
//    }
//    else
//    {
//        rectTopArrow = CGRectMake((screenSize.width-80)/2, 0, 80, 40) ;
//    }
//    btnTopArrow.frame = rectTopArrow;
   
}
*/
-(void)btnLeftTapped
{
    
    for (long i = [_arrayManageListSRVC count]-1; i>=0; i--)
    {
        NSString *str=[_arrayManageListSRVC objectAtIndex:i];
        NSLog(@"%@",_arrayManageListSRVC[i]);
        NSLog(@"%@",str);
        NSLog(@"%@",self.StrSearch);
       
        if(i == 0)
        {
            NSLog(@"not");
            if([strLocalVideoCall isEqualToString:@"YES"])
            {
                [self reset];

                NSLog(@"%@",_arrayManageListSRVC[i]);
               
                NSString *str;
                for (int i = [_arrayManageListSRVC count]-1; i>=0; i--)
                {
                    str=[_arrayManageListSRVC objectAtIndex:i];
                    [arrayReverse addObject:str];
                }
                NSLog(@"%@",self.StrSearch);
                self.StrSearch = arrayReverse[i];
                lblTitle.text = [self.StrSearch uppercaseString];
                
                NSDictionary *videosInfo = [[MDatabase sharedDatabase] videosInfoForKey:self.StrSearch];
                
                arraySearchedData = [[videosInfo objectForKey:@"videos"] mutableCopy];
                if (arraySearchedData == nil || [arraySearchedData count] == 0)
                {
                    [self showActivity];
                    [self performSelector:@selector(doLoadVideos) withObject:nil afterDelay:0.5];
                }
                else {
                    nextPageToken = [videosInfo objectForKey:@"nextPageToken"];
                    if (nextPageToken) {
                        canShowNextPage = YES;
                    }
                    strLocalVideoCall =@"NO";
                    arrayTableData = [arraySearchedData mutableCopy];
                    [tableViewSearch reloadData];
                    [tableViewChild reloadData];
                }
                i=0;
            }
        }
        else if([str caseInsensitiveCompare:self.StrSearch] == NSOrderedSame)
        {
            [self reset];

          //  [self animationLeftView];
        if([strLocalVideoCall isEqualToString:@"YES"])
        {
            canShowLocalVideos =YES;
            NSLog(@"%@",_arrayManageListSRVC[i]);
            NSLog(@"%@",self.StrSearch);
            self.StrSearch = _arrayManageListSRVC[i];
            lblTitle.text = [self.StrSearch uppercaseString];
            
            NSDictionary *videosInfo = [[MDatabase sharedDatabase] videosInfoForKey:self.StrSearch];
            
            arraySearchedData = [[videosInfo objectForKey:@"videos"] mutableCopy];
            if (arraySearchedData == nil || [arraySearchedData count] == 0)
            {
                [self showActivity];
                [self performSelector:@selector(doLoadVideos) withObject:nil afterDelay:0.5];
            }
            else {
                nextPageToken = [videosInfo objectForKey:@"nextPageToken"];
                if (nextPageToken) {
                    canShowNextPage = YES;
                }
                strLocalVideoCall =@"NO";
                arrayTableData = [arraySearchedData mutableCopy];
                [tableViewSearch reloadData];
                [tableViewChild reloadData];
            }

            i=0;

        }
            else
                
            {
                NSLog(@"%@",_arrayManageListSRVC[i]);
                NSLog(@"%@",self.StrSearch);
                self.StrSearch = _arrayManageListSRVC[i-1];
                lblTitle.text = [self.StrSearch uppercaseString];
               
                NSDictionary *videosInfo = [[MDatabase sharedDatabase] videosInfoForKey:self.StrSearch];
                
                arraySearchedData = [[videosInfo objectForKey:@"videos"] mutableCopy];
                if (arraySearchedData == nil || [arraySearchedData count] == 0)
                {
                    [self showActivity];
                    [self performSelector:@selector(doLoadVideos) withObject:nil afterDelay:0.5];
                }
                else {
                    nextPageToken = [videosInfo objectForKey:@"nextPageToken"];
                    if (nextPageToken) {
                        canShowNextPage = YES;
                    }
                    arrayTableData = [arraySearchedData mutableCopy];
                    [tableViewSearch reloadData];
                    [tableViewChild reloadData];
                }

                i=0;

            }
            
        }
    }
   }



#pragma mark -Local Video Show
-(void)localVideo
{
    __block NSInteger numberOfVideos = 0;
    library = [[ALAssetsLibrary alloc] init];
    arrayLocalVideo = nil;
    arrayLocalVideo = [[NSMutableArray alloc] init];
    
    void (^assetEnumerator)( ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result != nil) {
            if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
 
                [arrayLocalVideo addObject:result];
                
            }
           
        }
    };
    
    NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
    
    void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil) {
            
            [group setAssetsFilter:[ALAssetsFilter allVideos]];
            [group enumerateAssetsUsingBlock:assetEnumerator];
            
            [assetGroups addObject:group];
            NSLog(@"%@",assetGroups);
            
            numberOfVideos = numberOfVideos + [group numberOfAssets];
            
            NSLog(@"Number of assets in group :%ld",(long)numberOfVideos);
           // NSLog(@"asset group is:%@",assetGroups);
            
        }
        else {
            
            NSLog(@"THE END");
         
            if ([arrayLocalVideo count] == 0 || arrayLocalVideo == nil) {
                
                UIAlertView *alert = [[ UIAlertView alloc] initWithTitle:@"Muvee" message:@"Local video not found" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                alert.tag =65;
                [alert show];
                
            }
           
            [tableViewSearch reloadData];
            [tableViewChild reloadData];
            [self hideActivity];
        }
    };
    
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {NSLog(@"A problem occurred");}];
}

#pragma mark-Method /IBAction
-(void) setIphoneImageSize
{
    numberOfThumbsInARow = 2;
    
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        numberOfThumbsInARow = 4;
    }
    // Add two imageView for thumbNails
    screenSize = self.view.frame.size;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        screenSize = CGSizeMake(1024, 768);
    }
    
    padding = 20.0;
    x = padding;
    y = padding/2;
    width  = (screenSize.width - ((numberOfThumbsInARow + 1) * padding))/numberOfThumbsInARow;
    height = width;
    
}

-(void) setIpadImageSize
{
    numberOfThumbsInARow = 4;
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        numberOfThumbsInARow = 5;
    }
    // Add two imageView for thumbNails
    screenSize = self.view.frame.size;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        screenSize = CGSizeMake(1024, 768);
    }
    
    padding = 20.0;
    x = padding;
    y = padding/2;
    width  = (screenSize.width - ((numberOfThumbsInARow + 1) * padding))/numberOfThumbsInARow;
    height = width;
    
}


-(IBAction)firstview
{
    videoStartNumber = 1;
    [self pageNumberCall];
}


-(void)reloadTable {
    
    [NSThread sleepForTimeInterval:1];
    [self performSelectorOnMainThread:@selector(endSearch) withObject:nil waitUntilDone:YES];
    
    
    switch ([arrayTableData count]) {
            
        case 0:
            numberOfItemsInTable = 20;
            break;
        case 20:
            numberOfItemsInTable = 40;
            break;
        case 40:
            numberOfItemsInTable = 60;
            break;
        case 60:
            numberOfItemsInTable = 80;
            break;
        case 80:
            numberOfItemsInTable = 100;
            break;
            
        default:
            numberOfItemsInTable = 60;
            break;
    }
    
    arrayTableData = [[NSMutableArray alloc] init];
    for (int i=0; i<numberOfItemsInTable; i++) {
        if (i < [arraySearchedData count]) {
            
            [arrayTableData addObject:[arraySearchedData objectAtIndex:i]];
        }
    }
//    [tableViewSearch reloadData];
//    [tableViewChild reloadData];
    NSInteger x_offset = (scrollViewSearch.contentOffset.x);
    NSInteger width_table = scrollViewSearch.frame.size.width;
    NSInteger index = (x_offset/width_table) + 1;
    NSLog(@"de%f",scrollViewSearch.contentOffset.x);
    NSLog(@"dew%f",scrollViewSearch.frame.size.width);
    NSLog(@"%ld", (long)index);
    
    
    UITableView *tableView = nil;
    for (id obj in scrollViewSearch.subviews) {
        if ([obj isKindOfClass:[UITableView class]] && [obj tag] == index) {
            tableView = (UITableView *)obj;
            break;
        }
    }
    
    if (tableView) {
        tableViewSearch = tableView;
        [tableViewSearch reloadData];
        
        
        UIView *footerView = [tableView viewWithTag:1000];
        UIActivityIndicatorView *activityIndicator = [self activityForFooter:footerView];
        if (activityIndicator) {
            [activityIndicator stopAnimating];
            // [labelLoadMore setHidden:YES];
            

        }
    }
     [self performSelector:@selector(hideActivity) withObject:nil afterDelay:0.2];

}


-(void)pageNumberCall
{
    [self showActivity];
    [self performSelector:@selector(doLoadVideos) withObject:nil afterDelay:0.1];
}


-(void)doLoadVideos {
    
    strLocalVideoCall =@"NO";
    
    NSString  *term = [self.StrSearch stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *filterBy = [AppDelegate sharedDelegate].settings.contentFilteringBy;
    
    //fetch duration time
    //https://www.googleapis.com/youtube/v3/videos?id=7lCDEYXw3mM&key=YOUR_API_KEY

    //https://www.googleapis.com/youtube/v3/videos?id=eLSOXxHa8Ps&part=contentDetails&key=AIzaSyAY10OJ2Ux-7-haYNaNOuvoqiNYWSZKjv4
    
    
    NSString* searchCall = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=snippet&q=%@&type=video&maxResults=50&key=AIzaSyAY10OJ2Ux-7-haYNaNOuvoqiNYWSZKjv4&safeSearch=%@",term, filterBy];
    
    if (nextPageToken != nil && canShowNextPage) {
        
        searchCall = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=snippet&q=%@&type=video&maxResults=50&pageToken=%@&key=AIzaSyAY10OJ2Ux-7-haYNaNOuvoqiNYWSZKjv4&safeSearch=%@",term, nextPageToken, filterBy];
    }
    
    NSLog(@"%@",searchCall);
    NSURL *URL = [NSURL URLWithString:searchCall];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0lu);
    dispatch_async(queue, ^{
        // Load Videos using youtube API
        [[VSWebHandler sharedWebHandler] loadVideosForURL:URL];
        [[VSWebHandler sharedWebHandler] startRequestWithCompletionBlock:^(id response, NSError *error) {
            
            // Stop Loading Activity Here
           // [self hideActivity];
            
            if (error) {
                
            }
            else {
                
                if ([arraySearchedData count] == 0) {
                    arraySearchedData = [[NSMutableArray alloc] init];
                }
                NSLog(@"response:::::%@",response);
                
                NSLog(@"items%@",[response objectForKey:@"items"]);
                NSLog(@"pageInfo%@",[response objectForKey:@"pageInfo"]);
                NSLog(@"%@",[[response objectForKey:@"pageInfo"] objectForKey:@"totalResults"]);
                
//                if([[[response objectForKey:@"pageInfo"] objectForKey:@"totalResults"] isEqualToNumber:0])
//                {
//                    NSLog(@"ZERO");
//                }
                
//                if([[[response objectForKey:@"pageInfo"] objectForKey:@"totalResults"] length] == 0)
//                {
//                    NSLog(@"NILNILNIL");
//                }
                
                

                
                
                if ([response isKindOfClass:[NSDictionary class]] && [[response allKeys] containsObject:@"items"]) {
                    
                    id results = [response objectForKey:@"items"];
                   
                    if([[response objectForKey:@"items"] count] == 0)
                    {
                        NSLog(@"NILNILNIL");
                        
                        label.text = [NSString stringWithFormat:@"No results for %@",self.StrSearch];
                        label.numberOfLines = 2;
                        [label setHidden:NO];
                        
                        
                    }

                    for (id result in results) {
                        
                        
                        id snippet = [result objectForKey:@"snippet"];
                        
                        NSString *Id = [[result objectForKey:@"id"] objectForKey:@"videoId"];
                        NSString *title = [snippet objectForKey:@"title"];
                        NSString *description = [snippet objectForKey:@"description"];
                        NSString *thumbnailURL = [[[snippet objectForKey:@"thumbnails"] objectForKey:@"default"] objectForKey:@"url"];
                        NSLog(@"arraySearchedData::::%@",arraySearchedData);
                        
                        if (![[arraySearchedData valueForKey:@"videoId"] containsObject:Id]) {
                            
                            NSDictionary *newVideoInfo = @{videoId:Id,
                                                           videoTitle:title,
                                                           videoDescription:description,
                                                           videoThumbnail:thumbnailURL};
                            
                            [arraySearchedData addObject:newVideoInfo];
                        }
                    }
                    
                   
                    
                    NSString *pageToken = @"";
                    if (nextPageToken == nil) {
                        
                        if ([[response allKeys] containsObject:@"nextPageToken"]) {
                            
                            nextPageToken = [response objectForKey:@"nextPageToken"];
                            canShowNextPage = YES;
                            pageToken = [nextPageToken copy];
                        }
                        else {
                            nextPageToken = nil;
                            canShowNextPage = NO;
                        }
                    }
                    
                    if (arraySearchedData) {
                        
                        NSDictionary *dict = @{@"videos": arraySearchedData,
                                               @"nextPageToken": pageToken};
                        [[MDatabase sharedDatabase] saveVideosInfo:dict forKey:self.StrSearch];
                    }
                    
                    @try {
                        [self reloadTable];
                    }
                    @catch (NSException *exception) {
                        
                    }
                }
            }
        }];
        
    });
}

-(IBAction)TopArrowButton:(id)sender
{
    MCaptchaViewController *MCVC =[[MCaptchaViewController alloc] initWithNibName:@"MCaptchaViewController" bundle:nil];
    MCVC.checkTopArrrowPressed = @"YES";
    [self.navigationController pushViewController:MCVC animated:NO];
}

-(IBAction)backButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma  View Will Disappear
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
}

#pragma mark - Animation View
/*
-(void)AnimationRightView
{
    if(canCheckSuperView)
    {
        UIView *theParentView = [tableViewSearch superview];
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.5];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromRight];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [theParentView addSubview:tableViewChild];
        [tableViewSearch removeFromSuperview];
        [[theParentView layer] addAnimation:animation forKey:@"tableViewChild"];
        
        canCheckSuperView = NO;
    }
    else
    {
        UIView *theParentView = [tableViewChild superview];
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.5];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromRight];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [theParentView addSubview:tableViewSearch];
        [tableViewChild removeFromSuperview];
        [[theParentView layer] addAnimation:animation forKey:@"tableViewSearch"];
        
        canCheckSuperView = YES;
    }
    
}
-(void)animationLeftView
{
    if(canCheckSuperView)
    {
        UIView *theParentView = [tableViewSearch superview];
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.5];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromLeft];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [theParentView addSubview:tableViewChild];
        [tableViewSearch removeFromSuperview];
        [[theParentView layer] addAnimation:animation forKey:@"tableViewChild"];
        
        canCheckSuperView = NO;
    }
    else
    {
        UIView *theParentView = [tableViewChild superview];
        CATransition *animation = [CATransition animation];
        [animation setDuration:0.5];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromLeft];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [theParentView addSubview:tableViewSearch];
        [tableViewChild removeFromSuperview];
        [[theParentView layer] addAnimation:animation forKey:@"tableViewSearch"];
        
        canCheckSuperView = YES;
        
    }
}
 */
#pragma mark- Show Activity
-(void)showActivity
{
    self.view.userInteractionEnabled = NO;
    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        activity = [ActivityView activityView];
        [activity setTitle:NSLocalizedString(@"Loading...", nil)];
        [activity setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
        [activity showBorder];
        [activity showActivityInView:self.view];
        activity.center = self.view.center;
    }
    else
    {
        activity = [ActivityView activityView];
        [activity setTitle:NSLocalizedString(@"Loading...", nil)];
        [activity setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
        [activity showBorder];
        [activity showActivityInView:self.view];
        activity.center =self.view.center;
    }
}

-(void)showActivityVideoPrepare
{
    self.view.userInteractionEnabled = NO;
    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        activity = [ActivityView activityView];
        [activity setTitle:NSLocalizedString(@"Preparing..", nil)];
        [activity setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
        [activity showBorder];
        [activity showActivityInView:self.view];
        activity.center = self.view.center;
    }
    else
    {
        activity = [ActivityView activityView];
        [activity setTitle:NSLocalizedString(@"Preparing..", nil)];
        [activity setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
        [activity showBorder];
        [activity showActivityInView:self.view];
        activity.center =self.view.center;
    }
}


#pragma mark- Hide Activity
-(void)hideActivity
{
    self.view.userInteractionEnabled = YES;
    [activity hideActivity];
    
}
#pragma mark Rest Array
-(void)reset {
    
    nextPageToken = nil;
    numberOfItemsInTable = 0;
    canShowNextPage = NO;
    videoStartNumber = 1;
    arrayTableData = nil;
    arraySearchedData = nil;
}


-(void)PlayerRunning
{
    if([[AppDelegate sharedDelegate].isPlayer isEqualToString:@"Stopp"])
    {
        playerController.fullscreen = NO;
        [timerStart invalidate];
        timerStart = nil;
        [self performSelector:@selector(PlayerStop) withObject:nil afterDelay:0.2];
        
    }
}
-(void)PlayerStop
{
    /*
    MCaptchaViewController *MCVC =[[MCaptchaViewController alloc] initWithNibName:@"MCaptchaViewController" bundle:nil];
    MCVC.hideCancel = YES;
    MCVC.checkTopArrrowPressed =@"NO";
    [AppDelegate sharedDelegate].isPlayer = @"Stop";
    [[[[self.navigationController viewControllers] lastObject] navigationController] pushViewController:MCVC animated:NO];
     */
    
    alertTimeOut = [[ UIAlertView alloc]initWithTitle:@"Muvee" message:@"Time Out." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alertTimeOut.tag=123;
    
    [alertTimeOut show];
    
}

#pragma mark - footerView&Indicator
- (void)setupTableViewFooterForTableView:(UITableView *)tableView
{
    // set up label
    footerVieww = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), 60)];
    footerVieww.backgroundColor = [UIColor clearColor];
    footerVieww.tag = 1000;
//    labelLoadMore = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(footerVieww.frame), 30)];
//    labelLoadMore.font = [UIFont boldSystemFontOfSize:16];
//    labelLoadMore.textColor = [UIColor lightGrayColor];
//    labelLoadMore.textAlignment = NSTextAlignmentCenter;
//    // labelLoadMore.text = @"Load More...";
//    [footerVieww addSubview:labelLoadMore];
    
    // set up activity indicator
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect rect = activityIndicatorView.frame;
    rect.origin.x = (CGRectGetWidth(footerVieww.frame) - CGRectGetWidth(activityIndicatorView.frame))/2.0;
    rect.origin.y = (CGRectGetHeight(footerVieww.frame) - CGRectGetHeight(activityIndicatorView.frame)) - 20.0;
    activityIndicatorView.frame = rect;
    activityIndicatorView.hidesWhenStopped = YES;
    [footerVieww addSubview:activityIndicatorView];
    
    tableView.tableFooterView = footerVieww;
    
}

-(UIActivityIndicatorView *)activityForFooter:(UIView *)footerView {
    
    UIActivityIndicatorView *activityIndicator = nil;
    for (id obj in [footerView subviews]) {
        if ([obj isKindOfClass:[UIActivityIndicatorView class]]) {
            activityIndicator = (UIActivityIndicatorView *)obj;
            break;
        }
    }
    return activityIndicator;
}

#pragma mark - UIScrollViewDElegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"%@",lblTitle.text);
    canCheckLastScrollOffset = NO;
    if([lblTitle.text isEqualToString:@"LOCAL VIDEOS"])
    {
        
    }
    else
    {
        CGFloat offf = floor(scrollView.contentSize.height - scrollView.bounds.size.height);
        CGFloat offf2 = floor(scrollView.contentOffset.y);
        
        //          NSLog(@"%f",offf);
        //    NSLog(@"%f",offf2);
        
        
        if ([scrollView isKindOfClass:[UITableView class]] && (offf2 >= offf)) {
            
            UITableView *tableView = (UITableView *)scrollView;
            UIView *footerView = [tableView viewWithTag:1000];
            [footerVieww setHidden:NO];
            UIActivityIndicatorView *activityIndicator = [self activityForFooter:footerView];
            if (activityIndicator) {
                [activityIndicator startAnimating];
                //[labelLoadMore setHidden:NO];
                
            }
            
            // Do load more here
            [self TableRefresh];
        }
    }
}
-(void)TableRefresh
{
    if([strLocalVideoCall isEqualToString:@"YES"])
    {
        [NSThread sleepForTimeInterval:1];
        [self performSelectorOnMainThread:@selector(endSearch) withObject:nil waitUntilDone:NO];
    }
    else
    {
        //  [labelLoadMore setHidden:NO];
        [self performSelectorInBackground:@selector(findNextVideo) withObject:nil];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"%@", scrollView);
//    if (justchanging==YES) {
//        justchanging=NO;
//    }
//    else{
//    indexCount = 1;
//    [self startReloading];
     [label setHidden:YES];
        if ([scrollView isKindOfClass:[UITableView class]])
        {
            
        }
        else
        {
            NSLog(@"scrollViewSearch%@",scrollViewSearch);
            NSLog(@"%@",[[tempArrayManageListSRVC lastObject]uppercaseString]);
             NSLog(@"%@",[[tempArrayManageListSRVC firstObject]uppercaseString]);
            NSLog(@"%@",lblTitle.text);
                NSLog(@"offset%f",scrollViewSearch.contentOffset.x);
            

            if(canCheckLastScrollOffset)
            {
                NSLog(@"not show activity");
                // not show activity
            }
            else
            {
                NSLog(@"show activity");
                [self showActivity];
                 [self performSelector:@selector(doTask:) withObject:scrollView afterDelay:0.2];
            }

            
            NSLog(@"%lu",(unsigned long)[tempArrayManageListSRVC count]);
             NSLog(@"%f",([tempArrayManageListSRVC count]-1)*screenSize.width);
            if(scrollViewSearch.contentOffset.x == ([tempArrayManageListSRVC count]-1)*screenSize.width || scrollViewSearch.contentOffset.x == 0.0 )
            {
              
                canCheckLastScrollOffset = YES;
            }
                      // }
            

        }
    //}
}

- (void)doTask:(UIScrollView *)scrollView {
    
    //uiscrollView Call (swipe)
    NSInteger x_offset = (scrollViewSearch.contentOffset.x);
    NSInteger width_table = scrollViewSearch.frame.size.width;
    
    NSLog(@"xxxx%f",scrollViewSearch.contentOffset.x);
    NSLog(@"width  %f",scrollViewSearch.frame.size.width);
    
    NSInteger index = (x_offset/width_table) + 1;
    NSLog(@"%ld", (long)index);
    
    UITableView *tableView = nil;
    for (id obj in scrollViewSearch.subviews) {
        if ([obj isKindOfClass:[UITableView class]] && [obj tag] == index) {
            tableView = (UITableView *)obj;
            break;
        }
    }
    if (tableView) {
        
        tableViewSearch = tableView;
        [self reset];
        int page = index - 1;
        
        NSLog(@"_arrayManageListSRVC%lu",(unsigned long)[_arrayManageListSRVC count]);
        NSLog(@"Dragging - You are now on page %i",page);
        NSLog(@"_arrayManageListSRVC index = %@",tempArrayManageListSRVC[page]);
        // chkHowManyPage = page +1;
        NSLog(@"%@",tempArrayManageListSRVC[page]);
        if([tempArrayManageListSRVC[page] isEqualToString:@"LOCAL VIDEOS"])
        {
            [self localVideo];
            lblTitle.text = @"LOCAL VIDEOS";
            strLocalVideoCall = @"YES";
            canShowLocalVideos=NO;
            lastSearchTitle = lblTitle.text;
            //                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            //                [defaults setValue:lastSearchTitle forKey:@"lastSearchTitleStr"];
            //                NSString *lastSearchedKey = [defaults valueForKey:@"lastSearchTitleStr"];
            //                NSLog(@"%@",lastSearchedKey);
            //                [defaults synchronize];
            
        }
        else
        {
            //      strChkLocalvideoPage = @"NO";
            
            NSLog(@"Dragging - You are now on page %i",page);
            // _arrayManageListSRVC =[AppDelegate sharedDelegate].playlist;
            NSLog(@"_arrayManageListSRVC index = %@",_arrayManageListSRVC[page]);
            
            self.StrSearch = tempArrayManageListSRVC[page];
            lastSearchTitle = self.StrSearch;
            
            lblTitle.text = [self.StrSearch uppercaseString];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue:lastSearchTitle forKey:@"lastSearchTitleStr"];
            NSString *lastSearchedKey = [defaults valueForKey:@"lastSearchTitleStr"];
            NSLog(@"%@",lastSearchedKey);
            [defaults synchronize];
            
            NSDictionary *videosInfo = [[MDatabase sharedDatabase] videosInfoForKey:self.StrSearch];
            
            arraySearchedData = [[videosInfo objectForKey:@"videos"] mutableCopy];
            if (arraySearchedData == nil || [arraySearchedData count] == 0)
            {
                if ([[DataStorage sharedStorage] isInternetAvailable]) {
                    [self performSelector:@selector(doLoadVideos) withObject:nil afterDelay:0.5];
                }
                else {
                    [self hideActivity];
                }
            }
            else {
                nextPageToken = [videosInfo objectForKey:@"nextPageToken"];
                if (nextPageToken) {
                    canShowNextPage = YES;
                }
                strLocalVideoCall =@"NO";
                arrayTableData = [arraySearchedData mutableCopy];
                NSLog(@"arrayTableData%@",arrayTableData);
                
                [self hideActivity];
                //  [tableViewSearch reloadData];
            }
            [tableViewSearch reloadData];
            
        }
        
    }
    else {
        [self hideActivity];
    }
}

# pragma mark - Orientation related methods
//- (BOOL)shouldAutorotate {
//    return YES;
//}
//
//- (NSUInteger)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskLandscape;
//}

//- (NSUInteger)supportedInterfaceOrientations {
//    [self shouldAutorotate];
//    return UIInterfaceOrientationMaskLandscape;
//    //edit by tijender
//    //UIInterfaceOrientationMaskPortrait
//}
//// pre-iOS 6 support
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    return  (toInterfaceOrientation =UIInterfaceOrientationLandscapeRight);
//    //
//    //edit by tijender
//    //UIInterfaceOrientationPortrait
//}
////-(NSUInteger)supportedInterfaceOrientations {
////    return UIInterfaceOrientationMaskLandscape;
////}
//
//-(BOOL)shouldAutorotate {
//    return NO;
//}

@end
