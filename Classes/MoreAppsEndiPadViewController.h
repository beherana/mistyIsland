//
//  MoreAppsEndiPadViewController.h
//  Misty-Island-Rescue-Universal
//
//  Created by Martin Kamara on 2011-07-26.
//  Copyright 2011 Commind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertViewController.h"
#import "WebViewHelper.h"

@interface MoreAppsEndiPadViewController : UIViewController<CustomAlertViewControllerDelegate> {
    IBOutlet UIView *moreAppsView;
    IBOutlet UIView *moreAppsTicketView;
    IBOutlet UIView *endTicketView;
    IBOutlet UIWebView *webView;
    IBOutlet UIActivityIndicatorView *webActivityIndicator;
    IBOutlet UIImageView *webNoConnectionImage;
    
    WebViewHelper *webViewHelper;
    
    
    NSURL * willOpenUrl;
}

@property (nonatomic, retain) UIView *moreAppsView;
@property (nonatomic, retain) UIView *moreAppsTicketView;
@property (nonatomic, retain) UIView *endTicketView;
@property (nonatomic, retain) NSURL *willOpenUrl;
@property (nonatomic, retain) WebViewHelper *webViewHelper;

- (void)showLeavingAppAlert;

@end
