//
//  BookScene.h
//  Thomas
//
//  Created by Johannes Amilon on 11/4/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "AccelerometerDelegateLayer.h"
#import "FluidField.h"
#import "ReadOverlayView.h"


@interface BookScene : CCScene <CCTargetedTouchDelegate>{
	AccelerometerDelegateLayer *layer;
	int page;
	NSMutableArray *components;
	NSMutableDictionary *componentsByName;
	BOOL animating;
	BOOL hasPhysics;
	b2World *world;
	BOOL useAccelerometer;
	int touchedElement;
	b2MouseJoint *mouseJoint;
	b2Vec2 touchPoint;
	b2Body *groundBody;
	CGRect physicsBox;
	BOOL respawnObjects;
	BOOL hasFog;
	FluidField *fog;
	CCTexture2D *fogTexture;
	float fogRevealStart;
	float fogRevealDuration;
	float fogRevealTimer;
	BOOL fogReveal;
	BOOL landscapeRight;
	NSString *bgSound;
	float bgVolume;
	BOOL bgRepeat;
	CCSprite *repeatButton;
	CCSprite *moreAppsButton;
    CCSprite *moreAppsOnButton;
	float fogX;
	BOOL isScreenshot;
	CCLabel *label;
	CGPoint layerOffset;
    BOOL lastPage;
@private
	NSString *text;
	ReadOverlayViewStyle style;
	
}

@property (readonly) int page;
@property (readonly) NSMutableArray *components;
@property (nonatomic,retain) CCSprite *moreAppsButton;
@property (nonatomic,retain) CCSprite *moreAppsOnButton;

-(void)setPage:(int)newPage;
-(void)stopAnimation;
-(void)startAnimation;
-(void)triggerAnimationByName:(NSString *)name;
-(void)addRecursive:(NSDictionary *)data:(CCNode *)currentNode;
-(void)removeRecursive:(CCNode *)node;
-(void)setupPhysics;
-(void)setupFog:(NSDictionary *)fogDict;
-(void)update:(ccTime) dt;
-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;
-(void)orientationChanged:(BOOL)isLandscapeRight;

-(void)setReplayVisible;
-(void)setReplayHidden;
-(BOOL) isDraggingObject;
-(void)turnIntoScreenshot;

-(BOOL) isAnimating;

-(void)showText;

@end
#warning remove this once transition to Cocos2d v2.0 This method draws the scene without swapping buffers allowing taking the screenshot
@interface CCDirector (iOS6Extension)
-(void)drawSceneNoSwap;
@end