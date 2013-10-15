//
//  MainMenuController.h
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/14/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MoreAppsMainViewController.h"

@class ThomasRootViewController;

@interface MainMenuController : UIViewController {

	ThomasRootViewController *myparent;
    MoreAppsMainViewController *moreAppsViewController;
	
	IBOutlet UIButton *randr;
	IBOutlet UIButton *randrReturn;
    IBOutlet UIButton *moreAppsButton;
	
	IBOutlet UIImageView *iPhoneReturnImage;
	
	BOOL menuIsVisible;
    CGFloat moreAppsButtonOrgXPosition;
}

-(void) initWithParent: (id) parent;

-(void)hideShowMainMenu:(BOOL)hide;
-(IBAction)menuButtonPressed:(id)sender;
-(IBAction)moreAppsTab:(id)sender;
-(void)hideMoreAppsTab;

-(void)setReturnImage;

-(void)enableUserInteraction;
-(void)disableUserInteraction;

//getters
-(BOOL)getMenuIsVisible;

@property (nonatomic, retain) UIButton *moreAppsButton;
@property (nonatomic, retain) MoreAppsMainViewController *moreAppsViewController;

@end
