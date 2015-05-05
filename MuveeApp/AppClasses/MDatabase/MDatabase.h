//
//  MDatabase.h
//  MuveeApp
//
//  Created by iApp on 15/12/14.
//  Copyright (c) 2014 iApp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

extern NSString *const mild;
extern NSString *const moderate;
extern NSString *const strict;

extern NSString *const videoId;
extern NSString *const videoTitle;
extern NSString *const videoDescription;
extern NSString *const videoThumbnail;
extern NSString *const videoDuration;


@class MDatabase, MUserSettings, MUser;

@interface MDatabase : NSObject

+(MDatabase *)sharedDatabase;

-(void)saveUser:(MUser *)user;
-(void)saveSearchKeyToPlaylist:(NSString *)key;
-(void)saveUserSettings:(MUserSettings *)settings;

-(void)deleteUser;
-(void)deleteUserSettings;
-(void)deleteLocalPlaylist;


-(MUser *)currentUser;
-(MUserSettings *)currentUserSettings;
-(NSArray *)localPlaylist;
-(void)updatePlaylist:(NSArray *)playlist;


-(BOOL)isCapchaLockEnable;
-(void)setCapchaLockEnable:(BOOL)enabled;

-(void)savePasscode:(NSString *)passcode forUser:(NSString *)userEmail;
-(void)deletePasscode:(NSString *)passcode forUser:(NSString *)userEmail;
-(void)clearAllPasscode;
-(NSString *)passcodeForUser:(NSString *)userEmail;


// Video Cache
-(NSDictionary *)videosInfoForKey:(NSString *)key;
-(void)saveVideosInfo:(NSDictionary *)videosInfo forKey:(NSString *)key;
-(void)clearVideoCache;

@end

@interface MUserSettings : NSObject

@property (strong, nonatomic) NSString *passcode;
@property (nonatomic) BOOL localVideos;
@property (nonatomic) BOOL kidMode;
@property (strong, nonatomic) NSString *timeoutMinutes;
@property (strong, nonatomic) NSString *contentFilteringBy;

@end

@interface MUser : NSObject

@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *gender;

@end
