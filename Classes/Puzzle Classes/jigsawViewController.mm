//
//  jigsawViewController.m
//  The Bird & The Snail - Knock Knock - Deluxe
//
//  Created by Henrik Nord on 6/29/09.
//  Copyright 2009 Haunted House. All rights reserved.
//

#import "jigsawViewController.h"
#import "JigsawPuzzlePieceController.h"
#import "PuzzleDelegate.h"
#import "FinishedPuzzleMovieController.h"

#import "cdaAnalytics.h"

#define kNumberOfJigsawPieces 6
#define kNumberOfHardJigsawPieces 12

#define kCompensateX 212
#define kCompensateY 12

CGFloat jigsawDegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

@implementation jigsawViewController

@synthesize rotationHolder;
@synthesize puzzleKeeper;
@synthesize largeJigsawPieces;
@synthesize finalDestination, startDestinationLandscape; 
@synthesize finalHardDestination, startHardDestinationLandscape; 
@synthesize completedPieces;

-(void) initWithParent: (id) parent
{
	self=[super init];
	if (self){
		myParent=parent;
	}
	return;
}

-(void) leavePuzzle {
	[myParent runExitFromJigsawToMenu];
}
- (IBAction) leavePuzzlePressed: (id) sender {
	[self leavePuzzle];
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		NSString *thePath = [[NSBundle mainBundle] pathForResource:@"puzzles" ofType:@"plist"];
		NSDictionary *puzzleData = [[[NSDictionary alloc] initWithContentsOfFile:thePath] autorelease];
		int currentpuzzle = [self getCurrentPuzzle];
		NSString *puzzletag = [NSString stringWithFormat:@"puzzle%i", currentpuzzle];
		NSDictionary *mypuzzle = [[[NSDictionary alloc] initWithDictionary:[puzzleData objectForKey:puzzletag]] autorelease];
		NSMutableArray *scrambledx = [[[NSMutableArray alloc] initWithArray:[mypuzzle objectForKey:@"scrambledX"]] autorelease];
		NSMutableArray *scrambledy = [[[NSMutableArray alloc] initWithArray:[mypuzzle objectForKey:@"scrambledY"]] autorelease];
		NSMutableArray *finalx = [[[NSMutableArray alloc] initWithArray:[mypuzzle objectForKey:@"finaldestinationX"]] autorelease];
		NSMutableArray *finaly = [[[NSMutableArray alloc] initWithArray:[mypuzzle objectForKey:@"finaldestinationY"]] autorelease];
		NSMutableArray *rotations = [[[NSMutableArray alloc] initWithArray:[mypuzzle objectForKey:@"rotation"]] autorelease];
		startDestinationLandscape = [[NSMutableArray arrayWithObjects:scrambledx, scrambledy, rotations, nil] retain];
		finalDestination = [[NSMutableArray arrayWithObjects:finalx, finaly, nil] retain];
		mymovie = [[mypuzzle valueForKey:@"movie"] integerValue];
	} else {
		startDestinationLandscape = [[NSMutableArray arrayWithObjects:
									  [[NSMutableArray arrayWithObjects:  [NSNumber numberWithFloat:-90.0], [NSNumber numberWithFloat:-90.0], [NSNumber numberWithFloat:-90.0], [NSNumber numberWithFloat:720.0], [NSNumber numberWithFloat:720.0], [NSNumber numberWithFloat:720.0], nil] retain],
									  [[NSMutableArray arrayWithObjects:  [NSNumber numberWithFloat:60.0], [NSNumber numberWithFloat:240.0], [NSNumber numberWithFloat:420.0], [NSNumber numberWithFloat:60.0], [NSNumber numberWithFloat:240.0], [NSNumber numberWithFloat:420.0], nil] retain],
									  [[NSMutableArray arrayWithObjects:  [NSNumber numberWithFloat:-6.0], [NSNumber numberWithFloat:6.0], [NSNumber numberWithFloat:10.0], [NSNumber numberWithFloat:-2.0], [NSNumber numberWithFloat:-5.0], [NSNumber numberWithFloat:3.0], nil] retain],
									  nil] retain];
		finalDestination = [[NSMutableArray arrayWithObjects:
							 [[NSMutableArray arrayWithObjects:  [NSNumber numberWithFloat:138.0], [NSNumber numberWithFloat:138.5], [NSNumber numberWithFloat:338.5], [NSNumber numberWithFloat:339.0], [NSNumber numberWithFloat:513.5], [NSNumber numberWithFloat:514.0], nil] retain],
							 [[NSMutableArray arrayWithObjects:  [NSNumber numberWithFloat:315.0], [NSNumber numberWithFloat:115.5], [NSNumber numberWithFloat:314.5], [NSNumber numberWithFloat:117.5], [NSNumber numberWithFloat:117.0], [NSNumber numberWithFloat:314.5], nil] retain],
							 nil] retain];
		
		startHardDestinationLandscape = [[NSMutableArray arrayWithObjects:
										  [[NSMutableArray arrayWithObjects: [NSNumber numberWithFloat:900.0],[NSNumber numberWithFloat:895.0], [NSNumber numberWithFloat:85.0],[NSNumber numberWithFloat:895.0], [NSNumber numberWithFloat:90.0], [NSNumber numberWithFloat:150.0],[NSNumber numberWithFloat:160.0], [NSNumber numberWithFloat:955.0],[NSNumber numberWithFloat:85.0], [NSNumber numberWithFloat:955.0],[NSNumber numberWithFloat:150.0], [NSNumber numberWithFloat:955.0], nil] retain],
										  [[NSMutableArray arrayWithObjects: [NSNumber numberWithFloat:245.0],[NSNumber numberWithFloat:417.0], [NSNumber numberWithFloat:335.0],[NSNumber numberWithFloat:40.0], [NSNumber numberWithFloat:150.0], [NSNumber numberWithFloat:51.0],[NSNumber numberWithFloat:242.0], [NSNumber numberWithFloat:150.0],[NSNumber numberWithFloat:509.0], [NSNumber numberWithFloat:330.0],[NSNumber numberWithFloat:420.0], [NSNumber numberWithFloat:510.0], nil] retain],
										  [[NSMutableArray arrayWithObjects:  [NSNumber numberWithFloat:-6.0], [NSNumber numberWithFloat:6.0], [NSNumber numberWithFloat:10.0], [NSNumber numberWithFloat:-2.0], [NSNumber numberWithFloat:-5.0], [NSNumber numberWithFloat:3.0], [NSNumber numberWithFloat:-6.0], [NSNumber numberWithFloat:6.0], [NSNumber numberWithFloat:10.0], [NSNumber numberWithFloat:-2.0], [NSNumber numberWithFloat:-5.0], [NSNumber numberWithFloat:3.0], nil] retain],
										  nil] retain];
		finalHardDestination = [[NSMutableArray arrayWithObjects:
								 [[NSMutableArray arrayWithObjects:  [NSNumber numberWithFloat:313.0], [NSNumber numberWithFloat:295.0], [NSNumber numberWithFloat:311.0], [NSNumber numberWithFloat:464.0], [NSNumber numberWithFloat:444.0], [NSNumber numberWithFloat:445.0], [NSNumber numberWithFloat:604.0], [NSNumber numberWithFloat:623.0], [NSNumber numberWithFloat:592.0], [NSNumber numberWithFloat:741.0], [NSNumber numberWithFloat:760.0], [NSNumber numberWithFloat:745.0], nil] retain],
								 [[NSMutableArray arrayWithObjects:  [NSNumber numberWithFloat:395.0], [NSNumber numberWithFloat:250.0], [NSNumber numberWithFloat:100.0], [NSNumber numberWithFloat:389.0], [NSNumber numberWithFloat:248.0], [NSNumber numberWithFloat:106.0], [NSNumber numberWithFloat:385.0], [NSNumber numberWithFloat:229.0], [NSNumber numberWithFloat:93.0], [NSNumber numberWithFloat:394.0], [NSNumber numberWithFloat:246.0], [NSNumber numberWithFloat:97.0], nil] retain],
								 nil] retain];
		
	}

	[[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	
	
	levelOfDifficulty = [myParent getLevelOfDifficulty];
	
	//Load and setup all the puzzle-pieces...
	NSMutableArray *large_controllers = [[NSMutableArray alloc] init];
	NSMutableArray *completed_controllers = [[NSMutableArray alloc] init];
	if (levelOfDifficulty == 0) {
		for (unsigned i = 0; i < kNumberOfJigsawPieces; i++) {
			[large_controllers addObject:[NSNull null]];
			[completed_controllers addObject:[NSNull null]];
		}
	} else {
		for (unsigned i = 0; i < kNumberOfHardJigsawPieces; i++) {
			[large_controllers addObject:[NSNull null]];
			[completed_controllers addObject:[NSNull null]];
		}
	}

	UIView *mypuzzlekeeper = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:mypuzzlekeeper];
	self.puzzleKeeper = mypuzzlekeeper;
	[mypuzzlekeeper release];
	
	firstRun = YES;
	if (levelOfDifficulty == 0) {
		for (unsigned i = 0; i < kNumberOfJigsawPieces; i++) {
			//big pieces
			NSString *size = [NSString stringWithFormat:@"big"];
			JigsawPuzzlePieceController *bigcontroller = [[JigsawPuzzlePieceController alloc] initWithJigsawPiece:(i+1) size:size];
			bigcontroller.view.tag = (i+1);
			[self.puzzleKeeper addSubview:bigcontroller.view];
			[bigcontroller initWithParent:self];
			[large_controllers replaceObjectAtIndex:i withObject:bigcontroller];
			NSNumber *mystate = [NSNumber numberWithInt:0];
			[completed_controllers replaceObjectAtIndex:i withObject:mystate];
			[bigcontroller release];
			
		}
	} else {
		for (unsigned i = 0; i < kNumberOfHardJigsawPieces; i++) {
			//big pieces
			NSString *size = [NSString stringWithFormat:@"small"];
			JigsawPuzzlePieceController *bigcontroller = [[JigsawPuzzlePieceController alloc] initWithJigsawPiece:(i+1) size:size];
			bigcontroller.view.tag = (i+1);
			[self.puzzleKeeper addSubview:bigcontroller.view];
			[bigcontroller initWithParent:self];
			[large_controllers replaceObjectAtIndex:i withObject:bigcontroller];
			NSNumber *mystate = [NSNumber numberWithInt:0];
			[completed_controllers replaceObjectAtIndex:i withObject:mystate];
			[bigcontroller release];
		}
	}

	self.largeJigsawPieces = large_controllers;
	[large_controllers release];
	large_controllers = nil;
	self.completedPieces = completed_controllers;
	[completed_controllers release];
	completed_controllers = nil;
	
	[self.view bringSubviewToFront:tapToStart];
	//self.view.backgroundColor = [UIColor redColor];
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
		tapToStart.center = CGPointMake(512, (myParent.view.frame.size.height - tapToStart.frame.size.height)/2+180);
	} else {
		[self.view bringSubviewToFront:backButton];
		//[self.view bringSubviewToFront:puzzleBKG];
	}
	tapToStart.alpha = 0.0;
	tapToStart.hidden = NO;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.5];
	tapToStart.alpha = 1.0;
	[UIView commitAnimations];
	
	[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	
}
-(int) getCurrentPuzzle {
	//int current = [[myParent getCurrentSlidePuzzle] intValue];
	return [[myParent getCurrentSlidePuzzle] intValue];
}
- (int) getMyJigsawPuzzle {
	int theCurrentPuzzle;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		theCurrentPuzzle = mymovie;
	} else {
		theCurrentPuzzle = [[myParent getCurrentSlidePuzzle] intValue];
	}
	
	return theCurrentPuzzle;
}

- (void) switchToBig:(int)piece {
	for (unsigned i = 0; i < [self.largeJigsawPieces count]; i++) {
		unsigned mypiece = piece-1;
		unsigned complete = [[self.completedPieces objectAtIndex:i] integerValue];
		if (i != mypiece && complete != 1) {
			JigsawPuzzlePieceController *controller = [self.largeJigsawPieces objectAtIndex:i % [self.largeJigsawPieces count]];
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationDuration:0.3];
			controller.view.alpha = 0.3;
			[UIView commitAnimations];
		}
	}
}
- (void) returnToSmall: (int)piece {
	for (unsigned i = 0; i < [self.largeJigsawPieces count]; i++) {
		unsigned mypiece = piece-1;
		unsigned complete = [[self.completedPieces objectAtIndex:i] integerValue];
		if (i != mypiece && complete != 1) {
			JigsawPuzzlePieceController *controller = [self.largeJigsawPieces objectAtIndex:i % [self.largeJigsawPieces count]];
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationDuration:0.5];
			controller.view.alpha = 1.0;
			[UIView commitAnimations];
		}
	}
}
- (void) switchDepth: (int)piece direction:(int)dir {
	if (dir == 1) {
		JigsawPuzzlePieceController *controller = [self.largeJigsawPieces objectAtIndex:piece-1 % [self.largeJigsawPieces count]];
		[self.puzzleKeeper bringSubviewToFront:controller.view];
		//[controller release];
	} else {
		for (unsigned i = 0; i < [self.largeJigsawPieces count]; i++) {
			unsigned mypiece = piece-1;
			unsigned complete = [[self.completedPieces objectAtIndex:i] integerValue];
			if (i != mypiece && complete != 1) {
				JigsawPuzzlePieceController *controller = [self.largeJigsawPieces objectAtIndex:i % [self.largeJigsawPieces count]];
				[self.puzzleKeeper bringSubviewToFront:controller.view];
				//[controller release];
			}
		}
	}
}

- (void) scrambelPuzzlePieces {
	//hide the puzzle submenu
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
		[myParent hidePuzzleSubMenu];
	}
	
	for (unsigned i = 0; i < [self.largeJigsawPieces count]; i++) {
		//reset completed puzzle pieces
		NSNumber *mystate = [NSNumber numberWithInt:0];
		[self.completedPieces replaceObjectAtIndex:i withObject:mystate];
		
		//spread them out
		JigsawPuzzlePieceController *controller = [self.largeJigsawPieces objectAtIndex:i % [self.largeJigsawPieces count]];
		[controller scrambleJigsawPuzzle];
	}
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.5];
	tapToStart.alpha = 0.0;
	[UIView commitAnimations];
}

- (void) checkJigsawCompletion {
	BOOL finished = YES;
	for (unsigned i = 0; i < [self.largeJigsawPieces count]; i++) {
		NSNumber *mystate = [NSNumber numberWithInt:[[self.completedPieces objectAtIndex:i] integerValue]];
		if (mystate != [NSNumber numberWithInt:1]) {
			finished = NO;
		}
	}
	if (finished) {
		//act upon it
		//FLURRY
		[[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"PUZZLE completed with puzzle number:%i and level of difficulty: %i" , [[myParent getCurrentSlidePuzzle] intValue], levelOfDifficulty]];
		//[FlurryAnalytics endTimedEvent:@"Solving_puzzle"];
		//
		/**/
		movieIsPlaying = YES;
		myFinishedPuzzleMovieController = [FinishedPuzzleMovieController alloc];
		[myFinishedPuzzleMovieController initWithParent:self];
		myFinishedPuzzleMovieController = [myFinishedPuzzleMovieController initWithNibName:@"FinishedPuzzleMovieView" bundle:nil];
		[self.view addSubview:myFinishedPuzzleMovieController.view];
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
			myFinishedPuzzleMovieController.view.center = CGPointMake(240, 143);
		} else {
			myFinishedPuzzleMovieController.view.center = CGPointMake(myFinishedPuzzleMovieController.view.center.x+kCompensateX, myFinishedPuzzleMovieController.view.center.y+kCompensateY);
		}
		 
	}	
}
- (void) cleanupFinishedEndedMovie:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	[self cleanupFinishedMovie];
}
- (void) cleanupFinishedMovie {
	//NSLog(@"Got the clean up call");
	if (movieIsPlaying) {
		movieIsPlaying = NO;
		unscrambled = NO;
		[myFinishedPuzzleMovieController stopMovie];
		[myFinishedPuzzleMovieController.view removeFromSuperview];
		//[myFinishedPuzzleMovieController.view release];
	}
}

- (BOOL) getUnscrambled {
	return unscrambled;
}
- (BOOL) setUnscrambled {
	if (unscrambled) {
		unscrambled = NO;
	} else {
		unscrambled = YES;
	}
	return unscrambled;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	[startDestinationLandscape release];
	[finalDestination release];
	
	[startHardDestinationLandscape release];
	[finalHardDestination release];
	
	[completedPieces removeAllObjects];
	[completedPieces release];
	[rotationHolder removeAllObjects];
	[rotationHolder release];
	[puzzleKeeper release];
	[largeJigsawPieces release];
	
	[tapToStart release];
	[puzzleBKG release];
	[backButton release];
    [super dealloc];
}


@end
