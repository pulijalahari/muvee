//
//  MSettingViewController.h
//  Muvee
//
//  Created by iApp on 12/3/14.
//  Copyright (c) 2014 iAppTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KVPasscodeViewController.h"


@interface MSettingViewController : UIViewController<KVPasscodeViewControllerDelegate>

- (IBAction)showPasscode:(id)sender;
@end
