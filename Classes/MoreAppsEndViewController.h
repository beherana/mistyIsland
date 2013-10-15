//
//  MoreAppsEndViewController.h
//  Misty-Island-Rescue-Universal
//
//  Created by Martin Kamara on 2011-07-26.
//  Copyright 2011 Commind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertViewController.h"
#import "WebViewHelper.h"

@interface MoreAppsEndViewController : UIViewController<CustomAlertViewControllerDelegate> {

    IBOutlet UIWebView *webView;

    NSURL *willOpenUrl;
    WebViewHelper *webViewHelper;
    
    
}
@property (nonatomic,retain) NSURL *willOpenUrl;
@property (nonatomic,retain) WebViewHelper *webViewHelper;

-(IBAction)closeWindow:(id)sender;
- (void)showLeavingAppAlert;

@end
