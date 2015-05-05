//
//  VSWebHandler.h
//  PhotoStack
//
//  Created by Vakul on 11/06/14.
//  Copyright (c) 2014 iAppTechnologies. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SHOW_NO_INTERNET_ALERT(_DELEGATE) [[[UIAlertView alloc] initWithTitle:@"" message:@"Please check your internet connection. It might be slow or disconnected." delegate:_DELEGATE cancelButtonTitle:@"OK" otherButtonTitles:nil] show]

typedef void (^VSWebRequestFinishBlock) (id response, NSError *error);

@interface VSWebHandler : NSObject

+(VSWebHandler *)sharedWebHandler;
-(void)startRequestWithCompletionBlock:(VSWebRequestFinishBlock)block;
-(void)cancelRequest;


// GET METHODS
-(void)loadVideosForURL:(NSURL *)URL;


@end
