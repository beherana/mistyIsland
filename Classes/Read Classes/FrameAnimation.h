//
//  SceneAnimation.h
//  Thomas
//
//  Created by Johannes Amilon on 11/8/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "cocos2d.h"

@interface FrameAnimation : NSObject {
	CCSpriteSheet *spriteSheet;
	NSMutableDictionary *sprites;
	NSMutableDictionary *animations;
	NSMutableDictionary *firstFrames;
	NSString *name;
	int parentIndex;
	BOOL repeatsForever;
	BOOL visibleInactive;
	BOOL returnToFirstFrame;
	BOOL hasSound;
}

@property(readonly)CCSpriteSheet *spriteSheet;
@property(nonatomic) int parentIndex;
@property(readonly) BOOL hasSound;

-(id) initWithDictionary:(NSDictionary *)data:(int)tag;

-(void) startAnimations;
-(void) stopAnimations;
-(void) animationDone;
-(int) numberOfCallbacks;
-(void) killAnimations;

@end
