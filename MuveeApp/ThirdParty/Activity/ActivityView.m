//
//  ActivityView.m
//  thatcloud
//
//  Created by IrØn∏∏anill on 27/12/13.
//  Copyright (c) 2013 Ink. All rights reserved.
//

#import "ActivityView.h"

@interface ActivityView ()
{
    UIView *parentView;
}
@end

@implementation ActivityView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

static ActivityView *localInstance = nil;
+(ActivityView *)activityView
{
    NSArray *outlets = [[NSBundle mainBundle] loadNibNamed:@"ActivityView" owner:self options:nil];
    for (id outlet in outlets)
    {
        if ([outlet isKindOfClass:[ActivityView class]])
        {
            localInstance = (ActivityView *)outlet;
            break;
        }
    }
    
    return localInstance;
}

-(void)setTitle:(NSString *)title
{
    for (id obj in localInstance.subviews) {
        if ([obj isKindOfClass:[UILabel class]]) {
            UILabel *lbl = (UILabel *)obj;
            [lbl setText:title];
            break;
        }
    }
}

-(void)showActivityInView:(UIView *)view
{
    parentView = view;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        localInstance.center = CGPointMake(160.0, 200.0);
    }
    else
        if (UIDeviceOrientationIsLandscape([[UIApplication sharedApplication]statusBarOrientation]))
        {
            localInstance.center = CGPointMake(500.0, 410.0);
        }
        else
        {
            localInstance.center = CGPointMake(400.0, 410.0);
        }

        
    [view addSubview:localInstance];
        
    for (id obj in localInstance.subviews) {
        if ([obj isKindOfClass:[UIActivityIndicatorView class]]) {
            UIActivityIndicatorView *act = (UIActivityIndicatorView *)obj;
            [act startAnimating];
            break;
        }
    }

}

-(void)hideActivity
{
    [localInstance removeFromSuperview];
    for (UIView *v in parentView.subviews)
    {
        if ([v isKindOfClass:[ActivityView class]]) {
            [v removeFromSuperview];
        }
    }
    localInstance = nil;
}

-(void)showBorder
{
    [[localInstance layer] setCornerRadius:8.0];
}


@end
