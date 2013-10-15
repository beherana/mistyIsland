//
//  SettingsFollowShareViewController.h
//  Misty-Island-Rescue-Universal
//
//  Created by Martin Kamara on 2011-07-27.
//  Copyright 2011 Commind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAlertViewController.h"


@interface SettingsFollowShareViewController : UITableViewController <CustomAlertViewControllerDelegate> {
    
    NSURL *_willOpenUrl;
}

@property (nonatomic, retain) NSURL *willOpenUrl;

-(void)deselectAllRows;


@end
