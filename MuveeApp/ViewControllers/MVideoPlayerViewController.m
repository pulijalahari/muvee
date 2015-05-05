//
//  MVideoPlayerViewController.m
//  Muvee
//
//  Created by iApp on 04/12/14.
//  Copyright (c) 2014 iAppTechnologies. All rights reserved.
//

#import "MVideoPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "ActivityView.h"


@interface MVideoPlayerViewController ()
{
    ActivityView *activity;
    CGSize screenSize;
    int width,height;
    CGFloat y;
    int x;
}

@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;

@end

@implementation MVideoPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _arrVideoUrl =[[NSArray alloc]init];
        // Custom initialization
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self playVideo];
}

#pragma mark - UIButtonActions
- (IBAction)playVideo
{
    
    NSString *strKey=[NSString stringWithFormat:@"%@",_arrVideoUrl];
    NSString *prefix = @"       http://www.youtube.com/watch?v="; // string prefix, not needle prefix!
    NSString *suffix = @"&feature=youtube_gdata_player   "; // string suffix, not needle suffix!
    NSRange needleRange = NSMakeRange(prefix.length,
                                      strKey.length - prefix.length - suffix.length);
    NSString *needle = [strKey substringWithRange:needleRange];
    NSLog(@"needle: %@", needle); // -> "hello World"

    
    //    initialize LBYouTubePlayerViewController here and pass the url
    lbYoutubePlayerVC = [[LBYouTubePlayerViewController alloc]initWithYouTubeURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.youtube.com/watch?v=%@",needle]] quality:LBYouTubeVideoQualityLarge];
    lbYoutubePlayerVC.delegate=self;
}

#pragma mark - LBYouTubePlayerControllerDelegate methods

-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller didSuccessfullyExtractYouTubeURL:(NSURL *)videoURL
{
    moviePlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    [moviePlayerViewController.moviePlayer prepareToPlay];
    [moviePlayerViewController.moviePlayer play];
    [self presentViewController:moviePlayerViewController animated:YES completion:nil];
}

-(void)youTubePlayerViewController:(LBYouTubePlayerViewController *)controller failedExtractingYouTubeURLWithError:(NSError *)error
{
    NSLog(@"URL extracting failed with error: %@", error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}









//-(void)viewWillAppear:(BOOL)animated
//{
//    self.navigationController.navigationBarHidden=NO;
//    [self showActivity];
//
//}
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    self.title=_strTitle;
//    x= 30;
//    
//}
//
//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:YES];
//    CGRect rect = _webView.frame;
//
//      [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleOrientationChangeNotification) name: UIApplicationDidChangeStatusBarOrientationNotification object: nil];
//    
//    if([[UIDevice currentDevice] userInterfaceIdiom ]== UIUserInterfaceIdiomPhone  )
//       {
//           if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
//           {
//               if(IS_IPHONE_4)
//               {
//               screenSize=self.view.frame.size;
//               width=420;
//               height=260;
//               rect = CGRectMake(30, 30, width, height);
//               }
//               else
//               {
//                   screenSize=self.view.frame.size;
//                   width=420;
//                   height=260;
//                   rect = CGRectMake(74, 30, width, height);
//               }
//           }
//           else
//           {
//               if(IS_IPHONE_4)
//               {
//                   width=260;
//                   height=250;
//                  rect = CGRectMake(30, 115, width, height);
//                  
//               }
//               if(IS_IPHONE_5)
//               {
//                   width=260;
//                   height=250;
//                rect = CGRectMake(30, 159, width, height);
//               }
//             
//           }
//        
//       }
//        else
//     {
//         if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
//         {
//            self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(50, 50,924, 668)];
//             screenSize=self.view.frame.size;
//             width=924;
//             height=668;
//             rect = CGRectMake(50, 50, width, height);
//
//         }
//         else
//         {
//             self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(50, 50,668, 924)];
//             screenSize=self.view.frame.size;
//             width=668;
//             height=924;
//             rect = CGRectMake(50, 50, width, height);
//
//         }
//        
//        
//     }
//    _webView = [[UIWebView alloc] initWithFrame:rect];
//
//    [self.webView setAllowsInlineMediaPlayback:YES];
//    [self.webView setMediaPlaybackRequiresUserAction:NO];
//    [self.view addSubview:self.webView];
//    [self webViewEmbed];
//
//    }
//
//-(void)webViewEmbed
//{
//    NSString *strKey=[NSString stringWithFormat:@"%@",_arrVideoUrl];
//    NSString *prefix = @"       http://www.youtube.com/watch?v="; // string prefix, not needle prefix!
//    NSString *suffix = @"&feature=youtube_gdata_player   "; // string suffix, not needle suffix!
//    NSRange needleRange = NSMakeRange(prefix.length,
//                                      strKey.length - prefix.length - suffix.length);
//    NSString *needle = [strKey substringWithRange:needleRange];
//    NSLog(@"needle: %@", needle); // -> "hello World"
//    
//    
//    NSString* embedHTML = [NSString stringWithFormat:@"\
//                           <html>\
//                           <body style='margin:0px;padding:0px;'>\
//                           <script type='text/javascript' src='http://www.youtube.com/iframe_api'></script>\
//                           <script type='text/javascript'>\
//                           function onYouTubeIframeAPIReady()\
//                           {\
//                           ytplayer=new YT.Player('playerId',{events:{onReady:onPlayerReady}})\
//                           }\
//                           function onPlayerReady(a)\
//                           { \
//                           a.target.playVideo(); \
//                           }\
//                           </script>\
//                           <iframe id='playerId' type='text/html' width='%d' height='%d' src='http://www.youtube.com/embed/%@?enablejsapi=1&rel=0&playsinline=1&autoplay=1' frameborder='0'>\
//                           </body>\
//                           </html>", width, height, needle];
// //   [self hideActivity];
//    
//    [self.webView loadHTMLString:embedHTML baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",_arrVideoUrl]]];
//   // [self hideActivity];
//}
//
//-(void)handleOrientationChangeNotification
//{
//    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//    {
//        //iphone
//        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
//        {
//            screenSize=self.view.frame.size;
//            NSLog(@"MV%@",NSStringFromCGSize(screenSize));
//            
////            screenSize=self.view.frame.size;
////            width=420;
////            height=260;
////            CGRect rect = _webView.frame;
////            rect = CGRectMake(30, 30, width, height);
////            _webView.frame = rect;
//            
//            
//            
//            if(IS_IPHONE_4)
//            {
//                screenSize=self.view.frame.size;
//                width=420;
//                height=260;
//                CGRect rect = _webView.frame;
//                rect = CGRectMake(30, 30, width, height);
//                _webView.frame = rect;
//                
//
//            }
//            else
//            {
//                screenSize=self.view.frame.size;
//                width=420;
//                height=260;
//               // rect = CGRectMake(74, 30, width, height);
//                CGRect rect = _webView.frame;
//                rect = CGRectMake(74, 30, width, height);
//                _webView.frame = rect;
//                            }
//            //[self webViewEmbed];
//        }
//        
//        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
//        {
//            screenSize=self.view.frame.size;
//            if(IS_IPHONE_4)
//            {
//                width=260;
//                height=200;
//                CGRect rect = _webView.frame;
//                rect = CGRectMake(30, 115, width, height);
//                _webView.frame = rect;
//            }
//            if(IS_IPHONE_5)
//            {
//                width=260;
//                height=250;
//                CGRect rect = _webView.frame;
//                rect = CGRectMake(30, 159, width, height);
//                _webView.frame = rect;
//            }
//            
//           // [self webViewEmbed];
//        }
//        
//    }
//    else
//    {
//        //ipad
//        if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
//        {
//            screenSize=self.view.frame.size;
//            NSLog(@"MV%@",NSStringFromCGSize(screenSize));
//            
//            screenSize=self.view.frame.size;
//            width=924;
//            height=668;
//            CGRect rect = _webView.frame;
//            rect = CGRectMake(30, 30, width, height);
//            _webView.frame = rect;
//            //[self webViewEmbed];
//        
//            
//            
//        }
//        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
//        {
//            screenSize=self.view.frame.size;
//            width=668;
//            height=924;
//            CGRect rect = _webView.frame;
//            rect = CGRectMake(30, 30, width, height);
//            _webView.frame = rect;
//            //[self webViewEmbed];
//        }
//
//           }
//
//    
//    _webView.frame = self.view.bounds;
//    
//}
//
//
//- (void)videoPlayBackDidFinish:(NSNotification *)notification {
//    
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
//    
//    // Stop the video player and remove it from view
//    [_moviePlayer stop];
//    [_moviePlayer.view removeFromSuperview];
//    _moviePlayer = nil;
//    
//    // Display a message
//    //    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Video Playback" message:@"Just finished the video playback. The video is now removed." preferredStyle:UIAlertControllerStyleAlert];
//    //    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
//    //    [alertController addAction:okayAction];
//    //    [self presentViewController:alertController animated:YES completion:nil];
//    
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
//#pragma mark- Show Activity
//-(void)showActivity
//{
//    self.view.userInteractionEnabled = NO;
//    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
//    {
//        activity = [ActivityView activityView];
//       // [activity setTitle:NSLocalizedString(@"Loading...", nil)];
//        [activity setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
//        [activity showBorder];
//        [activity showActivityInView:self.view];
//        activity.center = self.view.center;
//    }
//    else
//    {
//        activity = [ActivityView activityView];
//       // [activity setTitle:NSLocalizedString(@"Loading...", nil)];
//        [activity setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
//        [activity showBorder];
//        [activity showActivityInView:self.webView];
//        activity.center = self.view.center;
//}
//}
//#pragma mark- Hide Activity
//-(void)hideActivity
//{
//    self.view.userInteractionEnabled = YES;
//    [activity hideActivity];
//    
//}
//



//-(void)viewWillAppear:(BOOL)animated
//{
//    self.navigationController.navigationBarHidden=NO;
//    
//        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleOrientationChangeNotification) name: UIApplicationDidChangeStatusBarOrientationNotification object: nil];
//
//    
//}
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    self.title=_strTitle;
//    
//    
//    CGRect rect = _webView.frame;
//    
//    if([[UIDevice currentDevice] userInterfaceIdiom ]== UIUserInterfaceIdiomPhone  )
//    {
//        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
//        {
//            if(IS_IPHONE_4)
//            {
//                screenSize=self.view.frame.size;
//                width=420;
//                height=260;
//                rect = CGRectMake(30, 30, width, height);
//            }
//            else
//            {
//                screenSize=self.view.frame.size;
//                width=420;
//                height=260;
//                rect = CGRectMake(74, 30, width, height);
//            }
//        }
//        else
//        {
//            if(IS_IPHONE_4)
//            {
//                width=260;
//                height=350;
//                rect = CGRectMake(30, 65, width, height);
//                
//            }
//            if(IS_IPHONE_5)
//            {
//                width=260;
//                height=250;
//                rect = CGRectMake(30, 159, width, height);
//            }
//            
//        }
//        
//    }
//    else
//    {
//        if(UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
//        {
//            self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(50, 50,924, 668)];
//            screenSize=self.view.frame.size;
//            width=924;
//            height=668;
//            rect = CGRectMake(50, 50, width, height);
//            
//        }
//        else
//        {
//            self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(50, 50,668, 924)];
//            screenSize=self.view.frame.size;
//            width=668;
//            height=924;
//            rect = CGRectMake(50, 50, width, height);
//            
//        }
//    }
//    _webView = [[UIWebView alloc] initWithFrame:rect];
//    _webView.frame = self.view.bounds;
//    
//    [self.webView setAllowsInlineMediaPlayback:YES];
//    [self.webView setMediaPlaybackRequiresUserAction:NO];
//    [self.webView setBackgroundColor:[UIColor clearColor]];
//    
//    [self.webView setOpaque:NO];
//    [self.view addSubview:self.webView];
//    
//    
//    
//    [self webViewEmbed];
//
//}
//
//-(void)webViewEmbed
//{
//    
////    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 10,300, 400)];
////    [self.webView setAllowsInlineMediaPlayback:YES];
////    [self.webView setMediaPlaybackRequiresUserAction:NO];
////    
////    [self.view addSubview:self.webView];
//    
//    
//    NSString *strKey=[NSString stringWithFormat:@"%@",_arrVideoUrl];
//    NSString *prefix = @"       http://www.youtube.com/watch?v="; // string prefix, not needle prefix!
//    NSString *suffix = @"&feature=youtube_gdata_player   "; // string suffix, not needle suffix!
//    NSRange needleRange = NSMakeRange(prefix.length,
//                                      strKey.length - prefix.length - suffix.length);
//    NSString *needle = [strKey substringWithRange:needleRange];
//    NSLog(@"needle: %@", needle); // -> "hello World"
//    
//    
//    NSString* embedHTML = [NSString stringWithFormat:@"\
//                           <html>\
//                           <body style='margin:0px;padding:0px;'>\
//                           <script type='text/javascript' src='http://www.youtube.com/iframe_api'></script>\
//                           <script type='text/javascript'>\
//                           function onYouTubeIframeAPIReady()\
//                           {\
//                           ytplayer=new YT.Player('playerId',{events:{onReady:onPlayerReady}})\
//                           }\
//                           function onPlayerReady(a)\
//                           { \
//                           a.target.playVideo(); \
//                           }\
//                           </script>\
//                           <iframe id='playerId' type='text/html' width='%d' height='%d' src='http://www.youtube.com/embed/%@?enablejsapi=1&rel=0&playsinline=1&autoplay=1' frameborder='0'>\
//                           </body>\
//                           </html>", width, height, needle];
//    [self.webView loadHTMLString:embedHTML baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",_arrVideoUrl]]];
//    
//  }
//
//- (void)videoPlayBackDidFinish:(NSNotification *)notification {
//    
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
//    
//    // Stop the video player and remove it from view
//    [_moviePlayer stop];
//    [_moviePlayer.view removeFromSuperview];
//    _moviePlayer = nil;
//    
// }
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}


@end
