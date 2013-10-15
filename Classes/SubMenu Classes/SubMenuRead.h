//
//  SubMenuRead.h
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/22/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubMenuViewController.h"

@class SubMenuViewController;

@interface SubMenuRead : UIViewController <UIScrollViewDelegate> {
	
	SubMenuViewController *myparent;
	
	IBOutlet UIImageView *selectframe;
	IBOutlet UIScrollView *thumbScroller;
	
	IBOutlet UISwitch *narrationSwitch;
	//IBOutlet UISwitch *musicSwitch;
	IBOutlet UISwitch *swipeSwitch;
	
	UIView *thumbholder;
	
	int selectedScene;
	
	NSArray *sceneData;
	
	BOOL currentNarrationSetting;
	BOOL currentMusicSetting;
	BOOL currentSwipeSetting;
	
	NSMutableArray *thumbControllers;
	
	BOOL iPhoneMode;
}

@property (nonatomic, retain) UIView *thumbholder;
@property (nonatomic, retain) NSArray *sceneData;
@property (nonatomic, retain) NSMutableArray *thumbControllers;

-(void)initWithParent:(id)parent;

- (void)switchActionNarration:(id)sender;
- (void)switchActionMusic:(id)sender;
- (void)switchActionSwipe:(id)sender;

-(void)menuTappedWithThumb:(int)thumb;

-(void)setCurrentPage:(int)page;

-(void) updateColorsOnLabels:(BOOL)black;

@end
