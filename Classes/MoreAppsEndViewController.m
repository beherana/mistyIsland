//
//  MoreAppsEndViewController.m
//  Misty-Island-Rescue-Universal
//
//  Created by Martin Kamara on 2011-07-26.
//  Copyright 2011 Commind. All rights reserved.
//

#import "MoreAppsEndViewController.h"
#import "NetworkUtils.h"

@implementation MoreAppsEndViewController

@synthesize willOpenUrl, webViewHelper;

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
    //load the webview
    if (self.webViewHelper==nil) {
        NSString *url;
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] >= 2){
            //use highres url
            url = @"http://callaway.com/app_webviews/hit/misty_iphone/gift/misty_iphone_gift.html";
        }
        else {
            url = @"http://callaway.com/app_webviews/hit/misty_iphone_lq/gift/misty_iphone_gift.html";
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
    self.webViewHelper = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(IBAction)closeWindow:(id)sender {
    self.view.alpha = 0.0f;
}

-(IBAction)giftThisApp:(id)sender {
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


- (void)dealloc {
    self.willOpenUrl = nil;
    self.webViewHelper = nil;
    
    [super dealloc];
}

@end
