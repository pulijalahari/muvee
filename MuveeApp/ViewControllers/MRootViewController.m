//
//  MRootViewController.m
//  Muvee
//
//  Created by iApp on 12/1/14.
//  Copyright (c) 2014 iAppTechnologies. All rights reserved.
//

#import "MRootViewController.h"
#import "JSONModelLib.h"
#import "SearchResultsViewController.h"
#import "MSettingViewController.h"
#import "MManageListViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>




@interface MRootViewController ()<UITextFieldDelegate, KVPasscodeViewControllerDelegate>
{
    IBOutlet UIButton *btnMPlaylist,*btnSearch;
    CGSize screenSize;
    CGFloat width;
    CGFloat y,x;
    NSMutableArray *arrayManagePlayList;
    UIImageView *imageIcon;
    UIButton *btnBack,*btnSetting;
    IBOutlet  UITextField *txtSearch;
    NSString *newPasscode;
}

@end

@implementation MRootViewController


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
     btnMPlaylist.userInteractionEnabled = YES;
     btnSetting.userInteractionEnabled = YES;
    //Get Size
    screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    self.navigationController.navigationBarHidden = YES;
    arrayManagePlayList = [NSMutableArray arrayWithCapacity:1];
    
    CGRect rect = btnMPlaylist.frame;
    CGRect rectBtnSearch = btnSearch.frame;
    CGRect rectImage = imageIcon.frame;
    CGRect rectBtnBack = btnBack.frame;
    CGRect rectBtnSetting = btnSetting.frame;
    UIImage *image;
    
   
    rectBtnBack = CGRectMake(10, 20, 13, 16);
    rect = CGRectMake((screenSize.width-270)/2, 220, 270, 36);
    rectImage = CGRectMake((screenSize.width-46)/2, 5, 46, 30);
    rectBtnSearch = CGRectMake((screenSize.width-270)/2, 130, 270, 36);
    NSLog(@"%f",(screenSize.width-270)/2);
    
    CGRect rectText = txtSearch.frame;
    rectText = CGRectMake(25, 76, screenSize.width-50, 36);

    if([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPad)
    {
        rectImage = CGRectMake((screenSize.width-60)/2, 10, 91, 60);
        image=[UIImage imageNamed:@"icon1@2x"];
                 rectBtnSearch = CGRectMake((screenSize.width-500)/2, 260, 500, 50) ;
        rectText = CGRectMake(30, 122, screenSize.width-60, 50);
        rect = CGRectMake((screenSize.width-500)/2, 350,  500, 50) ;
        NSLog(@"%f",screenSize.width);
        NSLog(@"%f",screenSize.width-500);

        rectBtnSetting = CGRectMake(18, 18, 58, 45);
        
    }
    
    txtSearch.frame = rectText;

    btnSetting = [[UIButton alloc]initWithFrame:rectBtnSetting];
    btnMPlaylist = [[UIButton alloc]initWithFrame:rect];
    btnSearch = [[UIButton alloc]initWithFrame:rectBtnSearch];

    if([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPad)
    {
       
        [btnSetting addTarget:self action:@selector(settingPressed:) forControlEvents:UIControlEventTouchUpInside];
                
        [btnSetting setBackgroundImage:[UIImage imageNamed:@"setting@2x"] forState:UIControlStateNormal];
        [btnSearch setBackgroundImage:[UIImage imageNamed:@"search_btn@2x"] forState:UIControlStateNormal];
        [btnMPlaylist setBackgroundImage:[UIImage imageNamed:@"mamage@2x"] forState:UIControlStateNormal];
    }
    else
    {
        [btnSetting setBackgroundImage:[UIImage imageNamed:@"setting"] forState:UIControlStateNormal];
        [btnSearch setBackgroundImage:[UIImage imageNamed:@"search_btn"] forState:UIControlStateNormal];
        [btnMPlaylist setBackgroundImage:[UIImage imageNamed:@"mamage"] forState:UIControlStateNormal];
        image=[UIImage imageNamed:@"icon1"];
    }
    
    [self.view addSubview:btnSetting];
    [btnSearch addTarget:self action:@selector(searchButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btnSearch];
    
    imageIcon =[[UIImageView alloc] initWithFrame:rectImage];
    [self.view addSubview:imageIcon];
    imageIcon.image=image;
    
    [btnMPlaylist addTarget:self action:@selector(PlaylistButton) forControlEvents:UIControlEventTouchUpInside];
    [btnMPlaylist setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:btnMPlaylist];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    btnMPlaylist.userInteractionEnabled = YES;
    btnSetting.userInteractionEnabled = YES;
   //
 //btnSetting.userInteractionEnabled = YES;
    txtSearch.text = @"";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    @try {
        screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        
        //
        self.navigationController.navigationBarHidden = YES;
        
        
        //orientation Notification
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleOrientationChangeNotification) name: UIApplicationDidChangeStatusBarOrientationNotification object: nil];
        

    }
    @catch (NSException *exception) {
        
    }
  
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    btnSetting.userInteractionEnabled = YES;
}
#pragma mark- Method/IBAction
-(void)PlaylistButton
{
    btnMPlaylist.userInteractionEnabled = NO;
    btnSetting.userInteractionEnabled = NO;
  //  btnSetting.enabled = NO;
    [txtSearch resignFirstResponder];
    MManageListViewController *MMLVC;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        MMLVC= [[MManageListViewController alloc] initWithNibName:@"MManageListViewController" bundle:nil];
    }
    else
    {
        MMLVC= [[MManageListViewController alloc] initWithNibName:@"MManageListViewController_ipad" bundle:nil];
    }
    
    MMLVC.arrManageList = [AppDelegate sharedDelegate].playlist;
    

    if([MMLVC.arrManageList containsObject:@"LOCAL VIDEOS"])
    {
        [MMLVC.arrManageList removeObject:@"LOCAL VIDEOS"];
    }

    
    [self.navigationController pushViewController:MMLVC animated:YES];
    
}


-(void)searchButton
{
    [txtSearch resignFirstResponder];
    NSString *t = [txtSearch.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if(t.length <= 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Muvee" message:@"Please enter text." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
    else
    {
        [txtSearch resignFirstResponder];
        NSString *strSearch = [txtSearch.text stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceCharacterSet]];
        
        //  arrayManagePlayList =[[NSUserDefaults standardUserDefaults]valueForKey:@"ArrayManageplayList"];
        
        if (![arrayManagePlayList containsObject:strSearch]) {
            [arrayManagePlayList addObject:strSearch];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
            [defaults setValue:arrayManagePlayList forKey:@"ArrayManageplayList"];
            [defaults synchronize];
        }
        
        
        if (![[AppDelegate sharedDelegate].playlist containsObject:strSearch]) {
            
            // Save it to array
            [[AppDelegate sharedDelegate].playlist addObject:strSearch];
            
            
            // Save it to local db
            [[MDatabase sharedDatabase] saveSearchKeyToPlaylist:strSearch];
            
            
            if ([[DataStorage sharedStorage] isInternetAvailable]) {
                
                // Check this user should not be exist in database
                PFQuery *_query = [PFQuery queryWithClassName:@"Playlist"];
                [_query whereKey:@"email" equalTo:[AppDelegate sharedDelegate].user.email];
                [_query whereKey:@"searchedKey" equalTo:strSearch];
                
                [_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    
                    BOOL canSave = NO;
                    if ([objects isKindOfClass:[NSArray class]]) {
                        if ([objects count] == 0)
                            canSave = YES;
                        else
                            canSave = NO;
                    }
                    else {
                        canSave = YES;
                    }
                    
                    if (canSave) {
                        
                        // Save it to Parse
                        PFObject *_object = [PFObject objectWithClassName:@"Playlist"];
                        [_object setObject:[AppDelegate sharedDelegate].user.email forKey:@"email"];
                        [_object setObject:strSearch forKey:@"searchedKey"];
                        
                        //                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults] ;
                        //                        [defaults setValue:strSearch forKey:@"searchedKey"];
                        //                        [defaults synchronize];
                        //                        NSLog(@"%@",[defaults valueForKey:@"searchedKey"]);
                        
                        [_object saveInBackground];
                    }
                    
                }];
                
            }
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
        
        
        SRVC.StrSearch=strSearch;
        //  SRVC.arrayManageListSRVC = arrayManagePlayList;
        
        SRVC.arrayManageListSRVC = [AppDelegate sharedDelegate].playlist;
        
        // [self presentViewController:SRVC animated:YES completion:nil];
        [self.navigationController pushViewController:SRVC animated:YES];
    }
    
}




-(IBAction)settingPressed:(id)sender
{
    btnMPlaylist.userInteractionEnabled = NO;
    btnSetting.userInteractionEnabled = NO;
    [txtSearch resignFirstResponder];
    [self gotoSettings];
   
}

-(void)sizeIphoneButton
{
    CGRect rectImage = imageIcon.frame;
    rectImage = CGRectMake((screenSize.width-46)/2, 5, 46, 30);
    imageIcon.frame = rectImage;
    
    CGRect rect = btnMPlaylist.frame;
    rect = CGRectMake((screenSize.width-270)/2, 220, 270, 36);
    btnMPlaylist.frame = rect;
    
    CGRect rectText = txtSearch.frame;
    rectText = CGRectMake(25, 76, screenSize.width-50, 36);
    txtSearch.frame = rectText;
    
    CGRect rectBtnSearch = btnSearch.frame;
    rectBtnSearch = CGRectMake((screenSize.width-270)/2, 130, 270, 36);
    btnSearch.frame = rectBtnSearch;
    }

-(void)sizeIpadButton
{
    screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
 
    
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    {
    }
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
    {
    }
    CGRect rectText = txtSearch.frame;
    rectText = CGRectMake(30, 122, screenSize.width-60, 50);
    txtSearch.frame = rectText;
   
    CGRect rectImage = imageIcon.frame;
    rectImage = CGRectMake((screenSize.width-60)/2, 10, 91, 60);
    imageIcon.frame = rectImage;
    
    CGRect rect = btnMPlaylist.frame;
    rect = CGRectMake((screenSize.width-500)/2, 350,  500, 50) ;
    NSLog(@"%f",screenSize.width);
    NSLog(@"%f",(screenSize.width-500)/2);
    btnMPlaylist.frame = rect;
    
    CGRect rectBtnSearch = btnSearch.frame;
    rectBtnSearch = CGRectMake((screenSize.width-500)/2, 260, 500, 50) ;
    btnSearch.frame = rectBtnSearch;
    
    CGRect rectBtnSetting = btnSetting.frame;
    rectBtnSetting = CGRectMake(18, 18, 58, 45);
    btnSetting.frame = rectBtnSetting;
}

-(void)gotoSettings {
     btnSetting.userInteractionEnabled = NO;
    MSettingViewController *MSVC;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        //iphone
        MSVC = [[MSettingViewController alloc] initWithNibName:@"MSettingViewController" bundle:nil];
    }
    else
    {
        //ipad
        MSVC = [[MSettingViewController alloc] initWithNibName:@"MSettingViewController_ipad" bundle:nil];
    }
    
    [self.navigationController pushViewController:MSVC animated:YES];
    // btnSetting.userInteractionEnabled = TRUE;
}

#pragma mark-orientation Notification
-(void)handleOrientationChangeNotification
{
    @try {
        screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            //iphone
            [self sizeIphoneButton];
        }
        else
        {
            //ipad
            [self sizeIpadButton];
        }

    }
    @catch (NSException *exception) {
        
    }
   
 }

#pragma mark-PassCode Delegate

-(void)passcodeController:(KVPasscodeViewController *)controller passcodeEntered:(NSString *)passCode {
    
    NSString *passcode = [AppDelegate sharedDelegate].settings.passcode;
    if ([passcode isEqualToString:@""] && newPasscode.length == 0) {
        
        newPasscode = passCode;
        [controller resetWithAnimation:KVPasscodeAnimationStyleConfirm];
        controller.instructionLabel.text = NSLocalizedString(@"Enter conferm passcode.", @"");
    }
    else
    {
        if (newPasscode.length > 0) {
        
            if ([newPasscode isEqualToString:passCode]) {
                
                // New Passcode set
                controller.instructionLabel.text = NSLocalizedString(@"Please passcode set.", @"");
                [AppDelegate sharedDelegate].settings.passcode = newPasscode;
                [[MDatabase sharedDatabase] saveUserSettings:[AppDelegate sharedDelegate].settings];
                
                [self dismissViewControllerAnimated:NO completion:NULL];
                [self gotoSettings];
                
            }
            else {
                
                // Confirm Passcode don't match
                 controller.instructionLabel.text = NSLocalizedString(@"Confirm Passcode don't match.", @"");
                newPasscode = @"";
                [controller resetWithAnimation:KVPasscodeAnimationStyleConfirm];
            }
        }
        else
        {
            if ([passcode isEqualToString:passCode]) {
                
                [self dismissViewControllerAnimated:NO completion:NULL];
                [self gotoSettings];
            }
            
            else
            {
             [controller resetWithAnimation:KVPasscodeAnimationStyleInvalid];   controller.instructionLabel.text = NSLocalizedString(@"Invalid passcode.", @"");
                
            }

        }
    }
    
}



#pragma mark-UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([alertView tag ] == 11)
    {
        [self dismissViewControllerAnimated:NO completion:NULL];
    }
}

#pragma mark-UISearchBar Delegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.text = @" ";
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}// return NO to not resign first responder

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchButton];
}

#pragma mark- UITouchEvent Method

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txtSearch resignFirstResponder];
}

#pragma  mark - UITextField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    txtSearch.text = @"";
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [txtSearch resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
       [self searchButton];
       return YES;
}
#pragma mark - Hide Status Bar
- (BOOL)prefersStatusBarHidden
{
    return YES;
}


//# pragma mark - Orientation related methods
//// IOS < 6.0
//-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
//{
//    if ([[UIDevice currentDevice]userInterfaceIdiom]== UIUserInterfaceIdiomPad)
//    {
//        [self deviceChangeForOrientation:toInterfaceOrientation];
//        return YES;
//    }
//    else
//    {
//        return NO;
//    }
//}
//
//// IOS >= 6
//-(BOOL)shouldAutorotate
//{
//    return NO;
//}
//
//-(NSUInteger)supportedInterfaceOrientations
//{
//    if ([[UIDevice currentDevice]userInterfaceIdiom]== UIUserInterfaceIdiomPad)
//    {
//        return UIInterfaceOrientationPortrait;
//    }
//    else
//    {
//        return UIInterfaceOrientationMaskPortrait;
//    }
//}
//
//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration NS_AVAILABLE_IOS(3_0)
//{
//    [self deviceChangeForOrientation:toInterfaceOrientation];
//    
//}

-(void)deviceChangeForOrientation:(UIInterfaceOrientation)orientation
{
}

- (void) deviceRotatedToPortraitMode
{
}

- (void) deviceRotatedToLandscapeMode {
}


@end
