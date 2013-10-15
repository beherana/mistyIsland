//
//  SubMenuViewController.h
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/21/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubMenuPuzzles.h"
#import "SubMenuDots.h"
#import "SubMenuPaint.h"
#import "SubMenuRead.h"

@class ThomasRootViewController;
@class SubMenuPuzzles;
@class SubMenuDots;
@class SubMenuPaint;
@class SubMenuRead;

@interface SubMenuViewController : UIViewController {

	ThomasRootViewController *myparent;
	SubMenuPuzzles *mySubMenuPuzzles;
	SubMenuDots *mySubMenuDots;
	SubMenuPaint *mySubMenuPaint;
	SubMenuRead *mySubMenuRead;
	
	IBOutlet UIView *subContentHolder;
	IBOutlet UIView *train;
	IBOutlet UIImageView *tracksLeftRight;
	IBOutlet UIImageView *trainlight;
	IBOutlet UIImageView *traindark;
	IBOutlet UIView *wagon;
	
	IBOutlet UIButton *leftnavRead;
	IBOutlet UIButton *rightnavRead;
	
	IBOutlet UIImageView *blackSubmenuFade;
	IBOutlet UIImageView *whiteSubmenuFade;
	
	IBOutlet UILabel *pageNumber;
	
	BOOL subMenuIsVisible;
	BOOL subMenuIsRemoved;
	
	int visibleInterface;
	
	BOOL iPhoneMode;
	
}

@property (nonatomic, retain) IBOutlet UILabel *pageNumber;
@property (nonatomic, retain) IBOutlet UIView *train;

-(void) initWithParent: (id) parent;

-(void)hideShowSubMenu:(BOOL)hide;

-(void)addInterfaceToSubMenu:(int)interface;
-(void)removeInterfaceFromSubMenu;

-(void)setSubmenuFade;
-(void)restoreSubmenuFade;

-(void)disableTappedNavButton;
-(void)enableTappedNavButton;
-(IBAction)navLeftInRead:(id)sender;
-(IBAction)navRightInRead:(id)sender;

-(void)preStartJigsawPuzzle:(int)puzzle;
-(int) getPuzzleDifficulty;
-(void) setPuzzleLevelOfDifficulty:(int)diff;

-(void)preStartDots:(int)dot;
-(int) getDotDifficulty;
-(void) setDotLevelOfDifficulty:(int)diff;

-(BOOL)getNarrationValue;
-(void)setNarrationValue:(BOOL)value;
-(BOOL)getMusicValue;
-(void)setMusicValue:(BOOL)value;
-(BOOL)getSwipeValue;
-(void)setSwipeValue:(BOOL)value;
-(void)playNarrationOnScene;

-(void)refreshPaintImage:(int)image;
-(int) getCurrentPaintPage;

-(int) getCurrentPuzzlePage;
-(int) getCurrentDotsPage;

-(int) getCurrentReadPage;
-(int) setCurrentReadPage:(int)page;
-(void) gotoPage:(int)page:(BOOL)withTransition;
//pause and resume with fade down on scene
-(void) pauseCocos:(BOOL)fade;
-(void) resumeCocos:(BOOL)fade;

-(void)refreshPaintTrain:(int)image;
-(void) updatePuzzleTrain:(int)image;

-(BOOL) getIPhoneMode;

@end

@interface SubmenuViewIPhone : UIImageView
{
	
}


@end

