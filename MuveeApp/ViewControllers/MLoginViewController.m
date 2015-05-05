
//
//  MLoginViewController.m
//  Muvee
//
//  Created by iApp on 12/2/14.
//  Copyright (c) 2014 iAppTechnologies. All rights reserved.
//

#import "MLoginViewController.h"
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "MRootViewController.h"
#import "ActivityView.h"
#import "DataStorage.h"
#import "VSWebHandler.h"

//#define GoogleClientID     @"776423537981.apps.googleusercontent.com"
//#define GoogleClientSecret @"v59k14jTicRLJzqCYeUZtrps"

#define GoogleClientID  @"71105402497-g2dctvvj4fttb23gtd1vn2qt1bl6kl04.apps.googleusercontent.com"
#define GoogleClientSecret @"dS2I0ZagBSbejM91hpeADCt5"


@interface MLoginViewController ()<GPPSignInDelegate>
{
    IBOutlet UIButton *btnLogin;

    ActivityView *activity;
    CGSize screenSize;
    CGFloat y;
    UIImageView *imageIcon;
}

@end

@implementation MLoginViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //get screen size
    
    screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    CGRect rect = btnLogin.frame;
    CGRect rectImage = imageIcon.frame;
    
    self.navigationController.navigationBarHidden =YES;
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        
    {
        rectImage = CGRectMake((screenSize.width-68)/2, 7, 68, 52);
        rect = CGRectMake((screenSize.width-283)/2, (screenSize.height)/3, 283, 43);
    }
    else
    {
        rectImage = CGRectMake((screenSize.width-103)/2, 7, 135, 103);
        rect = CGRectMake((screenSize.width-500)/2, (screenSize.height)/3, 500, 55);
    }
    
    btnLogin = [[UIButton alloc]initWithFrame:rect];
    [btnLogin addTarget:self action:@selector(loginButton:) forControlEvents:UIControlEventTouchUpInside];
    [btnLogin setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [btnLogin setBackgroundImage:[UIImage imageNamed:@"button@2x"] forState:UIControlStateNormal];
    }
    
    [btnLogin setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:btnLogin];
    
    //image
    imageIcon =[[UIImageView alloc] initWithFrame:rectImage];
    [self.view addSubview:imageIcon];
    UIImage *image=[UIImage imageNamed:@"iconLogin"];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        image=[UIImage imageNamed:@"iconLogin@2x"];
        
    }
    imageIcon.image=image;

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    //orientation Notification
   [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleOrientationChangeNotification) name: UIApplicationDidChangeStatusBarOrientationNotification object: nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark- hide Status Bar
-(BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark-orientation Notification
-(void)handleOrientationChangeNotification
{
    screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    activity.center = self.view.center;
    
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

#pragma  mark- Methods/IBActions
-(void)sizeIphoneButton
 {

    CGRect rect = btnLogin.frame;
    rect = CGRectMake((screenSize.width-283)/2, (screenSize.height)/3, 283, 43);
    btnLogin.frame = rect;
    
    CGRect rectImage = imageIcon.frame;
    rectImage = CGRectMake((screenSize.width-68)/2, 7, 68, 52);
    imageIcon.frame = rectImage;

   }

-(void)sizeIpadButton
{
    NSLog(@"%f",screenSize.width);
    
    CGRect rect = btnLogin.frame;
    rect = CGRectMake((screenSize.width-500)/2, (screenSize.height)/3, 500, 55);
    btnLogin.frame = rect;
    
    CGRect rectImage = imageIcon.frame;
    rectImage = CGRectMake((screenSize.width-135)/2, 7, 135, 103);
    imageIcon.frame = rectImage;
}

-(IBAction)loginButton:(id)sender
{
    if ([[DataStorage sharedStorage] isInternetAvailable]) {
        
        GPPSignIn *signIn = [GPPSignIn sharedInstance];
        
        signIn.shouldFetchGooglePlusUser = YES;
        signIn.shouldFetchGoogleUserEmail = YES;
        
        signIn.clientID = GoogleClientID;
        
        signIn.scopes = @[@"profile"];
        signIn.delegate = self;
        
        if (signIn.authentication == nil)
        {
//            if (![self.view.subviews containsObject:activity]) {
//            [self showActivity];
//        }
            [self showActivity];
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0lu);
            dispatch_async(queue, ^{
                 [signIn authenticate];
            });
           
        }
        else {
            [self getUserDetail];
        }

    }
    else {
        SHOW_NO_INTERNET_ALERT(nil);
    }
    
}

-(void)cancel
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark-Account Detail

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error {
    
    if (error) {
        NSLog(@"%@", error.localizedDescription);
        [self hideActivity];
    }
    else {

        @try {
            [self getUserDetail];
        }
        @catch (NSException *exception) {
            [self.navigationController popViewControllerAnimated:NO ];
           //[self dismissViewControllerAnimated:NO completion:NULL];
        }
    }
}

-(void)getUserDetail {
    
    GTLPlusPerson *person = [GPPSignIn sharedInstance].googlePlusUser;
    
    NSLog(@"Name: %@", person.displayName);
    NSLog(@"Gender:%@", person.gender);
    NSLog(@"Email:%@", [GPPSignIn sharedInstance].userEmail);
    
   
    
    NSString *userEmail = [GPPSignIn sharedInstance].userEmail;
    
    // Save user to local database
    MUser *user = [[MUser alloc] init];
    user.email = userEmail;
    user.name = person.displayName;
    user.gender = person.gender;
    
    [[AppDelegate sharedDelegate] setUser:user];
    [[MDatabase sharedDatabase] saveUser:user];
    
    // Check this user should not be exist in database
    PFQuery *_query = [PFQuery queryWithClassName:@"Users"];
    [_query whereKey:@"email" equalTo:userEmail];
    [_query findObjectsInBackgroundWithBlock:^(NSArray *_objects, NSError *error) {
        
        
        if (error) {
            [self hideActivity];
            [[[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Login falied please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            return;
        }
        else {
            
            
            BOOL canSave = NO;
            if ([_objects isKindOfClass:[NSArray class]]) {
                if ([_objects count] == 0)
                    canSave = YES;
                else
                    canSave = NO;
            }
            else {
                canSave = YES;
            }
            
            if (canSave) {
                
                // Save User to Parse
                PFObject *_object = [PFObject objectWithClassName:@"Users"];
                [_object setObject:userEmail forKey:@"email"];
                [_object setObject:person.displayName forKey:@"name"];
                [_object setObject:person.gender forKey:@"gender"];
                [_object saveInBackground];
            }
            
            
            // MRootViewController *MRVC=[[MRootViewController alloc]initWithNibName:@"MRootViewController" bundle:nil];
            // [self.navigationController pushViewController:MRVC animated:YES];
            
            
            if ([[AppDelegate sharedDelegate] user] && [[DataStorage sharedStorage] isInternetAvailable]) {
                
                // Find user playlist from Database
                PFQuery *_query = [PFQuery queryWithClassName:@"Playlist"];
                [_query whereKey:@"email" equalTo:[AppDelegate sharedDelegate].user.email];
                [_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    
                    if ([objects isKindOfClass:[NSArray class]] && [objects count] > 0) {
                        
                        for (PFObject *obj in objects) {
                            
                            NSString *key = [obj objectForKey:@"searchedKey"];
                            if (![[AppDelegate sharedDelegate].playlist containsObject:key]) {
                                
                                [[[AppDelegate sharedDelegate] playlist] addObject:key];
                                [[MDatabase sharedDatabase] saveSearchKeyToPlaylist:key];
                            }
                        }
                    }
                    
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                      //  [self dismissViewControllerAnimated:NO completion:NULL];
                        //edit by tijender
                        [self.navigationController popViewControllerAnimated:NO ];
                        
                    }];
                    [self hideActivity];
                    
                    
                }];
            }
            else {
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                  //  [self dismissViewControllerAnimated:NO completion:NULL];
                    //edit by tijender
                    [self.navigationController popViewControllerAnimated:NO ];
                }];
                [self hideActivity];
            }
            
          //  [self hideActivity];

        }

    }];
    
 }


#pragma mark- Show Activity
-(void)showActivity
{
    self.view.userInteractionEnabled = NO;
    if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        activity = [ActivityView activityView];
        [activity setTitle:NSLocalizedString(@"Loading ...", nil)];
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
        activity.center = self.view.center;
    }
}

#pragma mark- Hide Activity
-(void)hideActivity
{
    self.view.userInteractionEnabled = YES;
    [activity hideActivity];
}


@end
