//
//  LandingPageTabsViewController.h
//  Misty-Island-Rescue-Universal
//
//  Created by Karl Söderström on 2011-08-04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertViewController.h"
#import "WebViewHelper.h"
#import <MessageUI/MFMailComposeViewController.h>


typedef enum {
    LandingPage_TabShown_None = 0,
    LandingPage_TabShown_Info,
    LandingPage_TabShown_MoreApps
} LandingPage_TabShown;

@interface LandingPageTabsViewController : UIViewController <CustomAlertViewControllerDelegate, MFMailComposeViewControllerDelegate> {

    IBOutlet UIView *overlay;
    IBOutlet UIView *infoTab;
    IBOutlet UIView *moreAppsTab;
    IBOutlet UIScrollView *infoScrollView;
    IBOutlet UIView *copyView;
    IBOutlet UIScrollView *followScrollView;
    IBOutlet UIImageView *followImage;
    IBOutlet UIImageView *infoImage;
    IBOutlet UIImageView *noConnectionImage;
    IBOutlet UIWebView *webView;
    IBOutlet UIButton *infoButton;
    IBOutlet UIButton *infoTabCloseButton;
    IBOutlet UIButton *moreAppsButton;
    IBOutlet UIButton *moreAppsTabCloseButton;

    MFMailComposeViewController *mailComposerController;

LandingPage_TabShown tabShown;

WebViewHelper *webViewHelper;

NSURL *_willOpenUrl;
}

@property (nonatomic, retain) NSURL *willOpenUrl;
@property (nonatomic, retain) WebViewHelper *webViewHelper;
@property (nonatomic, retain) MFMailComposeViewController *mailComposerController;

- (IBAction)btnInfoTabAction:(id)sender;
- (IBAction)btnMoreAppsTabAction:(id)sender;
- (IBAction)btnFacebookAction:(id)sender;
- (IBAction)btnTwitterAction:(id)sender;
- (IBAction)btnOfficialThomasAction:(id)sender;
- (IBAction)btnCallawayAction:(id)sender;
- (IBAction)btnHITAction:(id)sender;
- (IBAction)btnGiftAction:(id)sender;
- (IBAction)btnEmailSupport:(id)sender;

-(void)addVersionLabelToFollowView;
-(void)openUrl:(NSURL *)url;

-(void)displayComposerSheet;
-(void) showAlert:(NSString*)title message:(NSString*)message;

@end
