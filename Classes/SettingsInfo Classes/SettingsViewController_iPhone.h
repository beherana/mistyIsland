//
//  SettingsViewController_iPhone.h
//  ThomasSettings
//
//  Created by Radif Sharafullin on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsInformationScroll_iPhone.h"
#import "SettingsFollowShareViewController.h"

@class ThomasSettingsViewController;

@interface SettingsViewController_iPhone : UIViewController <UITableViewDelegate, UITableViewDataSource>{
	
	ThomasSettingsViewController *myParent;
	
	IBOutlet UITableView * tv;
	IBOutlet UIButton *backButton;
	IBOutlet UILabel *sectionLabel;
    IBOutlet UIImageView *topFadeImage;
    IBOutlet UIView *copyrightView;
	SettingsInformationScroll_iPhone *infoScrollView;
    SettingsFollowShareViewController *followShareView;
    
@private
	CGRect tvIndentFrame;
	
}

@property (nonatomic, retain) SettingsFollowShareViewController *followShareView;

- (void) initWithParent: (id) parent;
- (void) presentFollowShare;


-(IBAction)backPressed:(UIButton *)sender;
-(NSString*)imagePathForResolution:(NSString*)path;
@end
