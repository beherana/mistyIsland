//
//  PuzzleDelegate.m
//  The Bird & The Snail - Knock Knock - Slide View
//
//  Created by Henrik Nord on 3/24/09.
//  Copyright Haunted House 2009. All rights reserved.
//
#import "PuzzleDelegate.h"
#import "PuzzleViewController.h"
#import "jigsawViewController.h"

@interface PuzzleDelegate (PrivateMethods)
//sounds
- (void)playSlidePuzzleSceneChangeSound;
//
@end

CGFloat SlidePuzzleDegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

@implementation PuzzleDelegate

@synthesize puzzleView;

-(void) initWithParent: (id) parent
{
	self=[super init];
	if (self){
		myRoot=parent;
	}
	return;
}

- (void)dealloc {
	NSLog(@"PuzzleDelegate got a dealloc call");
	[puzzleView removeFromSuperview];
	[puzzleView release];	
    [super dealloc];
}

- (void) viewDidLoad {
	[super viewDidLoad];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		iPhoneMode = YES;
		levelOfDifficulty = 0;
	} else {
		//levelOfDifficulty = [NSNumber numberWithInt:0];
		Misty_Island_Rescue_iPadAppDelegate *appDelegate = (Misty_Island_Rescue_iPadAppDelegate *)[[UIApplication sharedApplication] delegate];
		levelOfDifficulty = [appDelegate getSaveCurrentPuzzleDifficulty];
	}
	if (myPuzzleViewController==nil) {
		myPuzzleViewController = [[PuzzleViewController alloc] initWithNibName:@"PuzzleView" bundle:[NSBundle mainBundle]];
	}
	
	[myPuzzleViewController initWithParent:self];
	[self.view addSubview:myPuzzleViewController.view];
	
	NSLog(@"This is my width: %f", self.view.frame.size.width);
	NSLog(@"This is my height: %f", self.view.frame.size.height);
}
- (void) cleanCurrentlySelectedPuzzle {
	//NSLog(@"Should clean up currently selected puzzle here");
	if ([myPuzzleViewController.view superview]) {
		[myPuzzleViewController.view removeFromSuperview];
		[myPuzzleViewController release];
	}
	if ([myJigsawViewController.view superview]) {
		[myJigsawViewController cleanupFinishedMovie];
		[myJigsawViewController.view removeFromSuperview];
		[myJigsawViewController release];
		myJigsawViewController = nil;
	}
}

-(int) getLevelOfDifficulty {

	return levelOfDifficulty;
	
}
-(void) setLevelOfDifficulty:(int)diff {
	levelOfDifficulty = diff;
	[myPuzzleViewController changePuzzleDifficulty:diff];
}
-(void)hidePuzzleSubMenu {
	[myRoot hidePuzzleSubMenu];
}
-(void) retractPuzzleMenu {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:0.6];
	myPuzzleViewController.menuHolder.transform = CGAffineTransformTranslate(myPuzzleViewController.menuHolder.transform, 0.0, myPuzzleViewController.menuHolder.frame.size.height);
	myPuzzleViewController.easyPuzzleButton.alpha = 0.0;
	myPuzzleViewController.hardPuzzleButton.alpha = 0.0;
	[UIView commitAnimations];
}
-(void) restorePuzzleMenu {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.3];
	myPuzzleViewController.menuHolder.transform = CGAffineTransformTranslate(myPuzzleViewController.menuHolder.transform, 0.0, (myPuzzleViewController.menuHolder.frame.size.height)*-1);
	if (levelOfDifficulty == 0) {
		myPuzzleViewController.easyPuzzleButton.alpha = 0.4;
		myPuzzleViewController.hardPuzzleButton.alpha = 1.0;
	} else {
		myPuzzleViewController.easyPuzzleButton.alpha = 1.0;
		myPuzzleViewController.hardPuzzleButton.alpha = 0.4;
	}

	[UIView commitAnimations];
}

-(BOOL)getSetToGo {
	return setToGo;
}
-(BOOL)getSetForNextImage {
	return setForNextImage;
}


-(BOOL) setJigsawMode {
	if (jigsawMode) {
		jigsawMode = NO;
	} else {
		jigsawMode = YES;
	}
	return jigsawMode;
}
-(BOOL) getJigsawMode {
	return jigsawMode;
}

- (id) getCurrentSlidePuzzle {
	NSNumber *thePuzzle = [NSNumber numberWithInt:currentPuzzle];
	return thePuzzle;
}
-(int) getCurrentPuzzle {
	return currentPuzzle;
}
//
- (void)preStartJigsawPuzzle: (int)tag {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		jigsawMode = YES;
		currentPuzzle = tag;
		[myPuzzleViewController zoomSelectedJigsaw:currentPuzzle];
		[self playSlidePuzzleSceneChangeSound];
	} else {
		//update interface
		jigsawMode = YES;
		currentPuzzle = tag;
		[myRoot updatePuzzleTrain];
		[myPuzzleViewController zoomSelectedJigsaw:currentPuzzle];
		[self playSlidePuzzleSceneChangeSound];
	}
}
-(void)startJigsaw {
	NSLog(@"startJigsaw called");
	
	if (myJigsawViewController==nil) {
		myJigsawViewController = [[jigsawViewController alloc] initWithNibName:@"jigsawView" bundle:nil];
	} else {
		[self runExitFromJigsawToMenu];
		myJigsawViewController = [[jigsawViewController alloc] initWithNibName:@"jigsawView" bundle:nil];
	}
	[myJigsawViewController initWithParent:self];
	[self.view addSubview:myJigsawViewController.view];
	[self.view bringSubviewToFront:myJigsawViewController.view];
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
		NSLog(@"AND iPad Nib should be the one being loaded");
		myJigsawViewController.view.center = CGPointMake(500, 390);
	}
}
//

- (void) removeFinishedPuzzleMovie {
	[myJigsawViewController cleanupFinishedMovie];
}

- (IBAction) exitFromJigsawToMenu: (id)sender {
	[self runExitFromJigsawToMenu];
}
- (void) runExitFromJigsawToMenu {
	[myJigsawViewController cleanupFinishedMovie];
	[myJigsawViewController.view removeFromSuperview];
	[myJigsawViewController release];
	myJigsawViewController = nil;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		[myPuzzleViewController redrawMenu:0];
	}
	//
}

- (IBAction) exitToMainMenu: (id)sender {
	NSLog(@"Finding puzzle delagate at least");
	[[Misty_Island_Rescue_iPadAppDelegate get].myRootViewController playFXEventSound:@"mainmenu"];

	[myRoot navigateFromMainMenuWithItem:2];
}
//

//------ SOUNDS ------

- (void)playSlidePuzzleSceneChangeSound {
	
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = (Misty_Island_Rescue_iPadAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	if (appDelegate.fxPlayer.playing) [appDelegate stopFXPlayback];
	//REPLACED - temp silence
	//NSString *mypath = [NSString stringWithFormat:@"endsound"];
	NSString *mypath = [NSString stringWithFormat:@"silence"];
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	[fileURL release];
	if (thePlayer) {
		appDelegate.fxPlayer = thePlayer;
		[thePlayer release];
		appDelegate.fxPlayer.volume = 0.6;
		[appDelegate startFXPlayback];
	}
}
//
@end
