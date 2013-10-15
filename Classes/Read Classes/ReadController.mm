    //
//  ReadController.m
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 11/19/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "ReadController.h"
#import "Misty_Island_Rescue_iPadAppDelegate.h"
#import "ThomasRootViewController.h"

@implementation ReadController

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
	
	if ([[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController].currentScene isDraggingObject]) {
		return;
	}
	if ([[Misty_Island_Rescue_iPadAppDelegate get] getReadViewIsPaused]) {
		return;
	}
	if ([[Misty_Island_Rescue_iPadAppDelegate get] getSwipeInReadIsTurnedOff]) {
		return;
	}
	if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
		[[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] turnpage:YES];
	} else {
		[[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] turnpage:NO];
    }
	 
}

-(void) setupSwipe{
	/**/
	rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
	rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
	[self.view addGestureRecognizer:rightSwipe];
	
	leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
	leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
	[self.view addGestureRecognizer:leftSwipe];
	 
}

-(void) removeSwipe{
	/**/
	[self.view removeGestureRecognizer:leftSwipe];
	[self.view removeGestureRecognizer:rightSwipe];
	 
}
#pragma mark iPhone related
-(void) addMainMenuButton {
	if (![[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] getIPhoneMode]) return;
	//add main menu button
	NSBundle *bundle = [NSBundle mainBundle];
	UIButton *homebutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [homebutton setShowsTouchWhenHighlighted:YES];
	[homebutton addTarget:self action:@selector(returnToMainMenuFromRead:) forControlEvents:UIControlEventTouchUpInside];
	NSString *buttonImagePath = [bundle pathForResource:[NSString stringWithFormat:@"mainmenubutton_iPhone"] ofType:@"png"];
	[homebutton setBackgroundImage:[UIImage imageWithContentsOfFile:buttonImagePath] forState:UIControlStateNormal];
	CGRect homebuttonframe = CGRectMake(-1, 4, 51, 47);
	homebutton.frame = homebuttonframe;
	[self.view addSubview:homebutton];
}

-(void)enableUserInteraction {
    [self.view setUserInteractionEnabled:YES];
}
-(void)disableUserInteraction {
    [self.view setUserInteractionEnabled:NO];
}

-(IBAction)returnToMainMenuFromRead:(id)sender {
	[[Misty_Island_Rescue_iPadAppDelegate get].myRootViewController playFXEventSound:@"mainmenu"];

	[[Misty_Island_Rescue_iPadAppDelegate get].myRootViewController navigateFromMainMenuWithItem:2];
}

#pragma mark dealloc
-(void) dealloc{
	[leftSwipe release];
	[rightSwipe release];
	[super dealloc];
}


@end
