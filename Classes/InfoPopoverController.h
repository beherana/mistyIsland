//
//  InfoPopoverController.h
//  Misty-Island-Rescue-iPad
//
//  Created by Johannes Amilon on 12/2/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface InfoPopoverController : UIViewController <MFMailComposeViewControllerDelegate> {
	IBOutlet UIScrollView *scroller;
	IBOutlet UIImageView *infotext;
	UIImage *info;
	UIImage *info_uk;
}

-(IBAction) emailSupport:(id)sender;

@end
