//
//  LandingPageTabsViewController.m
//  Misty-Island-Rescue-Universal
//
//  Created by Karl Söderström on 2011-08-04.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LandingPageTabsViewController.h"
#import "NetworkUtils.h"
#import "Misty_Island_Rescue_iPadAppDelegate.h"

@implementation LandingPageTabsViewController

@synthesize willOpenUrl = _willOpenUrl;
@synthesize webViewHelper;
@synthesize mailComposerController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

//append the current version numnber to followScrollView
-(void) addVersionLabelToFollowView {
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    UILabel *versionLabel = [[UILabel alloc] init];
	versionLabel.text = [NSString stringWithFormat:@"Thomas & Friends Misty Island Rescue: Version %@", [bundleInfo objectForKey:@"CFBundleVersion"]];
    [versionLabel setFont:[UIFont fontWithName:@"Georgia" size:14]];
    [versionLabel setTextColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
    CGSize versionLabelSize = [versionLabel.text sizeWithFont:versionLabel.font constrainedToSize:followScrollView.frame.size lineBreakMode:versionLabel.lineBreakMode];
    versionLabel.contentMode = UIViewContentModeBottomLeft;
    
    //append label to scrollview
    versionLabel.frame = CGRectMake(1, followScrollView.contentSize.height+26, versionLabelSize.width, versionLabelSize.height);    
    //get current scroll view size and extend it
    CGSize scrollViewSize = followScrollView.contentSize;
    //extend content size for scroll view
    scrollViewSize.height += versionLabel.frame.size.height+26;
    followScrollView.contentSize = scrollViewSize;
    
    [followScrollView addSubview:versionLabel];
    [versionLabel release];    
}

- (void)resetTabs {
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         overlay.alpha = 0.0;
                         CGRect frame = infoTab.frame;
                         frame.origin.y = 719;
                         infoTab.frame = frame;
                         frame = moreAppsTab.frame;
                         frame.origin.y = 718;
                         moreAppsTab.frame = frame;
                     }
                     completion:^(BOOL finished) {
                         overlay.hidden = YES; 
                         
                         //enable and disable the buttons
                         moreAppsButton.userInteractionEnabled = YES;
                         infoButton.userInteractionEnabled = YES;
                         infoTabCloseButton.userInteractionEnabled = NO;
                         moreAppsTabCloseButton.userInteractionEnabled = NO;
                         //bring the open buttons to front
                         [self.view bringSubviewToFront:infoButton];
                         [self.view bringSubviewToFront:moreAppsButton];
                         
                         [[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] adjustMainMenu];
                     }];
    
    tabShown = LandingPage_TabShown_None;
}

- (void)bringToFront {
    [[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController].view bringSubviewToFront:self.view];
}

- (IBAction)btnInfoTabAction:(id)sender {
    if (tabShown == LandingPage_TabShown_None) {
        [self bringToFront];
        overlay.alpha = 0.0;
        overlay.hidden = NO;
        //disable and enable buttons
        moreAppsButton.userInteractionEnabled = NO;
        infoButton.userInteractionEnabled = NO;
        infoTabCloseButton.userInteractionEnabled = YES;
        moreAppsTabCloseButton.userInteractionEnabled = YES;
        
        [UIView animateWithDuration:0.3
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             overlay.alpha = 0.4;
                             //put the pressed tab on to of the other
                             [self.view bringSubviewToFront:infoTab];
                             CGRect frame = infoTab.frame;
                             frame.origin.y = 12;
                             infoTab.frame = frame;
                         }
                         completion:nil];
        tabShown = LandingPage_TabShown_Info;
    } else {
        [self resetTabs];
    }
}

- (IBAction)btnMoreAppsTabAction:(id)sender {
    if (tabShown == LandingPage_TabShown_None) {
        [self bringToFront];
        //populate the webview
        if (self.webViewHelper==nil) {
            WebViewHelper *wvTmp = [[WebViewHelper alloc] initWithWebView:webView inView:moreAppsTab forURL:@"http://callaway.com/app_webviews/hit/misty_ipad/cross_sell/ipad_cs.html" dialogueHolderView:self.view customNoConnectionImage:noConnectionImage customActivityIndicator:nil];
            self.webViewHelper = wvTmp;
            [wvTmp release];
        }
        else {
            [self.webViewHelper refresh];
        }
        
        overlay.alpha = 0.0;
        overlay.hidden = NO;
        //disable and enable buttons
        moreAppsButton.userInteractionEnabled = NO;
        infoButton.userInteractionEnabled = NO;
        infoTabCloseButton.userInteractionEnabled = YES;
        moreAppsTabCloseButton.userInteractionEnabled = YES;
        
        [UIView animateWithDuration:0.3
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut 
                         animations:^{
                             overlay.alpha = 0.4;
                             //put the pressed tab on to of the other
                             [self.view bringSubviewToFront:moreAppsTab];
                             CGRect frame = moreAppsTab.frame;
                             frame.origin.y = 9;
                             moreAppsTab.frame = frame;
                         }
                         completion:nil];
        tabShown = LandingPage_TabShown_MoreApps;
    } else {
        [self resetTabs];
    }
}

//leaving app or no network dialogue
- (void)showLeavingAppAlert
{
    CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
    alert.delegate = self;
    if ([NetworkUtils connectedToNetwork]) {
        NSString *fragment = [self.willOpenUrl fragment];
        if ([fragment isEqualToString:@"itunes"]) {
            alert.view.tag = CAVCLeaveToItunesAlert;
        } else if ([fragment isEqualToString:@"appstore"]) {
            alert.view.tag = CAVCLeaveToAppStoreAlert;
        } else {
            alert.view.tag = CAVCLeaveToWebsiteAlert;
        }
    } else {
        alert.view.tag = CAVCInternetAlert;
    }

    [alert show:self.view];
    [alert release];	
}

- (void)CustomAlertViewController:(CustomAlertViewController *)alert wasDismissedWithValue:(NSString *)value
{
    if ([value isEqualToString:@"Continue"]) {
        [self openUrl:self.willOpenUrl];
    }
    
    self.willOpenUrl = nil;
}

- (void)openUrl:(NSURL *)url {
    //reset state before continuing
    [self resetTabs];
    
    //goto the url
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)btnFacebookAction:(id)sender {
    self.willOpenUrl = [NSURL URLWithString:@"http://www.facebook.com/Thomasandfriends"];
    
    [self showLeavingAppAlert];
}

- (IBAction)btnTwitterAction:(id)sender {
    self.willOpenUrl = [NSURL URLWithString:@"http://twitter.com/#!/trueblueengine"];
    
    [self showLeavingAppAlert];
}

- (IBAction)btnOfficialThomasAction:(id)sender {
    self.willOpenUrl = [NSURL URLWithString:@"http://m.thomasandfriends.com"];
    
    [self showLeavingAppAlert];
}

- (IBAction)btnCallawayAction:(id)sender {
    self.willOpenUrl = [NSURL URLWithString:@"http://www.callaway.com"];
    
    [self showLeavingAppAlert];
}

- (IBAction)btnHITAction:(id)sender {
    self.willOpenUrl = [NSURL URLWithString:@"http://www.hitentertainment.com"];
    
    [self showLeavingAppAlert];
}

- (IBAction)btnGiftAction:(id)sender {
    self.willOpenUrl = [NSURL URLWithString:@"https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/giftSongsWizard?gift=1&salableAdamId=408089724&productType=C&pricingParameter=STDQ#itunes"];
    
    [self showLeavingAppAlert];
}

-(IBAction)btnEmailSupport:(id)sender {
	if ([MFMailComposeViewController canSendMail]) {
		[self displayComposerSheet];
	} else {
		NSString *title = @"Sorry!";
		NSString *message = @"You need to have an email account set up on your device in order to send an email from it.";
		[self showAlert:title message:message];
	}
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //display uk info image instead
    if ([[[Misty_Island_Rescue_iPadAppDelegate get] getCurrentLanguage] isEqualToString:@"en_GB"]) {
        infoImage.image = [UIImage imageNamed:@"instructions_txt_uk.png"];
    }
    
    tabShown = LandingPage_TabShown_None;
    
    UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetTabs)] autorelease];
    [overlay addGestureRecognizer:recognizer];
    
    //determine the size of the scroll content area
    infoScrollView.contentSize = infoImage.frame.size;
    CGSize followSize = followImage.frame.size;
    followSize.height += followImage.frame.origin.y;
    followSize.height += copyView.frame.size.height;
    followScrollView.contentSize = followSize;
    
    //Version label - append current version to the scrollview
    [self addVersionLabelToFollowView];
    
    
    infoTab.alpha = 0.0;
    moreAppsTab.alpha = 0.0;
    [UIView animateWithDuration:0.2 animations:^{
        infoTab.alpha = 1.0;
        moreAppsTab.alpha = 1.0;
    }];

}

- (void)viewDidUnload {
    [overlay release];
    overlay = nil;
    [infoTab release];
    infoTab = nil;
    [moreAppsTab release];
    moreAppsTab = nil;
    [infoScrollView release];
    [followScrollView release];
    infoScrollView = nil;
    followScrollView = nil;
    [copyView release];
    copyView = nil;
    [noConnectionImage release];
    noConnectionImage = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark -
#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet 
{
	
    //prompt the user if not connected to network
    if (![NetworkUtils connectedToNetwork]) {
        CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
        alert.delegate = self;
        alert.view.tag = CAVCInternetAlert;
        
        [alert show:self.view];
        [alert release];	
		
		return;
	}
	
	self.mailComposerController = [[[MFMailComposeViewController alloc] init] autorelease];
	self.mailComposerController.mailComposeDelegate = self;
	
    [self.mailComposerController setSubject:[NSString stringWithFormat:@"Thomas & Friends Misty Island Rescue Version v%@ (iPad) Support request",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] ]];
	
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"support@callaway.com"];
	
	[self.mailComposerController setToRecipients:toRecipients];
	
	// Fill out the email body text
	NSString *emailBody = @"";
	[self.mailComposerController setMessageBody:emailBody isHTML:NO];
	
	[self presentModalViewController:self.mailComposerController animated:YES];
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	//message.hidden = NO;
	// Notifies users about errors associated with the interface
	NSString *title = @"";
	NSString *message = @"";
	
	switch (result)
	{
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved:
			title = @"Message saved!";
			message = @"Your messade has been saved.";
			[self showAlert:title message:message];
			break;
		case MFMailComposeResultSent:
			title = @"Message sent!";
			message = @"Your support request has been sent. We will get back to you shortly.";
			[self showAlert:title message:message];
			break;
		case MFMailComposeResultFailed:
			title = @"Failed to send!";
			message = @"There was an error. Your email has not been sent.";
			[self showAlert:title message:message];
			break;
		default:
			title = @"Failed to send!";
			message = @"There was an error. Your email has not been sent.";
			[self showAlert:title message:message];
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
}

//TEMP old alert
-(void) showAlert:(NSString*)title message:(NSString*)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}



- (void)dealloc
{
    [self.mailComposerController dismissModalViewControllerAnimated:NO];
    self.mailComposerController.delegate =nil;
    self.mailComposerController = nil;
    
    [overlay release];
    [infoTab release];
    [moreAppsTab release];
    [infoScrollView release];
    [followScrollView release];
    
    self.webViewHelper = nil;
    [copyView release];

    [noConnectionImage release];
    [super dealloc];
}

@end
