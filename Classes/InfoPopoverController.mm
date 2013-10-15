    //
//  InfoPopoverController.mm
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 12/2/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "InfoPopoverController.h"
#include "Misty_Island_Rescue_iPadAppDelegate.h"
#include "NetworkUtils.h"

@interface InfoPopoverController (PrivateMethods)
-(void) showAlert:(NSString*)title message:(NSString*)message;
-(void)launchMailAppOnDevice;
-(void)displayComposerSheet;
@end

@implementation InfoPopoverController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	scroller.contentSize=CGSizeMake(375, 1550);
	info = [UIImage imageNamed:@"info_text.png"];
	info_uk = [UIImage imageNamed:@"info_text_uk.png"];
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = (Misty_Island_Rescue_iPadAppDelegate *)[[UIApplication sharedApplication] delegate];
	if ([[appDelegate getCurrentLanguage] isEqualToString:@"en_GB"]) {
		infotext.image = info_uk;
	} else {
		infotext.image = info;
	}
}

-(IBAction) emailSupport:(id)sender {
	if ([MFMailComposeViewController canSendMail]) {
		[self displayComposerSheet];
	} else {
		NSString *title = @"Sorry!";
		NSString *message = @"You need to have an email account set up on your device in order to send an email from it.";
		[self showAlert:title message:message];
	}

}
#pragma mark -
#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet 
{
	
	if ([NetworkUtils connectedToNetwork] == NO) {
		//no network - no email
		NSString *title = @"Can't send email!";
		NSString *message = @"You need an active internet connection to send your support request. Please make sure you're connected to a network before trying to send your request.";
		[self showAlert:title message:message];
		
		return;
	}
	
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
		[picker setSubject:[NSString stringWithFormat:@"Thomas Misty Island Resque v%@ (iPad) Support request",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"] ]];
	
	
	// Set up recipients
	NSArray *toRecipients = [NSArray arrayWithObject:@"support@callaway.com"];
	
	[picker setToRecipients:toRecipients];
	
	// Fill out the email body text
	NSString *emailBody = @"";
	[picker setMessageBody:emailBody isHTML:NO];
	
	[self presentModalViewController:picker animated:YES];
    [picker release];
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
-(void) showAlert:(NSString*)title message:(NSString*)message {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}

#pragma mark -
#pragma mark Workaround

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
	NSString *recipients = @"mailto:support@callaway.com&subject=Thomas Misty Island Resque v1.2 Support request";
	NSString *body = @"&body=";
	
	NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}
#pragma mark -
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[scroller release];
	[infotext release];
    [super dealloc];
}


@end
