
//
//  AppDelegate.m
//  muvee
//
//  Created by iApp on 12/1/14.
//  Copyright (c) 2014 iAppTechnologies. All rights reserved.
//

#import "AppDelegate.h"
#import "MRootViewController.h"
#import "MLoginViewController.h"
#import <GooglePlus/GooglePlus.h>
#import <Parse/Parse.h>
#import "MCaptchaViewController.h"
#import "SearchResultsViewController.h"
#import "MhelpViewController.h"



@interface AppDelegate ()
{
    int timerSet;
   

}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    timerSet =0;
    _timerAppLock = [[NSTimer alloc]init];
    
      id rootViewController;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        rootViewController=[[MRootViewController alloc]initWithNibName:@"MRootViewController" bundle:nil];
    }
    else
    {
        rootViewController=[[MRootViewController alloc]initWithNibName:@"MRootViewController_ipad" bundle:nil];
    }

    self.navigationController = [[MainNavigationViewController alloc]initWithRootViewController:rootViewController];
    
    self.window.rootViewController = self.navigationController;
    
    [self.window makeKeyAndVisible];
    
    
    // Parse Initialization
    [Parse setApplicationId:@"zRH1jvUSdIY2jPf2xlNnJKOb0jl1TFa0THaVTQOk" clientKey:@"vRcKym2VjDKYRDw1dUcEdnFmkzPTwqNZUnNUe6PX"];

    MUser *u = [[MDatabase sharedDatabase] currentUser];
    if (u == nil)
    { 
            [self showLoginScreen];
    }
    else
    {
        [[AppDelegate sharedDelegate] setUser:u];
    }
    
    MUserSettings *s = [[MDatabase sharedDatabase] currentUserSettings];
    if (s == nil) {
        
        // Default Dettings
        s = [[MUserSettings alloc] init];
        s.passcode = @"";
        s.localVideos = NO;
        s.kidMode = YES;
        s.timeoutMinutes = @"30";
        s.contentFilteringBy = strict;
        [[NSUserDefaults standardUserDefaults] setValue:@"30 minutes" forKey:@"TimeSet"];
        [[NSUserDefaults standardUserDefaults]synchronize];

    }
    
    [[AppDelegate sharedDelegate] setSettings:s];
    
    NSMutableArray *playtlist = [[MDatabase sharedDatabase] localPlaylist].mutableCopy;
    if (playtlist == nil)
        playtlist = [[NSMutableArray alloc] init];
    [[AppDelegate sharedDelegate] setPlaylist:playtlist];
    
    
    if ([[MDatabase sharedDatabase] isCapchaLockEnable]) {
        
        MCaptchaViewController *MCVC =[[MCaptchaViewController alloc] initWithNibName:@"MCaptchaViewController" bundle:nil];
        MCVC.hideCancel = YES;
        [self.navigationController pushViewController:MCVC animated:NO];
    }

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
   
    
    
    [self.timerAppLock invalidate];
    self.timerAppLock = nil;
    
    self.isPlayerPlaying = NO;
    if([AppDelegate sharedDelegate].settings.kidMode  == YES)
    {
        [self timerStart];
    }
    
  
    //NSString *lastSearchedKey = [[AppDelegate sharedDelegate].playlist lastObject];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastSearchedKey = [defaults valueForKey:@"lastSearchTitleStr"];
    [defaults synchronize];
   //  NSString *lastSearchedKey = [AppDelegate sharedDelegate].lastSearchTitle;
    NSLog(@"lastSearchedKey =%@",lastSearchedKey);

    if (lastSearchedKey != nil && lastSearchedKey.length != 0) {
        
        id rootViewController;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            rootViewController=[[MRootViewController alloc]initWithNibName:@"MRootViewController" bundle:nil];
        }
        else
        {
            rootViewController=[[MRootViewController alloc]initWithNibName:@"MRootViewController_ipad" bundle:nil];
        }
        
        
        
        SearchResultsViewController *SRVC;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            SRVC =[[SearchResultsViewController alloc]initWithNibName:@"SearchResultsViewController" bundle:nil];
        }
        else
        {
            SRVC =[[SearchResultsViewController alloc]initWithNibName:@"SearchResultsViewController_ipad" bundle:nil];
        }
        
        
        
        SRVC.StrSearch=lastSearchedKey;
        NSLog(@"%@",SRVC.StrSearch);
        
        UIViewController *controller = [[AppDelegate sharedDelegate].navigationController.viewControllers lastObject];
        NSLog(@"controller:::: %@",controller);
        
                if ([controller isKindOfClass:[MhelpViewController class]]) {
                    
                    NSLog(@"HELPCONTROLLER");
                    
                }

        if([[AppDelegate sharedDelegate].isPlayer isEqualToString:@"Start"])
        {
            // use for hide activity when player opened.
        }
        else
        {
        
        if (![self.window.subviews containsObject:activity]) {
            [self showActivity];
        }
        }
       
        
        [[NSUserDefaults standardUserDefaults] setValue:@"ActivityRunning" forKey:@"BecomeActivityCall"];
        [[NSUserDefaults standardUserDefaults]synchronize];
       
        
        [self performSelector:@selector(setViewControllersNow:) withObject:@[rootViewController, SRVC] afterDelay:0.2];


    }
    if ([[MDatabase sharedDatabase] isCapchaLockEnable]) {
        
        MCaptchaViewController *MCVC =[[MCaptchaViewController alloc] initWithNibName:@"MCaptchaViewController" bundle:nil];
        MCVC.hideCancel = YES;
        [self.navigationController pushViewController:MCVC animated:NO];
    }
}


-(void)setViewControllersNow:(NSArray *)viewControllers {
    self.navigationController.viewControllers = viewControllers;
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark- Show Activity
-(void)showActivity
{
   // self.window.userInteractionEnabled = NO;
    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        activity = [ActivityView activityView];
        [activity setTitle:NSLocalizedString(@"Loading...", nil)];
        [activity setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
        [activity showBorder];
        [activity showActivityInView:self.window];
        activity.center = self.window.center;
    }
    else
    {
        activity = [ActivityView activityView];
        [activity setTitle:NSLocalizedString(@"Loading...", nil)];
        [activity setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
        [activity showBorder];
        [activity showActivityInView:self.window];
        activity.center = self.window.center;
    }
}

-(void)hideActivity
{
   // self.window.userInteractionEnabled = YES;
    [activity hideActivity];
    
}



#pragma mark - Timer
-(void)timerStart {
    
    [self.timerAppLock invalidate];
    self.timerAppLock = nil;

    
    timerSet = 0;
    
    int time = [[AppDelegate sharedDelegate] settings].timeoutMinutes.intValue;
    
  //  time = 1;
    self.timerAppLock = [NSTimer scheduledTimerWithTimeInterval:time*60 target:self selector:@selector(timerRun:) userInfo:nil repeats:YES];
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:self.timerAppLock forMode: NSDefaultRunLoopMode];
    
    NSLog(@"total time set :%d",time);
}

-(void)timerRun:(NSTimer *)timer
{
    //int time = [[AppDelegate sharedDelegate] settings].timeoutMinutes.intValue;
     //timerSet = timerSet + 5;
    //if(timerSet == (time*300))
   // {
       // NSLog(@"time check:%d ",timerSet);
       // NSLog(@"time set:%d",time);
        NSLog(@"stop");
        
        [timer invalidate];
        timer = nil;
        
        [[[AppDelegate sharedDelegate] timerAppLock] invalidate];
        [[AppDelegate sharedDelegate] setTimerAppLock:nil];

 if([[AppDelegate sharedDelegate].isPlayer isEqualToString:@"Start"])
 {
     [AppDelegate sharedDelegate].isPlayer = @"Stopp";
 }
    else
    {
        MCaptchaViewController *MCVC =[[MCaptchaViewController alloc] initWithNibName:@"MCaptchaViewController" bundle:nil];
        MCVC.hideCancel = YES;
        MCVC.checkTopArrrowPressed =@"NO";
        [[[[self.navigationController viewControllers] lastObject] navigationController] pushViewController:MCVC animated:NO];
         [[MDatabase sharedDatabase] setCapchaLockEnable:TRUE];
    }
   
    
        
    
    //}
   
   // NSLog(@"timer Run=%d",timerSet);
}


#pragma mark - Google
- (BOOL)application: (UIApplication *)application
            openURL: (NSURL *)url
  sourceApplication: (NSString *)sourceApplication
         annotation: (id)annotation {
    
    
    [self hideActivity];
    
    return [GPPURLHandler handleURL:url
                  sourceApplication:sourceApplication
                         annotation:annotation];
}


+(AppDelegate *)sharedDelegate {
    
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}





#pragma mark-Get screen size

-(CGSize)currentSize
{
    return [self sizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

-(CGSize)sizeInOrientation:(UIInterfaceOrientation)orientation
{
    CGSize size = [UIScreen mainScreen].bounds.size;
    UIApplication *application = [UIApplication sharedApplication];
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
//        size = CGSizeMake(size.height, size.width);
        size = CGSizeMake(size.width, size.height);

    }
    if (application.statusBarHidden == NO)
    {
        size.height -= MIN(application.statusBarFrame.size.width, application.statusBarFrame.size.height);
    }
    
    return size;
}




-(UIFont *)fontWithSize:(CGFloat)size bold:(BOOL)bold {
    
    if (bold) {
        UIFont *font = [UIFont fontWithName:@"Steelfish Bold" size:size];
        return font;
    }
    else {
        UIFont *font = [UIFont fontWithName:@"Steelfish" size:size];
        return font;
    }
}

//login screen
-(void)showLoginScreen {

    
    id loginController;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        loginController=[[MLoginViewController alloc]initWithNibName:@"MLoginViewController" bundle:nil];
    }
    else
    {
        loginController=[[MLoginViewController alloc]initWithNibName:@"MLoginViewController_ipad" bundle:nil];
    }
    
   // [self.navigationController presentViewController:loginController animated:NO completion:NULL];
    [self.navigationController pushViewController:loginController animated:NO];
    
    if(![[[NSUserDefaults standardUserDefaults]valueForKey:@"checkFirstTimeUserForHelp"] isEqualToString:@"YES"])
    {
        MhelpViewController *helpView = [[MhelpViewController alloc]init];
//        [self.navigationController presentViewController:helpView animated:NO completion:nil];
        [self.navigationController pushViewController:helpView animated:NO];
        [[NSUserDefaults standardUserDefaults]setValue:@"YES" forKey:@"checkFirstTimeUserForHelp"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }

    
   }
-(void)showSearchScreen {
    
    id seachController;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        seachController=[[SearchResultsViewController alloc]initWithNibName:@"SearchResultsViewController" bundle:nil];
    }
    else
    {
        seachController=[[MLoginViewController alloc]initWithNibName:@"MLoginViewController_ipad" bundle:nil];
    }
    
    [self.navigationController presentViewController:seachController animated:NO completion:NULL];
    
  
    
    
}


//- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
//    
//    return UIInterfaceOrientationMaskAll;
//
//    
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//     
//        return UIInterfaceOrientationMaskAll;
//        
//        
//        if (self.isPlayerPlaying) {
//            return UIInterfaceOrientationMaskAll;
//        }
//        
//        UIViewController *controller = [[AppDelegate sharedDelegate].navigationController.viewControllers lastObject];
//        
//        if ([controller isKindOfClass:[SearchResultsViewController class]]) {
//            
//            return UIInterfaceOrientationMaskLandscape;
//        }
//        else {
//            return UIInterfaceOrientationMaskAll;
//        }
//
//    }
//    else {
//        return UIInterfaceOrientationMaskLandscape;
//    }
//}
//Unbalanced calls to begin/end appearance transitions for <MainNavigationViewController: 0x7c16d500>.
//NSInvalidArgumentException', reason: 'Can't add self as subview'
@end
