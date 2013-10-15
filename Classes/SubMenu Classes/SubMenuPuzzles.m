    //
//  SubMenuPuzzles.m
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/22/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "SubMenuPuzzles.h"
//#import "ThomasRootViewController.h"

//#import "Misty_Island_Rescue_iPadAppDelegate.h"

@implementation SubMenuPuzzles

@synthesize easyimage;
@synthesize easyimageSelected;
@synthesize hardimage;
@synthesize hardimageSelected;

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
-(void)initWithParent:(id)parent {
	myparent = parent;
	//start up a puzzle
	//start a puzzle
	/*
	srandom(time(NULL));
	int chosen = random() %  4;
	[myparent preStartJigsawPuzzle:chosen+1];
	UIView *selected = [self.view viewWithTag:chosen+1];
	selectframe.center = selected.center;
	 */
	[self menuTappedWithThumb:[myparent getCurrentPuzzlePage]];
}

/*
*/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//change this later so that is gets the latest selected value
	levelOfDifficulty = [myparent getPuzzleDifficulty];
	self.easyimage = [UIImage imageNamed:@"easy_button_unselected.png"];
	self.easyimageSelected = [UIImage imageNamed:@"easy_button_selected.png"];
	self.hardimage = [UIImage imageNamed:@"difficult_unselected.png"];
	self.hardimageSelected = [UIImage imageNamed:@"difficult_selected.png"];
	if (levelOfDifficulty == 0) {
		easybutton.image = easyimageSelected;
	} else {
		hardbutton.image = hardimageSelected;
	}

}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	int tag = touch.view.tag;
	if (tag > 0 && tag < 7) {
		[self menuTappedWithThumb:tag];
	} else if (tag == 7) {
		if (levelOfDifficulty == 1) {
			levelOfDifficulty = 0;
			easybutton.image = easyimageSelected;
			hardbutton.image = hardimage;
			[myparent hideShowSubMenu:YES];
			[myparent setPuzzleLevelOfDifficulty:levelOfDifficulty];
		}
	} else if (tag == 8) {
		if (levelOfDifficulty == 0) {
			levelOfDifficulty = 1;
			hardbutton.image = hardimageSelected;
			easybutton.image = easyimage;
			[myparent hideShowSubMenu:YES];
			[myparent setPuzzleLevelOfDifficulty:levelOfDifficulty];
		}
	}
	
	//Misty_Island_Rescue_iPadAppDelegate *appDelegate = (Misty_Island_Rescue_iPadAppDelegate *)[[UIApplication sharedApplication] delegate];
	//[appDelegate preStartJigsawPuzzle:mybase];
}

-(void)menuTappedWithThumb:(int)thumb {
	//NSLog(@"This is the selected puzzle: %i", thumb);
	UIView *tapped = [self.view viewWithTag:thumb];
	selectframe.center = tapped.center;
	selectedPuzzle = thumb;
	[myparent hideShowSubMenu:YES];
	[myparent preStartJigsawPuzzle:thumb];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


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
	[selectframe release];
	[easybutton release];
	[hardbutton release];
    self.easyimage = nil;
    self.easyimageSelected = nil;
    self.hardimage = nil;
    self.hardimageSelected = nil;
    [super dealloc];
}


@end
