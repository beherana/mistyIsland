//
//  SettingsInformationScroll_iPhone.m
//  ThomasSettings
//
//  Created by Radif Sharafullin on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsInformationScroll_iPhone.h"
#import <SystemConfiguration/SCNetworkReachability.h>
#include <netinet/in.h>
@interface SettingsInformationScroll_iPhone (topSecret)
- (BOOL) connectedToNetwork;
-(void) showAlert:(NSString*)title message:(NSString*)message;
-(void)displayComposerSheet;
@end

@implementation SettingsInformationScroll_iPhone
@synthesize imgView, vc, sv, willOpenUrl;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		UIView *rule=[[[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 1)] autorelease];
		rule.backgroundColor=[UIColor colorWithRed:84.0f/255.0f green:188.0f/255.0f blue:275.0f/255.0f alpha:1.0f];
		[rule setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		[self addSubview:rule];
		
		sv=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 1, self.frame.size.width, self.frame.size.height-1)];
		sv.showsVerticalScrollIndicator=NO;
		sv.showsHorizontalScrollIndicator=NO;
		
		imgView=[[UIImageView alloc]initWithFrame:sv.bounds];
		[sv addSubview:imgView];
		[self addSubview:sv];
		
		UIImageView *fade=[[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bottomFadeSettigns.png"]]autorelease];
		fade.frame=CGRectMake(0, self.frame.size.height-fade.frame.size.height, self.frame.size.width, fade.frame.size.height);
		fade.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
		[self addSubview:fade];
		
		
    }
    return self;
}
-(void)addEmailButton{
	UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
	button.frame=CGRectMake(5, 1809, 222, 25);
	button.showsTouchWhenHighlighted=YES;
	[button addTarget:self action:@selector(sendEmail) forControlEvents:UIControlEventTouchUpInside];
	[imgView addSubview:button];
	imgView.userInteractionEnabled=YES;
	
}

//add buttons to callaway and hits homepages
-(void)addHomepageLinkButtons {
    UIButton *callawayButton=[UIButton buttonWithType:UIButtonTypeCustom];
	callawayButton.frame=CGRectMake(50, 70, 160, 130);
	[callawayButton addTarget:self action:@selector(btnCallawayAction) forControlEvents:UIControlEventTouchUpInside];
	[imgView addSubview:callawayButton];
    
    UIButton *hitButton=[UIButton buttonWithType:UIButtonTypeCustom];
	hitButton.frame=CGRectMake(240, 70, 140, 130);
	[hitButton addTarget:self action:@selector(btnHITAction) forControlEvents:UIControlEventTouchUpInside];
	[imgView addSubview:hitButton];
    
    /* some code to help visualize the button placement
    hitButton.backgroundColor = [UIColor yellowColor];
    hitButton.alpha = 0.3f;
    callawayButton.backgroundColor = [UIColor redColor];
    callawayButton.alpha = 0.3f;
     */

    
	imgView.userInteractionEnabled=YES;
    
}
-(void)setContentsImage:(UIImage *)contents{

	imgView.frame=CGRectMake(0, 0, contents.size.width, contents.size.height);
	imgView.image=contents;
	sv.contentSize=CGSizeMake(contents.size.width, contents.size.height);
}


- (void)dealloc {
	[sv release];
	[imgView release];
    self.willOpenUrl = nil;

    [super dealloc];
}


-(void)sendEmail{
	if ([MFMailComposeViewController canSendMail]) {
		[self displayComposerSheet];
	} else {
		NSString *title = @"Sorry!";
		NSString *message = @"You need to have an email account set up on your device in order to send an email from it.";
		[self showAlert:title message:message];
	}
}
	
-(void)displayComposerSheet{
	
	if ([self connectedToNetwork] == NO) {
		//no network - no email
		NSString *title = @"Can't send email!";
		NSString *message = @"You need an active internet connection to send your support request. Please make sure you're connected to a network before trying to send your request.";
		[self showAlert:title message:message];
		
		return;
	}
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:[NSString stringWithFormat:@"Thomas Misty Island Resque v%@ (iPhone) Support request",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] ]];
	
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"support@callaway.com"];
	
	[picker setToRecipients:toRecipients];
	
	// Fill out the email body text
	NSString *emailBody = @"";
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self.vc presentModalViewController:picker animated:YES];
    [picker release];
}
-(void) showAlert:(NSString*)title message:(NSString*)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}
#pragma mark Check for Internet Connection
- (BOOL) connectedToNetwork
{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
	
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
    if (!didRetrieveFlags)
    {
        printf("Error. Could not recover network reachability flags\n");
        return 0;
    }
	
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
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
	[self.vc dismissModalViewControllerAnimated:YES];
}

//leaving app or no network dialogue
#pragma mark -
#pragma mark linking
//leaving app or no network dialogue
- (void)showLeavingAppAlert
{
    CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
    alert.delegate = self;
    alert.view.tag = [NetworkUtils connectedToNetwork] ? CAVCLeaveToWebsiteAlert : CAVCInternetAlert;
    [alert show:[[self.sv superview] superview]];
    [alert release];	
}

- (void)CustomAlertViewController:(CustomAlertViewController *)alert wasDismissedWithValue:(NSString *)value
{
    if (alert.view.tag == CAVCLeaveToWebsiteAlert) {
        if ([value isEqualToString:@"Continue"]) {
            [[UIApplication sharedApplication] openURL:self.willOpenUrl];
        }
    }
    
    self.willOpenUrl = nil;
}

- (IBAction)btnCallawayAction {
    self.willOpenUrl = [NSURL URLWithString:@"http://www.callaway.com"];
    
    [self showLeavingAppAlert];
}

- (IBAction)btnHITAction {
    self.willOpenUrl = [NSURL URLWithString:@"http://www.hitentertainment.com"];
    
    [self showLeavingAppAlert];
}


@end
