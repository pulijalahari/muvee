//
//  SearchResultsViewController.h
//  Muvee
//
//  Created by iApp on 12/1/14.
//  Copyright (c) 2014 iAppTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPullToRefresh.h"
#import <MediaPlayer/MediaPlayer.h>
#import "LBYouTubePlayerViewController.h"



@interface SearchResultsViewController : UIViewController<CustomPullToRefreshDelegate,UITableViewDelegate,UITableViewDataSource,LBYouTubePlayerControllerDelegate>
{
    IBOutlet UITableView *tableViewSearch,*tableViewChild;
    CustomPullToRefresh *_ptr;
     CustomPullToRefresh *_ptrChild;
    MPMoviePlayerViewController *moviePlayerViewController;
    LBYouTubePlayerViewController *lbYoutubePlayerVC;
    MPMoviePlayerController *playerController;

}
- (void) endSearch;
@property (strong ,nonatomic) NSString *StrSearch;
@property (strong , nonatomic) NSMutableArray *arrayManageListSRVC;
@property (nonatomic) NSInteger index;


-(void)showActivity;
-(void)hideActivity;

@end
