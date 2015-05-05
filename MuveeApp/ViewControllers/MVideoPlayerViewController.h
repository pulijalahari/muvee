//
//  MVideoPlayerViewController.h
//  Muvee
//
//  Created by iApp on 04/12/14.
//  Copyright (c) 2014 iAppTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LBYouTubePlayerViewController.h"

@interface MVideoPlayerViewController : UIViewController<LBYouTubePlayerControllerDelegate>
{
    MPMoviePlayerViewController *moviePlayerViewController;
    LBYouTubePlayerViewController *lbYoutubePlayerVC;
}
@property (strong ,nonatomic) NSArray *arrVideoUrl;
@property (strong, nonatomic) UIWebView *webView;
@property (strong ,nonatomic) NSString *strTitle;


@end
