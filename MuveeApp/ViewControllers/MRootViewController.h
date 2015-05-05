//
//  MRootViewController.h
//  Muvee
//
//  Created by iApp on 12/1/14.
//  Copyright (c) 2014 iAppTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRootViewController : UIViewController<UISearchBarDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong ,nonatomic)  IBOutlet UISearchBar *SearchBar;

@end
