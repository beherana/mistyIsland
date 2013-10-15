//
//  MatchMenuViewController.m
//  Misty-Island-Rescue-Universal
//
//  Created by Henrik Nord on 2/19/11.
//  Copyright 2011 Haunted House. All rights reserved.
//

#import "MatchMenuViewController.h"
#import "MemoryMatchViewController.h"

#import "cdaAnalytics.h"

@implementation MatchMenuViewController

@synthesize menuHolder, memoryholder;

-(void) initWithParent: (id) parent
{
	NSLog(@"init with parent called in Match");
	self=[super init];
	if (self){
		myParent=parent;
	}
	return;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[self redrawMenu];
}

- (void) redrawMenu {
	
	if (memoryloaded) {
		[[cdaAnalytics sharedInstance] endTimedEvent:@"Playing_Match_game"];
		memoryloaded = NO;
		[self.memoryholder.view removeFromSuperview];
        self.memoryholder = nil;
        //[memoryholder release];
	}
	
	/**/
	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	//add view for holding menu for buttons
	menuHolder = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:menuHolder];
	//
	float mywidth = self.view.bounds.size.width;
	float myheight = self.view.bounds.size.height;
	//add title
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *imagePath = [bundle pathForResource:[NSString stringWithFormat:@"selectmatchlevel"] ofType:@"png"];
	UIImageView *tempView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imagePath]];
	CGRect titleframe = CGRectMake((mywidth - tempView.frame.size.width)/2, 19.0, tempView.frame.size.width, tempView.frame.size.height);
	tempView.frame = titleframe;
	[menuHolder addSubview:tempView];
	[tempView release];
	//add main menu button
	UIButton *homebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homebutton setShowsTouchWhenHighlighted:YES];
	[homebutton addTarget:self action:@selector(returnToMainMenuFromMatch:) forControlEvents:UIControlEventTouchUpInside];
	NSString *buttonImagePath = [bundle pathForResource:[NSString stringWithFormat:@"mainmenubutton_iPhone"] ofType:@"png"];
	[homebutton setBackgroundImage:[UIImage imageWithContentsOfFile:buttonImagePath] forState:UIControlStateNormal];
	CGRect homebuttonframe = CGRectMake(-1, 4, 51, 47);
	homebutton.frame = homebuttonframe;
	[menuHolder addSubview:homebutton];
	/**/
	//add buttons
	float leftedgedistance = 99.0;
	float rightedgedistance = 99.0;
	float bottomedgedistance = 76.0;
	float buttonwidth = 90.0;
	float buttonheight = 129.0;
	
	UIButton *easymatch = [UIButton buttonWithType:UIButtonTypeCustom];
    [easymatch setShowsTouchWhenHighlighted:YES];
	[easymatch addTarget:self action:@selector(easyMatchSelected:) forControlEvents:UIControlEventTouchUpInside];
	NSString *easyImagePath = [bundle pathForResource:[NSString stringWithFormat:@"easymatchbutton"] ofType:@"png"];
	[easymatch setBackgroundImage:[UIImage imageWithContentsOfFile:easyImagePath] forState:UIControlStateNormal];
	CGRect easybuttonframe = CGRectMake(leftedgedistance, myheight - (bottomedgedistance+buttonheight) , buttonwidth, buttonheight);
	easymatch.frame = easybuttonframe;
	[menuHolder addSubview:easymatch];
	//
	UIButton *hardmatch = [UIButton buttonWithType:UIButtonTypeCustom];
    [hardmatch setShowsTouchWhenHighlighted:YES];
	[hardmatch addTarget:self action:@selector(hardMatchSelected:) forControlEvents:UIControlEventTouchUpInside];
	NSString *hardImagePath = [bundle pathForResource:[NSString stringWithFormat:@"hardmatchbutton"] ofType:@"png"];
	[hardmatch setBackgroundImage:[UIImage imageWithContentsOfFile:hardImagePath] forState:UIControlStateNormal];
	CGRect hardbuttonframe = CGRectMake(mywidth - (rightedgedistance + buttonwidth), myheight - (bottomedgedistance+buttonheight) , buttonwidth, buttonheight);
	hardmatch.frame = hardbuttonframe;
	[menuHolder addSubview:hardmatch];
	//
	//[self animateMenu];
	//temp
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	
}
- (void) animateMenu {
	
}
- (void) cleanUpMenu {
	[menuHolder removeFromSuperview];
}
- (void) zoomSelectedMatch:(int)myselected {
	/*MemoryMatchViewController *memoryMatch = [[MemoryMatchViewController alloc] initWithParentAndLevel:self level:myselected];
	memoryloaded = YES;
	[self cleanUpMenu];
	[self.view addSubview:memoryMatch.view];
	 */
	
	//FLURRY
	[[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"MATCH started with level of difficulty: %i", myselected]];
	[[cdaAnalytics sharedInstance] trackEvent:@"Playing_Match_game" timed:YES];
	//
	MemoryMatchViewController *memoryMatch = [[MemoryMatchViewController alloc] initWithParentAndLevel:self level:myselected];
    self.memoryholder = memoryMatch;	
    [memoryMatch release];
    
	memoryloaded = YES;
	[self cleanUpMenu];
	[self.view addSubview:memoryholder.view];
	
}

-(IBAction) easyMatchSelected:(id)sender {
	[self zoomSelectedMatch:0];
}
-(IBAction) hardMatchSelected:(id)sender {
	[self zoomSelectedMatch:1];
}

- (IBAction) returnToMainMenuFromMatch:(id)sender {
	[myParent playFXEventSound:@"mainmenu"];

	[myParent navigateFromMainMenuWithItem:2];
}
-(void)playFXEventSound:(NSString*)sound {
	[myParent playFXEventSound:sound];
}
- (void)playCardSound:(int)sound {
	[myParent playCardSound:sound];
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    if (self.memoryholder != nil) {
        [self.memoryholder.view removeFromSuperview];
        self.memoryholder = nil;
    }
	[menuHolder release];
	//NSLog(@"released?");
    [super dealloc];
}


@end
