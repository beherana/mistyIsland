//
//  ThomasRootViewController.h
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/10/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MainMenuController.h"
#import "SubMenuViewController.h"
#import "PuzzleDelegate.h"
#import "PaintHolderLandscapeViewController.h"
#import "PaintViewController.h"
#import "WatchViewController.h"
#import "LandingPageViewController.h"
#import "Misty_Island_Rescue_iPadAppDelegate.h"
#import "cocos2d.h"
#import "BookScene.h"
#import "ReadController.h"
#import "DotViewController.h"
#import "IntroViewController.h"
#import "PaintMenuViewController.h"
#import "MatchMenuViewController.h"
#import "ReadOverlayView.h"
#import "MoreAppsEndViewController.h"
#import "MoreAppsEndiPadViewController.h"
#import "CustomAlertViewController.h"

@class PuzzleDelegate;
@class ThomasSettingsViewController;

@interface ThomasRootViewController : UIViewController <UIApplicationDelegate, CustomAlertViewControllerDelegate> {

	LandingPageViewController *myLandingpageViewController;
	PuzzleDelegate *myPuzzleDelegate;
	PaintHolderLandscapeViewController *myPaintHolder;
	MainMenuController *myMainMenuController;
	SubMenuViewController *mySubViewController;
	WatchViewController *myWatchViewController;
	ReadController *myReadController;
	DotViewController *myDotViewController;
	IntroViewController *myIntroViewController;
	PaintMenuViewController *myPaintMenuViewController;
	MatchMenuViewController *myMatchMenuViewController;
	ThomasSettingsViewController *mySettingsViewController;
    MoreAppsEndViewController *moreAppsEndViewController;
    MoreAppsEndiPadViewController *moreAppsEndiPadViewController;

	
	IBOutlet UIImageView *landingpage;
	
	BOOL projectInit;
	BOOL menusoundInit;
	
	int currentNavigationItem;
	int savedNavigationItem;
	NSArray *sceneData;
	int currentReadPage;
	
	int currentPaintImage;
	int currentPuzzle;
	int currentDotImage;
	int currentDotState;
	
	BOOL currentMusicSetting;
	BOOL speakerIsPaused;
	BOOL speakerIsPausedByFX;
	
	EAGLView *glview;
	BookScene *currentScene;
	BookScene *nextScene;
	BOOL cocosInit;
	BOOL cocosShown;
	BOOL cocosPaused;
	BOOL queueClear;
	BOOL turningPage;
	BOOL landscapeRight;
	
	BOOL readViewIsPaused;
	
	NSTimer *readSceneDelay;
	float fullSpeakerDelayTime;
	NSDate *speakerDelayStart;
	NSDate *speakerDelayPaused;
	BOOL speakerIsDelayed;

	BOOL endPageIsDisplayed;
	UIImageView *endview;

	BOOL speakerWhileOff;
	
	NSMutableArray *hotspotsOnScene;
	BOOL hotspotsAreDelayed;
	NSTimer *readHotspotDelay;
	NSTimer *readHotspotRespawnTimer;
	float fullHotspotDelayTime;
	UIView *hotspotHolder;
	
	BOOL iPhoneMode;
	int lastVisitedMenuItem;
	
	//@private
	ReadOverlayView *readOverlayView;
}

@property (nonatomic, readonly) PuzzleDelegate *myPuzzleDelegate;
@property (nonatomic, readonly) MainMenuController *myMainMenuController;

@property (nonatomic, retain) NSArray *sceneData;
@property (nonatomic,readonly) BookScene *currentScene;
@property (nonatomic,readonly) BOOL landscapeRight;

@property (nonatomic, retain) NSTimer *readSceneDelay;
@property (nonatomic, retain) NSDate *speakerDelayStart;

@property (nonatomic, retain) UIImageView *endview;

@property (nonatomic, retain) NSMutableArray *hotspotsOnScene;
@property (nonatomic, retain) NSTimer *readHotspotDelay;
@property (nonatomic, retain) NSTimer *readHotspotRespawnTimer;
@property (nonatomic, retain) UIView *hotspotHolder;

@property (nonatomic, retain) MoreAppsEndViewController *moreAppsEndViewController;
@property (nonatomic, retain) MoreAppsEndiPadViewController *moreAppsEndiPadViewController;


-(void)navigateFromMainMenuWithItem:(int)item;
-(void)returnFromMainMenuToLastItem;
-(void)unloadCurrentNavigationItem;
-(void)adjustMainMenu;
-(void)videoFinishedPlaying;
-(void)introFinishedPlaying;
-(void)showFakeLandingPage;

-(void)preStartJigsawPuzzle:(int)puzzle;

-(int) getCurrentReadPage;
-(int) setCurrentReadPage:(int)page;
-(int) getCurrentPaintPage;
-(void) setCurrentPaintPage:(int)page;
-(int) getCurrentPuzzlePage;
-(int) getCurrentDotsPage;
-(int) getCurrentDotsState;
-(void) setSpeakerIsPaused:(BOOL)paused;
-(void) setSpeakerIsPausedByFX:(BOOL)paused;
-(BOOL) getSpeakerIsPaused;
-(int) getNumberOfReadPages;
-(BOOL) isLastPage;
-(BOOL)getEndPageIsDisplayed;
-(BOOL)getIPhoneMode;
-(NSString*)getCurrentLanguage;

-(int) getCurrentNavigationItem;
-(int) getLastVisitedMenuItem;

-(void) gotoPage:(int)page:(BOOL)withTransition;
-(void) turnpage:(BOOL)forwards;
-(void) sceneTransitionDone;
-(void) sceneCleanup;
-(void) fullCleanup;
-(void) pauseCocos;
-(void) resumeCocos;
//pause and resume with fade down on scene
-(void)unPauseReadView;
-(BOOL)getReadViewIsPaused;
-(void) pauseCocos:(BOOL)fade;
-(void) resumeCocos:(BOOL)fade;
-(BOOL)getCocosPaused;
//
-(void) stopCocos;
-(void) startCocos;
-(void) clearCocos;
-(void) killCocos;
-(void) resetCocos;

-(int) getSavedNavigationItem;
-(int) getPuzzleDifficulty;
-(void) setPuzzleLevelOfDifficulty:(int)diff;
-(void)hidePuzzleSubMenu;

-(void)preStartDots:(int)dot;
-(int) getDotDifficulty;
-(void) setDotLevelOfDifficulty:(int)diff;
-(void)hideDotsSubMenu;

-(BOOL)getNarrationValue;
-(void)setNarrationValue:(int)value;
-(int)getMusicValue;
-(void)setMusicValue:(int)value;
-(BOOL)getSwipeValue;
-(void)setSwipeValue:(BOOL)value;

-(void)playNarrationOnScene;
-(void)pauseNarrationOnScene;
-(void)resumeNarrationOnScene;

-(void)refreshPaintImage:(int)image;
-(void) updatePaintTrain:(int)image;
-(void) updatePuzzleTrain;
-(void) updateDotTrain:(int)image;
-(void) updatePageNumberAndTrain;
-(void) checkForSceneDelayActions;
-(void)removePendingSceneDelay;
-(void) doSceneDelayActions;
-(void) doHotspotsDelayActions;
-(void)removePendingHotspotsDelay;
-(void)respawnHotspots;

-(void)narrationFinished;

-(void)checkIfNarrationDateIsDelayed;
-(BOOL)getSpeakerIsDelayed;
-(void) setSpeakerIsDelayed:(BOOL)delayed;

-(void) displayEndPage;
-(void) removeEndPage;

- (void)playFXEventSound:(NSString *)sound;
- (void)playCardSound:(int)sound;
- (void)pauseReadPlayback;
- (void)startReadPlayback;

-(void) forceNarrationOnScene;
//<<----- HAVE A LOOK AT THIS - DO IT CONDITIONAL INSIDE READ?
//-(void)showReadOverlayViewWithText:(NSString *)text style:(int)style;
-(void)showReadOverlayViewWithText:(NSString *)text style:(ReadOverlayViewStyle)style;
-(void)setOverlayViewToNil;
//<<<<----
-(void)showMoreAppsEndPage;



@end
