//
//  LandingPageViewController.h
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/15/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InfoPopoverController.h"
#import "LandingPageTabsViewController.h"

@interface LandingPageViewController : UIViewController <UIPopoverControllerDelegate>{
	InfoPopoverController *popoverContent;
	UIPopoverController *popover;
    LandingPageTabsViewController *_tabs;
}

@property (nonatomic, retain) LandingPageTabsViewController *tabs;

-(IBAction) infoButtonClicked:(id)sender;
-(IBAction) speakTitleButtonTapped:(id)sender;
-(void)killPopoversOnSight;

@end
