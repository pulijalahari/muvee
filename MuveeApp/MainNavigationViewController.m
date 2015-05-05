//
//  MainNavigationViewController.m
//  OrientationChecker
//
//  Created by iapp on 18/02/15.
//  Copyright (c) 2015 iAppTechnologies. All rights reserved.
//

#import "MainNavigationViewController.h"
#import "SearchResultsViewController.h"

@interface MainNavigationViewController () <UINavigationControllerDelegate>

@end

@implementation MainNavigationViewController

-(void)viewDidLoad {
    self.delegate = self;
}

-(BOOL)shouldAutorotate {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    
        if (self.isPortraitOrientation) {
            return NO;
        }
        
        return YES;
    }
    else {
        return NO;
    }
}

-(NSUInteger)supportedInterfaceOrientations {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (self.isPortraitOrientation) {
            return UIInterfaceOrientationMaskPortrait;
        }
        else {
            return UIInterfaceOrientationMaskAll;
        }
    }
    else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

/*-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.isPortraitOrientation) {
        return UIInterfaceOrientationPortrait;
    }
    else {
        return UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
    }
}*/

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        if ([viewController isKindOfClass:[SearchResultsViewController class]]) {
            // Portrait Only
            self.portraitOrientation = YES;
        }
        else {
            // All Orientations
            self.portraitOrientation = NO;
        }

    }
    else {
        
    }
    
}



- (NSUInteger)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        if (self.isPortraitOrientation) {
            return UIInterfaceOrientationMaskPortrait;
        }
        else {
            return UIInterfaceOrientationMaskAll;
        }

    }
    else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

@end
