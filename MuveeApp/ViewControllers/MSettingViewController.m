//
//  MSettingViewController.m
//  Muvee
//
//  Created by iApp on 12/3/14.
//  Copyright (c) 2014 iAppTechnologies. All rights reserved.
//

#import "MSettingViewController.h"
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "MhelpViewController.h"

@interface MSettingViewController ()<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
{
    UIImageView *imageIcon;
    IBOutlet UITableView *tableVw;
    int mint;
    CGSize screenSize;
    UIButton *backButton,*btnTimeSet,*btnHelp;
    NSString *newPasscode,*strChangePasscode;
    BOOL canEnterNewPasscode;
    NSMutableArray *pickerArray;
    NSArray *arrayMintues;
    
}

@property (nonatomic, strong) UIImageView *secretContentView;
@property (nonatomic, strong) UIButton *loginLogoutButton;
@property (nonatomic, assign) BOOL locked;
@property (strong,nonatomic) IBOutlet UIPickerView *picker;


@end

@implementation MSettingViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pickerArray = [NSMutableArray arrayWithCapacity:1];
   pickerArray = [NSMutableArray arrayWithObjects:@"30 minutes", @"1 hour", @"1 hours 30 minutes ", @"2 hours ", @"2 hours 30 minutes ", @"3 hours",@"3 hours 30 minutes",@"4 hours",@"4 hours 30 minutes",@"5 hours ",@"5 hours 30 minutes",@"6 hours ",nil];

    arrayMintues = @[@"30",@"60",@"90",@"120",@"150",@"180",@"210",@"240",@"270",@"300",@"330",@"360"];
    
    
    //get sceren size
     screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    [tableVw setSeparatorStyle:UITableViewCellEditingStyleNone];
    
    CGRect rectImage = imageIcon.frame;
    UIImage *image;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        rectImage = CGRectMake((screenSize.width-46)/2, 5, 46, 30);
        image=[UIImage imageNamed:@"icon1"];

    }
    else
    {
        //ipad
        rectImage = CGRectMake((screenSize.width-60)/2, 10, 91, 60);
        image=[UIImage imageNamed:@"icon1@2x"];
        
        backButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 25, 26, 31)];
        [backButton addTarget:self action:@selector(btnBack:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setBackgroundImage:[UIImage imageNamed:@"back_errow@2x.png"]forState:UIControlStateNormal];
        [self.view addSubview:backButton];

    }
    
    imageIcon =[[UIImageView alloc] initWithFrame:rectImage];
    [self.view addSubview:imageIcon];
    imageIcon.image=image;
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
   //orientation Notification
     [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(handleOrientationChangeNotification) name: UIApplicationDidChangeStatusBarOrientationNotification object: nil];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [tableVw setSeparatorStyle:UITableViewCellEditingStyleNone];
   
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark-Hide Status bar 
-(BOOL)prefersStatusBarHidden
{
    return  YES;
}
#pragma mark-orientation Notification
-(void)handleOrientationChangeNotification
{
    screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    [tableVw reloadData];
    [self.picker removeFromSuperview];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
               //iphone
        CGRect rectImage = imageIcon.frame;
        rectImage = CGRectMake((screenSize.width-46)/2, 5, 46, 30);
        imageIcon.frame = rectImage;

    }
    else
    {
        //ipad
        CGRect rectImage = imageIcon.frame;
        rectImage = CGRectMake((screenSize.width-60)/2, 10, 91, 60);
        imageIcon.frame = rectImage;
    }
    
}



#pragma mark- UITableView DAta source and Delegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self removeTimePicker];
   
    if (indexPath.row == 0) {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *lastSearchedKey =nil;
        [defaults setValue:lastSearchedKey forKey:@"lastSearchTitleStr"];
        [defaults synchronize];
        
        // Logout User
        [[GPPSignIn sharedInstance] signOut];
        [[AppDelegate sharedDelegate] setUser:nil];
        [[MDatabase sharedDatabase] deleteUser];
        [[[AppDelegate sharedDelegate] playlist] removeAllObjects];
        [[MDatabase sharedDatabase] updatePlaylist:nil];
        
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        [[AppDelegate sharedDelegate] showLoginScreen];
    }
    
    else if (indexPath.row == 1) {
        
        KVPasscodeViewController *passcodeController = [[KVPasscodeViewController alloc] init];
        passcodeController.delegate = self;
        strChangePasscode =@"YES";
        
        UINavigationController *passcodeNavigationController = [[UINavigationController alloc] initWithRootViewController:passcodeController];
        if(![[AppDelegate sharedDelegate].settings.passcode isEqualToString:@""])
        {
            passcodeController.instructionLabel.text = @"Enter old passcode.";
        }

        [self.navigationController presentViewController:passcodeNavigationController animated:YES completion:nil];
    }
    else if (indexPath.row ==5)
    {
        
       
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 1) {
        return 0;
    }
    if(indexPath.row == 7)
    {
        return 60;
    }
    else {
        return 100.0;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier=@"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell)
    {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    for(id obj in cell.contentView.subviews)
    {
        [obj removeFromSuperview];
    }
       screenSize = tableVw.frame.size;
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    
    if(indexPath.row == 0)
    {
       //280
        
        UILabel *lblAccount = [[UILabel alloc]initWithFrame:CGRectMake(20, 40, 150, 30)];
        lblAccount.text = @"Account";
      //  lblAccount .font =[UIFont fontWithName:@"STEELFIB" size:14];
        lblAccount.textColor=[UIColor colorWithRed:196.0/255.0f green:32.0f/255.0f blue:55.0f/255.0f alpha:1];
        lblAccount.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:lblAccount];
        
        
        UILabel *lblDeatil = [[UILabel alloc]initWithFrame:CGRectMake(20, 70, 200, 30)];
        lblDeatil.text = @"Change your youtube account to logout";
        lblDeatil.textColor= [UIColor lightGrayColor];
        lblDeatil.font = [UIFont italicSystemFontOfSize:10];
        [cell.contentView addSubview:lblDeatil];
        
        
        UILabel *change = [[UILabel alloc]initWithFrame:CGRectMake(screenSize.width-100, 40, 90, 30)];
        change.text = @"Change";
        change.textColor= [UIColor lightGrayColor];
        change.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:change];

        UIImageView *imgView=[[UIImageView alloc]initWithFrame:CGRectMake(screenSize.width-40, 46, 20, 20)];
        [cell.contentView addSubview: imgView];
        UIImage *img = [UIImage imageNamed:@"change_arrow@2x"];
        imgView.image =img;

        UIView *viewColor=[[UIView alloc]initWithFrame:CGRectMake(20, 70,screenSize.width-40, 0.5)];
        viewColor.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:viewColor];
        
    }
     if(indexPath.row == 1)
    {
       /*
        
        UILabel *lblAccount = [[UILabel alloc]initWithFrame:CGRectMake(20, 40, 200, 30)];
        
        if ([[[AppDelegate sharedDelegate] settings].passcode isEqualToString:@""])
            lblAccount.text = @"Set Passcode";
        else
            lblAccount.text = @"Change PassCode";
        lblAccount.textColor=[UIColor colorWithRed:196.0/255.0f green:32.0f/255.0f blue:55.0f/255.0f alpha:1];
        lblAccount.font = [UIFont systemFontOfSize: 14];
        NSLog(@"%@",lblAccount.font);
        [cell.contentView addSubview:lblAccount];
        
        UILabel *lblDeatil = [[UILabel alloc]initWithFrame:CGRectMake(20, 70, 200, 30)];
        
        if ([[[AppDelegate sharedDelegate] settings].passcode isEqualToString:@""])
            lblDeatil.text = @"Set your youtube passcode";
        else
            lblDeatil.text = @"Change your youtube passcode";
        lblDeatil.textColor= [UIColor lightGrayColor];
        lblDeatil.font = [UIFont italicSystemFontOfSize:10];
        [cell.contentView addSubview:lblDeatil];
        
        UILabel *change = [[UILabel alloc]initWithFrame:CGRectMake(screenSize.width-100, 40, 90, 30)];
        if ([[[AppDelegate sharedDelegate] settings].passcode isEqualToString:@""])
            change.text = @"Set";
        else
            change.text = @"Change";
       change.textColor= [UIColor lightGrayColor];
        change.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:change];
        
        UIImageView *imgView=[[UIImageView alloc]initWithFrame:CGRectMake(screenSize.width-40, 46, 20, 20)];
        [cell.contentView addSubview: imgView];
        UIImage *img = [UIImage imageNamed:@"change_arrow"];
        imgView.image =img;
        
        UIView *viewColor=[[UIView alloc]initWithFrame:CGRectMake(20, 70, width-40, 0.5)];
        viewColor.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:viewColor];

        */

    }
    if(indexPath.row == 2)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *lblAccount = [[UILabel alloc]initWithFrame:CGRectMake(20, 40, 150, 30)];
        lblAccount.text = @"Local Videos";
        lblAccount.textColor=[UIColor colorWithRed:196.0/255.0f green:32.0f/255.0f blue:55.0f/255.0f alpha:1];
        lblAccount.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:lblAccount];
        
        UIView *viewColor=[[UIView alloc]initWithFrame:CGRectMake(20, 70,screenSize.width-40, 0.5)];
        viewColor.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:viewColor];

        
        UILabel *lblDeatil = [[UILabel alloc]initWithFrame:CGRectMake(20, 70, 200, 30)];
        lblDeatil.text = @"Allow the app to access the phone videos";
        lblDeatil.textColor= [UIColor lightGrayColor];
        lblDeatil.font = [UIFont italicSystemFontOfSize:10];
        [cell.contentView addSubview:lblDeatil];
        
        UISwitch *onoff = [[UISwitch alloc] initWithFrame: CGRectMake(screenSize.width-75,36,50,27)];
        [onoff setOnTintColor:[UIColor colorWithRed:196.0/255.0f green:32.0f/255.0f blue:55.0f/255.0f alpha:1]];
        onoff.on = [[AppDelegate sharedDelegate] settings].localVideos;
        [onoff addTarget: self action: @selector(localVideos:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview: onoff];
    }
    
    if(indexPath.row == 3)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *lblAccount = [[UILabel alloc]initWithFrame:CGRectMake(20, 40, 150, 30)];
        lblAccount.text = @"Kid Mode";
        lblAccount.textColor=[UIColor colorWithRed:196.0/255.0f green:32.0f/255.0f blue:55.0f/255.0f alpha:1];
        lblAccount.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:lblAccount];
        
        UIView *viewColor=[[UIView alloc]initWithFrame:CGRectMake(20, 70,screenSize.width-40, 0.5)];
        viewColor.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:viewColor];

        
        UILabel *lblDeatil = [[UILabel alloc]initWithFrame:CGRectMake(20, 70, 200, 30)];
        lblDeatil.text = @"Requires an adult to get out of the app";
        lblDeatil.textColor= [UIColor lightGrayColor];
        
        lblDeatil.font = [UIFont italicSystemFontOfSize:10];
        [cell.contentView addSubview:lblDeatil];
        
        UISwitch *onoff = [[UISwitch alloc] initWithFrame: CGRectMake(screenSize.width-75,36,50,27)];
        [onoff setOnTintColor:[UIColor colorWithRed:196.0/255.0f green:32.0f/255.0f blue:55.0f/255.0f alpha:1]];
        onoff.on = [[AppDelegate sharedDelegate] settings].kidMode;
        [onoff addTarget: self action: @selector(kidMode:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview: onoff];

    }
    if(indexPath.row == 4)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *lblAccount = [[UILabel alloc]initWithFrame:CGRectMake(20, 40, 150, 30)];
        lblAccount.text = @"Timeout Settings";
        lblAccount.textColor=[UIColor colorWithRed:196.0/255.0f green:32.0f/255.0f blue:55.0f/255.0f alpha:1];
        lblAccount.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:lblAccount];
        
        UIView *viewColor=[[UIView alloc]initWithFrame:CGRectMake(20, 70,screenSize.width-40, 0.5)];
        viewColor.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:viewColor];

        
        UILabel *lblDeatil = [[UILabel alloc]initWithFrame:CGRectMake(20, 70, 200, 30)];
        lblDeatil.text = @"For how long kid may watch video's?";
        lblDeatil.textColor= [UIColor lightGrayColor];
        lblDeatil.font = [UIFont italicSystemFontOfSize:10];
        [cell.contentView addSubview:lblDeatil];

    }
    
    if(indexPath.row == 5)
    {
        
        btnTimeSet= [UIButton buttonWithType:UIButtonTypeCustom];
        btnTimeSet.frame = CGRectMake(40, 30, 240, 30);
        [btnTimeSet setTitle:[[NSUserDefaults standardUserDefaults] valueForKey:@"TimeSet"] forState:UIControlStateNormal];
        btnTimeSet.layer.borderWidth = 1.0;
        btnTimeSet.layer.borderColor = [UIColor colorWithRed:196.0/255.0f green:32.0f/255.0f blue:55.0f/255.0f alpha:1].CGColor;
        btnTimeSet.layer.cornerRadius = 5.0;
        [btnTimeSet setBackgroundColor:[UIColor clearColor]];
        [btnTimeSet setTitleColor:[UIColor colorWithRed:196.0/255.0f green:32.0f/255.0f blue:55.0f/255.0f alpha:1] forState:UIControlStateNormal];
        [btnTimeSet addTarget:self action:@selector(btnPickerSet) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnTimeSet];
   
   
    }
    if(indexPath.row == 6)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *lblAccount = [[UILabel alloc]initWithFrame:CGRectMake(20, 1, 150, 30)];
        lblAccount.text = @"Content Filter";
        lblAccount.textColor= [UIColor lightGrayColor];
        lblAccount.font = [UIFont systemFontOfSize:14];
        [cell.contentView addSubview:lblAccount];
        
        NSArray *itemArray = [NSArray arrayWithObjects: @"MILD", @"MODERATE", @"STRICT", nil];
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:itemArray];
        //   segmentedControl.frame = CGRectMake(20, 30, screenSize.width-40, 30);
        segmentedControl.frame = CGRectMake(40, 30, 240, 30);

        //  segmentedControl.backgroundColor =
        segmentedControl.tintColor =[UIColor colorWithRed:196.0/255.0f green:32.0f/255.0f blue:55.0f/255.0f alpha:1];
        segmentedControl.layer.borderWidth =0.0f;
        [segmentedControl addTarget:self action:@selector(MySegmentControlAction:) forControlEvents: UIControlEventValueChanged];
        
        

         if ([[[AppDelegate sharedDelegate] settings].contentFilteringBy isEqualToString:mild])
         {
             segmentedControl.selectedSegmentIndex = 0;
         }
        else if ([[[AppDelegate sharedDelegate] settings].contentFilteringBy isEqualToString:moderate])
        {
            segmentedControl.selectedSegmentIndex = 1;
        }
        else
        {
            segmentedControl.selectedSegmentIndex =2;
        }
        [cell.contentView addSubview:segmentedControl];
        
        
        

        
    }
    if(indexPath.row == 7)
    {
        
//        btnHelp= [UIButton buttonWithType:UIButtonTypeCustom];
//        btnHelp.frame = CGRectMake(40, 30, 240, 30);
//        [btnHelp setTitle:@"Help" forState:UIControlStateNormal];
//        [btnHelp setTitleColor:[UIColor colorWithRed:196.0/255.0f green:32.0f/255.0f blue:55.0f/255.0f alpha:1] forState:UIControlStateNormal];
//        [btnHelp addTarget:self action:@selector(helpAction) forControlEvents:UIControlEventTouchUpInside];
//        [cell.contentView addSubview:btnHelp];
        
        btnHelp= [UIButton buttonWithType:UIButtonTypeCustom];
        btnHelp.frame = CGRectMake(25, 0, 320, 40);
        if([UIScreen mainScreen].bounds.size.height == 768 ||[UIScreen mainScreen].bounds.size.height == 1024)
        {
            btnHelp.frame = CGRectMake(25, 0, 320, 80);
        }
        [btnHelp setTitle:@"Help" forState:UIControlStateNormal];
        btnHelp.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        // btnHelp.titleLabel.textAlignment = NSTextAlignmentLeft;
        btnHelp.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [btnHelp setTitleColor:[UIColor colorWithRed:196.0/255.0f green:32.0f/255.0f blue:55.0f/255.0f alpha:1] forState:UIControlStateNormal];
        [btnHelp addTarget:self action:@selector(helpAction) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnHelp];
        UIView *viewColor=[[UIView alloc]initWithFrame:CGRectMake(20, 30,screenSize.width-40, 0.5)];
        viewColor.backgroundColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:viewColor];
        
        
    }

    return cell;
}

#pragma mark-Methods/IBActons
-(void)btnPickerSet
{
    screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    if (![self.view.subviews containsObject:self.picker]) {
     
        self.picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, screenSize.height-200, screenSize.width, 200)];
        //  [self.picker setBackgroundColor:[UIColor colorWithRed:196.0/255.0f green:32.0f/255.0f blue:55.0f/255.0f alpha:1]];
       
        self.picker.dataSource = self;
        self.picker.delegate = self;
        [self.view addSubview:self.picker];
        
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
            CGRect rect = tableVw.frame;
            rect.size.height = rect.size.height - 200;
            tableVw.frame = rect;
            
        }
    }
}

-(void)helpAction
{
    MhelpViewController *helpView = [[MhelpViewController alloc]init];
    [self.navigationController pushViewController:helpView animated:NO];
//    [self presentViewController:helpView animated:YES completion:nil];
}
-(void)removeTimePicker {
    
    if ([self.view.subviews containsObject:self.picker]) {
        [self.picker removeFromSuperview];
        
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            
            CGRect rect = tableVw.frame;
            rect.size.height = rect.size.height + 200;
            tableVw.frame = rect;

        }
    }
}


-(IBAction)btnRadio1:(id)sender
{
    CGPoint point = CGPointZero;
    
    point = [tableVw convertPoint:point fromView:sender];
    
    int mints = [sender tag] * 5;
    
    [AppDelegate sharedDelegate].settings.timeoutMinutes = [NSString stringWithFormat:@"%d", mints];
    [[MDatabase sharedDatabase] saveUserSettings:[AppDelegate sharedDelegate].settings];
    
    
    // Invalidate timer
    [[[AppDelegate sharedDelegate] timerAppLock] invalidate];
    [[AppDelegate sharedDelegate] setTimerAppLock:nil];
    
    if ([AppDelegate sharedDelegate].settings.kidMode) {
        // start new timer
        [[AppDelegate sharedDelegate] timerStart];
    }

 }


- (IBAction) localVideos: (id) sender
{
    UISwitch *onoff = (UISwitch *) sender;
    if(onoff.on)
    {
        // switch is on
    }
    else
    {
        // switch is off
    }
    
    [AppDelegate sharedDelegate].settings.localVideos = onoff.on;
    [[MDatabase sharedDatabase] saveUserSettings:[AppDelegate sharedDelegate].settings];
}

- (IBAction) kidMode: (id) sender
{
    UISwitch *onoff = (UISwitch *) sender;
    if(onoff.on)
    {
        // switch is on
        [[[AppDelegate sharedDelegate] timerAppLock] invalidate];
        [[AppDelegate sharedDelegate] setTimerAppLock:nil];
        [[AppDelegate sharedDelegate] timerStart];
        
    }
    else
    {
        // switch is off
       [[[AppDelegate sharedDelegate] timerAppLock] invalidate];
        [[AppDelegate sharedDelegate] setTimerAppLock:nil];
    }
    
   [AppDelegate sharedDelegate].settings.kidMode = onoff.on;
    [[MDatabase sharedDatabase] saveUserSettings:[AppDelegate sharedDelegate].settings];
   
}

-(IBAction)btnBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)MySegmentControlAction:(UISegmentedControl *)segment
{
    if(segment.selectedSegmentIndex == 0)
    {
        // code for the first button
        [AppDelegate sharedDelegate].settings.contentFilteringBy = mild;
    }
    else if(segment.selectedSegmentIndex == 1)
    {
        // code for the 2nd button
        [AppDelegate sharedDelegate].settings.contentFilteringBy = moderate;
    }
    else
    {
        // code for the last button
        [AppDelegate sharedDelegate].settings.contentFilteringBy = strict;
    }
    
    
    [[MDatabase sharedDatabase] saveUserSettings:[AppDelegate sharedDelegate].settings];
}



- (IBAction)showPasscode:(id)sender {
    
    KVPasscodeViewController *passcodeController = [[KVPasscodeViewController alloc] init];
    passcodeController.delegate = self;
    UINavigationController *passcodeNavigationController =[[UINavigationController alloc] initWithRootViewController:passcodeController];
    [self.navigationController presentViewController:passcodeNavigationController animated:YES completion:nil];
   
}

#pragma mark - KVPasscodeViewControllerDelegate
- (void)passcodeController:(KVPasscodeViewController *)controller passcodeEntered:(NSString *)passCode {
    
   NSLog(@"%@",passCode);
   
    if([strChangePasscode isEqualToString:@"YES"])
    {
        if([[AppDelegate sharedDelegate].settings.passcode isEqualToString:@"" ])
        {
            NSString *passcode = [AppDelegate sharedDelegate].settings.passcode;
            if ([passcode isEqualToString:@""] && newPasscode.length == 0) {
                
                newPasscode = passCode;
                controller.instructionLabel.text = NSLocalizedString(@"Confirm passcode", @"");
                [controller resetWithAnimation:KVPasscodeAnimationStyleConfirm];
            }
            else
            {
                if (newPasscode.length > 0) {
                    
                    if ([newPasscode isEqualToString:passCode]) {
                        
                        // New Passcode set
                        [AppDelegate sharedDelegate].settings.passcode = newPasscode;
                        [[MDatabase sharedDatabase] saveUserSettings:[AppDelegate sharedDelegate].settings];
                        
                        [self dismissViewControllerAnimated:NO completion:NULL];
                        //  [self gotoSettings];
                        [tableVw reloadData];
                    }
                    else {
                        
                        // Confirm Passcode don't match
                        controller.instructionLabel.text = NSLocalizedString(@"Passcode & Confirm passcode don't match", @"");
                        newPasscode = @"";
                        [controller resetWithAnimation:KVPasscodeAnimationStyleNone];
                    }
                }
                else
                {
                    if ([passcode isEqualToString:passCode]) {
                        
                        [self dismissViewControllerAnimated:NO completion:NULL];
                        // [self gotoSettings];
                    }
                    
                }
            }

            
        }
      else  if([[AppDelegate sharedDelegate].settings.passcode isEqualToString:passCode ] && !canEnterNewPasscode)
        {
            
            [controller resetWithAnimation:KVPasscodeAnimationStyleConfirm];
             controller.instructionLabel.text = @"Choose new passcode";
           
            canEnterNewPasscode =YES;
            }
        else if(canEnterNewPasscode)
            {
                if (newPasscode.length == 0)
                {
                    newPasscode = passCode;
                    [controller resetWithAnimation:KVPasscodeAnimationStyleConfirm];
                    controller.instructionLabel.text = NSLocalizedString(@"Confirm passcode", @"");
                }
                else if([newPasscode isEqualToString:passCode])
                {
                    [AppDelegate sharedDelegate].settings.passcode = newPasscode;
                    [[MDatabase sharedDatabase] saveUserSettings:[AppDelegate sharedDelegate].settings];
                    canEnterNewPasscode =NO;
                    newPasscode = @"";
                    [self dismissViewControllerAnimated:NO completion:NULL];
                    //strChangePasscode =@"NO";
                    [tableVw reloadData];
                }
                else
                {
                    // Confirm Passcode don't match
                    
//                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Muvee" message:@"Confirm Passcode don't match" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                    alert.tag =11;
//                    [alert show];
                    newPasscode = @"";
                    [controller resetWithAnimation:KVPasscodeAnimationStyleInvalid];
                    controller.instructionLabel.text = @"Choose new passcode";
                }
            }
        
        else
        {
            controller.instructionLabel.text = @"Invalid Passcode";
            [controller resetWithAnimation:KVPasscodeAnimationStyleInvalid];

        }
    }
}
#pragma mark-UIpickerViewController Delegate

- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// The number of rows of data
- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return pickerArray.count;
}

// The data to return for the row and component (column) that's being passed in
- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSLog(@"%@",pickerArray[row]);
    return pickerArray[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
     NSLog(@"%@",pickerArray[row]);
    
    [[NSUserDefaults standardUserDefaults] setValue:pickerArray[row] forKey:@"TimeSet"];
       [[NSUserDefaults standardUserDefaults]synchronize];
    [btnTimeSet setTitle:[[NSUserDefaults standardUserDefaults] valueForKey:@"TimeSet"] forState:UIControlStateNormal];
    
    id mints = [arrayMintues objectAtIndex:row];
    int min = [mints integerValue];
    
    
    [AppDelegate sharedDelegate].settings.timeoutMinutes = [NSString stringWithFormat:@"%d", min];
    [[MDatabase sharedDatabase] saveUserSettings:[AppDelegate sharedDelegate].settings];
    
    
    // Invalidate timer
    [[[AppDelegate sharedDelegate] timerAppLock] invalidate];
    [[AppDelegate sharedDelegate] setTimerAppLock:nil];
    
    if ([AppDelegate sharedDelegate].settings.kidMode) {
        // start new timer
        [[AppDelegate sharedDelegate] timerStart];
    }
    
    NSLog(@"%d",[[AppDelegate sharedDelegate] settings].timeoutMinutes.intValue);
    //[self setTimeoutMint:[[AppDelegate sharedDelegate] settings].timeoutMinutes.intValue ];
 
}

#pragma mark- UITouch Event Method
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self removeTimePicker];
}


@end
