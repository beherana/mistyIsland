    //
//  SubMenuRead.m
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/22/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "SubMenuRead.h"
#import "subThumbViewController.h"
#import "cdaAnalytics.h"

@interface SubMenuRead (PrivateMethods)
-(void)createAndAddThumbs:(int)numthumbs;
@end

@implementation SubMenuRead

@synthesize thumbholder, sceneData, thumbControllers;

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
-(void)initWithParent:(id)parent {
	myparent = parent;
	iPhoneMode = [myparent getIPhoneMode];
	
	//setup all paint images...
	[self createAndAddThumbs:[sceneData count]];
	
	currentNarrationSetting = [myparent getNarrationValue];
	currentMusicSetting = [myparent getMusicValue];
	[narrationSwitch setOn:currentNarrationSetting];
	//[musicSwitch setOn:currentMusicSetting];
	currentSwipeSetting = [myparent getSwipeValue];
	if (currentSwipeSetting) {
		[swipeSwitch setOn:NO];
	} else {
		[swipeSwitch setOn:YES];
	}
	selectedScene = [myparent getCurrentReadPage];
	[self menuTappedWithThumb:selectedScene];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//setup prefs switches
	[narrationSwitch addTarget:self action:@selector(switchActionNarration:) forControlEvents:UIControlEventValueChanged];
	//[musicSwitch addTarget:self action:@selector(switchActionMusic:) forControlEvents:UIControlEventValueChanged];
	[swipeSwitch addTarget:self action:@selector(switchActionSwipe:) forControlEvents:UIControlEventValueChanged];
	//get number of scenes
	NSString *thePath = [[NSBundle mainBundle] pathForResource:@"scenenav" ofType:@"plist"];
	sceneData = [[NSArray alloc] initWithContentsOfFile:thePath];
	
	//setup all paint images...
	//[self createAndAddThumbs:[sceneData count]];

}

-(void)createAndAddThumbs:(int)numthumbs {
	float startx = 0;
	float starty = 16;
	float thumbwidth = 129;
	float thumbheight = 114;
	float increment = 20;//150;
	/**/
	if (iPhoneMode) {
		//change those values
		startx = 0;
		starty = 9;
		thumbwidth = 150;
		thumbheight = 130;
		increment = 7;
	}
	float totalwidth = startx + ((thumbwidth+increment)*(numthumbs));
	thumbScroller.contentSize = CGSizeMake(totalwidth, 135);
	thumbScroller.showsHorizontalScrollIndicator = NO;
    thumbScroller.showsVerticalScrollIndicator = NO;
	thumbScroller.delegate = self;
	CGRect holderframe = CGRectMake(startx, 0.0, totalwidth, self.view.frame.size.height);
	thumbholder = [[UIView alloc] initWithFrame:holderframe];
	[thumbScroller addSubview:thumbholder];
	float lastX = thumbwidth/2;
	thumbControllers = [[NSMutableArray alloc] init];
	for (unsigned i=0; i < numthumbs; i++) {
		float newx = 0.0;
		if (i == 0) {
			newx = lastX;
		} else {
			newx = lastX + increment+thumbwidth;
		}
		CGPoint nextpos = CGPointMake(newx, starty+thumbheight/2);		 
		//get scene number for thumb
		int scenenum = [[sceneData objectAtIndex:i] intValue];
		int pagenum = [[sceneData objectAtIndex:i] intValue]-1;
		if (iPhoneMode) {
		//	pagenum++;
			if (pagenum == [sceneData count]-1) pagenum = 0;
		}
		subThumbViewController *controller = [[subThumbViewController alloc] initWithThumb:scenenum parent:self thumbname:@"readthumb_" thumbid:i labelnum:pagenum];
		controller.view.center = nextpos;
		lastX = newx;
		[thumbholder addSubview:controller.view];
		[thumbControllers addObject:controller];
		[controller release];
	}
	[thumbScroller bringSubviewToFront:selectframe];
}

-(void)menuTappedWithThumb:(int)thumb {
	UIView *tapped = [[thumbholder subviews] objectAtIndex:thumb];
	selectframe.center = CGPointMake(tapped.center.x, tapped.center.y-11);
	selectedScene = [[sceneData objectAtIndex:thumb] intValue];
	[myparent hideShowSubMenu:YES];
	[myparent gotoPage:selectedScene :YES];
}
-(void)setCurrentPage:(int)page {
	if ([myparent getIPhoneMode]) {
		UIView *tapped = [[thumbholder subviews] objectAtIndex:page];
		UIView *scrollpos;
		if (tapped.frame.origin.x-(tapped.frame.size.width*2) > thumbScroller.contentOffset.x) {
			if (page+2 > [[thumbholder subviews] count]) {
				scrollpos = [[thumbholder subviews] objectAtIndex:page];
			} else {
				scrollpos = [[thumbholder subviews] objectAtIndex:page+1];
			}
		} else {
			if (page-1 < 0) {
				scrollpos = [[thumbholder subviews] objectAtIndex:page];
			} else {
				scrollpos = [[thumbholder subviews] objectAtIndex:page-1];
			}
		}
		selectframe.center = CGPointMake(tapped.center.x, tapped.center.y-11);
		selectedScene = [[sceneData objectAtIndex:page] intValue];
		//ADD Scroll to current selected button index...
		[thumbScroller scrollRectToVisible:scrollpos.frame animated:YES];
	} else {
		UIView *tapped = [[thumbholder subviews] objectAtIndex:page];
		selectframe.center = CGPointMake(tapped.center.x, tapped.center.y-11);
		selectedScene = [[sceneData objectAtIndex:page] intValue];
		//ADD Scroll to current selected button index...
		[thumbScroller scrollRectToVisible:selectframe.frame animated:YES];
	}
}

-(void) updateColorsOnLabels:(BOOL)black {
	for (unsigned i=0; i < [thumbControllers count]; i++) {
		subThumbViewController *controller = [thumbControllers objectAtIndex:i];
		[controller recolorTextLabel:black];
	}
}

#pragma mark -
#pragma mark scrollView 
- (void)scrollViewWillBeginDragging:(UIScrollView *)sender {
	
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {
	
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
}
#pragma mark -
#pragma mark Switches
- (void)switchActionNarration:(id)sender
{
	//FLURRY
	[[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"Turning off/on Narration: %i", [sender isOn]]];
	//
	//NSLog(@"switchAction - Narration: value = %d", [sender isOn]);
	currentNarrationSetting = [sender isOn];
	[myparent setNarrationValue:currentNarrationSetting];
}
- (void)switchActionMusic:(id)sender
{
	//NSLog(@"switchAction - Music: value = %d", [sender isOn]);
	currentMusicSetting = [sender isOn];
	[myparent setMusicValue:currentMusicSetting];	 
}
- (void)switchActionSwipe:(id)sender
{
	//FLURRY
	[[cdaAnalytics sharedInstance] trackEvent:[NSString stringWithFormat:@"Turning off/on Swipe: %i", [sender isOn]]];
	//
	//NSLog(@"switchAction - Swipe: value = %d", [sender isOn]);
	if ([sender isOn]) {
		currentSwipeSetting = NO;
	} else {
		currentSwipeSetting = YES;
	}
	[myparent setSwipeValue:currentSwipeSetting];	 
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
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
	[selectframe release];
	thumbScroller.delegate=nil;
	[thumbScroller release];
	thumbScroller=nil;
	[thumbholder release];
	[sceneData release];
	[narrationSwitch release];
	[swipeSwitch release];
	[thumbControllers release];
    [super dealloc];
}


@end
