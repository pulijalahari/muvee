//
//  AppDelegate.h
//  muvee
//
//  Created by iApp on 12/1/14.
//  Copyright (c) 2014 iAppTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MDatabase.h"
#import "MainNavigationViewController.h"
#import "ActivityView.h"

@class GTMOAuth2Authentication;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    ActivityView *activity;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainNavigationViewController *navigationController;

+(AppDelegate *)sharedDelegate;

@property (strong, nonatomic) MUser *user;
@property (strong, nonatomic) MUserSettings *settings;
@property (strong, nonatomic) NSTimer *timerAppLock;
@property (nonatomic) int minuteSet;
@property (nonatomic) BOOL isPlayerPlaying;

@property (strong, nonatomic) NSMutableArray *playlist;
@property (strong, nonatomic) NSString *currentKey,*isPlayer;
@property (nonatomic) BOOL Player;

-(CGSize)currentSize;
-(CGSize)sizeInOrientation:(UIInterfaceOrientation)orientation;
@property (strong,nonatomic) NSString *lastSearchTitle;
-(void)timerStart;

-(UIFont *)fontWithSize:(CGFloat)size bold:(BOOL)bold;
-(void)showLoginScreen;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

-(void)showActivity;
-(void)hideActivity;

@end

