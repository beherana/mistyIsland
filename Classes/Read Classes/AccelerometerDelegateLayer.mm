//
//  AccelerometerDelegateLayer.m
//  Thomas
//
//  Created by Johannes Amilon on 11/12/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "AccelerometerDelegateLayer.h"
#import "BookScene.h"
#import "Misty_Island_Rescue_iPadAppDelegate.h"
#import "ThomasRootViewController.h"

@implementation AccelerometerDelegateLayer


-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
	//send accelerometer data to scene
	[[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController].currentScene accelerometer:accelerometer didAccelerate:acceleration];
}

@end
