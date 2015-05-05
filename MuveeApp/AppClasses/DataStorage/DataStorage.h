//
//  DataStorage.h
//  PhotoStack
//
//  Created by Vakul on 12/19/13.
//  Copyright (c) 2013 iAppTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import "DataStorage.h"




@interface DataStorage : NSObject

+(DataStorage *)sharedStorage;

@property (nonatomic) BOOL isFromGallery;

-(BOOL)isInternetAvailable;
-(BOOL)isIOS7;
-(BOOL)isIPhone5;

-(BOOL)isCameraAvailable;
-(BOOL)isPhotoGalleryAvailable;
-(BOOL)validateEmail:(NSString *)inputText;

-(UIImage *)imageFromView:(UIView *)view;
-(UIImage *)backgroundImage;


@end
