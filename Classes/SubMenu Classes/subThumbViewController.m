    //
//  subThumbViewController.m
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/27/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "subThumbViewController.h"


@implementation subThumbViewController

//-(void) initWithThumb:(int)thumb {
-(id) initWithThumb:(int)thumb parent:(id)parent thumbname:(NSString*)thumbname thumbid:(int)thumbid labelnum:(int)labelnum {
	myparent = parent;
	myThumbNumber = thumbid;
	
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *nexthumb = [bundle pathForResource:[NSString stringWithFormat:@"%@" "%i", thumbname, thumb] ofType:@"png"];
	UIImage *tempimg = [UIImage imageWithContentsOfFile:nexthumb];
	UIImageView *tempimgview = [[UIImageView alloc] initWithImage:tempimg];
	tempimgview.userInteractionEnabled = YES;
	[self.view addSubview:tempimgview];
	[tempimgview release];
	if (labelnum == 0) {
		myThumbNumberLabel.text = @"";
	} else {
		myThumbNumberLabel.text = [NSString stringWithFormat:@"%i", labelnum];
	}
	
	return self;
}

-(void)recolorTextLabel:(BOOL)black {
	if (black) {
		myThumbNumberLabel.textColor = [UIColor blackColor];
	} else {
		myThumbNumberLabel.textColor = [UIColor whiteColor];
	}
}

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
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[myparent menuTappedWithThumb:myThumbNumber];
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
	[myThumbNumberLabel release];
    [super dealloc];
}


@end
