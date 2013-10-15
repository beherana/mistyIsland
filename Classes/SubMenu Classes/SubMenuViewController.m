    //
//  SubMenuViewController.m
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/21/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "SubMenuViewController.h"
//#import "Misty_Island_Rescue_iPadAppDelegate.h"

@implementation SubmenuViewIPhone

-(id)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
	
	return [self.superview.superview hitTest:point withEvent:event];
}

@end


@interface SubMenuViewController (PrivateMethods)
-(void)removeAddSubmenuFromSection:(BOOL)hide;
-(void)addContent:(int)section;
@end

@implementation SubMenuViewController

@synthesize pageNumber;
@synthesize train;

/**/
-(void) initWithParent: (id) parent {
	//NSLog(@"Got an initcall from RootViewController");
	myparent = parent;
	iPhoneMode = [myparent getIPhoneMode];
	return;
}


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

/**/
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	subMenuIsVisible = NO;
	subMenuIsRemoved = YES;
	//[self removeAddSubmenuFromSection:subMenuIsRemoved];
}


-(void)hideShowSubMenu:(BOOL)hide {
	
	//NSLog(@"Trying to hide the sub menu with: %d", hide);
	
	float movevalue = -123.0;
	if (iPhoneMode) {
		movevalue = -137.0;
	}
	
	if (!hide && visibleInterface != 3 && [myparent getSpeakerIsPaused]) {
		[myparent setSpeakerIsPaused:NO];
	}
	if (!hide && visibleInterface == 3) {
		//update selectframe just in case
		[mySubMenuRead setCurrentPage:[myparent getCurrentReadPage]];
		[myparent pauseNarrationOnScene];
		if ([myparent getSpeakerIsDelayed]) {
			[myparent checkIfNarrationDateIsDelayed];
		}
	} else {
		if (visibleInterface == 3) {
			[myparent resumeNarrationOnScene];
		}
	}
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.3];
	if (hide) {
		//NSLog(@"Hides it");
		subMenuIsVisible = NO;
		self.view.transform = CGAffineTransformIdentity;
		if (visibleInterface == 3) {
			[myparent resumeCocos:YES];
			//Buttons are hidden for now - left in project in case navigation changes back to buttons again
			leftnavRead.alpha = 1.0;
			rightnavRead.alpha = 1.0;
			//leftnavRead.alpha = 0.0;
			//rightnavRead.alpha = 0.0;
			tracksLeftRight.alpha = 0.0;
		}
	} else {
		//NSLog(@"Shows it");
		subMenuIsVisible = YES;
		self.view.transform = CGAffineTransformTranslate(self.view.transform , 0.0, movevalue);
		if (visibleInterface == 3) {
			[myparent pauseCocos:YES];
			leftnavRead.alpha = 0.0;
			rightnavRead.alpha = 0.0;
			//tracksLeftRight.alpha = 0.0;
			tracksLeftRight.alpha = 1.0;
		}
	}
	[UIView commitAnimations];
}

-(void)addInterfaceToSubMenu:(int)interface {
	NSLog(@"this is the selected interface: %i", interface);
	visibleInterface = interface;
	
	if (iPhoneMode) {
		
		if (interface != 3 && [myparent getSpeakerIsPaused]) {
			[myparent setSpeakerIsPaused:NO];
		}
		
		if (interface == 3) {
			[self removeInterfaceFromSubMenu];
			[self addContent:interface];
			if (subMenuIsRemoved) {
				subMenuIsRemoved = NO;
				[self removeAddSubmenuFromSection:subMenuIsRemoved];
			}
			if (subMenuIsVisible) {
				[self hideShowSubMenu:subMenuIsVisible];
			}
		} else {
			[self removeInterfaceFromSubMenu];
			if (subMenuIsRemoved == NO) {
				subMenuIsRemoved = YES;
				[self removeAddSubmenuFromSection:subMenuIsRemoved];
			}
		}
		
	} else {
		//hide pagenumbers - changed - hide the wagon all togheter instead
		//if (pageNumber.hidden == NO) {
		//	pageNumber.hidden = YES;
		//}
		if (wagon.hidden == NO) {
			wagon.hidden = YES;
		}
		if (interface != 3 && [myparent getSpeakerIsPaused]) {
			[myparent setSpeakerIsPaused:NO];
		}
		if (interface == 1) {
			[self removeInterfaceFromSubMenu];
			[self addContent:interface];
			subMenuIsRemoved = YES;
			[self removeAddSubmenuFromSection:subMenuIsRemoved];
		} else if (interface == 2) {
			[self removeInterfaceFromSubMenu];
			[self addContent:interface];
			subMenuIsRemoved = YES;
			[self removeAddSubmenuFromSection:subMenuIsRemoved];
		} else if (interface == 3) {
			[self removeInterfaceFromSubMenu];
			[self addContent:interface];
			if (subMenuIsRemoved) {
				subMenuIsRemoved = NO;
				[self removeAddSubmenuFromSection:subMenuIsRemoved];
			}
			if (subMenuIsVisible) {
				[self hideShowSubMenu:subMenuIsVisible];
			}
		} else if (interface == 4) {
			[self removeInterfaceFromSubMenu];
			[self addContent:interface];
			subMenuIsRemoved = YES;
			[self removeAddSubmenuFromSection:subMenuIsRemoved];
		} else if (interface == 5) {
			[self removeInterfaceFromSubMenu];
			[self addContent:interface];
			if (subMenuIsRemoved) {
				subMenuIsRemoved = NO;
				[self removeAddSubmenuFromSection:subMenuIsRemoved];
			}
		} else if (interface == 6) {
			[self removeInterfaceFromSubMenu];
			[self addContent:interface];
			if (subMenuIsRemoved) {
				subMenuIsRemoved = NO;
				[self removeAddSubmenuFromSection:subMenuIsRemoved];
			}
			if (subMenuIsVisible) {
				[self hideShowSubMenu:subMenuIsVisible];
			}
		} else if (interface == 7) {
			[self removeInterfaceFromSubMenu];
			[self addContent:interface];
			if (subMenuIsRemoved) {
				subMenuIsRemoved = NO;
				[self removeAddSubmenuFromSection:subMenuIsRemoved];
			}
			if (subMenuIsVisible) {
				[self hideShowSubMenu:subMenuIsVisible];
			}
		}
	}
}
-(void)removeInterfaceFromSubMenu {
	//removes interface in subContentHolder
	if (mySubMenuRead != nil) {
		[mySubMenuRead.view removeFromSuperview];
		[mySubMenuRead release];
		mySubMenuRead = nil;
		[self restoreSubmenuFade];
	}
	if (mySubMenuPaint != nil) {
		[mySubMenuPaint.view removeFromSuperview];
		[mySubMenuPaint release];
		mySubMenuPaint = nil;
	}
	if (mySubMenuPuzzles != nil) {
		[mySubMenuPuzzles.view removeFromSuperview];
		[mySubMenuPuzzles release];
		mySubMenuPuzzles = nil;
	}
	if (mySubMenuDots != nil) {
		[mySubMenuDots.view removeFromSuperview];
		[mySubMenuDots release];
		mySubMenuDots = nil;
	}
}
-(void)addContent:(int)section {
	if (section == 1) {
		leftnavRead.alpha = 0.0;
		rightnavRead.alpha = 0.0;
		tracksLeftRight.alpha = 1.0;
	} else if (section == 2) {
		leftnavRead.alpha = 0.0;
		rightnavRead.alpha = 0.0;
		tracksLeftRight.alpha = 1.0;
	} else if (section == 3) {
		if (mySubMenuRead == nil) {
			mySubMenuRead = [[SubMenuRead alloc] initWithNibName:@"SubMenuRead" bundle:nil];
			[subContentHolder addSubview:mySubMenuRead.view];
			[mySubMenuRead initWithParent:self];
			//Buttons are hidden for now - left in project in case navigation changes back to buttons again
			leftnavRead.alpha = 1.0;
			rightnavRead.alpha = 1.0;
			//leftnavRead.alpha = 0.0;
			//rightnavRead.alpha = 0.0;
			//leftnavRead.hidden = YES;
			//rightnavRead.hidden = YES;
			tracksLeftRight.alpha = 0.0;
			//show wagon instead of just pagenumber
			wagon.hidden = NO;
			//pageNumber.hidden = NO;
			[self setSubmenuFade];
		}
	} else if (section == 4) {
		leftnavRead.alpha = 0.0;
		rightnavRead.alpha = 0.0;
		tracksLeftRight.alpha = 1.0;
	} else if (section == 5) {
		if (mySubMenuPaint == nil) {
			mySubMenuPaint = [[SubMenuPaint alloc] initWithNibName:@"SubMenuPaint" bundle:nil];
			[subContentHolder addSubview:mySubMenuPaint.view];
			[mySubMenuPaint initWithParent:self];
			leftnavRead.alpha = 0.0;
			rightnavRead.alpha = 0.0;
			tracksLeftRight.alpha = 1.0;
			[self restoreSubmenuFade];
		}
	} else if (section == 6) {
		if (mySubMenuPuzzles == nil) {
			mySubMenuPuzzles = [[SubMenuPuzzles alloc] initWithNibName:@"SubMenuPuzzles" bundle:nil];
			[subContentHolder addSubview:mySubMenuPuzzles.view];
			[mySubMenuPuzzles initWithParent:self];
			leftnavRead.alpha = 0.0;
			rightnavRead.alpha = 0.0;
			tracksLeftRight.alpha = 1.0;
			[self restoreSubmenuFade];
		}
	} else if (section == 7) {
		if (mySubMenuDots == nil) {
			mySubMenuDots = [[SubMenuDots alloc] initWithNibName:@"SubMenuDots" bundle:nil];
			[subContentHolder addSubview:mySubMenuDots.view];
			[mySubMenuDots initWithParent:self];
			leftnavRead.alpha = 0.0;
			rightnavRead.alpha = 0.0;
			tracksLeftRight.alpha = 1.0;
			[self restoreSubmenuFade];
		}
	}
}
-(void)removeAddSubmenuFromSection:(BOOL)hide {
	//hides the submenu in sections that doesn't use it
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.3];
	if (hide) {
		//NSLog(@"Hides it");
		self.view.alpha = 0.0;
	} else {
		//NSLog(@"Shows it");
		self.view.alpha = 1.0;
		if (visibleInterface == 3) {
			leftnavRead.alpha = 1.0;
			rightnavRead.alpha = 1.0;
			tracksLeftRight.alpha = 0.0;
		}

	}
	[UIView commitAnimations];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	int tag = touch.view.tag;
	if (tag == 1) {
		[self hideShowSubMenu:subMenuIsVisible];
	}
	/*
	if (subMenuIsVisible) {
		
	} else {
		
	}
	 */
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

#pragma mark Relay iPhoneMode
-(BOOL) getIPhoneMode {
	return iPhoneMode;
}

#pragma mark -
#pragma mark PUZZLES
-(void)preStartJigsawPuzzle:(int)puzzle {
	[myparent preStartJigsawPuzzle:puzzle];
}
-(int) getPuzzleDifficulty {
	return [myparent getPuzzleDifficulty];
}
-(void) setPuzzleLevelOfDifficulty:(int)diff {
	[myparent setPuzzleLevelOfDifficulty:diff];
}
-(int) getCurrentPuzzlePage {
	return [myparent getCurrentPuzzlePage];
}
#pragma mark -
#pragma mark DOTS
-(void)preStartDots:(int)dot {
	[myparent preStartDots:dot];
}
-(int) getDotDifficulty {
	return [myparent getDotDifficulty];
}
-(void) setDotLevelOfDifficulty:(int)diff {
	[myparent setDotLevelOfDifficulty:diff];
}
-(int) getCurrentDotsPage {
	return [myparent getCurrentDotsPage];
}
-(void) updatePuzzleTrain:(int)image {
	[myparent updateDotTrain:image];
}
#pragma mark -
#pragma mark PAINT 
-(void)refreshPaintImage:(int)image {
	[myparent refreshPaintImage:image];
}
-(int) getCurrentPaintPage {
	return [myparent getCurrentPaintPage];
}
-(void)refreshPaintTrain:(int)image {
	[myparent updatePaintTrain:image];
}
#pragma mark -
#pragma mark READ

-(void)setSubmenuFade {
	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"scenenav" ofType:@"plist"];
	NSArray *sceneData = [[NSArray alloc] initWithContentsOfFile:thePath];
	int scene = [[sceneData objectAtIndex:[myparent getCurrentReadPage]] intValue];
	if (scene > 17 && scene < 23) {
		if (blackSubmenuFade.alpha == 0.0) {
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationDuration:1.0];
			blackSubmenuFade.alpha = 1.0;
			whiteSubmenuFade.alpha = 0.0;
			trainlight.alpha = 0.0;
			traindark.alpha = 1.0;
			pageNumber.textColor = [UIColor grayColor];
			[UIView commitAnimations];
		}
        [mySubMenuRead updateColorsOnLabels:NO];
	} else {
		if (whiteSubmenuFade.alpha == 0.0) {
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationDuration:1.0];
			blackSubmenuFade.alpha = 0.0;
			whiteSubmenuFade.alpha = 1.0;
			trainlight.alpha = 1.0;
			traindark.alpha = 0.0;
			pageNumber.textColor = [UIColor grayColor];
			[UIView commitAnimations];
		}
        [mySubMenuRead updateColorsOnLabels:YES];
	}
	[sceneData release];
}
-(void)restoreSubmenuFade {
	if (whiteSubmenuFade.alpha == 0.0) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.3];
		blackSubmenuFade.alpha = 0.0;
		whiteSubmenuFade.alpha = 1.0;
		trainlight.alpha = 1.0;
		traindark.alpha = 0.0;
		pageNumber.textColor = [UIColor blackColor];
		[UIView commitAnimations];
	}
}
-(BOOL)getNarrationValue {
	return [myparent getNarrationValue];
}
-(void)setNarrationValue:(BOOL)value {
	[myparent setNarrationValue:value];
}
-(BOOL)getMusicValue {
	return [myparent getMusicValue];
}
-(void)setMusicValue:(BOOL)value {
	[myparent setMusicValue:value];
}
-(BOOL)getSwipeValue {
	return [myparent getSwipeValue];
}
-(void)setSwipeValue:(BOOL)value {
	[myparent setSwipeValue:value];
}
-(int) getCurrentReadPage {
	return [myparent getCurrentReadPage];
}
-(int) setCurrentReadPage:(int)page {
	return [myparent setCurrentReadPage:page];
}
-(void)playNarrationOnScene {
	[myparent playNarrationOnScene];
}
-(void)disableTappedNavButton {
	//NSLog(@"This is the page we're on: %i", [myparent getCurrentReadPage]);
	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"scenenav" ofType:@"plist"];
	NSArray *sceneData = [[NSArray alloc] initWithContentsOfFile:thePath];
	int scene = [[sceneData objectAtIndex:[myparent getCurrentReadPage]] intValue];
	
	if ([myparent getIPhoneMode]) {
		if (scene > 17 && scene < 23) {
			[rightnavRead setBackgroundImage:[UIImage imageNamed:@"nav_right_dark_disabled_iPhone.png"] forState:UIControlStateNormal];
			[leftnavRead setBackgroundImage:[UIImage imageNamed:@"nav_left_dark_disabled_iPhone.png"] forState:UIControlStateNormal];
			rightnavRead.showsTouchWhenHighlighted = NO;
			leftnavRead.showsTouchWhenHighlighted = NO;
		} else {
			[rightnavRead setBackgroundImage:[UIImage imageNamed:@"nav_right_disabled_iPhone.png"] forState:UIControlStateNormal];
			[leftnavRead setBackgroundImage:[UIImage imageNamed:@"nav_left_disabled_iPhone.png"] forState:UIControlStateNormal];
			rightnavRead.showsTouchWhenHighlighted = NO;
			leftnavRead.showsTouchWhenHighlighted = NO;
		}
	} else {
		if (scene > 17 && scene < 23) {
			[rightnavRead setBackgroundImage:[UIImage imageNamed:@"nav_right_disabled_black.png"] forState:UIControlStateNormal];
			[leftnavRead setBackgroundImage:[UIImage imageNamed:@"nav_left_disabled_black.png"] forState:UIControlStateNormal];
			rightnavRead.showsTouchWhenHighlighted = NO;
			leftnavRead.showsTouchWhenHighlighted = NO;
		} else {
			[rightnavRead setBackgroundImage:[UIImage imageNamed:@"nav_right_disabled.png"] forState:UIControlStateNormal];
			[leftnavRead setBackgroundImage:[UIImage imageNamed:@"nav_left_disabled.png"] forState:UIControlStateNormal];
			rightnavRead.showsTouchWhenHighlighted = NO;
			leftnavRead.showsTouchWhenHighlighted = NO;
		}
	}
}
-(void)enableTappedNavButton {
	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"scenenav" ofType:@"plist"];
	NSArray *sceneData = [[NSArray alloc] initWithContentsOfFile:thePath];
	int scene = [[sceneData objectAtIndex:[myparent getCurrentReadPage]] intValue];
	if ([myparent getIPhoneMode]) {
		if ([myparent getCurrentReadPage] == 0) {
			if (scene > 17 && scene < 23) {
				[rightnavRead setBackgroundImage:[UIImage imageNamed:@"nav_right_dark_iPhone.png"] forState:UIControlStateNormal];
				[leftnavRead setBackgroundImage:[UIImage imageNamed:@"nav_left_dark_disabled_iPhone.png"] forState:UIControlStateNormal];
				rightnavRead.showsTouchWhenHighlighted = YES;
				leftnavRead.showsTouchWhenHighlighted = NO;
			} else {
				[rightnavRead setBackgroundImage:[UIImage imageNamed:@"nav_right_iPhone.png"] forState:UIControlStateNormal];
				[leftnavRead setBackgroundImage:[UIImage imageNamed:@"nav_left_disabled_iPhone.png"] forState:UIControlStateNormal];
				rightnavRead.showsTouchWhenHighlighted = YES;
				leftnavRead.showsTouchWhenHighlighted = NO;
			}
		} else if ([myparent getCurrentReadPage] == [myparent getNumberOfReadPages]) {
			if (scene > 17 && scene < 23) {
				[rightnavRead setBackgroundImage:[UIImage imageNamed:@"nav_right_dark_disabled_iPhone.png"] forState:UIControlStateNormal];
				[leftnavRead setBackgroundImage:[UIImage imageNamed:@"nav_left_dark_iPhone.png"] forState:UIControlStateNormal];
				rightnavRead.showsTouchWhenHighlighted = NO;
				leftnavRead.showsTouchWhenHighlighted = YES;
			}	else {
				[rightnavRead setBackgroundImage:[UIImage imageNamed:@"nav_right_disabled_iPhone.png"] forState:UIControlStateNormal];
				[leftnavRead setBackgroundImage:[UIImage imageNamed:@"nav_left_iPhone.png"] forState:UIControlStateNormal];
				rightnavRead.showsTouchWhenHighlighted = NO;
				leftnavRead.showsTouchWhenHighlighted = YES;
			}
		} else {
			if (scene > 17 && scene < 23) {
				[rightnavRead setBackgroundImage:[UIImage imageNamed:@"nav_right_dark_iPhone.png"] forState:UIControlStateNormal];
				[leftnavRead setBackgroundImage:[UIImage imageNamed:@"nav_left_dark_iPhone.png"] forState:UIControlStateNormal];
				rightnavRead.showsTouchWhenHighlighted = YES;
				leftnavRead.showsTouchWhenHighlighted = YES;
			} else {
				[rightnavRead setBackgroundImage:[UIImage imageNamed:@"nav_right_iPhone.png"] forState:UIControlStateNormal];
				[leftnavRead setBackgroundImage:[UIImage imageNamed:@"nav_left_iPhone.png"] forState:UIControlStateNormal];
				rightnavRead.showsTouchWhenHighlighted = YES;
				leftnavRead.showsTouchWhenHighlighted = YES;
			}
		}
	} else {
		if ([myparent getCurrentReadPage] == 0) {
			if (scene > 17 && scene < 23) {
				[rightnavRead setBackgroundImage:[UIImage imageNamed:@"nav_right_black.png"] forState:UIControlStateNormal];
				[leftnavRead setBackgroundImage:[UIImage imageNamed:@"nav_left_disabled_black.png"] forState:UIControlStateNormal];
				rightnavRead.showsTouchWhenHighlighted = YES;
				leftnavRead.showsTouchWhenHighlighted = NO;
			} else {
				[rightnavRead setBackgroundImage:[UIImage imageNamed:@"nav_right.png"] forState:UIControlStateNormal];
				[leftnavRead setBackgroundImage:[UIImage imageNamed:@"nav_left_disabled.png"] forState:UIControlStateNormal];
				rightnavRead.showsTouchWhenHighlighted = YES;
				leftnavRead.showsTouchWhenHighlighted = NO;
			}
//        } else if ([myparent getCurrentReadPage] == [myparent getNumberOfReadPages] && [myparent getEndPageIsDisplayed
		} else if ([myparent getCurrentReadPage] == [myparent getNumberOfReadPages]) {
			if (scene > 17 && scene < 23) {
				[rightnavRead setBackgroundImage:[UIImage imageNamed:@"nav_right_disabled_black.png"] forState:UIControlStateNormal];
				[leftnavRead setBackgroundImage:[UIImage imageNamed:@"nav_left_black.png"] forState:UIControlStateNormal];
				rightnavRead.showsTouchWhenHighlighted = NO;
				leftnavRead.showsTouchWhenHighlighted = YES;
			}	else {
				[rightnavRead setBackgroundImage:[UIImage imageNamed:@"nav_right_disabled.png"] forState:UIControlStateNormal];
				[leftnavRead setBackgroundImage:[UIImage imageNamed:@"nav_left.png"] forState:UIControlStateNormal];
				rightnavRead.showsTouchWhenHighlighted = NO;
				leftnavRead.showsTouchWhenHighlighted = YES;
			}
		} else {
			if (scene > 17 && scene < 23) {
				[rightnavRead setBackgroundImage:[UIImage imageNamed:@"nav_right_black.png"] forState:UIControlStateNormal];
				[leftnavRead setBackgroundImage:[UIImage imageNamed:@"nav_left_black.png"] forState:UIControlStateNormal];
				rightnavRead.showsTouchWhenHighlighted = YES;
				leftnavRead.showsTouchWhenHighlighted = YES;
			} else {
				[rightnavRead setBackgroundImage:[UIImage imageNamed:@"nav_right.png"] forState:UIControlStateNormal];
				[leftnavRead setBackgroundImage:[UIImage imageNamed:@"nav_left.png"] forState:UIControlStateNormal];
				rightnavRead.showsTouchWhenHighlighted = YES;
				leftnavRead.showsTouchWhenHighlighted = YES;
			}
		}
	}
}
-(IBAction)navLeftInRead:(id)sender {
	if ([myparent getCurrentReadPage] != 0) {
		[myparent turnpage:NO];
		if (mySubMenuRead != nil) {
			[mySubMenuRead setCurrentPage:[myparent getCurrentReadPage]];
		}

	}
}
-(IBAction)navRightInRead:(id)sender {
    if ([myparent getCurrentReadPage] != [myparent getNumberOfReadPages]) {
        [myparent turnpage:YES];
        if (mySubMenuRead != nil) {
            [mySubMenuRead setCurrentPage:[myparent getCurrentReadPage]];
        }
    }
}

-(void) gotoPage:(int)page:(BOOL)withTransition {
	//[self hideShowSubMenu:YES];
	[myparent gotoPage:page :withTransition];
}
//pause and resume with fade down on scene
-(void) pauseCocos:(BOOL)fade {
	[myparent pauseCocos:fade];
}
-(void) resumeCocos:(BOOL)fade {
	[myparent resumeCocos:fade];
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

#pragma mark -

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[subContentHolder release];
	[train release];
	[leftnavRead release];
	[rightnavRead release];
	[tracksLeftRight release];
	[pageNumber release];
	[train release];
	[blackSubmenuFade release];
	[whiteSubmenuFade release];
	[trainlight release];
	[traindark release];
	[wagon release];
    [super dealloc];
}

@end
