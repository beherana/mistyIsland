//
//  PaintView.h
//  The Bird & The Snail
//
//  Created by Henrik Nord on 1/4/09.
//  Copyright 2009 Haunted House. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintViewController.h"

@class PaintViewController;
@class PaintHolderLandscapeViewController;

@interface PaintView : UIView {
	
	PaintHolderLandscapeViewController *myparent;
	
	CGContextRef preContext;
	
	CGLayerRef preLayer;
	
	NSMutableArray *xPoints;
	NSMutableArray *yPoints;
	
	BOOL outsideAllowedDrawArea;
	
	NSTimer *touchSettingsTimer;
	//NSTimer *hiresTimer;
	
	BOOL initCanvasState;
	
	BOOL touchIsRegistered;
	BOOL goingForPrefs;
	BOOL goingForRefresh;
	
	BOOL paintRefresh;
	
	//BOOL hiresTimerRunning;
	
	int myCurrentPaintImage;
	
	int canvasState;
	
	int updateCounter;
	
	NSMutableArray *brushsizes;
	
	
	float redvalue;
	float greenvalue;
	float bluevalue;
	float alfavalue;
	float brushsize;
	int selectedColor;
	
	int resolution;
	
	CGRect myrect;
	CGFloat myscale;
	
	//NSNumber *mypaintref;
	int mypaintref;
}

@property(nonatomic,retain)NSMutableArray *xPoints;
@property(nonatomic,retain)NSMutableArray *yPoints;

@property(nonatomic, retain)NSMutableArray *brushsizes;

-(void) initWithParent: (id) parent;

- (id)updateCanvasState:(int)icon;

@end
