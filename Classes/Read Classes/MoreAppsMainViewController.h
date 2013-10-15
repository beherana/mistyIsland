//
//  MoreAppsMainViewController.h
//  Misty-Island-Rescue-Universal
//
//  Created by Martin Kamara on 2011-07-27.
//  Copyright 2011 Commind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertViewController.h"
#import "WebViewHelper.h"

@interface MoreAppsMainViewController : UIViewController<CustomAlertViewControllerDelegate> {

    IBOutlet UIWebView *webView;
    
    WebViewHelper *webViewHelper;
    UIViewController *parentController;
    
    NSURL *willOpenUrl;
}

@property(nonatomic,retain) UIViewController *parentController;
@property(nonatomic,retain) NSURL *willOpenUrl;
@property(nonatomic,retain) WebViewHelper *webViewHelper;

-(IBAction)hide:(id)sender;
-(IBAction)giftApp:(id)sender;
- (void)showLeavingAppAlert;



@end
