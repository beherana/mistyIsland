//
//  SettingsInformationScroll_iPhone.h
//  ThomasSettings
//
//  Created by Radif Sharafullin on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "CustomAlertViewController.h"
#import "NetworkUtils.h"

@interface SettingsInformationScroll_iPhone : UIView <MFMailComposeViewControllerDelegate,CustomAlertViewControllerDelegate>  {
	UIScrollView *sv;
	UIImageView *imgView;
	UIViewController *vc;
    
    NSURL * willOpenUrl;
}
@property (nonatomic, readonly)UIImageView *imgView;
@property (nonatomic, assign) UIViewController *vc;
@property (nonatomic, retain) UIScrollView *sv;
@property (nonatomic, retain) NSURL *willOpenUrl;

-(void)setContentsImage:(UIImage *)contents;
-(void)addHomepageLinkButtons;
-(void)addEmailButton;
@end
