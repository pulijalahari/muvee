//
//  SearchResultsViewController.m
//  Muvee
//
//  Created by iApp on 12/1/14.
//  Copyright (c) 2014 iAppTechnologies. All rights reserved.
//

#import "SearchResultsViewController.h"
#import "MGBox.h"
#import "MGScrollView.h"

#import "JSONModelLib.h"
#import "VideoModel.h"

#import "PhotoBox.h"
#import "WebVideoViewController.h"

#import "SDWebImageManager.h"
#import "SDWebImageDownloader.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "ActivityView.h"
#import "MVideoPlayerViewController.h"
#import "MLoginViewController.h"
#import "VSWebHandler.h"
#import "MSPullToRefreshController.h"
#import "PasscodeViewController.h"
#import "MRootViewController.h"
#import "MCaptchaViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>


@interface SearchResultsViewController ()<SDWebImageManagerDelegate>
{
    NSMutableArray *videosUrl,*arrayTitle,*arrayimage,*arrayTimeDuration;
    UIImageView *imv;
    NSInteger numberOfThumbsInARow;
    CGSize screenSize ;
    CGFloat x,y,width,height,padding ;
    int videoStartNumber;
    ActivityView *activity;
    UIImageView *thumbnail;
    NSDictionary *json;
    UIButton *btn1,*btn2,*btn3,*btn4,*btn5,*btnLeftArrow,*btnRightArrow,*btnDownArrow;
    NSArray *reverseOrder;
    int lastRow;
    NSString *strDisapear;
    int lastIndex;
    int leftPressed;
    UILabel *lblTime;
    ALAsset *Asset1;
    
    NSInteger currentIndex;
    
    NSMutableArray *arraySearchedData;
    NSMutableArray *arrayTableData,*arrayLocalVideo,*arrayReverse;
    NSString *nextPageToken; // Will retrieve next page videos. API v3 API gives max 50 videos at once.
    BOOL canShowNextPage;
    NSInteger numberOfItemsInTable;
    IBOutlet UIButton *btnTopArrow;
    
    IBOutlet UILabel *lblTitle;
    NSString *strLocalVideoCall;
    ALAssetsLibrary *library;
    IBOutlet UIView *viewColor;
    UISwipeGestureRecognizer *swipeGestureRight;
    MRootViewController *rootVC;
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
    self.navigationController.navigationBarHidden = YES;
    
    library = [[ALAssetsLibrary alloc] init];
    lblTitle.text =[self.StrSearch uppercaseString];
    strDisapear = @"YES";
    _ptr = [[CustomPullToRefresh alloc] initWithScrollView:tableViewSearch delegate:self];
    

    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleOrientationChangeNotificationSearchresultView) name: UIApplicationDidChangeStatusBarOrientationNotification object: nil];
    
//    UISwipeGestureRecognizer *swipeGesture =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(viewSwipe)];
//    [self.navigationController.navigationBar addGestureRecognizer:swipeGesture];
//    swipeGesture.direction=UISwipeGestureRecognizerDirectionDown;

    arrayReverse =[NSMutableArray arrayWithCapacity:1];
    arrayLocalVideo =[NSMutableArray arrayWithCapacity:1];
    videosUrl=[NSMutableArray arrayWithCapacity:1];
    arrayTitle=[NSMutableArray arrayWithCapacity:1];
    arrayimage=[NSMutableArray arrayWithCapacity:1];
    arrayTimeDuration=[NSMutableArray arrayWithCapacity:1];
    leftPressed = 0;
    
   
    [self reset];
    
    NSDictionary *videosInfo = [[MDatabase sharedDatabase] videosInfoForKey:self.StrSearch];
    
    arraySearchedData = [[videosInfo objectForKey:@"videos"] mutableCopy];
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
        [tableViewSearch reloadData];
    }
    
    
    screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    CGRect rectTopArrow;
    if([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone)
    {
         rectTopArrow = CGRectMake((screenSize.width-40)/2, -4, 40, 20) ;
    }
    else
    {
        rectTopArrow = CGRectMake((screenSize.width-80)/2, 0, 80, 40) ;
    }
    
    
     btnTopArrow= [[UIButton alloc]initWithFrame:rectTopArrow];
    [btnTopArrow addTarget:self action:@selector(TopArrowButton:) forControlEvents:UIControlEventTouchUpInside];
    [btnTopArrow setBackgroundImage:[UIImage imageNamed:@"top_arrow@2x"] forState:UIControlStateNormal];
    [self.view addSubview:btnTopArrow];
    [btnTopArrow setHidden:YES];
    

    
    
    UISwipeGestureRecognizer *swipeGesture =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(imageSwipe:)];
    [tableViewSearch addGestureRecognizer:swipeGesture];
    swipeGesture.direction=UISwipeGestureRecognizerDirectionLeft;
    
    swipeGestureRight =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(imageSwipeRight:)];
    [tableViewSearch addGestureRecognizer:swipeGestureRight];
    swipeGestureRight.direction=UISwipeGestureRecognizerDirectionRight;
    
    
}

-(void)reset {
    
    nextPageToken = nil;
    numberOfItemsInTable = 0;
    canShowNextPage = NO;
    videoStartNumber = 1;
    
    arrayTableData = nil;
    arraySearchedData = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

-(void)findNextVideo
{
//    NSLog(@"%d",lastRow);
//    if(lastRow == 9)
//    {
//        [self btnTapped2];
//    }
//    else if (lastRow == 19)
//    {
//        [self btnTapped3];
//    }
//    else if (lastRow == 29)
//    {
//        [self btnTapped4];
//    }
//    else if (lastRow  == 39)
//    {
//        [self btnTapped5];
//    }
    
    
    
    
    if ([arrayTableData count] <= 50 && [arrayTableData count] > 20) {
        //[self showActivity];
        //[self performSelector:@selector(doLoadVideos) withObject:nil afterDelay:0.2];
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
            [self reloadTable];
        }
        else {
            [NSThread sleepForTimeInterval:1];
            [self performSelectorOnMainThread:@selector(endSearch) withObject:nil waitUntilDone:NO];
        }
    }


}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void) endSearch {

    [_ptr endRefresh];
    [tableViewSearch reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    
    lblTitle.text =[self.StrSearch uppercaseString];
    
  
   // if (self.arrayManageListSRVC == nil) {
        //self.arrayManageListSRVC =  [[NSUserDefaults standardUserDefaults]valueForKey:@"ArrayManageplayList"];
    //}
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    //[self showActivity];
    
}



-(BOOL)prefersStatusBarHidden
{
    return  YES;
}

-(IBAction)TopArrowButton:(id)sender
{
    MCaptchaViewController *MCVC =[[MCaptchaViewController alloc] initWithNibName:@"MCaptchaViewController" bundle:nil];
    MCVC.checkTopArrrowPressed =@"YES";
    [self.navigationController pushViewController:MCVC animated:NO];
}
-(void)viewSwipe
{
    MRootViewController *MRVC=[[MRootViewController alloc]initWithNibName:@"MRootViewController" bundle:nil];
    [self.navigationController pushViewController:MRVC animated:YES];

//  PasscodeViewController *PCVC=[[PasscodeViewController alloc]init];
//    PCVC.strViewChk = @"SearchView";
//    PCVC.strSearch =self.StrSearch;
//    [self.navigationController pushViewController:PCVC animated:YES];
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
   // [self hideActivity];
   screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    for (id obj in cell.contentView.subviews) {
        [obj removeFromSuperview];
    }
    
    CGRect rectTopArrow;
    if([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone)
    {
        rectTopArrow = CGRectMake((screenSize.width-40)/2, -4, 40, 20) ;
    }
    else
    {
        rectTopArrow = CGRectMake((screenSize.width-80)/2, 0, 80, 40) ;
    }
    btnTopArrow.frame = rectTopArrow;
    [btnTopArrow setHidden:NO];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
            [self setIphoneImageSize];
            
            if([strLocalVideoCall isEqualToString:@"YES"])
            {
                {
                    
                    NSInteger tag = indexPath.row * numberOfThumbsInARow;
                    
                    for (int i=0; i<numberOfThumbsInARow; i++) {
                        
                        
                        
                        thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
                        thumbnail.tag = tag;
                        thumbnail.userInteractionEnabled = TRUE;
                        [thumbnail setBackgroundColor:[UIColor blackColor]];
                        
                        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
                        [thumbnail addGestureRecognizer:tapGesture];
                        
                        [cell.contentView addSubview:thumbnail];
                        
                        UIImageView *iconPlay = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 39, 29)];
                        iconPlay.image = [UIImage imageNamed:@"play_icon"];
                        CGRect iRect = iconPlay.frame;
                        iRect.origin.x = (thumbnail.frame.size.width - iRect.size.width)/2.0;
                        iRect.origin.y = (thumbnail.frame.size.height - iRect.size.height)/2.0;
                        iconPlay.frame = iRect;
                        
                        [thumbnail addSubview:iconPlay];
                        
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
            
            
            
           thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
            thumbnail.tag = tag;
            thumbnail.userInteractionEnabled = TRUE;
            [thumbnail setBackgroundColor:[UIColor blackColor]];
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
            [thumbnail addGestureRecognizer:tapGesture];

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
            UIImageView *iconPlay = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 39, 29)];
            iconPlay.image = [UIImage imageNamed:@"play_icon"];
            CGRect iRect = iconPlay.frame;
            iRect.origin.x = (thumbnail.frame.size.width - iRect.size.width)/2.0;
            iRect.origin.y = (thumbnail.frame.size.height - iRect.size.height)/2.0;
            iconPlay.frame = iRect;
            
            [thumbnail addSubview:iconPlay];
            
            
            
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
                    NSLog(@"%@",arrayimage);
                  
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
            
                NSInteger tag = indexPath.row * numberOfThumbsInARow;
                
                for (int i=0; i<numberOfThumbsInARow; i++) {
                    
                    
                    
                    thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
                    thumbnail.tag = tag;
                    thumbnail.userInteractionEnabled = TRUE;
                    [thumbnail setBackgroundColor:[UIColor blackColor]];
                    
                    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
                    [thumbnail addGestureRecognizer:tapGesture];

                    [cell.contentView addSubview:thumbnail];
                    
                    UIImageView *iconPlay = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 39, 29)];
                    iconPlay.image = [UIImage imageNamed:@"play_icon"];
                    CGRect iRect = iconPlay.frame;
                    iRect.origin.x = (thumbnail.frame.size.width - iRect.size.width)/2.0;
                    iRect.origin.y = (thumbnail.frame.size.height - iRect.size.height)/2.0;
                    iconPlay.frame = iRect;
                    
                    [thumbnail addSubview:iconPlay];
                    
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
        
        else
        {
        NSInteger tag = indexPath.row * numberOfThumbsInARow;
        
        for (int i=0; i<numberOfThumbsInARow; i++) {
            
          
            
           thumbnail = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
            thumbnail.tag = tag;
            thumbnail.userInteractionEnabled = TRUE;
            [thumbnail setBackgroundColor:[UIColor blackColor]];
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
            [thumbnail addGestureRecognizer:tapGesture];

            [cell.contentView addSubview:thumbnail];
            
            UIImageView *iconPlay = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 39, 29)];
            iconPlay.image = [UIImage imageNamed:@"play_icon"];
            CGRect iRect = iconPlay.frame;
            iRect.origin.x = (thumbnail.frame.size.width - iRect.size.width)/2.0;
            iRect.origin.y = (thumbnail.frame.size.height - iRect.size.height)/2.0;
            iconPlay.frame = iRect;
            
            [thumbnail addSubview:iconPlay];
            
            if (tag >= [arrayTableData count]) {
                thumbnail.hidden = TRUE;
            }
            else {
                
                NSDictionary *videoInfo = [arrayTableData objectAtIndex:tag];
                
                @try {
                    SDWebImageManager *manager      = [SDWebImageManager sharedManager];
                    
                    NSString *thumbPath = [videoInfo objectForKey:videoThumbnail];
                    [thumbnail setImageWithURL:[NSURL URLWithString:thumbPath]];
                    
                    [manager downloadWithURL:[NSURL URLWithString:thumbPath] options:0 progress:^(NSUInteger receivedSize, long long expectedSize) {
                        //  cell.loadingView.hidden     = NO;
                        //[cell.loadingView startAnimating];
                    }
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                                       if (image) {
                                           
                                           //  cell.thumbnail.image    = image;
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
     lastRow=[arrayimage count]-1;
    lastRow =lastRow /2;
    
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

    [tableViewSearch reloadData];
}


-(void)pageNumberCall
{
    [self showActivity];
    [self performSelector:@selector(doLoadVideos) withObject:nil afterDelay:0.1];
}


-(void)doLoadVideos {
    
   strLocalVideoCall =@"NO";
    
    NSString  *term = [self.StrSearch stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
// NSString* searchCall = [NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/videos?q=%@&max-results=20&start-index=%d&alt=json", term,videoStartNumber];
    
    NSString *filterBy = [AppDelegate sharedDelegate].settings.contentFilteringBy;
    
  //  NSString* searchCall = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/search?part=snippet&q=%@&type=video&maxResults=%d&key=AIzaSyAY10OJ2Ux-7-haYNaNOuvoqiNYWSZKjv4&safeSearch=%@",term,videoStartNumber+19, filterBy];
    
    
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
            [self hideActivity];
            
            if (error) {
                
                
            }
            else {
                
                if ([arraySearchedData count] == 0) {
                    arraySearchedData = [[NSMutableArray alloc] init];
                }
                
                if ([response isKindOfClass:[NSDictionary class]] && [[response allKeys] containsObject:@"items"]) {
                    
                    id results = [response objectForKey:@"items"];
                    
                    for (id result in results) {
                        
                        
                        id snippet = [result objectForKey:@"snippet"];
                        
                        NSString *Id = [[result objectForKey:@"id"] objectForKey:@"videoId"];
                        NSString *title = [snippet objectForKey:@"title"];
                        NSString *description = [snippet objectForKey:@"description"];
                        NSString *thumbnailURL = [[[snippet objectForKey:@"thumbnails"] objectForKey:@"default"] objectForKey:@"url"];
                        
                        
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

                    
                    [self reloadTable];
                 }
            }
        }];

    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView .tag ==11)
     {
         [self.navigationController popViewControllerAnimated:YES];
      }
}



-(void)imageSwipeRight:(UIGestureRecognizer *) sender
{
    
    [self btnLeftTapped];
}
-(void)imageSwipe:(UIGestureRecognizer *) gesture
{
    NSLog(@"swipe");
    [self btnRightTapped];
    
}

-(void)imageTapped:(UIGestureRecognizer *)recognizer {
    
     screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
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


#pragma mark - LBYouTubePlayerControllerDelegate methods

-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL
{
    [self hideActivity];

    
    
    playerController = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlaybackComplete:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayerController];
    playerController.controlStyle = MPMovieControlStyleFullscreen;
   
    [self.view addSubview:playerController.view];
    playerController.fullscreen = YES;
    [playerController prepareToPlay];
    [playerController play];
}

-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller failedExtractingYouTubeURLWithError:(NSError *)error
{
    [self hideActivity];
    NSLog(@"URL extracting failed with error: %@", error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}



-(void) setIphoneImageSize
{
    numberOfThumbsInARow = 2;
    
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
        numberOfThumbsInARow = 4;
    }
    // Add two imageView for thumbNails
    screenSize = self.view.frame.size;
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
    padding = 20.0;
    x = padding;
    y = padding/2;
    width  = (screenSize.width - ((numberOfThumbsInARow + 1) * padding))/numberOfThumbsInARow;
    height = width;
    
}


-(void)handleOrientationChangeNotificationSearchresultView
{
    screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
     [tableViewSearch reloadData];
    
    CGRect rectTopArrow = btnTopArrow.frame;
    activity.center = self.view.center;
    
    if([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone)
    {
        rectTopArrow = CGRectMake((screenSize.width-40)/2, -4, 40, 20) ;
    }
    else
    {
        rectTopArrow = CGRectMake((screenSize.width-80)/2, 0, 80, 40) ;
    }
    btnTopArrow.frame = rectTopArrow;
   
        
}
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



-(void)btnLeftTapped
{
    [self reset];
    
    UIView *theParentView = [self.view superview];
    
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [theParentView addSubview:rootVC.view];
    [self.view removeFromSuperview];
    
    [[theParentView layer] addAnimation:animation forKey:@"MRootViewController"];
    
    NSLog(@"%@",_arrayManageListSRVC);
    
    for (long i = [_arrayManageListSRVC count]-1; i>=0; i--)
    {
        NSString *str=[_arrayManageListSRVC objectAtIndex:i];
        NSLog(@"%@",_arrayManageListSRVC[i]);
        NSLog(@"%@",str);
        NSLog(@"%@",self.StrSearch);
       
        if(i == 0)
        {
            NSLog(@"not");
            [btnLeftArrow setHidden:YES];
            if([strLocalVideoCall isEqualToString:@"YES"])
            {
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
                }
                
                i=0;
                
                
            }
        }
        else if([str caseInsensitiveCompare:self.StrSearch] == NSOrderedSame)
        {
        if([strLocalVideoCall isEqualToString:@"YES"])
        {
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
                }

                
                i=0;

            }
            
        }
    }
    
    
    
    
   }
-(void)btnDownTapped
{
    
}
-(void)btnRightTapped
{
    [self reset];
    
    NSLog(@"%@",_arrayManageListSRVC);
    
    for (int i = 0; i<[_arrayManageListSRVC count]; i++)
    {
        NSString *str = [_arrayManageListSRVC objectAtIndex:i];
        if(i == [_arrayManageListSRVC count]-1)
        {
            NSLog(@"not");
            [btnRightArrow setHidden:YES];
           
            if([[AppDelegate sharedDelegate]settings] .localVideos  == YES)
            {
            //[self showActivity];
            [self localVideo];
            lblTitle.text = @"LOCAL VIDEOS";
            strLocalVideoCall = @"YES";
            }
            
        }
         else if([str caseInsensitiveCompare:self.StrSearch] == NSOrderedSame)
        {
            
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
            }

            
            i=[_arrayManageListSRVC count];
            
        }
    }


    
   }



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
                
                UIAlertView *alert = [[ UIAlertView alloc] initWithTitle:@"Muvee" message:@"Local video not found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                
                [alert show];
                
            }
           
            [tableViewSearch reloadData];
            [self hideActivity];

        }
    };
    
    
    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {NSLog(@"A problem occurred");}];
}


-(IBAction)backButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)btnTapped1
{
    videoStartNumber = 1;
    [self pageNumberCall];
    btn1.userInteractionEnabled = NO;
    btn1.backgroundColor = [UIColor lightGrayColor];
}

-(void)btnTapped2
{
   // [btnRightArrow setHidden: NO];
    videoStartNumber = 21;
  //  [self pageNumberCall];
    [self doLoadVideos];


}

-(void)btnTapped3
{

    videoStartNumber = 41;
  //  [self pageNumberCall];
   
[self doLoadVideos];

}

-(void)btnTapped4
{
    videoStartNumber = 61;
   // [self pageNumberCall];
    [self doLoadVideos];
}

-(void)btnTapped5
{
    videoStartNumber = 81;
    //[self pageNumberCall];
    [self doLoadVideos];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    strDisapear = @"NO";
}




@end
