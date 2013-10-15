//
//  MoreAppsMainViewController.m
//  Misty-Island-Rescue-Universal
//
//  Created by Martin Kamara on 2011-07-27.
//  Copyright 2011 Commind. All rights reserved.
//

#import "MoreAppsMainViewController.h"
#import "NetworkUtils.h"
//#import "Misty_Island_Rescue_iPadAppDelegate.h"


@implementation MoreAppsMainViewController

@synthesize parentController;
@synthesize willOpenUrl;
@synthesize webViewHelper;

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    //load web view helper
    if (self.webViewHelper==nil) {
        NSString *url;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] >= 2){
            //use highres url
            url = @"http://callaway.com/app_webviews/hit/misty_iphone/cross_sell/misty_iphone_cs.html";
        }
        else {
            url = @"http://callaway.com/app_webviews/hit/misty_iphone_lq/cross_sell/misty_iphone_cs.html";
        }
        WebViewHelper *wvTmp = [[WebViewHelper alloc] initWithWebView:webView inView:self.view forURL:url dialogueHolderView:self.view];
        self.webViewHelper = wvTmp;
        [wvTmp release];
    }
    else {
        [self.webViewHelper refresh];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.webViewHelper = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(IBAction)hide:(id)sender {
    //assume that the parent controller knows what its doing
    if (self.parentController != nil) {
        [self.parentController hideMoreAppsTab];
    }
}

-(IBAction)giftApp:(id)sender {
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
    [alert show:self.view];
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
@end
