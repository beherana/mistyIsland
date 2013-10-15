//
//  jigsawViewController.h
//  The Bird & The Snail - Knock Knock - Deluxe
//
//  Created by Henrik Nord on 6/29/09.
//  Copyright 2009 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PuzzleDelegate.h"
#import "FinishedPuzzleMovieController.h"

@class JigsawPuzzlePieceController;
@class FinishedPuzzleMovieController;

@interface jigsawViewController : UIViewController {
	
	PuzzleDelegate *myParent;
	
	UIView *puzzleKeeper;
	
	FinishedPuzzleMovieController *myFinishedPuzzleMovieController;
	
	//IBOutlet UILabel *tapToStart;
	IBOutlet UIImageView *tapToStart;
	IBOutlet UIImageView *puzzleBKG;
	
	IBOutlet UIButton *backButton;
	
	NSMutableArray *largeJigsawPieces;
	
	NSMutableArray *finalDestination;
	NSMutableArray *startDestinationLandscape;
	
	NSMutableArray *finalHardDestination;
	NSMutableArray *startHardDestinationLandscape;
	
	NSMutableArray *completedPieces;
	
	BOOL firstRun;
	BOOL firstMovieRun;
	BOOL unscrambled;
	BOOL movieIsPlaying;
	int levelOfDifficulty; //0 == easy, increment for harder
	
	NSMutableArray *rotationHolder;
	
	int mymovie;
	
}

@property (nonatomic, retain) NSMutableArray *rotationHolder;

@property (nonatomic, retain) UIView *puzzleKeeper;

@property (nonatomic, retain) NSMutableArray *finalDestination;
@property (nonatomic, retain) NSMutableArray *startDestinationLandscape;

@property (nonatomic, retain) NSMutableArray *finalHardDestination;
@property (nonatomic, retain) NSMutableArray *startHardDestinationLandscape;

@property (nonatomic, retain) NSMutableArray *largeJigsawPieces;

@property (nonatomic, retain) NSMutableArray *completedPieces;

- (void)switchToBig:(int)piece;
- (void) returnToSmall: (int)piece;
- (void) switchDepth: (int)piece direction:(int)dir;

- (BOOL) getUnscrambled;
- (BOOL) setUnscrambled;

- (void) scrambelPuzzlePieces;
- (void) checkJigsawCompletion;

- (int) getMyJigsawPuzzle;
-(int) getCurrentPuzzle;
- (void) cleanupFinishedMovie;

- (void) initWithParent: (id) parent;

- (void) leavePuzzle;
- (IBAction) leavePuzzlePressed: (id) sender;

@end
