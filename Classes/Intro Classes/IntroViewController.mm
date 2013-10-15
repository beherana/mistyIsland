    //
//  IntroViewController.m
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/15/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import "IntroViewController.h"
#import "Misty_Island_Rescue_iPadAppDelegate.h"

@interface IntroViewController (PrivateMethods) 
-(void) playMovieAtURL;
-(void) movieDone;
@end

@implementation IntroViewController

@synthesize moviePlayer;
@synthesize checkEnd;

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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/
-(void) playMovieAtURL {
	//NSLog(@"movie started");
	movieEndedByItself = NO;
	
	MPMoviePlayerController *mp =[[MPMoviePlayerController alloc] init];
	NSString *mypath = @"thomas_intro";
	NSString *path = [[NSBundle mainBundle] pathForResource:mypath ofType:@"mp4"];
	
	if (mp)
	{		
		// save the movie player object
		self.moviePlayer = mp;
		[mp release];
		self.moviePlayer.backgroundView.backgroundColor = [UIColor whiteColor];
		self.moviePlayer.view.backgroundColor = [UIColor whiteColor];
		// set the movie content
		[self.moviePlayer setContentURL:[NSURL fileURLWithPath: path]];
		self.moviePlayer.shouldAutoplay = NO;
		//fullscreen
		// make sure the movie resizes when the parentView adjusts (due to rotation)
		if ([[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] getIPhoneMode]) {
			CGRect scaleup = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y-50, self.view.bounds.size.width, self.view.bounds.size.height+100);
			self.moviePlayer.view.frame = scaleup;
		} else {
			self.moviePlayer.view.frame = self.view.bounds;
		}
		self.moviePlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		//self.moviePlayer.view.alpha = 0.0;
		
		// Add view to parentview to give a frame to movie within the view
		[self.view addSubview:self.moviePlayer.view];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(myMovieFinishedCallback:) 
													 name:MPMoviePlayerPlaybackDidFinishNotification 
												   object:self.moviePlayer]; 
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(myMoviePreloadState:) 
													 name:MPMoviePlayerLoadStateDidChangeNotification 
												   object:self.moviePlayer];
		
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(exitFullScreenCloseMovie:) 
													 name:MPMoviePlayerDidExitFullscreenNotification 
												   object:self.moviePlayer];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieDuration:) name:MPMovieDurationAvailableNotification object:self.moviePlayer];
		
		self.moviePlayer.controlStyle = MPMovieControlStyleNone;
		//self.moviePlayer.controlStyle = MPMovieControlStyleDefault;
		self.moviePlayer.useApplicationAudioSession = YES;
		
		[self.view bringSubviewToFront:exitmovie];
	}
	
	
}
-(void)exitFullScreenCloseMovie:(NSNotification*)aNotification {
	if (movieEndedByItself == NO) {
		[self.moviePlayer play];
	}
}

-(void)myMoviePreloadState:(NSNotification*)aNotification {
	
	if ( self.moviePlayer.loadState & MPMovieLoadStatePlayable == MPMovieLoadStatePlayable && self.moviePlayer.playbackState == MPMoviePlaybackStateStopped) {
		
		self.moviePlayer=[aNotification object]; 
		[[NSNotificationCenter defaultCenter] removeObserver:self 
														name:MPMoviePlayerNowPlayingMovieDidChangeNotification 
													  object:self.moviePlayer];
		[self.moviePlayer play];
		/*
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.7];
		self.moviePlayer.view.alpha = 1.0;
		[UIView commitAnimations];
		*/
		//exitmovie.hidden = NO;
	}
}

// When the movie is done,release the controller. 
-(void)myMovieFinishedCallback:(NSNotification*)aNotification {
	//NSLog(@"This means I'm calling movieDone twice");
	moviePlayer=[aNotification object]; 
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:MPMoviePlayerPlaybackDidFinishNotification 
												  object:moviePlayer]; 
	movieEndedByItself = YES;
	[self movieDone];
}

-(void)myMovieDuration:(NSNotification*)aNotification {
	if (![[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] getIPhoneMode]) {
		movieDuration = self.moviePlayer.duration;
	} else {
		movieDuration = self.moviePlayer.duration-1.0;
	}
	checkEnd = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(fadeOutMovie) userInfo:nil repeats:YES];
}

-(IBAction)exitWatchMovie:(id)sender {
	[self.moviePlayer pause];
	[self.moviePlayer stop];
	//[self movieDone];
}

-(void)movieDone {
        if (_movieDoneCalled) return;
        _movieDoneCalled=TRUE;
    
    if ([checkEnd isValid]) {
        [checkEnd invalidate];
        checkEnd = nil;
    }

    //[[Misty_Island_Rescue_iPadAppDelegate get] showFakeLandingPage];
    if (![[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] getIPhoneMode]) [[Misty_Island_Rescue_iPadAppDelegate get] showFakeLandingPage];
    self.moviePlayer.view.alpha = 0.0;
	[self.moviePlayer stop];
	[self.moviePlayer.view removeFromSuperview];
	//[moviePlayer release];
	[[Misty_Island_Rescue_iPadAppDelegate get] introFinishedPlaying];
}

-(void) fadeOutMovie {
	movieCounter += 0.2;
	if (self.moviePlayer == nil || self.moviePlayer == NULL) return;
	if (movieCounter > movieDuration) {
		//turn on fake landingpage
		if (forcedEnd) {
			if ([checkEnd isValid]) {
				[checkEnd invalidate];
				checkEnd = nil;
			}
			if (![[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] getIPhoneMode]) [[Misty_Island_Rescue_iPadAppDelegate get] showFakeLandingPage];
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(introMovieFadedOut:finished:context:)];
			[UIView setAnimationDuration:0.3];
			self.moviePlayer.view.alpha = 0.0;
			[UIView commitAnimations];
			//[[Misty_Island_Rescue_iPadAppDelegate get] introFinishedPlaying];
		} else {
			[[Misty_Island_Rescue_iPadAppDelegate get] showFakeLandingPage];
			
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
}
-(void)introMovieFadedOut:(NSString*)animationID finished:(NSNumber*)finished context:(void*)context {
	[self movieDone];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if ([[Misty_Island_Rescue_iPadAppDelegate get] getIntroPresentationPlayed]) {
		forcedEnd = YES;
		movieCounter = movieDuration;
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	exitmovie.hidden = YES;
	forcedEnd = YES;
	[self playMovieAtURL];
    _movieDoneCalled=FALSE;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];

}

-(void)didEnterBackground{
    if (_movieDoneCalled) return;
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:MPMoviePlayerPlaybackDidFinishNotification 
                                                  object:moviePlayer];
    movieEndedByItself = YES;
    [self movieDone];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
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
	//exitmovie = nil;
	//[exitmovie release];
	exitmovie = nil;
	[checkEnd release];
    [super dealloc];
}


@end
