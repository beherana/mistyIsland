//
//  CustomAlertViewController.h
//  Angelina-New-Teacher-Universal
//
//  Created by Max Ehle on 2011-06-03.
//  Copyright 2011 Commind AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum 
{
    CAVCButtonTagOk = 1000,
    CAVCButtonTagCancel,
    CAVCButtonTagResume,
    CAVCButtonTagPage1,
    CAVCButtonTagContinue
};

enum {
    CAVCInternetAlert = 1,
    CAVCLeaveAppAlert,
    CAVCPaintSaveAlert,
    CAVCReadAlert,
    CAVCPaintSavedAlert,
    CAVCLeaveToWebsiteAlert,
    CAVCLeaveToItunesAlert,
    CAVCLeaveToAppStoreAlert
};


@class CustomAlertViewController;

@protocol CustomAlertViewControllerDelegate
@required
- (void) CustomAlertViewController:(CustomAlertViewController *)alert wasDismissedWithValue:(NSString *)value;

@optional
- (void) CAVCWasCancelled:(CustomAlertViewController *)alert;
@end


@interface CustomAlertViewController : UIViewController <UITextFieldDelegate>
{
    UIView *internetView;
    UIView *leaveAppView;
    UIView *paintSaveView;
    UIView *readView;
    UIView *paintSavedView;
    UIView *backgroundView;
    UIView *leaveToWebsiteView;
    UIView *leaveToItunesView;
    UIView *leaveToAppStoreView;
    
    id<NSObject, CustomAlertViewControllerDelegate> delegate;
}
@property (nonatomic, retain) IBOutlet UIView *internetView;
@property (nonatomic, retain) IBOutlet UIView *leaveAppView;
@property (nonatomic, retain) IBOutlet UIView *paintSaveView;
@property (nonatomic, retain) IBOutlet UIView *readView;
@property (nonatomic, retain) IBOutlet UIView *paintSavedView;
@property (nonatomic, retain) IBOutlet UIView *backgroundView;
@property (nonatomic, retain) IBOutlet UIView *leaveToWebsiteView;
@property (nonatomic, retain) IBOutlet UIView *leaveToItunesView;
@property (nonatomic, retain) IBOutlet UIView *leaveToAppStoreView;


@property (nonatomic, assign) IBOutlet id<CustomAlertViewControllerDelegate, NSObject> delegate;

- (void)show:(UIView*)starter;
- (void)show:(UIView*)starter withOverlay:(BOOL)overlay;
- (void)terminate;
- (IBAction)dismiss:(id)sender;
@end