    //
//  LandingPageViewController.m
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/15/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "LandingPageViewController.h"
#import "Misty_Island_Rescue_iPadAppDelegate.h"
#import "cdaAnalytics.h"

@implementation LandingPageViewController

@synthesize tabs = _tabs;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabs = [[[LandingPageTabsViewController alloc] initWithNibName:@"LandingPageTabsViewController" bundle:nil] autorelease];
    [[cdaAnalytics sharedInstance] trackPage:@"/LandingPage"]; 
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self.tabs.view removeFromSuperview];
    self.tabs = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    ThomasRootViewController *rootViewController = [[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController];
    [rootViewController.view addSubview:self.tabs.view];
    [rootViewController.view bringSubviewToFront:self.tabs.view];
    [rootViewController adjustMainMenu];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}
-(IBAction) speakTitleButtonTapped:(id)sender {
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = (Misty_Island_Rescue_iPadAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate playintroPresentation];
}



-(IBAction) infoButtonClicked:(id)sender{
	popoverContent=[[InfoPopoverController alloc] initWithNibName:@"InfoPopoverController" bundle:nil];
	popover = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
	[popover setDelegate:self];
	[popover setPopoverContentSize:CGSizeMake(988,545)];
	popoverContent.contentSizeForViewInPopover=popoverContent.view.bounds.size;
	[popover presentPopoverFromRect:((UIView *)sender).frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController*)popoverController{
	if (popover) {
		[popover dismissPopoverAnimated:YES];
		[popover release];
		popover=nil;
		if (popoverContent != nil) {
			[popoverContent release];
			popoverContent = nil;
		}
	}
}
-(void)killPopoversOnSight {
	if (popover) {
		[popover dismissPopoverAnimated:NO];
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}




- (void)dealloc {
	if (popover) {
		[popover release];
		popover=nil;
	}
	if (popoverContent != nil) {
		[popoverContent release];
		popoverContent = nil;
	}
    [self.tabs.view removeFromSuperview];
    self.tabs = nil;
    [super dealloc];
}


@end
