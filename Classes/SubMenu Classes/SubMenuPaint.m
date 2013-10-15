    //
//  SubMenuPaint.m
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/22/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "SubMenuPaint.h"
#import "subThumbViewController.h"

@interface SubMenuPaint (PrivateMethods)
-(void)createAndAddThumbs:(int)numthumbs;
@end

@implementation SubMenuPaint

@synthesize thumbholder;

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
	//start up paint
	/*skip random
	//select a random image
	srandom(time(NULL));
	int chosen = random() %  9;
	selectedPaintImage = chosen+1;
	NSLog(@"selectedPaintImage: %i", selectedPaintImage);
	[self menuTappedWithThumb:selectedPaintImage];
	 */
	//[myparent refreshPaintImage:selectedPaintImage];
	//[myparent preStartJigsawPuzzle:selectedPaintImage];
	//UIView *selected = [self.view viewWithTag:selectedPaintImage];
	//selectframe.center = selected.center;
	selectedPaintImage = [myparent getCurrentPaintPage];
	[self menuTappedWithThumb:selectedPaintImage];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//setup all paint images...
	[self createAndAddThumbs:10];

}

-(void)createAndAddThumbs:(int)numthumbs {
	float startx = 27;
	float starty = 16;
	float increment = 152;
	float thumbwidth = 129;
	float thumbheight = 114;
	float totalwidth = (startx*2) + (increment*numthumbs) + thumbwidth*2-startx;
	thumbScroller.contentSize = CGSizeMake(totalwidth, 135);
	thumbScroller.showsHorizontalScrollIndicator = NO;
    thumbScroller.showsVerticalScrollIndicator = NO;
	thumbScroller.delegate = self;
	CGRect holderframe = CGRectMake(startx, 0.0, totalwidth, self.view.frame.size.height);
	thumbholder = [[UIView alloc] initWithFrame:holderframe];
	[thumbScroller addSubview:thumbholder];
	for (unsigned i=0; i < numthumbs; i++) {
		CGPoint nextpos = CGPointMake((startx+increment)*i+thumbwidth/2, starty+thumbheight/2);
		subThumbViewController *controller = [[subThumbViewController alloc] initWithThumb:i+1 parent:self thumbname:@"paintthumb_" thumbid:i+1 labelnum:i+1];
		controller.view.center = nextpos;
		[thumbholder addSubview:controller.view];
		//[controller release];
	}
	[thumbScroller bringSubviewToFront:selectframe];
	 
}

-(void)menuTappedWithThumb:(int)thumb {
	//NSLog(@"menuTappedWithThumb: %i", thumb);
	UIView *tapped = [[thumbholder subviews] objectAtIndex:thumb-1];
	selectframe.center = CGPointMake(tapped.center.x+27, tapped.center.y-11);
	selectedPaintImage = thumb;
	[myparent hideShowSubMenu:YES];
	[myparent refreshPaintImage:selectedPaintImage];
	[myparent refreshPaintTrain:thumb];
}
/*
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"Thouching");
	UITouch *touch = [touches anyObject];
	int tag = touch.view.tag;
	if (tag > 0 && tag < 11) {
		selectframe.center = touch.view.center;
		//[myparent preStartJigsawPuzzle:tag];
	}
	
	//Misty_Island_Rescue_iPadAppDelegate *appDelegate = (Misty_Island_Rescue_iPadAppDelegate *)[[UIApplication sharedApplication] delegate];
	//[appDelegate preStartJigsawPuzzle:mybase];
}
*/
- (void)scrollViewWillBeginDragging:(UIScrollView *)sender {
	
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {
	
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	
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
	[thumbScroller release];
	[thumbholder release];
    [super dealloc];
}


@end
