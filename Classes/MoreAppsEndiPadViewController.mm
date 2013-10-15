//
//  MoreAppsEndiPadViewController.m
//  Misty-Island-Rescue-Universal
//
//  Created by Martin Kamara on 2011-07-26.
//  Copyright 2011 Commind. All rights reserved.
//

#import "MoreAppsEndiPadViewController.h"
#import "NetworkUtils.h"
#import "Misty_Island_Rescue_iPadAppDelegate.h"

@implementation MoreAppsEndiPadViewController

@synthesize moreAppsView, moreAppsTicketView, endTicketView, willOpenUrl, webViewHelper;

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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UISwipeGestureRecognizer *recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeAction:)] autorelease];
    recognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:recognizer];
}

- (void)viewDidUnload
{
    [webActivityIndicator release];
    webActivityIndicator = nil;
    [webNoConnectionImage release];
    webNoConnectionImage = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(void)swipeAction:(UISwipeGestureRecognizer *)recognizer {
	if ([[Misty_Island_Rescue_iPadAppDelegate get] getSwipeInReadIsTurnedOff]) {
		return;
	}
	if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
		[[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] turnpage:NO];
    }
}

- (IBAction)backgroundClick:(id)sender {
    [[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] hideDotsSubMenu];
}

-(IBAction)moreAppsButtonClick:(id)sender {
    
    [[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] hideDotsSubMenu];
    
    if (self.moreAppsTicketView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"MoreAppsEndPageiPad" owner:self options:nil];
        
        //populate the webview
        if (self.webViewHelper==nil) {
            WebViewHelper *wvTmp = [[WebViewHelper alloc] initWithWebView:webView inView:self.moreAppsTicketView forURL:@"http://callaway.com/app_webviews/hit/misty_ipad/gift/misty_ipad_gift.html" dialogueHolderView:[self.view superview] customNoConnectionImage:webNoConnectionImage customActivityIndicator:webActivityIndicator];
            self.webViewHelper = wvTmp;
            [wvTmp release];
        }
    }
    else if (self.moreAppsTicketView && self.webViewHelper) {
        [self.webViewHelper refresh];
    }

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.endTicketView cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

    
    [self.endTicketView addSubview:self.moreAppsView];
    [UIView commitAnimations];

}

-(IBAction)backButtonClick:(id)sender {
    [[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] hideDotsSubMenu];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.endTicketView cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

    
    [self.moreAppsView removeFromSuperview];
    [UIView commitAnimations];
}

-(IBAction)giftAppButtonClick:(id)sender {
    self.willOpenUrl = [NSURL URLWithString:@"https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/giftSongsWizard?gift=1&salableAdamId=408089724&productType=C&pricingParameter=STDQ"];
    [self showLeavingAppAlert];
}

#pragma mark -
#pragma mark linking
//leaving app or no network dialogue
- (void)showLeavingAppAlert
{
    CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
    alert.delegate = self;
    alert.view.tag = [NetworkUtils connectedToNetwork] ? CAVCLeaveToItunesAlert : CAVCInternetAlert;
    [alert show:[self.view superview]];
    [alert release];	
}

- (void)CustomAlertViewController:(CustomAlertViewController *)alert wasDismissedWithValue:(NSString *)value
{
    if (alert.view.tag == CAVCLeaveToItunesAlert) {
        if ([value isEqualToString:@"Continue"]) {
            [[UIApplication sharedApplication] openURL:self.willOpenUrl];
        }
    }
    
    self.willOpenUrl = nil;
}

- (void)dealloc {

    self.webViewHelper = nil;
    self.moreAppsTicketView = nil;
    self.endTicketView = nil;
    self.willOpenUrl = nil;
    
    [webActivityIndicator release];
    [webNoConnectionImage release];
    [super dealloc];
}


@end
