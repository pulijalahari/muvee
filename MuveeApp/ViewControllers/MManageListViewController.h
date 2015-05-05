//
//  MManageListViewController.h
//  Muvee
//
//  Created by iApp on 12/3/14.
//  Copyright (c) 2014 iAppTechnologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MManageListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong , nonatomic) NSMutableArray *arrManageList;


@end
