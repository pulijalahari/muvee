//
//  MCaptchaViewController.m
//  MuveeApp
//
//  Created by iApp on 17/12/14.
//  Copyright (c) 2014 iApp. All rights reserved.
//

#import "MCaptchaViewController.h"
#import "MRootViewController.h"

@interface MCaptchaViewController ()<UITextFieldDelegate>
{
    IBOutlet UITextField *txtCatcha;
    IBOutlet UILabel *lblCaptcha,*lblWrongCaptcha;
    NSArray *arrayRandom;
    NSString *RandomNumber;
    
    IBOutlet UIButton *btnCancel,*btnDone;
    CGSize screenSize;
    NSString *str,*lastStrSave;
    }

@end

@implementation MCaptchaViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
  //  int o = [[UIApplication sharedApplication] statusBarOrientation];
  //   [[UIDevice currentDevice] setValue: [NSNumber numberWithInteger: o] forKey:@"orientation"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [txtCatcha becomeFirstResponder];
    self.navigationController.navigationBarHidden =YES;
    [lblWrongCaptcha setHidden: YES];
  arrayRandom = [[NSArray alloc]init];
    arrayRandom = @[@"ZERO", @"ONE",@"TWO",@"THREE",@"FOUR",@"FIVE",@"SIX",@"SEVEN",@"EIGHT",@"NINE"];
    
    
    //rondom number
   
    int i= arc4random()%9;
    NSLog(@"Random Number: %i", i);
    int j = arc4random()%9;
    NSLog(@"Random Number: %i", j);
    int k = arc4random()%9;
    NSLog(@"Random Number: %i", k);
    
    str=@"";
    
    RandomNumber = [NSString stringWithFormat:@"%d%d%d",i,j,k];
    NSString *s1=[arrayRandom objectAtIndex:i];
    NSString *s2=[arrayRandom objectAtIndex:j];
    NSString *s3=[arrayRandom objectAtIndex:k];
    
     NSString *randomNumber = [NSString stringWithFormat:@"%@ %@ %@", s1, s2, s3];
    lblCaptcha.text = [NSString stringWithFormat:@"%@",randomNumber];
    
    
    if (self.hideCancel) {
        btnCancel.hidden = YES;
    }
    
    screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    CGRect rectBtnCancel = CGRectMake((screenSize.width-200)/2, 248, 200, 36);
    CGRect rectBtnDone = CGRectMake((screenSize.width-200)/2, 208, 200, 36);

    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        rectBtnCancel = CGRectMake((screenSize.width-300)/2, 308, 300, 50);
        rectBtnDone = CGRectMake((screenSize.width-300)/2, 268, 300, 50);
    }
    
    btnCancel = [[UIButton alloc]initWithFrame:rectBtnCancel];
    [btnCancel setTitle:@"Cancel"forState:UIControlStateNormal];
    [btnCancel setBackgroundColor:[UIColor colorWithRed:196.0/255.0f green:32.0f/255.0f blue:55.0f/255.0f alpha:1]];
    [btnCancel addTarget:self action:@selector(cancelButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCancel];
    
        btnDone = [[UIButton alloc]initWithFrame:rectBtnDone];
    [btnDone setTitle:@"Done"forState:UIControlStateNormal];
    [btnDone setBackgroundColor:[UIColor colorWithRed:196.0/255.0f green:32.0f/255.0f blue:55.0f/255.0f alpha:1]];
    //[btnDone addTarget:self action:@selector(okButton:) forControlEvents:UIControlEventTouchUpInside];
   // [self.view addSubview:btnDone];
    
    
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
           screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        NSLog(@"%f",screenSize.width);
        NSLog(@"%f",screenSize.height);
        
        CGRect rectTxtcaptcha = txtCatcha.frame;
        rectTxtcaptcha = CGRectMake((screenSize.width-500)/2, 130, 500, 50);
        txtCatcha.frame =rectTxtcaptcha;
        
        CGRect rectLblWrongCaptcha = lblWrongCaptcha.frame;
        rectLblWrongCaptcha = CGRectMake((screenSize.width-500)/2, 190, 500, 50);
        lblWrongCaptcha.frame = rectLblWrongCaptcha;
        
        CGRect rectLblCaptcha = lblCaptcha.frame;
        rectLblCaptcha = CGRectMake((screenSize.width-500)/2, 80, 500, 40);
        lblCaptcha.frame = rectLblCaptcha;
        
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrentationRotaion) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

#pragma  mark orientation Notification
-(void)handleOrentationRotaion
{
   screenSize = [[AppDelegate sharedDelegate] sizeInOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    CGRect rectBtnDone = btnDone.frame;
     rectBtnDone = CGRectMake((screenSize.width-200)/2, 208, 200, 36);
    
    
    CGRect rectBtnCancel= btnCancel.frame;
    rectBtnCancel = CGRectMake((screenSize.width-200)/2, 248, 200, 36);
    
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        rectBtnCancel = CGRectMake((screenSize.width-300)/2, 308, 300, 50);
        rectBtnDone = CGRectMake((screenSize.width-300)/2, 268, 300, 30);
    }
    btnDone.frame =rectBtnDone;
    btnCancel.frame = rectBtnCancel;
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        NSLog(@"%f",(screenSize.width-400)/2);
    CGRect rectTxtcaptcha = txtCatcha.frame;
    rectTxtcaptcha = CGRectMake((screenSize.width-500)/2, 130, 500, 50);
    txtCatcha.frame =rectTxtcaptcha;
    
    CGRect rectLblWrongCaptcha = lblWrongCaptcha.frame;
    rectLblWrongCaptcha = CGRectMake((screenSize.width-500)/2, 190, 500, 50);
    lblWrongCaptcha.frame = rectLblWrongCaptcha;
        
        CGRect rectLblCaptcha = lblCaptcha.frame;
        rectLblCaptcha = CGRectMake((screenSize.width-500)/2, 80, 500, 40);
        lblCaptcha.frame = rectLblCaptcha;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark-hide status Bar

-(BOOL)prefersStatusBarHidden
{
    return  YES;
}


#pragma mark- UITouchEvent Method

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txtCatcha resignFirstResponder];
}

#pragma  mark - UITextField delegate


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    txtCatcha.text=@"";
    str = @"";
    return  YES;
}
-(BOOL)textFieldBeginEditing:(UITextField *)textField
{
    return  YES;
}

-(BOOL)textFieldEndEditing:(UITextField *)textField
{
    return  YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    if ([string isEqualToString:@""]) {
        NSMutableString *s = [str mutableCopy];
        @try {
            [s deleteCharactersInRange:NSMakeRange(s.length-1, 1)];
            str = [s copy];
        }
        @catch (NSException *exception) {
            
        }
        
        return YES;
    }
    
    if ([string isEqualToString:@" "]) {
        if (!textField.text.length)
            return NO;
        if ([[textField.text stringByReplacingCharactersInRange:range withString:string] rangeOfString:@"  "].length)
            return NO;
    }
    
    NSLog(@"enter String:%@",txtCatcha.text);
    
//    if([string isEqualToString:@""])
//    {
//        str= [str stringByReplacingOccurrencesOfString:lastStrSave withString:@""];
//    }
    
    if([string isEqualToString:@""])
    {
        if([lastStrSave isEqualToString:@""])
        {
        str=@"";
        }
        else
        {
       str= [str stringByReplacingOccurrencesOfString:lastStrSave withString:@""];
            lastStrSave=@"";
        }
    }
    else
    {
        lastStrSave= string;
        str = [str stringByAppendingString:string];
        [lblWrongCaptcha setHidden:YES];
        
    }

    if(range.length + range.location > 3)
    {
        return NO;
    }
        if ([textField.text stringByReplacingCharactersInRange:range withString:string].length == 3)
     {
    if([str isEqualToString:RandomNumber])
    {
        str=@"";
        if([self.checkTopArrrowPressed isEqualToString:@"YES"])
        {
            [self.navigationController popToRootViewControllerAnimated:NO];
            self.checkTopArrrowPressed = @"NO";
        }
        else
        {
            [[[AppDelegate sharedDelegate] timerAppLock] invalidate];
            [[AppDelegate sharedDelegate] setTimerAppLock:nil];
            
            [[MDatabase sharedDatabase] setCapchaLockEnable:FALSE];
            [[AppDelegate sharedDelegate]timerStart];
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
    else
    {
        str=@"";
        [txtCatcha resignFirstResponder];
        [lblWrongCaptcha setHidden: NO];

        int i= arc4random()%9;
        NSLog(@"Random Number: %i", i);
        int j = arc4random()%9;
        NSLog(@"Random Number: %i", j);
        int k = arc4random()%9;
        NSLog(@"Random Number: %i", k);
        
        RandomNumber = [NSString stringWithFormat:@"%d%d%d",i,j,k];
        NSString *s1=[arrayRandom objectAtIndex:i];
        NSString *s2=[arrayRandom objectAtIndex:j];
        NSString *s3=[arrayRandom objectAtIndex:k];
        
        NSString *randomNumber = [NSString stringWithFormat:@"%@ %@ %@", s1, s2, s3];
        lblCaptcha.text = [NSString stringWithFormat:@"%@",randomNumber];
        txtCatcha.text =@"";
        [txtCatcha becomeFirstResponder];
        return NO;
    }

}
       return YES;

}

#pragma mark-Methods/IBActions
-(IBAction)cancelButton:(id)sender
{
    [[MDatabase sharedDatabase] setCapchaLockEnable:FALSE];
    
    [self.navigationController popViewControllerAnimated:NO];
}

-(IBAction)okButton:(id)sender
{
    [self matchCaptchaCode];
}

-(void)matchCaptchaCode
{
    str=@"";
    NSLog(@"%@",txtCatcha.text);
    NSLog(@"%@",RandomNumber);
    
    if([txtCatcha.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Muvee" message:@"Enter captcha code." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
  else if([txtCatcha.text isEqualToString:RandomNumber])
  {
//       MRootViewController *MRVC;
//            if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
//               {
//                   MRVC  = [[MRootViewController alloc]initWithNibName:@"MRootViewController" bundle:nil];
//               }
//            else
//                {
//                    MRVC  = [[MRootViewController alloc]initWithNibName:@"MRootViewController_ipad" bundle:nil];
//                }
      
      
      if([self.checkTopArrrowPressed isEqualToString:@"YES"])
      {
      [self.navigationController popToRootViewControllerAnimated:NO];
          self.checkTopArrrowPressed = @"NO";
      }
      else
      {
          [[[AppDelegate sharedDelegate] timerAppLock] invalidate];
          [[AppDelegate sharedDelegate] setTimerAppLock:nil];
          
          [[MDatabase sharedDatabase] setCapchaLockEnable:FALSE];
          [[AppDelegate sharedDelegate]timerStart];
          [self.navigationController popViewControllerAnimated:NO];
      }
   }
    else
    {
        [lblWrongCaptcha setHidden: NO];
        
        int i= arc4random()%9;
        NSLog(@"Random Number: %i", i);
        int j = arc4random()%9;
        NSLog(@"Random Number: %i", j);
        int k = arc4random()%9;
        NSLog(@"Random Number: %i", k);
        
        
        RandomNumber = [NSString stringWithFormat:@"%d%d%d",i,j,k];
        NSString *s1=[arrayRandom objectAtIndex:i];
        NSString *s2=[arrayRandom objectAtIndex:j];
        NSString *s3=[arrayRandom objectAtIndex:k];

        NSString *randomNumber = [NSString stringWithFormat:@"%@ %@ %@", s1, s2, s3];
        lblCaptcha.text = [NSString stringWithFormat:@"%@",randomNumber];
        txtCatcha.text =@"";
        
    }

}




@end
