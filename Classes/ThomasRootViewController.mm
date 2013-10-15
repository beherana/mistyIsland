    //
//  ThomasRootViewController.m
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/10/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "ThomasRootViewController.h"
#import "Misty_Island_Rescue_iPadAppDelegate.h"
#import "ThomasSettingsViewController.h"
#import "PlaySoundAction.h"
#import "cdaAnalytics.h"

@interface ThomasRootViewController (PrivateMethods)
-(void)playIntroMovie;
-(void)loadMainMenu;
-(void)unloadMainMenu;
-(void)loadSubMenu;
-(void)unloadSubMenu;
-(void)openLandingpage;
-(void)openPuzzles;
-(void)openMatch;
-(void)openPaint;
-(void)openSettings;
-(void)openPaintOnIPhone;
-(void)openWatch;
-(void)openDots;
-(void) preOpenRead;
-(void)leaveFromWatch;
-(void)openRead;
-(void)initCocos;
@end

@implementation ThomasRootViewController

@synthesize currentScene,landscapeRight, sceneData;
@synthesize myPuzzleDelegate;
@synthesize readSceneDelay, speakerDelayStart;
@synthesize endview;
@synthesize hotspotsOnScene, readHotspotDelay, hotspotHolder, readHotspotRespawnTimer;
@synthesize myMainMenuController;
@synthesize moreAppsEndViewController, moreAppsEndiPadViewController;

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
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		iPhoneMode = YES;
	} else {
		iPhoneMode = NO;
	}

	//start by getting the puzzles in there.
	//[self openPuzzles];
	//[self openPaint];
	projectInit = YES;
	menusoundInit = YES;
	cocosInit=NO;
	cocosShown=NO;
	cocosPaused=NO;
	queueClear=NO;
	turningPage=NO;
	
	//get scene data
	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"scenenav" ofType:@"plist"];
	sceneData = [[NSArray alloc] initWithContentsOfFile:thePath];
	//Set to 0 to be able to restore without being blocked by allready having that value and use savedNavigationItem for startup
	currentNavigationItem = 0;
	//restore saved prefs
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	savedNavigationItem = [appDelegate getSaveSelectedAppSection];
	currentReadPage = [appDelegate getSaveCurrentReadPage];
	currentPaintImage = [appDelegate getSaveCurrentPaintImage];
	currentPuzzle = [appDelegate getSaveCurrentPuzzle];
	currentDotImage = [appDelegate getSaveCurrentDotImage];
	currentDotState = [appDelegate getSaveDotDifficulty];
	//currentNarrationSetting=[appDelegate getSaveNarrationSetting];
	
	//if ([appDelegate getIntroPresentationPlayed]) {
	//	[self loadSubMenu];
	//	[self loadMainMenu];
		//[self playIntroMovie];
	//} else {
		//play intro
	if (iPhoneMode) {
		NSLog(@"Thomas iPhone started");
		lastVisitedMenuItem = [appDelegate getSaveLastVisitedMenuItem];;
		[self loadSubMenu];
		[self playIntroMovie];
		menusoundInit = NO;
	} else {
		[self loadSubMenu];
		[self playIntroMovie];
	}
	//}
	
}
#pragma mark -
#pragma mark INTRO
-(void)playIntroMovie {
	if (myIntroViewController == nil) {
		myIntroViewController = [[IntroViewController alloc] initWithNibName:@"IntroViewController" bundle:nil];
		[self.view addSubview:myIntroViewController.view];
	}
}

-(void)introFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	//[self stopRunway];
}
-(void)introFinishedPlaying {
	if (myIntroViewController != nil) {
		if (iPhoneMode) {
			Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
			[self navigateFromMainMenuWithItem:[appDelegate getSaveSelectedAppSection]];
			[myIntroViewController.view removeFromSuperview];
			[myIntroViewController release];
			myIntroViewController = nil;
			//TEMP - use only if intro doesn't contain a langing page, otherwise landing page handles this
			[appDelegate setIntroPresentationPlayed:YES];
			//
		} else {
			[self loadMainMenu];
			[myIntroViewController.view removeFromSuperview];
			[myIntroViewController release];
			myIntroViewController = nil;
			landingpage.hidden = YES;
		}
	}
}

-(void)introFadedOut:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	[myIntroViewController.view removeFromSuperview];
	[myIntroViewController release];
	myIntroViewController = nil;
}
-(void)showFakeLandingPage {
	landingpage.hidden = NO;
}
#pragma mark -
#pragma mark Navigation
- (void)playFXEventSound:(NSString *)sound {
	if (menusoundInit == NO) {
		Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
		[appDelegate playFXEventSound:sound];
	} else {
		menusoundInit = NO;
	}

}
-(void)returnFromMainMenuToLastItem {
	if (lastVisitedMenuItem) {
		[self playFXEventSound:@"mainmenu"];

		[self navigateFromMainMenuWithItem:lastVisitedMenuItem];
	}
}
-(void)navigateFromMainMenuWithItem:(int)item {
	
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	
	if (iPhoneMode) {
		if (currentNavigationItem == item) return;

		if (item != 2) {
			lastVisitedMenuItem = item;
		}
		
		currentNavigationItem = item;

		//dismiss any popover that might be present in the landingpage
		[myLandingpageViewController killPopoversOnSight];
		//
		[self unloadCurrentNavigationItem];
		
		
		[self removePendingSceneDelay];
		[self removePendingHotspotsDelay];
		
		if (item == 2) {
			//home - main menu
			[self loadMainMenu];
			myMainMenuController.view.hidden = NO;
			[self.view bringSubviewToFront:myMainMenuController.view];
			//FLURRY
			[[cdaAnalytics sharedInstance] trackEvent:@"Going to main menu"];
		} else if (item == 3) {
			//read
			[self openRead];
			//FLURRY
			[[cdaAnalytics sharedInstance] trackEvent:@"Read tapped in Main Menu"];
		} else if (item == 4) {
			//watch
			[self openWatch];
			//FLURRY
			[[cdaAnalytics sharedInstance] trackEvent:@"Watch tapped in Main Menu"];
		} else if (item == 5) {
			//paint
			[self openPaintOnIPhone];
			//FLURRY
			[[cdaAnalytics sharedInstance] trackEvent:@"Paint tapped in Main Menu"];
		} else if (item == 6) {
			//puzzle
			[self openPuzzles];
			//FLURRY
			[[cdaAnalytics sharedInstance] trackEvent:@"Puzzle tapped in Main Menu"];
		} else if (item == 7) {
			//memory match
			[self openMatch];
			//FLURRY
			[[cdaAnalytics sharedInstance] trackEvent:@"Memory match tapped in Main Menu"];
		} else if (item == 8) {
			//paint
			[self openPaint];
			//FLURRY
			//[[cdaAnalytics sharedInstance] trackEvent:@"Paint tapped in Main Menu on iPhone"];
		} else if (item == 9) {
			//settings + info
			[self openSettings];
			//FLURRY
			[[cdaAnalytics sharedInstance] trackEvent:@"Settings+info tapped in Main Menu"];
		}
		
		[mySubViewController addInterfaceToSubMenu:item];
		
		////adjust menu z-depth and visiblilty
		[self adjustMainMenu];
		//save navigation item
		if (item != 0) {
			[appDelegate setSaveSelectedAppSection:item];
			[appDelegate setSaveLastVisitedMenuItem:lastVisitedMenuItem];
		}
		//Remove main menu page
		if (item != 2) {
			[self unloadMainMenu];
		}
		
	} else {
		if (currentNavigationItem == item) return;
		currentNavigationItem = item;
		//dismiss any popover that might be present in the landingpage
		[myLandingpageViewController killPopoversOnSight];
		//
		[self unloadCurrentNavigationItem];
		
		[self removePendingSceneDelay];
		[self removePendingHotspotsDelay];
		
		if (item == 2) {
			//home/landingpage
			[self openLandingpage];
			//FLURRY
			[[cdaAnalytics sharedInstance] trackEvent:@"Home tapped in Main Menu"];
		} else if (item == 3) {
			//read
			//[self preOpenRead];
			[self openRead];
			//FLURRY
			[[cdaAnalytics sharedInstance] trackEvent:@"Read tapped in Main Menu"];
		} else if (item == 4) {
			//watch
			[self openWatch];
			//FLURRY
			[[cdaAnalytics sharedInstance] trackEvent:@"Watch tapped in Main Menu"];
		} else if (item == 5) {
			//paint
			[self openPaint];
			//FLURRY
			[[cdaAnalytics sharedInstance] trackEvent:@"Paint tapped in Main Menu"];
		} else if (item == 6) {
			//puzzle
			[self openPuzzles];
			//FLURRY
			[[cdaAnalytics sharedInstance] trackEvent:@"Puzzle tapped in Main Menu"];
		} else if (item == 7) {
			//connect the dots
			[self openDots];
			//FLURRY
			[[cdaAnalytics sharedInstance] trackEvent:@"Dots tapped in Main Menu"];
		}
		//hide menu - only if it's visible or if we're not moving to the Landingpage since we should have access
		//to all menu options on this page
		if ([myMainMenuController getMenuIsVisible] && item != 2) {
			[myMainMenuController hideShowMainMenu:YES];
		}
		[mySubViewController addInterfaceToSubMenu:item];
		//adjust menu z-depth and visiblilty
		[self adjustMainMenu];
		//save navigation item
		if (item != 0) {
			[appDelegate setSaveSelectedAppSection:item];
		}
	}
}
-(void)unloadCurrentNavigationItem {
	if (myPuzzleDelegate != nil) {
		[myPuzzleDelegate cleanCurrentlySelectedPuzzle];
		[myPuzzleDelegate.view removeFromSuperview];
		[myPuzzleDelegate release];
		myPuzzleDelegate = nil;
	}
	if (myMatchMenuViewController != nil) {
		[myMatchMenuViewController.view removeFromSuperview];
		[myMatchMenuViewController release];
		myMatchMenuViewController = nil;
	}
	if (myPaintMenuViewController != nil) {
		[myPaintMenuViewController.view removeFromSuperview];
		[myPaintMenuViewController release];
		myPaintMenuViewController = nil;
	}
	if (myPaintHolder != nil) {
		[myPaintHolder.view removeFromSuperview];
		[myPaintHolder release];
		myPaintHolder = nil;
	}
	if (myLandingpageViewController != nil) {
		[myLandingpageViewController.view removeFromSuperview];
		[myLandingpageViewController release];
		myLandingpageViewController = nil;
	}
	
	if (myDotViewController!=nil) {
		[myDotViewController.view removeFromSuperview];
		[myDotViewController release];
		myDotViewController=nil;
	}
	if (mySettingsViewController!=nil) {
		[mySettingsViewController.view removeFromSuperview];
		[mySettingsViewController release];
		mySettingsViewController=nil;
	}
	if (myReadController !=nil) {
		Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
		[appDelegate stopReadSpeakerPlayback];
		[appDelegate cleanUpReadSpeaker];
		[appDelegate stopEndSound];
		[self removePendingSceneDelay];
		[self removePendingHotspotsDelay];
		[self pauseCocos];
		//[appDelegate unloadReadMusic];
		[self clearCocos];
		if (endPageIsDisplayed) {
			[appDelegate stopInterfaceAudio];
            if (self.moreAppsEndiPadViewController != nil) {
                [self.moreAppsEndiPadViewController.view removeFromSuperview];
                self.moreAppsEndiPadViewController = nil;
            }
			[self.endview removeFromSuperview];
			endPageIsDisplayed = NO;
		}
		[myReadController removeSwipe];
		[myReadController.view removeFromSuperview];
		[myReadController release];
		myReadController=nil;
        
        if (self.moreAppsEndViewController != nil) {
            [self.moreAppsEndViewController.view removeFromSuperview];
            self.moreAppsEndViewController = nil;
        }
	}
}
-(void)adjustMainMenu {
	if (iPhoneMode && currentNavigationItem == 3) {
		[self.view bringSubviewToFront:mySubViewController.view];
	} else {
		if (currentNavigationItem == 4) {
			myMainMenuController.view.hidden = YES;
		} else {
			if (myMainMenuController.view.hidden) myMainMenuController.view.hidden = NO;
			//bring interface to top
			[self.view bringSubviewToFront:mySubViewController.view];
			[self.view bringSubviewToFront:myMainMenuController.view];
		}
	}
}
-(void)leaveFromWatch {
	//go to landing page
	[self navigateFromMainMenuWithItem:2];
	//show menu
	[myMainMenuController hideShowMainMenu:NO];
}
#pragma mark -
#pragma mark Main Menu
-(void)loadMainMenu {
	if (myMainMenuController == nil) {
		//myMainMenuController = [[MainMenuController alloc] initWithNibName:@"MainMenuController" bundle:nil];
		myMainMenuController = [[MainMenuController alloc] initWithNibName:@"MainMenuController" bundle:nil];
		if (!iPhoneMode) {
			myMainMenuController.view.center = CGPointMake(myMainMenuController.view.center.x-(myMainMenuController.view.frame.size.width/2-60.0), myMainMenuController.view.center.y+18.0);
		}
		//
		[self.view addSubview:myMainMenuController.view];
		[myMainMenuController initWithParent:self];
		//drop shadow -removed since it forces hi res retina resources to draw as low rez - go figure...
		//drop shadow should only apply to the menu on the iPad
		if (!iPhoneMode) {
			myMainMenuController.view.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.000].CGColor;
			myMainMenuController.view.layer.shadowOpacity = 0.3;
			myMainMenuController.view.layer.shouldRasterize = YES;
			myMainMenuController.view.layer.shadowOffset = CGSizeMake(2.16,2.16);
			myMainMenuController.view.layer.shadowRadius = 3.0;
		}
		//
		myMainMenuController.view.alpha = 0.0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(mainMenuLoaded:finished:context:)];
		[UIView setAnimationDuration:0.5];
		myMainMenuController.view.alpha = 1.0;
		[UIView commitAnimations];
	}
}

-(void)mainMenuLoaded:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	//
}
-(void)unloadMainMenu {
	if (myMainMenuController != nil) {
		[myMainMenuController.view removeFromSuperview];
		[myMainMenuController release];
		myMainMenuController = nil;
	}
}
//
#pragma mark -
#pragma mark Sub Menu
-(void)loadSubMenu {
	if (mySubViewController == nil) {
		//[self closeOpenPages];
		mySubViewController = [[SubMenuViewController alloc] initWithNibName:@"SubMenuViewController" bundle:nil];
		if (iPhoneMode) {
			mySubViewController.view.center = CGPointMake(mySubViewController.view.center.x, self.view.frame.size.height - mySubViewController.view.frame.size.height/2+(40+mySubViewController.view.frame.size.height/2));
		} else {
			mySubViewController.view.center = CGPointMake(mySubViewController.view.center.x, self.view.frame.size.height - mySubViewController.view.frame.size.height/2+(30+mySubViewController.view.frame.size.height/2));
		}
		//myMainMenuController.view.center = CGPointMake(myMainMenuController.view.center.x+17.0, myMainMenuController.view.center.y+17.0);
		[self.view addSubview:mySubViewController.view];
		[mySubViewController initWithParent:self];
		mySubViewController.view.alpha = 0.0;
		/*
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(subMenuLoaded:finished:context:)];
		[UIView setAnimationDuration:0.5];
		mySubViewController.view.alpha = 1.0;
		[UIView commitAnimations];
		*/
		//[myRootViewController updateInterfaceIcons:1];
	}
}

-(void)subMenuLoaded:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	//NSLog(@"Sub menu shoud be visible");
}

-(void)unloadSubMenu {
	if (mySubViewController != nil) {
		[mySubViewController.view removeFromSuperview];
		[mySubViewController release];
		mySubViewController = nil;
	}
}

#pragma mark -
#pragma mark Landingpage 
-(void)openLandingpage {
	if (myLandingpageViewController == nil) {
		//[self closeOpenPages];
		myLandingpageViewController = [[LandingPageViewController alloc] initWithNibName:@"LandingPageViewController" bundle:nil];
		[self.view addSubview:myLandingpageViewController.view];
		if (projectInit) {
			myLandingpageViewController.view.alpha = 1.0;
		} else {
			myLandingpageViewController.view.alpha = 0.0;
		}
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(landingpageFadedIn:finished:context:)];
		[UIView setAnimationDuration:0.5];
		myLandingpageViewController.view.alpha = 1.0;
		[UIView commitAnimations];
		
		//[myRootViewController updateInterfaceIcons:1];
	}
}

-(void)landingpageFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
    [myLandingpageViewController viewDidAppear:YES];
	if (projectInit) {
		projectInit = NO;
		if ([myMainMenuController getMenuIsVisible]==NO)
			[myMainMenuController hideShowMainMenu:NO];
	}
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	if ([appDelegate getIntroPresentationPlayed] == NO) {
		[appDelegate playintroPresentation];
		[appDelegate setIntroPresentationPlayed:YES];
	}
	landingpage.hidden = YES;
}
#pragma mark -
#pragma mark Puzzles 
-(void)openPuzzles {
	if (myPuzzleDelegate == nil) {
		//[self closeOpenPages];
		myPuzzleDelegate = [[PuzzleDelegate alloc] initWithNibName:@"PuzzleMainView" bundle:nil];
		[self.view addSubview:myPuzzleDelegate.view];
		[myPuzzleDelegate initWithParent:self];
		myPuzzleDelegate.view.alpha = 0.0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(puzzlesFadedIn:finished:context:)];
		[UIView setAnimationDuration:0.5];
		myPuzzleDelegate.view.alpha = 1.0;
		[UIView commitAnimations];
		
		//[myRootViewController updateInterfaceIcons:1];
	}
}

-(void)puzzlesFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	//[self stopRunway];
}

-(void)preStartJigsawPuzzle:(int)puzzle {
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	[appDelegate setSaveCurrentPuzzle:puzzle];
	[myPuzzleDelegate preStartJigsawPuzzle:puzzle];
}

-(int) getPuzzleDifficulty {
	return [myPuzzleDelegate getLevelOfDifficulty];
}
-(void) setPuzzleLevelOfDifficulty:(int)diff {
	[myPuzzleDelegate setLevelOfDifficulty:diff];
}
-(void)hidePuzzleSubMenu {
	[mySubViewController hideShowSubMenu:YES];
}
#pragma mark -
#pragma mark Match
-(void)openMatch {
	if (myMatchMenuViewController == nil) {
		//[self closeOpenPages];
		myMatchMenuViewController = [[MatchMenuViewController alloc] initWithNibName:@"MatchMenuViewController" bundle:nil];
		[myMatchMenuViewController initWithParent:self];
		[self.view addSubview:myMatchMenuViewController.view];
		myMatchMenuViewController.view.alpha = 0.0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(matchFadedIn:finished:context:)];
		[UIView setAnimationDuration:0.5];
		myMatchMenuViewController.view.alpha = 1.0;
		[UIView commitAnimations];
	}
}

-(void)matchFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	//
}
#pragma mark -
#pragma mark Settings + info 
-(void)openSettings {
	if (mySettingsViewController == nil) {
		mySettingsViewController = [[ThomasSettingsViewController alloc] initWithNibName:@"ThomasSettingsViewController" bundle:nil];
		[mySettingsViewController initWithParent:self];
		[self.view addSubview:mySettingsViewController.view];
		mySettingsViewController.view.alpha = 0.0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(settingsFadedIn:finished:context:)];
		[UIView setAnimationDuration:0.5];
		mySettingsViewController.view.alpha = 1.0;
		[UIView commitAnimations];
	}
}

-(void)settingsFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
    [mySettingsViewController viewDidAppear:YES];
}

#pragma mark -
#pragma mark Paint  
-(void)openPaintOnIPhone {
	if (myPaintMenuViewController == nil) {
		myPaintMenuViewController = [[PaintMenuViewController alloc] initWithNibName:@"PaintMenuViewController" bundle:nil];
		[myPaintMenuViewController initWithParent:self];
		[self.view addSubview:myPaintMenuViewController.view];
		myPaintMenuViewController.view.alpha = 0.0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(paintMenuIPhoneFadedIn:finished:context:)];
		[UIView setAnimationDuration:0.5];
		myPaintMenuViewController.view.alpha = 1.0;
		[UIView commitAnimations];
	}
}
-(void)paintMenuIPhoneFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	//
}
-(void)openPaint {
	if (myPaintHolder == nil) {
		myPaintHolder = [[PaintHolderLandscapeViewController alloc] initWithNibName:@"PaintHolderLandscapeView" bundle:nil];
		[self.view addSubview:myPaintHolder.view];
		myPaintHolder.view.alpha = 0.0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(paintFadedIn:finished:context:)];
		[UIView setAnimationDuration:0.5];
		myPaintHolder.view.alpha = 1.0;
		[UIView commitAnimations];
	}
}
-(void)paintFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	//
}
-(void)refreshPaintImage:(int)image {
	//save selection
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	[appDelegate setSaveCurrentPaintImage:image];
	//relay to paintholdercontroller
	[myPaintHolder refreshPaintImage:image];
}
#pragma mark -
#pragma mark Watch Movie
-(void)openWatch {
	if (myWatchViewController == nil) {
		myWatchViewController = [[WatchViewController alloc] initWithNibName:@"WatchViewController" bundle:nil];
		[self.view addSubview:myWatchViewController.view];
		myWatchViewController.view.alpha = 0.0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(watchFadedIn:finished:context:)];
		[UIView setAnimationDuration:0.5];
		myWatchViewController.view.alpha = 1.0;
		[UIView commitAnimations];
		
		//[myRootViewController updateInterfaceIcons:1];
	}
}
-(void)watchFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	//[self stopRunway];
}
-(void)videoFinishedPlaying {
	if (myWatchViewController != nil) {
		[myWatchViewController.view removeFromSuperview];
		[myWatchViewController release];
		myWatchViewController = nil;
		myMainMenuController.view.hidden = NO;
		projectInit = YES;
		[self navigateFromMainMenuWithItem:2];
		//[self openLandingpage];
		//[self adjustMainMenu];
	}
}
#pragma mark -
#pragma mark READ 
-(void) preOpenRead {
    
    //stay on the page
    [currentScene startAnimation];
    [self checkForSceneDelayActions];
    
    /* old alert view code
    CustomAlertViewController *alert = [[CustomAlertViewController alloc]init];
    alert.delegate = self;
    alert.view.tag = CAVCReadAlert;
    [alert show:self.view];
    [alert release]; 
     */
    /*
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you want to go to the first page of the story or resume from this one?" delegate:self cancelButtonTitle:@"Page 1" otherButtonTitles:@"Resume", nil];
	[alert show];
	[alert release];
     */
}

- (void) CustomAlertViewController:(CustomAlertViewController *)alert wasDismissedWithValue:(NSString *)value {
    if(alert.view.tag == CAVCReadAlert) {
        if ([value isEqualToString:@"Resume"]) {
            //stay on the page
            [currentScene startAnimation];
            [self checkForSceneDelayActions];
        }
        else if ([value isEqualToString:@"Page1"]) {
            if (iPhoneMode) {
                [self gotoPage:2 :YES];
            } else {
                [self gotoPage:2 :YES];
            }
        }
    }
}

    /* old alert view
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		//NSLog(@"This is button 0");
		if (iPhoneMode) {
			[self gotoPage:2 :YES];
		} else {
			[self gotoPage:2 :YES];
		}
	} else if (buttonIndex == 1) {
		//NSLog(@"This is button 1");
		//NSLog(@"Just stay on page");
		[currentScene startAnimation];
		[self checkForSceneDelayActions];
	}
}
     */
-(void)openRead{
	if (myReadController==nil) {
		//if cocos has not benn initialized, do so
		if (!cocosInit) {
			[self initCocos];
			cocosInit=YES;
			cocosShown=YES;
		}
		//if cocos is stopeed, start it up again
		if (!cocosShown) {
			[self startCocos];
		}
		//get cocos view
		myReadController=[[ReadController alloc] init];
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {

			glview.layer.transform=CATransform3DIdentity;
			glview.layer.transform=CATransform3DMakeScale(0.9375/2, 0.9375/2, 1);
			glview.layer.transform=CATransform3DTranslate(glview.layer.transform, -580, -480+37, 0);
		}
		myReadController.view.frame=glview.bounds;
		[myReadController.view addSubview:glview];
		turningPage=YES;
		[myReadController setupSwipe];
		[myReadController addMainMenuButton];
		
		//set first page
		currentScene=nil;
		nextScene=[[BookScene node] retain];
		[nextScene setPage:[[sceneData objectAtIndex:currentReadPage] integerValue]];
		[[CCDirector sharedDirector] replaceScene:nextScene];
		
		//see if we need to replace the submenu fade
		[mySubViewController setSubmenuFade];
		
		[self updatePageNumberAndTrain];
		
		[self.view addSubview:myReadController.view];
		myReadController.view.alpha = 0.0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(readFadedIn:finished:context:)];
		[UIView setAnimationDuration:0.5];
		myReadController.view.alpha = 1.0;
		[UIView commitAnimations];
	}
}
-(void)readFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:currentScene priority:0 swallowsTouches:YES];
	//[currentScene startAnimation];
	[self sceneCleanup];
	turningPage=NO;
	
	//check for narration
	//if (currentNarrationSetting) {
		//Play the speaker
		//NSLog(@"Play speaker on scene: %i", [[sceneData objectAtIndex:currentReadPage] integerValue]);
		//[self playNarrationOnScene];
	//}
	
	//[self checkForSceneDelayActions];
	if (iPhoneMode) {
		if (currentReadPage == 0 || currentReadPage == 1) {
			[currentScene startAnimation];
			[self checkForSceneDelayActions];
		} else {
			[self preOpenRead];
		}	
	} else {
		if (currentReadPage == 0) {
			[currentScene startAnimation];
			[self checkForSceneDelayActions];
		} else {
			[self preOpenRead];
		}
	}
	/*
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	if ([appDelegate getSaveMusicSetting]) {
		[appDelegate loadReadMusic];
	}
	 */
	//Enable arrow navigation
	[mySubViewController enableTappedNavButton];
    [myReadController enableUserInteraction];
    [myMainMenuController enableUserInteraction];
}
-(void) updatePageNumberAndTrain {
	if (iPhoneMode) {
		//train stays static - no pagenumbers
		mySubViewController.train.center = CGPointMake(self.view.bounds.size.width/2, mySubViewController.train.center.y);
	} else {
		float thepage = [[sceneData objectAtIndex:currentReadPage] integerValue]-1;
		//update pagenumbers in subviewController
        mySubViewController.pageNumber.text = [NSString stringWithFormat:@"%i", (int)thepage];
            
		float startposx = 121;
		float tracklength = 827;
		float numpages = 24;
		if (iPhoneMode) {
			//just in case they want it to start moving after all...
			startposx = 55;
			tracklength = 375;
		}
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.8];
		mySubViewController.train.center = CGPointMake(startposx+((tracklength/numpages)*(thepage-1)), mySubViewController.train.center.y);
		[UIView commitAnimations];
		
		/*Only works in 4.0 and later - this is for 3.2 so let's skip this for now
		 [UIView animateWithDuration:0.8
		 animations:^{mySubViewController.train.center = CGPointMake(32+((951/24)*thepage), mySubViewController.train.center.y);}
		 completion:^(BOOL finished){ NSLog(@"Train finished moving - Huff and Puff perhaps?"); }];
		 */
	}
}
-(void) checkForSceneDelayActions {
	//NSLog(@"checkForSceneDelayActions");
	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"scenedelay" ofType:@"plist"];
	NSArray *delaycheck = [[NSArray alloc] initWithContentsOfFile:thePath];
	NSDictionary *scenedelay = [NSDictionary dictionaryWithDictionary:[delaycheck objectAtIndex:currentReadPage]];
	//SPEAKER DELAY
	float delay = [[scenedelay objectForKey:@"delay"] floatValue];
	//HOTSPOT DELAY AND POSITIONS
	hotspotsOnScene = [[NSMutableArray alloc] initWithArray:[scenedelay objectForKey:@"indicators"]];
	//test
	/*
	NSDictionary *test = [NSDictionary dictionaryWithDictionary:[hotspots objectAtIndex:0]];
	float xtest = [[test objectForKey:@"x"] floatValue];
	NSLog(@"this is x: %f", xtest);
	*/
	//
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	
	if ([hotspotsOnScene count]>0) {
		hotspotsAreDelayed = YES;
		NSDictionary *getDelay = [NSDictionary dictionaryWithDictionary:[hotspotsOnScene objectAtIndex:0]];
		float hsdelay = [[getDelay objectForKey:@"delay"] floatValue];
		[appDelegate setHotspotsTime:hsdelay];
		readHotspotDelay = [[NSTimer scheduledTimerWithTimeInterval:hsdelay target:self selector:@selector(doHotspotsDelayActions) userInfo:nil repeats:NO] retain];
	}
		
	speakerIsDelayed = YES;
	[appDelegate setNarrationTime:delay];
	readSceneDelay = [[NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(doSceneDelayActions) userInfo:nil repeats:NO] retain];
	
	[delaycheck release];
}
-(void)removePendingSceneDelay {
	//NSLog(@"removePendingSceneDelay");
	if (readSceneDelay != nil) {
		if ([readSceneDelay isValid]) {
			speakerIsDelayed = NO;
			[speakerDelayStart release];
			[readSceneDelay invalidate];
			readSceneDelay = nil;
		}
	}
    if ([self isLastPage]) {
        [self removeEndPage];
    }
	 
}
-(void) doSceneDelayActions {
    if ([self isLastPage]) {
        [self displayEndPage];
    }

	//NSLog(@"doSceneDelayActions");
	if (speakerIsDelayed == NO) return;
	speakerIsDelayed = NO;
	/*if (currentNarrationSetting) {
		//Play the speaker
		[self playNarrationOnScene];
	}*/
	if (speakerWhileOff) {
		[self forceNarrationOnScene];
	}else {
		[self playNarrationOnScene];
	}
}

-(void)removePendingHotspotsDelay {
	//NSLog(@"removePendingHotspotsDelay");
	if (readHotspotDelay != nil) {
		if ([readHotspotDelay isValid]) {
			hotspotsAreDelayed = NO;
			[readHotspotDelay invalidate];
			readHotspotDelay = nil;
		}
	}
	/*
	if (readHotspotRespawnTimer != nil) {
		if ([readHotspotRespawnTimer isValid]) {
			[readHotspotRespawnTimer invalidate];
			readHotspotRespawnTimer = nil;
		}
	}
	 */
	
}
-(void) doHotspotsDelayActions {
	if (hotspotsAreDelayed == NO) return;
	if(readOverlayView) return;
	//NSLog(@"doHotspotsDelayActions");
	hotspotsAreDelayed = NO;
	//DO the HOTSPOT thingy here
	//NSLog(@"Hotspots are executing");
	if ([hotspotsOnScene count]>0) {
		CGRect myframe = CGRectMake(0, 0, 1024, 768);
		UIView *myhotspotholder = [[UIView alloc] initWithFrame:myframe];
		myhotspotholder.backgroundColor = [UIColor clearColor];
		myhotspotholder.alpha = 0.0;
		for (unsigned i=0; i<[hotspotsOnScene count]; i++) {
			//add hotspots...
			//NSLog(@"Adding hotspot");
			UIImageView *temp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TAF001_highlight.png"]];
			NSDictionary *getpos = [NSDictionary dictionaryWithDictionary:[hotspotsOnScene objectAtIndex:i]];
			float myx = [[getpos objectForKey:@"x"] floatValue];
			float myy = [[getpos objectForKey:@"y"] floatValue];
			
			
				
			
			
			if (iPhoneMode) {
				myx*=kiPhoneLayerScale;
				myy*=kiPhoneLayerScale;
			}
			
			temp.center = CGPointMake(myx, myy);
			if (myx>0 || myy>0) [myhotspotholder addSubview:temp];
			[temp release];
		}
		[self.view addSubview:myhotspotholder];
		self.hotspotHolder = myhotspotholder;
		[myhotspotholder release];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hotspotsFadedIn:finished:context:)];
		[UIView setAnimationDuration:2.0];
		self.hotspotHolder.alpha = 1.0;
		self.hotspotHolder.alpha = 0.0;
		[UIView commitAnimations];
	}
}
-(void)hotspotsFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	[self.hotspotHolder removeFromSuperview];
	//respawn hotspots
	//readHotspotRespawnTimer = [[NSTimer scheduledTimerWithTimeInterval:7 target:self selector:@selector(respawnHotspots) userInfo:nil repeats:NO] retain];
}
-(void)respawnHotspots {
	//if ([currentScene isAnimating]) {
	//	readHotspotRespawnTimer = [[NSTimer scheduledTimerWithTimeInterval:7 target:self selector:@selector(respawnHotspots) userInfo:nil repeats:NO] retain];
	//} else {
	hotspotsAreDelayed = YES;
	[self doHotspotsDelayActions];
	//}
}
-(void)checkIfNarrationDateIsDelayed {
	//NSLog(@"checkIfNarrationDateIsDelayed");
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	if (speakerIsDelayed) {
		//kill timer
		if ([readSceneDelay isValid]) {
			[speakerDelayStart release];
			[readSceneDelay invalidate];
			readSceneDelay = nil;
		}
		//get new time
		NSDate *old = [appDelegate getNarrationTime];
		NSDate *now = [NSDate date];
		NSTimeInterval difference = [now timeIntervalSinceDate:old];
		//NSLog(@"This is the difference: %f", float(difference));
		if (fullSpeakerDelayTime >= 0) {
			[appDelegate setSavedDelaytime:difference];
		}
	}
	if (hotspotsAreDelayed) {
		//kill timer
		if ([readHotspotDelay isValid]) {
			[readHotspotDelay invalidate];
			readHotspotDelay = nil;
		}
		//get new time
		NSDate *old = [appDelegate getHotspotsTime];
		NSDate *now = [NSDate date];
		NSTimeInterval difference = [now timeIntervalSinceDate:old];
		//NSLog(@"This is the difference: %f", float(difference));
		if (fullHotspotDelayTime >= 0) {
			[appDelegate setSavedHotspotsDelaytime:difference];
		}
	}
}

-(BOOL)getSpeakerIsDelayed {
	return speakerIsDelayed;
}
-(void) setSpeakerIsDelayed:(BOOL)delayed {
	speakerIsDelayed = delayed;
}
- (void)pauseReadPlayback {
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	[appDelegate pauseReadPlayback];
}
- (void)startReadPlayback {
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	[appDelegate startReadPlayback];
}
-(void) displayEndPage {
	if (iPhoneMode) return;
    
    if (endPageIsDisplayed) return;
	//NSLog(@"Displaying end page");
	//UIImage = [UIImage imageWithContentsOfFile:@
/* old end page
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *endimage = [bundle pathForResource:@"the_end" ofType:@"png"];
	UIImage *tempimg = [UIImage imageWithContentsOfFile:endimage];
	UIImageView *tempimgview = [[UIImageView alloc] initWithImage:tempimg];
	tempimgview.userInteractionEnabled = NO;
	tempimgview.center = CGPointMake(512, 384);
	[self.view addSubview:tempimgview];
	tempimgview.alpha = 0.0;
	self.endview = tempimgview;
	[tempimgview release];
 */
	/*
	[UIView animateWithDuration:0.3
					 animations:^{self.endview.alpha = 1.0;}
					 completion:^(BOOL finished){ NSLog(@"endview appeared"); }];
	*/

/* old end page
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.3];
	self.endview.alpha = 1.0;
	[UIView commitAnimations];
*/
    
    // allocate end page ticket view
    if (self.moreAppsEndiPadViewController == nil) {
        MoreAppsEndiPadViewController *moreAppsView = [MoreAppsEndiPadViewController alloc];
        self.moreAppsEndiPadViewController = [moreAppsView initWithNibName:@"EndPageiPad" bundle:nil];
        [moreAppsView release];
    }
    self.moreAppsEndiPadViewController.view.alpha = 0.0f;
    [self.view addSubview:self.moreAppsEndiPadViewController.view];

    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.3];
	self.moreAppsEndiPadViewController.view.alpha = 1.0f;
	[UIView commitAnimations];
    
    endPageIsDisplayed = YES;

    [self adjustMainMenu];
    //treat the end page as a seperate page
    return;
    

    
	[self pauseNarrationOnScene];
	if ([self getSpeakerIsDelayed]) {
		[self checkIfNarrationDateIsDelayed];
	}
	[self pauseCocos];
	/*
	[UIView animateWithDuration:0.3
					 animations:^{glview.alpha = 0.5;}
					 completion:^(BOOL finished){ NSLog(@"cocos faded"); }];
	*/
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.3];
	glview.alpha = 0.5;
	[UIView commitAnimations];
	
	[[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
	
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	[appDelegate playEndSound];
	
//	[myMainMenuController hideShowMainMenu:NO];
	
	//Enable arrow navigation
	[mySubViewController enableTappedNavButton];
    [myReadController enableUserInteraction];
    [myMainMenuController enableUserInteraction];
}
-(void) removeEndPage {
	if (iPhoneMode) return;
	//NSLog(@"Removing end page");
    //fade out the end page
    if (self.moreAppsEndiPadViewController) {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.moreAppsEndiPadViewController.view.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             [self.moreAppsEndiPadViewController.view removeFromSuperview];
                             self.moreAppsEndiPadViewController = nil;
                         }];
        
    }

    //new end page behavior
    return;
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	[appDelegate stopEndSound];
	[self resumeNarrationOnScene];
	/*
	[UIView animateWithDuration:0.2
					 animations:^{glview.alpha = 1.0;}
					 completion:^(BOOL finished){ NSLog(@"cocos appeared"); }];
	 */

	
	[self resumeCocos];
	
	[[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
	
	//Enable arrow navigation
	[mySubViewController enableTappedNavButton];
    [myReadController enableUserInteraction];
    [myMainMenuController enableUserInteraction];
}

#pragma mark ReadOverlayView
/*
-(void)showReadOverlayViewWithText:(NSString *)text style:(int)style{
	;//don't worry about it, it is for the iPhone
}
 */
-(void)showReadOverlayViewWithText:(NSString *)text style:(ReadOverlayViewStyle)style{
	NSLog(@"This is current read page: %i", currentReadPage);
	if(readOverlayView || currentReadPage == 0 || currentReadPage == [sceneData count]-1) return;
	readOverlayView=[[[ReadOverlayView alloc]initWithFrame:self.view.bounds text:text style:style]autorelease];
	[readOverlayView setTarget:self selector:@selector(setOverlayViewToNil)];
	[readOverlayView presentInViewAnimated:self.view];
	
}
-(void)setOverlayViewToNil{
	readOverlayView=nil;
	[self performSelector:@selector(respawnHotspots) withObject:nil afterDelay:.3];
}

//iPhone only
-(void)showMoreAppsEndPage{
    if (self.moreAppsEndViewController == nil) {
        MoreAppsEndViewController *moreAppsView = [MoreAppsEndViewController alloc];
        self.moreAppsEndViewController = [moreAppsView initWithNibName:@"MoreAppsEndView" bundle:nil];
        [moreAppsView release];
    }
    self.moreAppsEndViewController.view.alpha = 0.0f;
	[self.view addSubview:self.moreAppsEndViewController.view];
    
    //fade in the view
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	[UIView setAnimationDuration:.3];
	self.moreAppsEndViewController.view.alpha=1.0f;
	[UIView commitAnimations];

}


#pragma mark -
#pragma mark COUNT THE DOTS
-(void)openDots {
	if (myDotViewController ==nil) {
		//[self closeOpenPages];
		myDotViewController = [[DotViewController alloc] init];
		[self.view addSubview:myDotViewController.view];
		myDotViewController.view.alpha = 0.0;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(dotsFadedIn:finished:context:)];
		[UIView setAnimationDuration:0.5];
		myDotViewController.view.alpha = 1.0;
		[UIView commitAnimations];
		
		//[myRootViewController updateInterfaceIcons:1];
	}
	
}

-(void)dotsFadedIn:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	
}

-(void)preStartDots:(int)dot {
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	[appDelegate setSaveDotDifficulty:currentDotState];
	[appDelegate setSaveCurrentDotImage:dot];
	//[myDotViewController setPuzzle:(dot-1)%3];
	[myDotViewController initPuzzle:(dot-1)%3 :currentDotState==0];
}
-(int) getDotDifficulty {
	//return [myDotViewController getDifficulty];
	return [self getCurrentDotsState];
}
-(void) setDotLevelOfDifficulty:(int)diff {
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	currentDotState=diff;
	[appDelegate setSaveDotDifficulty:currentDotState];
	[myDotViewController setDifficulty:diff==0];
}
-(void)hideDotsSubMenu {
	//Call this from Dots if needed to hide the submenu for dots
	[mySubViewController hideShowSubMenu:YES];	
}
#pragma mark -
#pragma mark TRAIN UPDATES in other sections
-(void) updatePaintTrain:(int)image {
	int thepage = image;
	int startposx = -25;
	int tracklength = 963;
	int numpuzzles = 10;
	
	float thumbwidth = 129;
	float trainwidth = 110;
	float compensate = (thumbwidth-trainwidth)/2;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.8];
	mySubViewController.train.center = CGPointMake(startposx+((tracklength/numpuzzles)*thepage)-compensate, mySubViewController.train.center.y);
	[UIView commitAnimations];
	
	//4.0 specific - doesn't work on 3.2
	/*
	[UIView animateWithDuration:0.8
					 animations:^{mySubViewController.train.center = CGPointMake(startposx+((tracklength/numpuzzles)*thepage)-compensate, mySubViewController.train.center.y);}
					 completion:^(BOOL finished){ NSLog(@"Paint train finished moving"); }];
	 */
}
-(void) updatePuzzleTrain {
	int thepage = [myPuzzleDelegate getCurrentPuzzle];
	
	int startposx = -36;
	int tracklength = 760;
	float thumbwidth = 129;
	float trainwidth = 66;
	float compensate = (thumbwidth-trainwidth)/2;
	int numpuzzles = 5;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.8];
	mySubViewController.train.center = CGPointMake(startposx+((tracklength/numpuzzles)*thepage)-compensate, mySubViewController.train.center.y);
	[UIView commitAnimations];
	
	
	/*
	[UIView animateWithDuration:0.8
					 animations:^{mySubViewController.train.center = CGPointMake(startposx+((tracklength/numpuzzles)*thepage)-compensate, mySubViewController.train.center.y);}
					 completion:^(BOOL finished){ NSLog(@"Puzzle train finished moving"); }];
	 */
	/*
	int startposx = 20;
	int tracklength = 963;
	int numpuzzles = 6;
	
	float thumbwidth = 129;
	float trainwidth = 66;
	float compensate = (thumbwidth-trainwidth)/2;
	
	
	[UIView animateWithDuration:0.8
					 animations:^{mySubViewController.train.center = CGPointMake(startposx+((tracklength/numpuzzles)*thepage)-compensate, mySubViewController.train.center.y);}
					 completion:^(BOOL finished){ NSLog(@"Puzzle train finished moving"); }];
	 */
}
-(void) updateDotTrain:(int)image {
	int thepage = image;
	int startposx = -36;
	int tracklength = 445;
	float thumbwidth = 129;
	float trainwidth = 66;
	float compensate = (thumbwidth-trainwidth)/2;
	int numpuzzles = 3;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.8];
	mySubViewController.train.center = CGPointMake(startposx+((tracklength/numpuzzles)*thepage)-compensate, mySubViewController.train.center.y);
	[UIView commitAnimations];
	
	/*
	[UIView animateWithDuration:0.8
					 animations:^{mySubViewController.train.center = CGPointMake(startposx+((tracklength/numpuzzles)*thepage)-compensate, mySubViewController.train.center.y);}
					 completion:^(BOOL finished){ NSLog(@"Dots train finished moving"); }];
	 */
}
#pragma mark -
#pragma mark Getter and Setters
-(int) getCurrentNavigationItem {
	return currentNavigationItem;
}
-(int) getLastVisitedMenuItem {
	NSLog(@"This is the lastVisited in returFromMain: %i", lastVisitedMenuItem);
	return lastVisitedMenuItem;
}
-(int) getSavedNavigationItem {
	return savedNavigationItem;
}
-(int) getCurrentReadPage {
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	currentReadPage = [appDelegate getSaveCurrentReadPage];
	return currentReadPage;
}
-(int) setCurrentReadPage:(int)page {
	currentReadPage = page;
	return currentReadPage;
}
-(int) getNumberOfReadPages {
	return sceneData.count-1;
}
-(BOOL) isLastPage {
    if (currentReadPage ==  sceneData.count-1) {
        return YES;
    }
    else {
        return NO;
    }
}
-(BOOL)getEndPageIsDisplayed {
	return endPageIsDisplayed;
}
-(int) getCurrentPaintPage {
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	currentPaintImage = [appDelegate getSaveCurrentPaintImage];
	return currentPaintImage;
}
-(void) setCurrentPaintPage:(int)page {
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	[appDelegate setSaveCurrentPaintImage:page];
}
- (int) getCurrentPuzzlePage {
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	currentPuzzle = [appDelegate getSaveCurrentPuzzle];
	return currentPuzzle;
}
- (int) getCurrentDotsPage {
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	currentDotImage = [appDelegate getSaveCurrentDotImage];
	return currentDotImage;
}
-(int)getCurrentDotsState{
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	currentDotState = [appDelegate getSaveDotDifficulty];
	return currentDotState;
}
-(BOOL)getNarrationValue {
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	return [appDelegate getSaveNarrationSetting];
}
-(void)setNarrationValue:(int)value {
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	speakerWhileOff=NO;
	if (!turningPage && currentScene!=nil && value==0 && !speakerWhileOff) {
		[currentScene setReplayVisible];
	} else if (!turningPage && currentScene!=nil&& !speakerWhileOff) {
		//[currentScene setReplayHidden];
	}

	[appDelegate setSaveNarrationSetting:value]; 
}
-(int)getMusicValue {
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	currentMusicSetting = [appDelegate getSaveMusicSetting];
	return currentMusicSetting;
}
-(void)setMusicValue:(int)value {
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	[appDelegate setSaveMusicSetting:value];
}
-(BOOL)getSwipeValue {
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	return [appDelegate getSwipeInReadIsTurnedOff];
}
-(void)setSwipeValue:(BOOL)value {
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	[appDelegate setSwipeInReadIsTurnedOff:value];
}
-(BOOL) getIPhoneMode {
	return iPhoneMode;
}
-(NSString*)getCurrentLanguage {
	return [[Misty_Island_Rescue_iPadAppDelegate get] getCurrentLanguage];
}
#pragma mark -
#pragma mark COCOS 
-(void)initCocos{
	if (![CCDirector setDirectorType:kCCDirectorTypeDisplayLink]) {
		[CCDirector setDirectorType:kCCDirectorTypeNSTimer];
	}	
	CCDirector *director = [CCDirector sharedDirector];
	[director setDisplayFPS:NO];
	[director setAnimationInterval:1.0/60];
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];
	//CGRect eagleframe = CGRectMake(0, 0, 480, 360);
	glview = [EAGLView viewWithFrame:CGRectMake(0, 0, 1024, 768)
						 pixelFormat:kEAGLColorFormatRGBA8
						 depthFormat:GL_DEPTH_COMPONENT24_OES 
				  preserveBackbuffer:NO];
	[director setOpenGLView:glview];	
	[glview setMultipleTouchEnabled:NO];
	glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
	currentScene=nil;
	nextScene=nil;
	CCScene *scene=[CCScene node];
	[scene addChild:[CCColorLayer layerWithColor:ccc4(255, 0, 0, 255)]];
	[director runWithScene: scene];
}

-(void) gotoPage:(int)page:(BOOL)withTransition{
	if (currentScene!=nil) {
		if (page==currentScene.page) {
			return;
		}
	}
	if (turningPage) {
		return;
	}
	if (endPageIsDisplayed) {
		//at the end showing the addon over image
		endPageIsDisplayed = NO;
		[self removeEndPage];
	}
	[PlaySoundAction stopSounds];
	[PlaySoundAction clearSounds];
	[PlaySoundAction setSoundsPrevented:NO];
	speakerWhileOff=NO;
	[self removePendingSceneDelay];
	[self removePendingHotspotsDelay];
	turningPage=YES;
	currentReadPage = [sceneData indexOfObject:[NSNumber numberWithInt:page]];
	if ([myMainMenuController getMenuIsVisible]) {
		[myMainMenuController hideShowMainMenu:YES];
	}
    
    [myReadController disableUserInteraction];
    [myMainMenuController disableUserInteraction];
    
	//save current read page
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	if (appDelegate.speakerPlayer.playing) [appDelegate stopReadSpeakerPlayback];
	[appDelegate setSaveCurrentReadPage:currentReadPage];
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:currentScene];
	
	//[currentScene stopAnimation];
	[currentScene turnIntoScreenshot];
	
	
	//see if we need to replace the submenu fade
	[mySubViewController setSubmenuFade];
	
	nextScene=[[BookScene node] retain];
	[nextScene setPage:page];
	if (withTransition) {
		[[CCDirector sharedDirector] setDepthTest:YES];
		[[CCDirector sharedDirector] replaceScene:[CCPageTurnTransition transitionWithDuration:1.0f scene:nextScene backwards:(page<currentScene.page)]];
	}else {
		[[CCDirector sharedDirector] replaceScene:nextScene];
	}
	
	[self updatePageNumberAndTrain];
}

-(void) turnpage:(BOOL)forwards{
	if (turningPage) {
		return;
	}
    
    int numberofpages = sceneData.count-1;

    //if we are on first or last page do nothing
    if (forwards && currentReadPage == numberofpages) return;
    if (!forwards && currentReadPage == 0) return;
    
    if ([self isLastPage]) {
        [self removeEndPage];
    }
	//disable arrow temporary
	[mySubViewController disableTappedNavButton];
    [myReadController disableUserInteraction];
    [myMainMenuController disableUserInteraction];
	if (forwards) {
        /* OLD end page functionality
		if (currentReadPage == numberofpages) {
            //currentReadPage = 0;
			//show end page and then exit
			if (endPageIsDisplayed == NO) {
				endPageIsDisplayed = YES;
				[self displayEndPage];
			}
            //do nothing
			return;
		} else {
			currentReadPage++;
		}
         */
        currentReadPage++;
	}else {
		if (currentReadPage == 0) {
			//currentReadPage = numberofpages;
			//do nothing
			return;
		} else {
			if (endPageIsDisplayed) {
				//at the end showing the addon over image
				endPageIsDisplayed = NO;
				[self removeEndPage];
				//return;
			}
			currentReadPage--;
		}
	}
	[self gotoPage:[[sceneData objectAtIndex:currentReadPage] integerValue] :YES];
}

-(void) sceneTransitionDone{
	[[CCDirector sharedDirector] setDepthTest:NO];
	BOOL first=currentScene==nil;
	//NSLog(@"scene transition done");
	//switch scene
	if (nextScene!=nil) {
		[currentScene release];
		currentScene=nextScene;
		nextScene=nil;
	}
	//if cocos is shutting down, cancel
	if (queueClear) {
		queueClear=NO;
		[self clearCocos];
		return;
	}
	//if it's not the first page, start it up and clean up old resources
	//(if it's the first page it will be started in readFadedIn instead)
	if (!first){
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:currentScene priority:0 swallowsTouches:YES];
		[currentScene startAnimation];
		[self performSelector:@selector(sceneCleanup) withObject:nil afterDelay:0.2f];
		turningPage=NO;
		//check for narration
		//if (currentNarrationSetting) {
			//Play the speaker
			//NSLog(@"Play speaker on scene: %i", [[sceneData objectAtIndex:currentReadPage] integerValue]);
			//[self playNarrationOnScene];
		//}
		//Enable arrow navigation
		//[mySubViewController enableTappedNavButton];
		//check for scene delays
		[self checkForSceneDelayActions];
		
	}
//    if(currentReadPage == (int)[sceneData count]-1) {
//        [self displayEndPage];
//    }
	//check for narration - moved to scene delay
	/*
	if (currentNarrationSetting) {
		//Play the speaker
		NSLog(@"Play speaker on scene: %i", [[sceneData objectAtIndex:currentReadPage] integerValue]);
		[self playNarrationOnScene];
	}
	 */
	//Enable arrow navigation
	[mySubViewController enableTappedNavButton];
    [myReadController enableUserInteraction];
    [myMainMenuController enableUserInteraction];
    
	//save current read page
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	[appDelegate setSaveCurrentReadPage:currentReadPage];
}

-(void) sceneCleanup{
	//release cocos data
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

-(void) fullCleanup{
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeSpriteFrames];
	[[CCTextureCache sharedTextureCache] removeAllTextures];
}

#pragma mark -
#pragma mark AUDIO
-(void)playNarrationOnScene {
	//NSLog(@"playNarrationOnScene");
	if (currentReadPage == 0 && iPhoneMode) return;
	//if ((currentReadPage == 0 || currentReadPage == [sceneData count]-1) && iPhoneMode) return;
	if (currentNavigationItem != 3) return;
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	if ([appDelegate getSaveNarrationSetting]) {
		if (appDelegate.speakerPlayer.playing) [appDelegate stopReadSpeakerPlayback];
		NSString *mypath = @"";
		if ([[appDelegate getCurrentLanguage] isEqualToString:@"en_GB"]) {
			mypath = [NSString stringWithFormat:@"Speaker_Scene_%i" "_UK", [[sceneData objectAtIndex:currentReadPage] integerValue]];
		} else {
			mypath = [NSString stringWithFormat:@"Speaker_Scene_%i", [[sceneData objectAtIndex:currentReadPage] integerValue]];
		}
		NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
		AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
		[fileURL release];
		if (thePlayer) {
			appDelegate.speakerPlayer = thePlayer;
			[thePlayer release];
			appDelegate.speakerPlayer.volume = 1.0;
			[appDelegate startReadSpeakerPlayback];
			if (!turningPage && currentScene!=nil){
				[currentScene setReplayHidden];
			}
		}
	}
}

-(void)forceNarrationOnScene {
	//NSLog(@"forceNarrationOnScene");
	if (currentNavigationItem != 3) return;
	speakerWhileOff=YES;
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	if (speakerIsPausedByFX) {
		[appDelegate forceReadSpeakerPlayback];
		if (!turningPage && currentScene!=nil){
			[currentScene setReplayHidden];
		}
	} else {
	if (appDelegate.speakerPlayer.playing) [appDelegate stopReadSpeakerPlayback];
	NSString *mypath = @"";
	if ([[appDelegate getCurrentLanguage] isEqualToString:@"en_GB"]) {
		mypath = [NSString stringWithFormat:@"Speaker_Scene_%i" "_UK", [[sceneData objectAtIndex:currentReadPage] integerValue]];
	} else {
		mypath = [NSString stringWithFormat:@"Speaker_Scene_%i", [[sceneData objectAtIndex:currentReadPage] integerValue]];
	}
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: [[NSBundle mainBundle] pathForResource:mypath ofType:@"m4a"]];
	AVAudioPlayer *thePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
	[fileURL release];
	if (thePlayer) {
		appDelegate.speakerPlayer = thePlayer;
		[thePlayer release];
		appDelegate.speakerPlayer.volume = 1.0;
		[appDelegate forceReadSpeakerPlayback];
		if (!turningPage && currentScene!=nil){
			[currentScene setReplayHidden];
		}
	}
	}
}

-(void) setSpeakerIsPaused:(BOOL)paused {
	speakerIsPaused = paused;
}
-(BOOL) getSpeakerIsPaused {
	return speakerIsPaused;
}
-(void) setSpeakerIsPausedByFX:(BOOL)paused {
	speakerIsPausedByFX = paused;
}
-(void)pauseNarrationOnScene {
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	if (appDelegate.speakerPlayer.playing) [appDelegate pauseReadSpeakerPlayback];
}
-(void)resumeNarrationOnScene {
	//NSLog(@"resumeNarrationOnScene");
	if (currentNavigationItem != 3) return;
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	if (speakerIsDelayed) {
		float thetime = [appDelegate getSavedDelaytime];
		//NSLog(@"Should be some time here: %f", thetime);
		readSceneDelay = [[NSTimer scheduledTimerWithTimeInterval:thetime target:self selector:@selector(doSceneDelayActions) userInfo:nil repeats:NO] retain];
	} else if (speakerIsPaused) {
		if (speakerWhileOff) {
			[appDelegate forceReadSpeakerPlayback];
		}else {
			[appDelegate startReadSpeakerPlayback];
		}
		speakerIsPaused = NO;
	}
	if (hotspotsAreDelayed) {
		float thehstime = [appDelegate getSavedHotspotsDelaytime];
		//NSLog(@"Should be some time here: %f", thehstime);
		readSceneDelay = [[NSTimer scheduledTimerWithTimeInterval:thehstime target:self selector:@selector(doHotspotsDelayActions) userInfo:nil repeats:NO] retain];
	}
}
-(void)narrationFinished{
	speakerWhileOff=NO;
	//Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	if (!turningPage && currentScene!=nil){
		[currentScene setReplayVisible];
	}
}
- (void)playCardSound:(int)sound {
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
	[appDelegate playCardSound:sound];
}
#pragma mark -
#pragma mark Application related

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	landscapeRight=toInterfaceOrientation==UIInterfaceOrientationLandscapeRight;
	[currentScene orientationChanged:landscapeRight];
	[nextScene orientationChanged:landscapeRight];
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
	[currentScene release];
	[nextScene release];
	[[CCDirector sharedDirector] release];
	[sceneData release];
	[myPuzzleDelegate release];
	[readSceneDelay release];
	[speakerDelayStart release];
	[endview release];
	[hotspotsOnScene release];
	[readHotspotDelay release];
	[readHotspotRespawnTimer release];
	[hotspotHolder release];
    [super dealloc];
}

-(void) pauseCocos{
	if (cocosInit && cocosShown && !cocosPaused) {
		cocosPaused=YES;
		[PlaySoundAction pauseSounds];
		[[CCDirector sharedDirector] pause];
	}	
}
-(void) resumeCocos{
	if (cocosInit && cocosShown && cocosPaused) {
		cocosPaused=NO;
		[PlaySoundAction resumeSounds];
		[[CCDirector sharedDirector] resume];
	}
}
//pause and resume with fade down on scene
-(void) pauseCocos:(BOOL)fade {
	if (cocosInit && cocosShown && !cocosPaused) {
		if (fade) {
			glview.alpha = 0.5;
			readViewIsPaused = YES;
		}
		cocosPaused=YES;
		[PlaySoundAction pauseSounds];
		[[CCDirector sharedDirector] pause];
	}	
}
-(void) resumeCocos:(BOOL)fade {
	if (cocosInit && cocosShown && cocosPaused) {
		if (fade) {
			glview.alpha = 1.0;
			readViewIsPaused = NO;
		}
		cocosPaused=NO;
		[PlaySoundAction resumeSounds];
		[[CCDirector sharedDirector] resume];
	}
}
-(void)unPauseReadView {
	if (readViewIsPaused) {
		//unpause
		readViewIsPaused = NO;
		[mySubViewController hideShowSubMenu:YES];
	}
}
-(BOOL)getReadViewIsPaused {
	return readViewIsPaused;
}
-(BOOL)getCocosPaused {
	return cocosPaused;
}
-(void) stopCocos{
	//NSLog(@"stopCocos");
	if (cocosInit && cocosShown) {
		cocosShown=NO;
		[[CCDirector sharedDirector] stopAnimation];
	}
}

-(void) startCocos{
	//NSLog(@"startCocos");
	if (cocosInit && !cocosShown) {
		cocosShown=YES;
		[[CCDirector sharedDirector] startAnimation];
	}
}

-(void) clearCocos{
	NSLog(@"clearCocos");
	if (!cocosInit || !cocosShown) {
		return;
	}
	
	if (nextScene!=nil) {
		queueClear=YES;
		return;
	}
	
	NSLog(@"clearCocos - wasn't returned");
	
	[PlaySoundAction stopSounds];
	[PlaySoundAction clearSounds];
	[PlaySoundAction setSoundsPrevented:NO];
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:currentScene];
	[currentScene stopAnimation];
	[currentScene release];
	currentScene=nil;
	
	CCScene *scene=[CCScene node];
	[scene addChild:[CCColorLayer layerWithColor:ccc4(255, 255, 255, 255)]];
	[[CCDirector sharedDirector] replaceScene:scene];
	[self performSelector:@selector(sceneCleanup) withObject:nil afterDelay:0.2f];
	[self performSelector:@selector(stopCocos) withObject:nil afterDelay:0.3f];
}

-(void) killCocos{
	if (cocosInit) {
		[[CCDirector sharedDirector] end];
	}
}
-(void) resetCocos{
	if (cocosInit) {
		[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
	}
}



@end
