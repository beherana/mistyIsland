//
//  subThumbViewController.h
//  Misty-Island-Rescue-iPad
//
//  Created by Henrik Nord on 11/27/10.
//  Copyright 2010 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "SubMenuPaint.h"

@class SubMenuPaint;

@interface subThumbViewController : UIViewController {
	
	SubMenuPaint *myparent;
	
	int myThumbNumber;
	
	IBOutlet UILabel *myThumbNumberLabel;

}

-(id) initWithThumb:(int)thumb parent:(id)parent thumbname:(NSString*)thumbname thumbid:(int)thumbid labelnum:(int)labelnum ;
-(void)recolorTextLabel:(BOOL)black;

@end
