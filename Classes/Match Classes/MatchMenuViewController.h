//
//  MatchMenuViewController.h
//  Misty-Island-Rescue-Universal
//
//  Created by Henrik Nord on 2/19/11.
//  Copyright 2011 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ThomasRootViewController;
@class MemoryMatchViewController;

@interface MatchMenuViewController : UIViewController {

	ThomasRootViewController *myParent;
    MemoryMatchViewController *memoryholder;
	
	UIView *menuHolder;
	
	BOOL memoryloaded;
}
@property (nonatomic, retain) UIView *menuHolder;
@property (nonatomic, retain) MemoryMatchViewController *memoryholder;

- (void) initWithParent: (id) parent;

- (void) redrawMenu;
- (void) animateMenu;
- (void) cleanUpMenu;

- (void) zoomSelectedMatch:(int)myselected;

-(IBAction) easyMatchSelected:(id)sender;
-(IBAction) hardMatchSelected:(id)sender;

- (IBAction) returnToMainMenuFromMatch:(id)sender;

-(void)playFXEventSound:(NSString*)sound;
- (void)playCardSound:(int)sound;

@end
