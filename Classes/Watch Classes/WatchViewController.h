//
//  WatchViewController.h
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/15/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>


@interface WatchViewController : UIViewController {

	MPMoviePlayerController *moviePlayer;
    NSURL *mMovieURL;
	
	BOOL movieIsPlaying;
	
	BOOL movieEndedByItself;
	
	
	IBOutlet UIButton *exitmovie;
	
}

@property (readwrite, retain) MPMoviePlayerController *moviePlayer;

-(IBAction)exitWatchMovie:(id)sender;

@end
