//
//  FinishedPuzzleMovieController.m
//  The Bird & The Snail
//
//  Created by Henrik Nord on 1/27/09.
//  Copyright 2009 Haunted House. All rights reserved.
//

#import "FinishedPuzzleMovieController.h"
#import "Misty_Island_Rescue_iPadAppDelegate.h"
#import "jigsawViewController.h"

@interface FinishedPuzzleMovieController (PrivateMethods) 
-(void) playMovieAtURL;
@end

CGFloat jigsawMoviePuzzleDegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};

@implementation FinishedPuzzleMovieController
@synthesize moviePlayer;
@synthesize checkEnd;

-(void) initWithParent: (id) parent
{
	self=[super init];
	if (self){
		myParent=parent;
		theCurrentPuzzle = [myParent getMyJigsawPuzzle];
		
	}
	return;
}
/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		
    }
    return self;
}
*/
/**/

-(void) stopMovie {
	
	if ([checkEnd isValid]) {
		[checkEnd invalidate];
		checkEnd = nil;
	}
	
	[self.moviePlayer pause];
	[self.moviePlayer stop];
	[self.moviePlayer.view removeFromSuperview];
	[moviePlayer release];
}
-(void) playMovieAtURL {
	
	//
	[preLoadMovieActivityIndicator startAnimating];
	
	MPMoviePlayerController *mp =[[MPMoviePlayerController alloc] init];
	Misty_Island_Rescue_iPadAppDelegate *appDelegate = (Misty_Island_Rescue_iPadAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSString *langadd = @"";
	if ([[appDelegate getCurrentLanguage] isEqualToString:@"en_GB"]) {
		langadd = @"_UK";
	}
	NSString *name = [NSString stringWithFormat:@"puzzle%i" @"%@", theCurrentPuzzle, langadd];
	NSString *path = [[NSBundle mainBundle] pathForResource:name ofType: @"mp4"];
	if (mp)
	{		
		// save the movie player object
		self.moviePlayer = mp;
		[mp release];
		self.moviePlayer.backgroundView.backgroundColor = [UIColor clearColor];
		// set the movie content
		[self.moviePlayer setContentURL:[NSURL fileURLWithPath: path]];
        self.moviePlayer.view.backgroundColor = [UIColor clearColor];
		self.moviePlayer.shouldAutoplay = NO;
		// Add view to parentview to give a frame to movie within the view
		[self.view addSubview:self.moviePlayer.view];
		self.moviePlayer.view.frame = self.view.bounds;
		self.moviePlayer.view.alpha = 0.0;
		
		// make sure the movie resizes when the parentView adjusts (due to rotation)
		self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(myMovieFinishedCallback:) 
													 name:MPMoviePlayerPlaybackDidFinishNotification 
												   object:self.moviePlayer]; 
		
	//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMoviePreloadState:) name:MPMoviePlayerLoadStateDidChangeNotification object:self.moviePlayer];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieDuration:) name:MPMovieDurationAvailableNotification object:self.moviePlayer];
		
		self.moviePlayer.controlStyle = MPMovieControlStyleNone;
		//Radif set it to yes. The cocos sounds were disappearing if it is set to no.
		self.moviePlayer.useApplicationAudioSession = YES;
		
		[self.moviePlayer play];
		/**/
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.7];
		self.moviePlayer.view.alpha = 1.0;
		[UIView commitAnimations];
		
		[preLoadMovieActivityIndicator stopAnimating];

	}
} 
 
-(void)myMoviePreloadState:(NSNotification*)aNotification {
	
	if ( self.moviePlayer.loadState & MPMovieLoadStatePlayable == MPMovieLoadStatePlayable && self.moviePlayer.playbackState == MPMoviePlaybackStateStopped) {
		
		self.moviePlayer=[aNotification object]; 
		[[NSNotificationCenter defaultCenter] removeObserver:self 
														name:MPMoviePlayerNowPlayingMovieDidChangeNotification 
													  object:self.moviePlayer];
		[self.moviePlayer play];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.7];
		self.moviePlayer.view.alpha = 1.0;
		[UIView commitAnimations];
		
		[preLoadMovieActivityIndicator stopAnimating];
	}
}
-(void)myMovieDuration:(NSNotification*)aNotification {
	movieDuration = self.moviePlayer.duration-1.0;
	checkEnd = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(fadeOutMovie) userInfo:nil repeats:YES];
}
-(void) fadeOutMovie {
	movieCounter += 0.2;
	if (self.moviePlayer == nil || self.moviePlayer == NULL) return;
	if (movieCounter > movieDuration) {
		if ([checkEnd isValid]) {
			[checkEnd invalidate];
			checkEnd = nil;
		}
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.7];
		self.moviePlayer.view.alpha = 0.0;
		[UIView commitAnimations];
	}
}
// When the movie is done,release the controller. 
-(void)myMovieFinishedCallback:(NSNotification*)aNotification {
	
	self.moviePlayer=[aNotification object]; 
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:MPMoviePlayerPlaybackDidFinishNotification 
												  object:self.moviePlayer];
	
	if ([checkEnd isValid]) {
		[checkEnd invalidate];
		checkEnd = nil;
	}
	
	self.moviePlayer.view.alpha = 0.0;
	[myParent cleanupFinishedMovie];
}
- (void)viewDidLoad {
    [super viewDidLoad];	
	[self playMovieAtURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[self.moviePlayer release];
	if ([checkEnd isValid]) {
		[checkEnd invalidate];
		checkEnd = nil;
	}
	
    [super dealloc];
}


@end
