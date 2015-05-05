//
//  MManageListViewController.m
//  Muvee
//
//  Created by iApp on 12/3/14.
//  Copyright (c) 2014 iAppTechnologies. All rights reserved.
//

#import "MManageListViewController.h"
#import "SearchResultsViewController.h"


@interface MManageListViewController ()
{
    IBOutlet UITableView *tableVw;
    NSMutableArray *Arr;
    IBOutlet UIButton *editButton,*doneButton,*backButton;
    BOOL canReverseArray;
    UIImageView *imageIcon;
    CGSize screenSize;
    BOOL isCellSeleted;
    NSString *moveitem;
    int fromIndex,toIndex;
    
    UILabel *label;
}

@end

@implementation MManageListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
    {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.arrManageList = [[NSMutableArray alloc]init];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [editButton setHidden:NO];
    
   
    
    screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        screenSize = CGSizeMake(1024, 768);
    }
    
    Arr = _arrManageList;
    
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 100.0)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:14.0];
    label.text = @"No Playlist";
    label.textAlignment = NSTextAlignmentCenter;
    label.center = self.view.center;

    
    

    CGRect rectImage = imageIcon.frame;
    CGRect rectEdit = editButton.frame;
    CGRect rectDone = doneButton.frame;
    UIImage *image;
    
    
    if([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPhone)
            {
                rectImage = CGRectMake((screenSize.width-46)/2, 5, 46, 30);
                image=[UIImage imageNamed:@"icon1"];
            
                rectEdit = CGRectMake((screenSize.width-270)/2, screenSize.height-46, 270, 36) ;
                rectDone = CGRectMake((screenSize.width-270)/2, screenSize.height-46, 270, 36) ;

            }
            else
            {
            rectImage = CGRectMake((screenSize.width-60)/2, 10, 91, 60);
            image=[UIImage imageNamed:@"icon1@2x"];
            
            rectEdit = CGRectMake((screenSize.width-500)/2, screenSize.height-70, 500, 50) ;
            rectDone = CGRectMake((screenSize.width-500)/2, screenSize.height-70,  500, 50) ;
                
                backButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 25, 26, 31)];
                [backButton addTarget:self action:@selector(backButton:) forControlEvents:UIControlEventTouchUpInside];
                [backButton setBackgroundImage:[UIImage imageNamed:@"back_errow@2x"]forState:UIControlStateNormal];
                [self.view addSubview:backButton];
            
            }
    
    imageIcon =[[UIImageView alloc] initWithFrame:rectImage];
    [self.view addSubview:imageIcon];
    imageIcon.image=image;
    self.navigationController.navigationBarHidden = YES;
    
    
    //edit and done Button
    
    editButton = [[UIButton alloc]initWithFrame:rectEdit];
    doneButton = [[UIButton alloc]initWithFrame:rectDone];
    
    [editButton setBackgroundImage:[UIImage imageNamed:@"edit1"] forState:UIControlStateNormal];
    [doneButton setBackgroundImage:[UIImage imageNamed:@"done"] forState:UIControlStateNormal];
    
    if([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPad)
     {
    [editButton setBackgroundImage:[UIImage imageNamed:@"edit1@2x"] forState:UIControlStateNormal];
    [doneButton setBackgroundImage:[UIImage imageNamed:@"done@2x"] forState:UIControlStateNormal];
     }
    
    [editButton addTarget:self action:@selector(enterEditMode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:editButton];
    
    [doneButton addTarget:self action:@selector(doneMode:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneButton];
    
    [doneButton setHidden: YES];
    
    
    if ([Arr count] == 0 || Arr == nil) {

        tableVw.hidden = YES;
        doneButton.hidden = YES;
        editButton.hidden = YES;
        [self.view addSubview:label];
    }
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES ];
    
  //ORIENTATION NOTIFICATION
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrentationRotaion) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}
-(BOOL)prefersStatusBarHidden
{
    return  YES;
}

-(IBAction)backButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)MoveList:(id)sender
{
    [tableVw setEditing:YES animated:YES];
}

-(void)handleOrentationRotaion
{
    screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[UIApplication sharedApplication].statusBarOrientation];
   
   if([[UIDevice currentDevice] userInterfaceIdiom ] == UIUserInterfaceIdiomPad)
    {
        screenSize = CGSizeMake(1024, 768);
        CGRect rectImage = imageIcon.frame;
        rectImage = CGRectMake((screenSize.width-60)/2, 10, 91, 60);
        imageIcon.frame =rectImage;

        CGRect rectEdit = editButton.frame;
        CGRect rectDone = doneButton.frame;
        
        rectEdit = CGRectMake((screenSize.width-500)/2, screenSize.height-70, 500, 50) ;
        rectDone = CGRectMake((screenSize.width-500)/2, screenSize.height-70,  500, 50) ;
        
        editButton.frame = rectEdit;
        doneButton.frame = rectDone;

    }
}


#pragma  mark- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [Arr count];
}
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier =@"Cell";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
   if(!cell)
   {
       cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
       
   }
    //[tableVw setEditing:YES animated:YES];
  for(id obj in cell.contentView.subviews)
  {
      [obj removeFromSuperview];
  }
    NSLog(@"%@",Arr);
   cell.textLabel.text= [[Arr objectAtIndex:indexPath.row] uppercaseString];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    NSLog(@"%@",Arr );

    
    return  cell;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        
        
        
        
        // Delete This object from Parse
        if ([[DataStorage sharedStorage] isInternetAvailable]) {
            
            NSString *key = [Arr objectAtIndex:indexPath.row];
            
            
            // Check this user should not be exist in database
            PFQuery *_query = [PFQuery queryWithClassName:@"Playlist"];
            [_query whereKey:@"email" equalTo:[AppDelegate sharedDelegate].user.email];
            [_query whereKey:@"searchedKey" equalTo:key];
            
            [_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                
                if ([objects isKindOfClass:[NSArray class]] && [objects count] > 0) {
                    
                    PFObject *object = [objects objectAtIndex:0];
                    [object deleteInBackground];
                }
                
            }];
            
        }

        
        
        
        [Arr removeObjectAtIndex:indexPath.row];
        
        [[AppDelegate sharedDelegate] setPlaylist:Arr];
        [[MDatabase sharedDatabase] updatePlaylist:Arr];
        
        if ([Arr count] == 0 || Arr == nil) {
            
            tableVw.hidden = YES;
            doneButton.hidden = YES;
            editButton.hidden = YES;
            [self.view addSubview:label];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *lastSearchedKey =nil;
            [defaults setValue:lastSearchedKey forKey:@"lastSearchTitleStr"];
                [defaults synchronize];
        }
        [tableVw reloadData];
    
     }        }



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strName=[Arr objectAtIndex:indexPath.row];
    SearchResultsViewController *SRVC;
    
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        SRVC =[[SearchResultsViewController alloc]initWithNibName:@"SearchResultsViewController" bundle:nil];
    }
    else
    {
        SRVC =[[SearchResultsViewController alloc]initWithNibName:@"SearchResultsViewController_ipad" bundle:nil];
    }
    
    SRVC.StrSearch=strName;
    
    
    
    SRVC.arrayManageListSRVC = Arr;
    // [self presentViewController:SRVC animated:YES completion:nil];
    [self.navigationController pushViewController:SRVC animated:YES];

    
    

    
}




- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isCellSeleted)
        return YES;
else
    return NO;
    
}


#pragma mark Row reordering
// Determine whether a given row is eligible for reordering or not.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath
{
    
    NSLog(@"Arr%@",Arr);
//    fromIndex =fromIndexPath.row;
//    toIndex =toIndexPath.row;
    moveitem = [Arr objectAtIndex:fromIndexPath.row];
    [Arr removeObject:moveitem];
    [Arr insertObject:moveitem atIndex:toIndexPath.row];
    NSLog(@"Arr%@",Arr);
    NSLog(@"%@",[AppDelegate sharedDelegate].playlist);
   
    [[AppDelegate sharedDelegate] setPlaylist:Arr];
    [[MDatabase sharedDatabase] updatePlaylist:Arr];
    
    NSLog(@"%@",[AppDelegate sharedDelegate].playlist);
    
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString *lastSearchedKey = [defaults valueForKey:@"lastSearchTitleStr"];
//    [defaults synchronize];

  //  [tableView reloadData];
}



//customcell;
//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
//{
//    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//    
//    // Configure the view for the selected state
//}

- (IBAction)enterEditMode:(id)sender
{
        [tableVw setEditing:YES animated:YES];
        [doneButton setHidden:NO];
        [editButton setHidden:YES];
        isCellSeleted =YES;
        [tableVw reloadData];
    }

-(IBAction)doneMode:(id)sender
{
//    moveitem = [Arr objectAtIndex:fromIndex];
//    [Arr removeObject:moveitem];
//    [Arr insertObject:moveitem atIndex:toIndex];
//      [tableVw reloadData];
//    
//    [[AppDelegate sharedDelegate] setPlaylist:Arr];
//    [[MDatabase sharedDatabase] updatePlaylist:Arr];

    [tableVw setEditing:NO animated:YES];
    [doneButton setHidden:YES];
    [editButton setHidden:NO];
    isCellSeleted =NO;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
   }
@end