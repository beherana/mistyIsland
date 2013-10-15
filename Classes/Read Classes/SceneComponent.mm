//
//  SceneComponent.m
//  Thomas
//
//  Created by Johannes Amilon on 11/5/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "SceneComponent.h"
#import "SetPropsAction.h"
#import "FrameAnimation.h"
#import "SlowWarp.h"
#import "SmokeNode.h"
#import "Misty_Island_Rescue_iPadAppDelegate.h"
#import "ThomasRootViewController.h"
#import "PlaySoundAction.h"
#import "ToggleSmokeAction.h"
#import "FadeChildrenAction.h"


@implementation SceneComponent

@synthesize name,filename,z;

+(id) componentWithDictionary:(NSDictionary *)dict:(int)tag{
	return [[[self alloc] initWithDictionary:dict :tag] autorelease];
}

-(id) initWithDictionary:(NSDictionary *)dict:(int)tag{
	if ((self=[super init])) {
		NSDictionary *subDict;
		NSArray *subArray;
		name=[[dict objectForKey:@"name"] retain];
		z=[[dict objectForKey:@"z"] intValue];
		isAnimating=0;
		
		isSmoke=NO;
		
		hasSound=NO;
		
		//load object
		if ([dict objectForKey:@"source"]!=nil) {			
			subDict=[dict objectForKey:@"source"];
			
			if ([dict objectForKey:@"smoke"]!=nil) {
				isSmoke=YES;
			}
			
			if (isSmoke) {
				SmokeNode *smokeNode=[[SmokeNode alloc] initWithTotalParticles:200];
				filename=[[[subDict objectForKey:@"name"] stringByAppendingString:@".png"] retain];
				smokeNode.texture=[[CCTextureCache sharedTextureCache] addImage:filename];
				smokeNode.position=CGPointMake([[subDict objectForKey:@"x"] floatValue], [[subDict objectForKey:@"y"] floatValue]);
				smokeNode.posVar=CGPointZero;
				smokeNode.duration=kCCParticleDurationInfinity;
				smokeNode.emitterMode=kCCParticleModeGravity;
				smokeNode.gravity=CGPointZero;
				smokeNode.speed = 160;
				smokeNode.speedVar = 20;
				smokeNode.radialAccel = 0;
				smokeNode.radialAccelVar = 0;
				smokeNode.tangentialAccel = 0;
				smokeNode.tangentialAccelVar = 0;
				smokeNode.angle = 90;
				smokeNode.angleVar = 0;
				smokeNode.life = 5;
				smokeNode.lifeVar = 0;
				smokeNode.startSpin = 0;
				smokeNode.startSpinVar = -360;
				smokeNode.endSpin = 0;
				smokeNode.endSpinVar = -(720+360);
				ccColor4F startColor = {1.0f, 1.0f, 1.0f, 1.0f};
				smokeNode.startColor = startColor;
				ccColor4F startColorVar = {0.0f, 0.0f, 0.0f, 0.0f};
				smokeNode.startColorVar = startColorVar;
				ccColor4F endColor = {1.0f, 1.0f, 1.0f, 0.4f};
				smokeNode.endColor = endColor;
				ccColor4F endColorVar = {0.0f, 0.0f, 0.0f, 0.0f};	
				smokeNode.endColorVar = endColorVar;
				smokeNode.startSize = [[subDict objectForKey:@"startSize"] floatValue];
				smokeNode.startSizeVar = 0.0f;
				smokeNode.endSize = [[subDict objectForKey:@"endSize"] floatValue];
				smokeNode.endSizeVar = [[subDict objectForKey:@"endSizeVar"] floatValue];
				smokeNode.emissionRate = 15;
				smokeNode.blendAdditive = NO;
				smokeNode.p0 = CGPointMake([[subDict objectForKey:@"p0x"] floatValue],[[subDict objectForKey:@"p0y"] floatValue]);
				smokeNode.p1 = CGPointMake([[subDict objectForKey:@"p1x"] floatValue],[[subDict objectForKey:@"p1y"] floatValue]);
				smokeNode.p2 = CGPointMake([[subDict objectForKey:@"p2x"] floatValue],[[subDict objectForKey:@"p2y"] floatValue]);
				smokeNode.p3 = CGPointMake([[subDict objectForKey:@"p3x"] floatValue],[[subDict objectForKey:@"p3y"] floatValue]);		
				smokeNode.spewSmoke=[[dict objectForKey:@"smoke"] boolValue];	
				smokeNode.flippingPage=YES;
				node=smokeNode;
				node.tag=tag;
				sprite=nil;
			}else {
				if ([subDict objectForKey:@"name"]==nil || [[subDict objectForKey:@"name"] isEqualToString:@""]) {
					sprite=nil;
					filename=nil;
					node=[[CCNode node] retain];
					node.tag=tag;
					node.position=CGPointMake([[subDict objectForKey:@"x"] floatValue], [[subDict objectForKey:@"y"] floatValue]);
					node.scaleX=[[subDict objectForKey:@"scaleX"] floatValue];
					node.scaleY=[[subDict objectForKey:@"scaleY"] floatValue];
					node.rotation=[[subDict objectForKey:@"rotation"] floatValue];
				}else {
					filename=[[[subDict objectForKey:@"name"] stringByAppendingString:@".png"] retain];
					sprite=[[CCSprite spriteWithFile:filename] retain];
					[sprite.texture setAntiAliasTexParameters];
					sprite.position=CGPointMake([[subDict objectForKey:@"x"] floatValue], [[subDict objectForKey:@"y"] floatValue]);
					sprite.scaleX=[[subDict objectForKey:@"scaleX"] floatValue];
					sprite.scaleY=[[subDict objectForKey:@"scaleY"] floatValue];
					sprite.rotation=[[subDict objectForKey:@"rotation"] floatValue];
					if ([subDict valueForKey:@"alpha"]) {
						sprite.opacity=[[subDict objectForKey:@"alpha"] floatValue]*255;
					}
					sprite.anchorPoint=CGPointMake([[subDict objectForKey:@"transformationPointX"] floatValue], [[subDict objectForKey:@"transformationPointY"] floatValue]);
					sprite.tag=tag;
                    
                    if ([subDict objectForKey:@"vertexZ"] != nil) {
                        float vertexZ = [[subDict objectForKey:@"vertexZ"] floatValue];
                        [sprite setVertexZ:vertexZ];
                    }
                    
					node=nil;
				}
			}			
		}else {
			sprite=nil;
			filename=nil;
			node=[[CCNode node] retain];
			node.tag=tag;
		}
		
		//check metadata
		if ([dict objectForKey:@"metadata"]!=nil) {
			subDict=[dict objectForKey:@"metadata"];
			if (![[subDict objectForKey:@"isVisible"] boolValue] && sprite!=nil) {
				sprite.opacity=0;
			}
			if ([subDict objectForKey:@"interactiveDuringIntro"]!=nil && [[subDict objectForKey:@"interactiveDuringIntro"] boolValue]) {
				interactiveDuringIntro=YES;
			}else {
				interactiveDuringIntro=NO;
			}
		}else {
			interactiveDuringIntro=YES;
		}
		
		triggerState=0;
		if ([dict objectForKey:@"animationTrigger"]!=nil) {
			animationTrigger=[[[dict objectForKey:@"animationTrigger"] objectForKey:@"objects"] retain];
			if ([[[dict objectForKey:@"animationTrigger"] objectForKey:@"repeatable"] boolValue]) {
				triggerState=1;
			}
		}else {
			animationTrigger=nil;
			triggerState=-1;
		}
		
		startTranslateAnimations=[[NSMutableArray alloc] init];
		clickTranslateAnimations=[[NSMutableArray alloc] init];
		startFrameAnimations=[[NSMutableArray alloc] init];
		clickFrameAnimations=[[NSMutableArray alloc] init];
		
		
		//load tranlate animations
		subArray=[dict objectForKey:@"translateAnimations"];
		if (subArray!=nil) {
			for (uint i=0; i<[subArray count]; ++i) {
				subDict=[subArray objectAtIndex:i];
				
				CCSequence *mainSequence =[CCSequence actions:[CCInstantAction action],nil];
				
				//Need to store current values in case new values arent provided
				float currentX = sprite.position.x;
				float currentY = sprite.position.y;
				float currentScaleX = sprite.scaleX;
				float currentScaleY = sprite.scaleY;
				
				BOOL repeatsForever=[[subDict valueForKey:@"repeatForever"] boolValue];
				
				for ( NSDictionary *keyframe in [subDict valueForKey:@"keyframes"] )
				{					
					float duration = [(NSNumber *)[keyframe valueForKey:@"duration"] floatValue];
					
					CCSpawn *keyframeAction = [CCSpawn actionWithDuration:duration];
					
					if([keyframe valueForKey:@"x"] || [keyframe valueForKey:@"y"])
					{				
						float xChange = [keyframe valueForKey:@"x"] ? [[keyframe objectForKey:@"x"] floatValue] : currentX;
						float yChange = [keyframe valueForKey:@"y"] ? [[keyframe objectForKey:@"y"] floatValue] : currentY;
						
						currentX = xChange;
						currentY = yChange;
						
						CCMoveBy *moveAction = [CCMoveTo actionWithDuration:duration position:ccp(xChange,yChange)];
						keyframeAction = [CCSpawn actionOne:keyframeAction two:moveAction];
						
					}
					
					if([keyframe valueForKey:@"scaleX"] || [keyframe valueForKey:@"scaleY"])
					{
						float scaleXChange = [keyframe valueForKey:@"scaleX"] ? [[keyframe objectForKey:@"scaleX"] floatValue] : currentScaleX;
						float scaleYChange = [keyframe valueForKey:@"scaleY"] ? [[keyframe objectForKey:@"scaleY"] floatValue] : currentScaleY;
						
						currentScaleX = scaleXChange;
						currentScaleY = scaleYChange;
						
						CCScaleBy *scaleAction = [CCScaleTo actionWithDuration:duration scaleX:scaleXChange scaleY:scaleYChange];
						keyframeAction = [CCSpawn actionOne:keyframeAction two:scaleAction];
					}
					
					if([keyframe valueForKey:@"rotation"])
					{
						CCRotateBy *rotateAction = [CCRotateTo actionWithDuration:duration angle:[[keyframe objectForKey:@"rotation"] floatValue]];
						keyframeAction = [CCSpawn actionOne:keyframeAction two:rotateAction];
					}
					
					if([keyframe valueForKey:@"alpha"])
					{
						GLubyte alpha = [[keyframe objectForKey:@"alpha"] floatValue]*255;
						CCFiniteTimeAction *fadeAction=nil;
						if ([keyframe objectForKey:@"fadeIncludesChildren"]) {
							if ([[keyframe objectForKey:@"fadeIncludesChildren"] boolValue]) {
								fadeAction=[FadeChildrenAction actionWithDuration:duration opacity:alpha];
							}
						}
						if (fadeAction==nil) {
							fadeAction = [CCFadeTo actionWithDuration:duration opacity:alpha];
						}						
						keyframeAction = [CCSpawn actionOne:keyframeAction two:fadeAction];
					}
					
					if ([keyframe valueForKey:@"warp"]) {
						NSDictionary *warp=[keyframe objectForKey:@"warp"];
						CCIntervalAction *warpAction=[SlowWarp actionWithRange:[[warp objectForKey:@"amplitude"] floatValue] shakeZ:NO grid:ccg([[warp objectForKey:@"sectionsX"] intValue], [[warp objectForKey:@"sectionsY"] intValue]) duration:duration frameRate:[[warp objectForKey:@"framerate"] floatValue]];
						
						if (!repeatsForever) {
							warpAction=[CCSequence actions:warpAction, [CCStopGrid action], nil];
						}
						keyframeAction = [CCSpawn actionOne:keyframeAction two:warpAction];
					}
					
					if([keyframe valueForKey:@"sound"])
					{
						hasSound=YES;
						PlaySoundAction *playSound=[PlaySoundAction actionWithFilePath:[keyframe objectForKey:@"sound"]];
						if ([keyframe objectForKey:@"volume"]) {
							playSound.volume=[[keyframe objectForKey:@"volume"] floatValue];
						}
						keyframeAction=[CCSpawn actionOne:keyframeAction two:playSound];
					}
					
					if([keyframe valueForKey:@"smoke"] && isSmoke)
					{
						ToggleSmokeAction *toggleSmoke=[ToggleSmokeAction actionWithState:[[keyframe objectForKey:@"smoke"] boolValue]];
						keyframeAction=[CCSpawn actionOne:keyframeAction two:toggleSmoke];
					}
					
					//We make final action in case of easing.  In that case we will need to add a new action around the spawn action;
					float ease = [(NSNumber*)[keyframe valueForKey:@"ease"] floatValue];
					//if there is easing we will figure out whether its in or out then multiply the amount by 2 to try and mimic flash's default easing
					
					
					if(ease != 0.0f)
					{
						CCFiniteTimeAction *easeAction;
						
						if(ease < 0.0f) {
							if (ease < -1.9f) {
								easeAction = [CCEaseExponentialIn actionWithAction:keyframeAction];
							} else {
								easeAction = [CCEaseIn actionWithAction:keyframeAction rate: fabsf(ease)*2];
							}
						} else if(ease > 0.0f) {
							if (ease > 1.9f) {
								easeAction = [CCEaseExponentialOut actionWithAction:keyframeAction];
							} else {
								easeAction = [CCEaseOut actionWithAction:keyframeAction rate: fabsf(ease)*2];
							}
						}
						mainSequence = [CCSequence actionOne:mainSequence two:easeAction];
					} else {
						mainSequence = [CCSequence actionOne:mainSequence two:keyframeAction];
					}
				}	
				
				if(repeatsForever)
				{
					mainSequence = [CCRepeatForever actionWithAction:mainSequence];
				}			
				
				if ([[subDict objectForKey:@"type"] isEqualToString:@"start"]) {
					if (!interactiveDuringIntro && !repeatsForever) {
						mainSequence = [CCSequence actionOne:mainSequence two:[CCCallFuncN actionWithTarget:self selector:@selector(animationDone)]];
					}
					[startTranslateAnimations addObject:mainSequence];
				}else {
					if (!repeatsForever) {
						mainSequence = [CCSequence actionOne:mainSequence two:[CCCallFuncN actionWithTarget:self selector:@selector(animationDone)]];
					}
					[clickTranslateAnimations addObject:mainSequence];
				}				
			}
		}
		
		//load frame animations
		subArray=[dict objectForKey:@"frameAnimations"];
		if (subArray!=nil) {
			for (uint i=0; i<[subArray count]; ++i) {
				subDict=[subArray objectAtIndex:i];
				FrameAnimation *animation=[[[FrameAnimation alloc] initWithDictionary:subDict :1000+i] autorelease];
				if (animation.hasSound) {
					hasSound=YES;
				}
				if ([[subDict objectForKey:@"type"] isEqualToString:@"start"]) {
					if (!interactiveDuringIntro) {
						animation.parentIndex=tag;
					}
					[startFrameAnimations addObject:animation];
				}else {
					animation.parentIndex=tag;
					[clickFrameAnimations addObject:animation];
				}
				[[self getCocosNode] addChild:animation.spriteSheet];
			}
		}

		//click box
		NSString *clickarea=[dict objectForKey:@"clickarea"];
		if (clickarea==nil) {
			if (sprite!=nil) {
				clickable=YES;
				clickBox=CGRectMake(0, 0, sprite.contentSize.width, sprite.contentSize.height);
			}else {
				clickable=NO;
			}

		}else {
			if ([clickarea isEqualToString:@"NO"]) {
				clickable=NO;
			}else {
				clickable=YES;
				clickBox=CGRectFromString(clickarea);
			}
		}

		
	}
	return self;
}

-(void) runStartAnimations{
	//run all "start-type" animations
	for (uint i=0; i<[startTranslateAnimations count]; ++i) {
		if (!interactiveDuringIntro && [[startTranslateAnimations objectAtIndex:i] class]!=[CCRepeatForever class]) {
			++isAnimating;
		}
		[[self getCocosNode] runAction:[startTranslateAnimations objectAtIndex:i]];
	}
	for (uint i=0; i<[startFrameAnimations count]; ++i) {
		if (!interactiveDuringIntro){
			isAnimating+=[[startFrameAnimations objectAtIndex:i] numberOfCallbacks];
		}
		[[startFrameAnimations objectAtIndex:i] startAnimations];
	}
	if (isSmoke) {
		((SmokeNode*)node).flippingPage=NO;
	}
}

-(void) stopAnimations{
	//stop all animations
	[[self getCocosNode] stopAllActions];
	for (uint i=0; i<[startFrameAnimations count]; ++i) {
		[[startFrameAnimations objectAtIndex:i] stopAnimations];
	}
	for (uint i=0; i<[clickFrameAnimations count]; ++i) {
		[[clickFrameAnimations objectAtIndex:i] stopAnimations];
	}
	isAnimating=-1;
	if (isSmoke) {
		((SmokeNode*)node).flippingPage=YES;
	}
}

-(CCNode *)getCocosNode{
	//get the cocos node for this component
	return sprite==nil?node:sprite;
}

-(BOOL) handleTouch:(CGPoint)point{
	//handle click (start "interactive-type" animations)
	if ([clickFrameAnimations count]==0 && [clickTranslateAnimations count]==0 && [animationTrigger count]==0) {
		return NO;
	}
	if (isAnimating!=0) {
		return NO;
	}
	if (!clickable) {
		return NO;
	}
	if (CGRectContainsPoint(CGRectApplyAffineTransform(clickBox, [[self getCocosNode] nodeToWorldTransform]), point)) {
		if (hasSound) {
			[PlaySoundAction setSoundsPrevented:NO];
			Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
			//if (appDelegate.speakerPlayer.playing) [appDelegate stopReadSpeakerPlayback];
			//pause speaker instead
			if (appDelegate.speakerPlayer.playing) [appDelegate pauseByFXReadSpeakerPlayback];
		}
		
		//trigger animations in other objects
		if (triggerState!=-1 && animationTrigger!=nil) {
			if (triggerState==0) {
				triggerState=-1;
			}
			for (uint i=0; i<[animationTrigger count]; ++i) {
				[[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController].currentScene triggerAnimationByName:[animationTrigger objectAtIndex:i]];
			}
		}
		
		for (uint i=0; i<[clickTranslateAnimations count]; ++i) {
			if ([[clickTranslateAnimations objectAtIndex:i] class]!=[CCRepeatForever class]) {
				++isAnimating;
			}
			[[self getCocosNode] runAction:[clickTranslateAnimations objectAtIndex:i]];
		}
		for (uint i=0; i<[clickFrameAnimations count]; ++i) {
			isAnimating+=[[clickFrameAnimations objectAtIndex:i] numberOfCallbacks];
			[[clickFrameAnimations objectAtIndex:i] startAnimations];
		}
		//NSLog(@"starting animation");
		return YES;
	}
	return NO;
}

-(void)triggerAnimations{
	if ([clickFrameAnimations count]==0 && [clickTranslateAnimations count]==0) {
		return;
	}
	if (isAnimating!=0) {
		return;
	}
	
	if (hasSound) {
		[PlaySoundAction setSoundsPrevented:NO];
		Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
		//if (appDelegate.speakerPlayer.playing) [appDelegate stopReadSpeakerPlayback];
		//pause speaker instead
		if (appDelegate.speakerPlayer.playing) [appDelegate pauseByFXReadSpeakerPlayback];
	}
	
	for (uint i=0; i<[clickTranslateAnimations count]; ++i) {
		if ([[clickTranslateAnimations objectAtIndex:i] class]!=[CCRepeatForever class]) {
			++isAnimating;
		}
		[[self getCocosNode] runAction:[clickTranslateAnimations objectAtIndex:i]];
	}
	for (uint i=0; i<[clickFrameAnimations count]; ++i) {
		isAnimating+=[[clickFrameAnimations objectAtIndex:i] numberOfCallbacks];
		[[clickFrameAnimations objectAtIndex:i] startAnimations];
	}
}

-(BOOL)isTouched:(CGPoint)point{
	//check if component was touched
	if ([clickFrameAnimations count]==0 && [clickTranslateAnimations count]==0 && [animationTrigger count]==0) {
		return NO;
	}
	if (!clickable) {
		return NO;
	}
	return CGRectContainsPoint(CGRectApplyAffineTransform(clickBox, [[self getCocosNode] nodeToWorldTransform]), point);
}

-(void)animationDone{
	//called when an animation is done playing. interactive-type animations can only be started when previous animations have finished
	--isAnimating;
	//NSLog(@"animations running=%d",isAnimating);
}

-(void)killAnimations{
	for (uint i=0; i<[startFrameAnimations count]; ++i) {
		[[startFrameAnimations objectAtIndex:i] killAnimations];
	}
	for (uint i=0; i<[clickFrameAnimations count]; ++i) {
		[[clickFrameAnimations objectAtIndex:i] killAnimations];
	}	
	[startTranslateAnimations release];
	[clickTranslateAnimations release];
	[startFrameAnimations release];
	[clickFrameAnimations release];
	startTranslateAnimations=nil;
	clickTranslateAnimations=nil;
	startFrameAnimations=nil;
	clickFrameAnimations=nil;
}

-(void) dealloc{
	[name release];
	[filename release];
	[sprite release];
	[node release];
	[startTranslateAnimations release];
	[clickTranslateAnimations release];
	[startFrameAnimations release];
	[clickFrameAnimations release];
	[animationTrigger release];
	[super dealloc];
}

@end
