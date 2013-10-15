//
//  CustomAlertViewController.m
//  Angelina-New-Teacher-Universal
//
//  Created by Max Ehle on 2011-06-03.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import "CustomAlertViewController.h"
#import "AlertAnimations.h"
#import <QuartzCore/QuartzCore.h>

@interface CustomAlertViewController()
- (void)alertDidFadeOut;
@end

@implementation CustomAlertViewController
@synthesize internetView, leaveAppView, paintSaveView, readView, paintSavedView;
@synthesize backgroundView;
@synthesize leaveToWebsiteView;
@synthesize leaveToItunesView;
@synthesize leaveToAppStoreView;

@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        //get rid of the alert view when entering background
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(terminate) 
                                                     name: UIApplicationDidEnterBackgroundNotification
                                                   object: nil];
    }
    
    return self;
}

#pragma mark -
#pragma mark IBActions
- (void)show:(UIView*)starter {
    [self show:starter withOverlay:YES];
}

- (void)show:(UIView*)starter withOverlay:(BOOL)overlay {
    // Retaining self is odd, but we do it to make this "fire and forget"
    [self retain];
    
    // We need to add it to the window, which we can get from the delegate
    //id appDelegate = [[UIApplication sharedApplication] delegate];
    //UIWindow *window = [appDelegate window];
    //UIViewController *rootViewController = [appDelegate rootViewController];
    
//    Angelina_AppDelegate *appDelegate = [Angelina_AppDelegate get];
//    ThomasRootViewController *rootViewController = [appDelegate myRootViewController];
    
    //[window addSubview:self.view];
    
//    [rootViewController.view addSubview:self.view];
//    [rootViewController.view bringSubviewToFront:self.view];
    
    // Make sure the alert covers the whole window
    //self.view.frame = rootViewController.view.frame;
    //self.view.center = rootViewController.view.center;
    
    [starter addSubview:self.view];
    [starter bringSubviewToFront:self.view];
    
    //set view
    switch (self.view.tag) {
        case CAVCInternetAlert:
            [internetView setHidden:NO];
            break;
        case CAVCLeaveAppAlert:
            [leaveAppView setHidden:NO];
            break;
        case CAVCPaintSaveAlert:
            [paintSaveView setHidden:NO];
            break;
        case CAVCReadAlert:
            [readView setHidden:NO];
            break;
        case CAVCPaintSavedAlert:
            [paintSavedView setHidden:NO];
            break;
        case CAVCLeaveToWebsiteAlert:
            [leaveToWebsiteView setHidden:NO];
            break;
        case CAVCLeaveToItunesAlert:
            [leaveToItunesView setHidden:NO];
            break;
        case CAVCLeaveToAppStoreAlert:
            [leaveToAppStoreView setHidden:NO];
            break;
        default:
            break;
            

    }    
    
    // "Pop in" animation for alert
//    [alertView doPopInAnimationWithDelegate:self];
    
    // "Fade in" animation for background
    if (overlay) {
        [backgroundView doFadeInAnimation];
    }
}



- (IBAction)dismiss:(id)sender {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2555];
    self.view.alpha = 0.0;
    [UIView commitAnimations];
    
    [self performSelector:@selector(alertDidFadeOut:) withObject:sender afterDelay:0.2555];
}

//get rid of the alert view
-(void)terminate {
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    [self.view removeFromSuperview];
    [self autorelease];
}

#pragma mark -
- (void)viewDidUnload {
    self.internetView   = nil;
    self.leaveAppView   = nil;
    self.paintSaveView  = nil;
    self.readView       = nil;
    self.paintSavedView = nil;
    
    self.backgroundView = nil;
    
    [self setLeaveToWebsiteView:nil];
    [self setLeaveToItunesView:nil];
    [self setLeaveToAppStoreView:nil];
    [super viewDidUnload];

}

#pragma mark -
#pragma mark Private Methods
- (void)alertDidFadeOut:(id)sender {
    if ([sender tag] == CAVCButtonTagOk) {
        [delegate CustomAlertViewController:self wasDismissedWithValue:@"Ok"];
    }
    else if (sender == self || [sender tag] == CAVCButtonTagResume)
    {
        [delegate CustomAlertViewController:self wasDismissedWithValue:@"Resume"];
    }
    else if (sender == self || [sender tag] == CAVCButtonTagPage1)
    {
        [delegate CustomAlertViewController:self wasDismissedWithValue:@"Page1"];
    }
    else if (sender == self || [sender tag] == CAVCButtonTagContinue)
    {
        [delegate CustomAlertViewController:self wasDismissedWithValue:@"Continue"];
    }
    else
    {
        if ([delegate respondsToSelector:@selector(CAVCWasCancelled:)])
            [delegate CAVCWasCancelled:self];
    } 

    
    [self.view removeFromSuperview];
    [self autorelease];
}

#pragma mark -
#pragma mark CAAnimation Delegate Methods
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
}

#pragma mark -
#pragma mark Text Field Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self dismiss:self];
    return YES;
}

- (void)dealloc {
    [leaveToWebsiteView release];
    [leaveToItunesView release];
    [leaveToAppStoreView release];
    [super dealloc];
}
@end
