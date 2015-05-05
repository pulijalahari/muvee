//
//  MDatabase.m
//  MuveeApp
//
//  Created by iApp on 15/12/14.
//  Copyright (c) 2014 iApp. All rights reserved.
//

#import "MDatabase.h"

/*
 
 @property (strong, nonatomic) NSString *passcode;
 @property (nonatomic) BOOL localVideos;
 @property (nonatomic) BOOL kidMode;
 @property (strong, nonatomic) NSString *timeoutMinutes;
 @property (strong, nonatomic) NSString *contentFilteringBy;

 
 */



#define EMAIL       @"email"
#define NAME        @"name"
#define GENDER      @"gender"

#define PLAYLIST @"playlist"

#define PASSCODE                @"passcode"
#define LOCAL_VIDEOS            @"localVideos"
#define KID_MODE                @"kidMode"
#define TIMEOUT_MINUTES         @"timeoutMinutes"
#define CONTENT_FILTERING_BY    @"contentFilteringBy"

#define CURRENT_USER          @"user"
#define CURRENT_USER_SETTINGS @"userSettings"

#define CAPCHA_ENABLED @"capchaEnabled"

#define VIDEO_CACHE @"videoCache"


NSString *const mild = @"none";
NSString *const moderate = @"moderate";
NSString *const strict = @"strict";



NSString *const videoId = @"videoId";
NSString *const videoTitle = @"videoTitle";;
NSString *const videoDescription = @"videoDescription";;
NSString *const videoThumbnail = @"videoThumbnail";;
NSString *const videoDuration = @"videoDuration";;

@implementation MDatabase

static MDatabase *mdb = nil;
+(MDatabase *)sharedDatabase {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mdb = [[MDatabase alloc] init];
    });
    
    return mdb;
}

-(void)saveUser:(MUser *)user {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *userDetail = @{EMAIL: user.email,
                                 NAME: user.name,
                                 GENDER: user.gender};
    
    [defaults setObject:userDetail forKey:CURRENT_USER];
    
    [defaults synchronize];
}

-(void)saveSearchKeyToPlaylist:(NSString *)key {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *playlist = [[self localPlaylist] mutableCopy];
    [playlist addObject:key];
    [defaults setObject:playlist forKey:PLAYLIST];
    [defaults synchronize];
}

-(void)saveUserSettings:(MUserSettings *)settings {
 
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDictionary *userSettings = @{PASSCODE: settings.passcode,
                                 LOCAL_VIDEOS: @(settings.localVideos),
                                 KID_MODE: @(settings.kidMode),
                                 TIMEOUT_MINUTES: settings.timeoutMinutes,
                                 CONTENT_FILTERING_BY: settings.contentFilteringBy};
    
    [defaults setObject:userSettings forKey:CURRENT_USER_SETTINGS];
    [defaults synchronize];
}

-(void)deleteUser {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:CURRENT_USER];
    [defaults synchronize];
}


-(void)deleteLocalPlaylist {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:PLAYLIST];
    [defaults synchronize];
}


-(void)deleteUserSettings {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:CURRENT_USER_SETTINGS];
    [defaults synchronize];
}


-(MUser *)currentUser {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *user = [defaults objectForKey:CURRENT_USER];
    if (user) {
    
        MUser *user1 = [[MUser alloc] init];
        user1.email = [user objectForKey:EMAIL];
        user1.name = [user objectForKey:NAME];
        user1.gender = [user objectForKey:GENDER];
        return user1;
    }
    
    return nil;
}

-(NSArray *)localPlaylist {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *playlist = [defaults objectForKey:PLAYLIST];
    
    if (![playlist isKindOfClass:[NSArray class]]) {
       playlist = [[NSMutableArray alloc] init];
    }
    
    return playlist;
}


-(void)updatePlaylist:(NSArray *)playlist {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (playlist == nil)
        [defaults setObject:[[NSMutableArray alloc] init] forKey:PLAYLIST];
    else
        [defaults setObject:playlist forKey:PLAYLIST];
    
    
    [defaults synchronize];
}


-(MUserSettings *)currentUserSettings {
 
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *settings = [defaults objectForKey:CURRENT_USER_SETTINGS];
    if (settings) {
        
        MUserSettings *settings1 = [[MUserSettings alloc] init];
        settings1.passcode = [settings objectForKey:PASSCODE];
        settings1.localVideos = [[settings objectForKey:LOCAL_VIDEOS] boolValue];
        settings1.kidMode = [[settings objectForKey:KID_MODE] boolValue];
        settings1.timeoutMinutes = [settings objectForKey:TIMEOUT_MINUTES];
        settings1.contentFilteringBy = [settings objectForKey:CONTENT_FILTERING_BY];
        
        return settings1;
    }
    
    return nil;
}



-(BOOL)isCapchaLockEnable {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:CAPCHA_ENABLED];
}

-(void)setCapchaLockEnable:(BOOL)enabled {
 
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:enabled forKey:CAPCHA_ENABLED];
    [defaults synchronize];
}


#pragma mark - Passcode
-(void)savePasscode:(NSString *)passcode forUser:(NSString *)userEmail {

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *passcodes = [defaults objectForKey:@"passcode"];
    
    if (![passcodes isKindOfClass:[NSArray class]] || passcodes == nil) {
        passcodes = [[NSMutableArray alloc] init];
        [passcodes addObject:@{userEmail: passcode}];
    }
    else {
        passcodes = [passcodes mutableCopy];
        NSMutableDictionary *d = nil;
        NSInteger index = 0;
        for (NSDictionary *dict in passcodes) {
            if ([[[dict allKeys] objectAtIndex:0] isEqualToString:userEmail]) {
                d = [dict mutableCopy];
                index = [passcodes indexOfObject:dict];
                break;
            }
        }
        
        if (d) {
            [d setObject:passcode forKey:userEmail];
            [passcodes replaceObjectAtIndex:index withObject:d];
        }
        else {
           [passcodes addObject:@{userEmail: passcode}];
        }
    }
    
    
    [defaults setObject:passcodes forKey:@"passcode"];
    [defaults synchronize];
}

-(void)deletePasscode:(NSString *)passcode forUser:(NSString *)userEmail {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *passcodes = [defaults objectForKey:@"passcode"];

    
    NSMutableDictionary *d = nil;
    for (NSDictionary *dict in passcodes) {
        if ([[[dict allKeys] objectAtIndex:0] isEqualToString:userEmail]) {
            d = [dict mutableCopy];
            break;
        }
    }

    if (d) {
        passcodes = [passcodes mutableCopy];
        [passcodes removeObject:d];
        
        [defaults setObject:passcodes forKey:@"passcode"];
        [defaults synchronize];
    }
}

-(void)clearAllPasscode {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"passcode"];
    [defaults synchronize];
}

-(NSString *)passcodeForUser:(NSString *)userEmail {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *passcodes = [defaults objectForKey:@"passcode"];
    
    NSMutableDictionary *d = nil;
    for (NSDictionary *dict in passcodes) {
        if ([[[dict allKeys] objectAtIndex:0] isEqualToString:userEmail]) {
            d = [dict mutableCopy];
            break;
        }
    }
    
    if (d) {
       return [[d allValues] objectAtIndex:0];
    }

    return nil;
}



#pragma mark - Video Cache
-(NSDictionary *)videosInfoForKey:(NSString *)key {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *videoCache = [defaults objectForKey:VIDEO_CACHE];
 
    if (videoCache) {
        
        return [videoCache objectForKey:key];
    }
    else {
        return nil;
    }
}

-(void)saveVideosInfo:(NSDictionary *)videosInfo forKey:(NSString *)key {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *videoCache = [defaults objectForKey:VIDEO_CACHE];
    
    if (videoCache) {
        videoCache = [videoCache mutableCopy];
    }
    else {
        videoCache = [[NSMutableDictionary alloc] init];
    }
    
    [videoCache setObject:videosInfo forKey:key];
    [defaults setObject:videoCache forKey:VIDEO_CACHE];
    [defaults synchronize];
}

-(void)clearVideoCache {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:VIDEO_CACHE];
    [defaults synchronize];
}



@end


@implementation MUserSettings
@end

@implementation MUser
@end