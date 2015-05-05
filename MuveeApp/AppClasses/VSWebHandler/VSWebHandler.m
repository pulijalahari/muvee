//
//  VSWebHandler.m
//  PhotoStack
//
//  Created by Vakul on 11/06/14.
//  Copyright (c) 2014 iAppTechnologies. All rights reserved.
//

#import "VSWebHandler.h"
#import "ASIFormDataRequest.h"
#import "DataStorage.h"

@interface VSWebHandler ()

@property (strong, nonatomic) VSWebRequestFinishBlock requestFinishBlock;
@property (strong, nonatomic) ASIFormDataRequest *request;

-(void)configureASIRequestWithParameters:(NSDictionary *)parameters andURL:(NSString *)urlString;

@end

@implementation VSWebHandler



static VSWebHandler *handler = nil;
+(VSWebHandler *)sharedWebHandler
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[VSWebHandler alloc] init];
    });
    
    return handler;
}

#pragma mark - ASIRequest Methods
-(void)startRequestWithCompletionBlock:(VSWebRequestFinishBlock)block
{
    self.requestFinishBlock = block;
    
    if ([[DataStorage sharedStorage] isInternetAvailable])
    {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self.request startSynchronous];
    }
    else
    {
        self.request = nil;
        NSError *error = [NSError errorWithDomain:@"com.client.muvee" code:42 userInfo:@{NSLocalizedDescriptionKey:@"There is a problem to connect with server please try after 5-10 minutes."}];
        
        self.requestFinishBlock (nil, error);
        
        SHOW_NO_INTERNET_ALERT(nil);
    }
}

-(void)cancelRequest
{
    self.request=nil;
    if (self.request) {
        [self.request cancel];
        self.requestFinishBlock = nil;
    }
}


-(void)configureASIRequestWithURL:(NSURL *)URL
{
    // CANCEL PREVIOUSLY SENT REQUEST IF ANY
    [self cancelRequest];
    
    // INITIALIZE ASIFormDataRequest
    if (self.request == nil) {
        
        self.request = [[ASIFormDataRequest alloc] init];
        self.request.delegate = self;
        [self.request setRequestMethod:@"GET"];
        [self.request setDidFinishSelector:@selector(requestSucceeded:)];
        [self.request setDidFailSelector:@selector(requestFailed:)];
    }
    
    
    NSLog(@"CurrentURL: %@", URL);
    
    [self.request setURL:URL];
}


-(void)requestSucceeded:(ASIHTTPRequest *)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSString *response = [request responseString];
    NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    NSLog(@"URL: %@\nResponse: %@", request.url, result);
    
    if (self.requestFinishBlock) {
        
        if (!result) {
            NSError *error = [NSError errorWithDomain:@"com.seb.fixit" code:42 userInfo:@{NSLocalizedDescriptionKey:@"There is a problem to connect with server please try after 5-10 minutes."}];
            self.requestFinishBlock (nil, error);
        }
        else
            self.requestFinishBlock (result, nil);
    
    }
    
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    NSError *error = [request error];
    NSLog(@"URL: %@\nError: %@", request.url, error.localizedDescription);
    
    if (self.requestFinishBlock) {
        self.requestFinishBlock (nil, error);
    }
}


#pragma mark - Requests
-(void)loadVideosForURL:(NSURL *)URL {
    
    [self configureASIRequestWithURL:URL];
}

@end
