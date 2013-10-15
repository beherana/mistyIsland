//
//  BookScene.m
//  Thomas
//
//  Created by Johannes Amilon on 11/4/10.
//  Copyright 2010 Vitamin Se Media AB. All rights reserved.
//

#import "BookScene.h"
#import "Misty_Island_Rescue_iPadAppDelegate.h"
#import "SceneComponent.h"
#import "PhysicsSprite.h"
#import "FogSprite.h"
#import "SimpleAudioEngine.h"
#import "FontLabelStringDrawing.h"
#import "PlaySoundAction.h"
#import "cdaAnalytics.h"

#define PTM_RATIO 64.0

#define GRID_COLUMNS 128
#define GRID_ROWS 64


@implementation BookScene

@synthesize page,components,moreAppsButton,moreAppsOnButton;

/*-(id) init{
	if ((self=[super init]) ) {
		
	}
	return self;
}*/

-(void)setPage:(int)newPage{
	//NSLog(@"pageset");

		landscapeRight=[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController].landscapeRight;

	
	isScreenshot=NO;
	page=newPage;
    lastPage = [[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] isLastPage];
	NSMutableArray *data=[NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"scene%d",page] ofType:@"plist"]];
	
	components=[[NSMutableArray alloc] initWithCapacity:[data count]-1];
	componentsByName=[[NSMutableDictionary alloc] initWithCapacity:[data count]-1];
	SceneComponent *currentComponent;
	//load objects
	for (uint i=1; i<[data count]; ++i) {
		currentComponent=[SceneComponent componentWithDictionary:[data objectAtIndex:i] :i-1];
		[components addObject:currentComponent];
		[componentsByName setObject:currentComponent forKey:currentComponent.name];
		//NSLog(@"adding %@",currentComponent.name);
	}
	
	
	//This is to prevent the misterious black rectangle on the iphone
	CCColorLayer *superLayer=[[[CCColorLayer alloc] initWithColor:ccc4(255, 255, 255, 255)] autorelease];
	[self addChild:superLayer];
	
	
	//set background color
	if ([[[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"bgColor"] isEqual:@"BLACK"]) {
		layer=[[AccelerometerDelegateLayer alloc] initWithColor:ccc4(0, 0, 0, 255)];
	}else {
		layer=[[AccelerometerDelegateLayer alloc] initWithColor:ccc4(255, 255, 255, 255)];
	}
	

	layerOffset=ccp(0,0);
	
	if ([[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"offsetX"])
		layerOffset.x=[[[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"offsetX"] floatValue];
	
	if ([[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"offsetY"])
		layerOffset.y=[[[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"offsetY"] floatValue];
	
	
	
	layer.anchorPoint=ccp(0,0);
	layer.position=layerOffset;
	
	[self addChild:layer z:0 tag:0];
	animating=NO;
	
	//background sound/music
	NSDictionary *sound=[[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"bgSound"];
	if (sound!=nil) {
		bgSound=[[sound objectForKey:@"filename"] retain];
		bgVolume=[[sound objectForKey:@"volume"] floatValue];
		bgRepeat=[[sound objectForKey:@"repeat"] boolValue];
		[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:bgSound];
	}else {
		bgSound=nil;
	}
	
	//place background objects
	NSArray *objects=[[[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"static"] objectForKey:@"background"];
	for (uint i=0;i<[objects count]; ++i) {
		[self addRecursive:[objects objectAtIndex:i]:layer];
	}
	//place foreground objects
	objects=[[[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"animated"] objectForKey:@"objects"];
	for (uint i=0;i<[objects count]; ++i) {
		[self addRecursive:[objects objectAtIndex:i]:layer];
	}
	
	//language
	NSDictionary *languages=[[[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"static"] objectForKey:@"text"];
	NSString *language=[((Misty_Island_Rescue_iPadAppDelegate*)[[UIApplication sharedApplication] delegate]) getCurrentLanguage];
	NSDictionary *labelDict=[languages objectForKey:language];
	if (labelDict==nil) {
		labelDict=[languages objectForKey:@"en_US"];
	}
	
	//text box
	CGRect labelBounds=CGRectFromString([labelDict objectForKey:@"boundingBox"]);
	
	
	if ([labelDict objectForKey:@"linespacing"]) {
		[CocosFontHaxxor setRowSpace:[[labelDict objectForKey:@"linespacing"] intValue]];
	}else {
		[CocosFontHaxxor setRowSpace:10];
	}
	
	if (text) [text release];
	if ([labelDict objectForKey:@"overlayText"]) 
		text=[[labelDict objectForKey:@"overlayText"] retain];
	else 
		text=[[labelDict objectForKey:@"text"] retain];
	

	

	
	label=[[CCLabel labelWithString:[labelDict objectForKey:@"text"]
								 dimensions:labelBounds.size alignment:UITextAlignmentLeft
								   fontName:[labelDict objectForKey:@"font"]
								   fontSize:[[labelDict objectForKey:@"size"] floatValue]] retain];
	label.position=CGPointMake(labelBounds.origin.x+labelBounds.size.width/2, labelBounds.origin.y+labelBounds.size.height/2);
	if ([[labelDict objectForKey:@"color"] isEqual:@"WHITE"]) {
		[label setColor:ccWHITE];
		style=ReadOverlayViewStyleBlack;
	}else {
		[label setColor:ccBLACK];
		style=ReadOverlayViewStyleWhite;
	}
	//label.opacity=0;
	
	//narration repeat button
	
	NSString *deviceSuffix= (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)?  @"~iphone" : @"~ipad";
	NSString *greySuffix=@"";
	if (newPage > 17 && newPage < 23) greySuffix=@"_grey";
	
	NSString *repeatButtonName=[NSString stringWithFormat:@"audio_reload%@%@.png",greySuffix,deviceSuffix];
	repeatButton=[[CCSprite spriteWithFile:repeatButtonName] retain];
	
	repeatButton.visible= [((Misty_Island_Rescue_iPadAppDelegate*)[[UIApplication sharedApplication] delegate]) getSaveNarrationSetting]==0;
	repeatButton.position=CGPointMake(labelBounds.origin.x+labelBounds.size.width-[repeatButton boundingBox].size.width, labelBounds.origin.y+labelBounds.size.height-[CocosFontHaxxor latestHeight]-14);
	//repeatButton.opacity=0;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		//repeatButton.position=ccp(repeatButton.position.x,720);
		//SCR 113
		repeatButton.position=ccp(975-layerOffset.x,715-layerOffset.y);
		repeatButton.scale=(1/kiPhoneLayerScale)*.52;
	}
    //do not show repeat button on iPad last page
    if (!lastPage || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [layer addChild:repeatButton z:1000 tag:6000];
    }
	
	[layer addChild:label z:[[labelDict objectForKey:@"z"] intValue] tag:5000];
    
    //moreapps button
    if (lastPage && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.moreAppsButton = [CCSprite spriteWithFile:@"more_apps_btn@2x.png"];
        self.moreAppsButton.position = CGPointMake(512, 300);
        [layer addChild:self.moreAppsButton z:1000 tag:5001];
        //add a pressed state for the moreapps image
        self.moreAppsOnButton = [CCSprite spriteWithFile:@"more_apps_btn_on@2x.png"];
        self.moreAppsOnButton.position = self.moreAppsButton.position;
        self.moreAppsOnButton.visible = NO;
        [layer addChild:self.moreAppsOnButton z:1001 tag:5002];
    }
    else {
        self.moreAppsButton = nil;
    }
	
	//initialize physics
	hasPhysics=NO;
	world=NULL;
	mouseJoint=NULL;
	if ([[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"hasPhysics"]!=nil) {
		if ([[[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"hasPhysics"] boolValue]) {
			[self setupPhysics];
		}
	}
	
	//initialize fog
	hasFog=NO;
	fog=NULL;
	fogTexture=nil;
	NSDictionary *fogDict=[[[[data objectAtIndex:0] objectForKey:@"scenemetadata"] objectForKey:@"animated"] objectForKey:@"fog"];
	if (fogDict!=nil) {
		[self setupFog:fogDict];
	}
    
    [[cdaAnalytics sharedInstance] trackPage:[NSString stringWithFormat:@"/BookPage%d", page]]; 
}

-(void) setReplayVisible{
	if (isScreenshot) {
		return;
	}
	
	[PlaySoundAction setSoundsPrevented:NO];
	if (!animating) {
		return;
	}
	repeatButton.visible=YES;
}

-(void) setReplayHidden{
	if (isScreenshot) {
		return;
	}
	
	[PlaySoundAction setSoundsPrevented:YES];
	[PlaySoundAction stopSounds];
	if (!animating) {
		return;
	}
	repeatButton.visible=NO;
}

-(void) setupPhysics{
	hasPhysics=YES;
	NSDictionary *physics=[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"scene%d_physics",page] ofType:@"plist"]];
	useAccelerometer=[[[physics objectForKey:@"data"] objectForKey:@"useAccelerometer"] boolValue];
	respawnObjects=[[[physics objectForKey:@"data"] objectForKey:@"respawnObjects"] boolValue];
	world=new b2World(b2Vec2([[[physics objectForKey:@"data"] objectForKey:@"gravityX"] floatValue],[[[physics objectForKey:@"data"] objectForKey:@"gravityY"] floatValue]),false);	
	
	//setup boundaries
	physicsBox=CGRectFromString([[physics objectForKey:@"data"] objectForKey:@"boundingBox"]);
	CGRect boundingBox=CGRectMake(physicsBox.origin.x/PTM_RATIO, physicsBox.origin.y/PTM_RATIO, physicsBox.size.width/PTM_RATIO, physicsBox.size.height/PTM_RATIO);
	b2BodyDef groundBodyDef;
	groundBody=world->CreateBody(&groundBodyDef);
	b2PolygonShape groundBox;
	b2FixtureDef boxShapeDef;
	boxShapeDef.shape=&groundBox;
	if ([[[physics objectForKey:@"data"] objectForKey:@"hasLeftWall"] boolValue]) {
		groundBox.SetAsEdge(b2Vec2(boundingBox.origin.x,boundingBox.origin.y),b2Vec2(boundingBox.origin.x,boundingBox.origin.y+boundingBox.size.height));
		groundBody->CreateFixture(&boxShapeDef);
	}
	if ([[[physics objectForKey:@"data"] objectForKey:@"hasRightWall"] boolValue]) {
		groundBox.SetAsEdge(b2Vec2(boundingBox.origin.x+boundingBox.size.width,boundingBox.origin.y),b2Vec2(boundingBox.origin.x+boundingBox.size.width,boundingBox.origin.y+boundingBox.size.height));
		groundBody->CreateFixture(&boxShapeDef);
	}
	if ([[[physics objectForKey:@"data"] objectForKey:@"hasTop"] boolValue]) {
		groundBox.SetAsEdge(b2Vec2(boundingBox.origin.x,boundingBox.origin.y+boundingBox.size.height),b2Vec2(boundingBox.origin.x+boundingBox.size.width,boundingBox.origin.y+boundingBox.size.height));
		groundBody->CreateFixture(&boxShapeDef);
	}
	if ([[[physics objectForKey:@"data"] objectForKey:@"hasBottom"] boolValue]) {
		groundBox.SetAsEdge(b2Vec2(boundingBox.origin.x,boundingBox.origin.y),b2Vec2(boundingBox.origin.x+boundingBox.size.width,boundingBox.origin.y));
		groundBody->CreateFixture(&boxShapeDef);
		
	}
	
	//create objects
	NSArray *objects=[physics objectForKey:@"objects"];
	NSArray *definitions=[[physics objectForKey:@"data"] objectForKey:@"definitions"];
	for (uint i=0; i<[objects count]; ++i) {
		NSDictionary *object=[objects objectAtIndex:i];
		NSDictionary *definition=[definitions objectAtIndex:[[object objectForKey:@"definition"] intValue]];
		PhysicsSprite *sprite=[PhysicsSprite spriteWithFile:[definition objectForKey:@"image"]];
		if ([definition objectForKey:@"spriteOffset"]!=nil) {
			sprite.spriteOffset=CGSizeFromString([definition objectForKey:@"spriteOffset"]);
		}
		if ([definition objectForKey:@"preventRotation"]!=nil) {
			sprite.preventRotation=[[definition objectForKey:@"preventRotation"] boolValue];
		}
		sprite.position=ccp([[object objectForKey:@"x"] floatValue]+sprite.spriteOffset.width,[[object objectForKey:@"y"] floatValue]+sprite.spriteOffset.height);
		sprite.rotation=[[object objectForKey:@"rotation"] floatValue];
		sprite.canGrab=[[definition objectForKey:@"canGrab"] boolValue];
		sprite.startPosition=sprite.position;
		sprite.startVelocity=ccp([[object objectForKey:@"impulseX"] floatValue],[[object objectForKey:@"impulseY"] floatValue]);
		sprite.startRotation=sprite.rotation;
		sprite.startSpin=[[object objectForKey:@"spin"] floatValue];
		[layer addChild:sprite z:1001 tag:9000+i];
		
		
		
		b2BodyDef bodyDef;
		bodyDef.type=b2_dynamicBody;
		bodyDef.position.Set(sprite.position.x/PTM_RATIO,sprite.position.y/PTM_RATIO);
		bodyDef.angle=-1*CC_DEGREES_TO_RADIANS(sprite.rotation);
		bodyDef.userData=sprite;
		b2Body *body=world->CreateBody(&bodyDef);
		
		b2FixtureDef shapeDef;
		
		if ([definition objectForKey:@"radius"]!=nil) {
			b2CircleShape circle;
			circle.m_radius=[[definition objectForKey:@"radius"] floatValue]/PTM_RATIO;
			shapeDef.shape=&circle;
		}else {
			b2PolygonShape box;
			box.SetAsBox([[definition objectForKey:@"width"] floatValue]/PTM_RATIO/2, [[definition objectForKey:@"height"] floatValue]/PTM_RATIO/2);
			shapeDef.shape=&box;
		}		
		
		shapeDef.density=[[definition objectForKey:@"density"] floatValue];
		shapeDef.friction=[[definition objectForKey:@"friction"] floatValue];
		shapeDef.restitution=[[definition objectForKey:@"restitution"] floatValue];
		body->CreateFixture(&shapeDef);
		
		body->SetLinearVelocity(b2Vec2(sprite.startVelocity.x,sprite.startVelocity.y));
		body->SetAngularVelocity(sprite.startSpin);
	}
}

-(void)setupFog:(NSDictionary *)fogDict{
	hasFog=YES;
	fog = new FluidField();
	fog->init();
	
	//set parameters;
	fog->setGridSize(GRID_COLUMNS,GRID_ROWS);
	int fogWidth=[[fogDict objectForKey:@"width"] intValue];
	int fogHeight=[[fogDict objectForKey:@"height"] intValue];
	fog->setDisplaySize(fogWidth,fogHeight);
	fog->setSpawnArea([[fogDict objectForKey:@"spawnTop"] intValue],[[fogDict objectForKey:@"spawnBottom"] intValue]);
	fog->setDensity([[fogDict objectForKey:@"density"] floatValue]);
	fog->setTurbulence([[fogDict objectForKey:@"turbulence"] floatValue]);
	fog->setNoiseScale([[fogDict objectForKey:@"noiseScaleX"] floatValue], [[fogDict objectForKey:@"noiseScaleY"] floatValue]);
	fog->setWindSpeed([[fogDict objectForKey:@"windSpeed"] floatValue]);
	if ([fogDict objectForKey:@"force"]!=nil) {
		fog->setForce([[fogDict objectForKey:@"force"] floatValue]);
	}
	if ([fogDict objectForKey:@"viscosity"]!=nil) {
		fog->setViscosity([[fogDict objectForKey:@"viscosity"] floatValue]);
	}
	int border=[[fogDict objectForKey:@"topBorder"] intValue];
	if (border!=-1) {
		fog->setTopBorder(border);
	}
	border=[[fogDict objectForKey:@"bottomBorder"] intValue];
	if (border!=-1) {
		fog->setBottomBorder(border);
	}
	/*border=[[fogDict objectForKey:@"leftBorder"] intValue];
	if (border!=-1) {
		fog->setLeftBorder(border);
	}
	border=[[fogDict objectForKey:@"rightBorder"] intValue];
	if (border!=-1) {
		fog->setRightBorder(border);
	}*/
	fog->clear();
	
	fogReveal=NO;
	if ([fogDict objectForKey:@"reveal"]!=nil) {
		fogReveal=YES;
		fog->setThickness(1.0f);
		fogRevealStart=[[[fogDict objectForKey:@"reveal"] objectForKey:@"start"] floatValue];
		fogRevealDuration=[[[fogDict objectForKey:@"reveal"] objectForKey:@"duration"] floatValue];
		fogRevealTimer=0;
	}

	// Set up fog
	fogTexture = [[CCTexture2D alloc] initWithData:fog->getData(0) pixelFormat:kCCTexture2DPixelFormat_RGBA8888 pixelsWide:GRID_COLUMNS pixelsHigh:GRID_ROWS contentSize:CGSizeMake(GRID_COLUMNS,GRID_ROWS)];
	
	FogSprite *fogSprite = [FogSprite spriteWithTexture:fogTexture];
	fogX=[[fogDict objectForKey:@"x"] floatValue];
	fogSprite.position = ccp( fogX, [[fogDict objectForKey:@"y"] floatValue] );
	fogSprite.scaleX = (float)fogWidth/(float)GRID_COLUMNS;
	fogSprite.scaleY = (float)fogHeight/(float)GRID_ROWS;
	
	[layer addChild:fogSprite z:[[fogDict objectForKey:@"z"] intValue] tag:1000];
}

-(void)update:(ccTime)dt{
	if (isScreenshot) {
		return;
	}
	
	if (hasPhysics) {
		world->Step(dt, 10, 10);
		for (b2Body *b = world->GetBodyList(); b; b=b->GetNext()) {		
			if (b->GetUserData() !=NULL) {
				PhysicsSprite *objectData=(PhysicsSprite *)b->GetUserData();			
				if (b->GetPosition().x*PTM_RATIO<-500 || b->GetPosition().x*PTM_RATIO>1524 || b->GetPosition().y*PTM_RATIO<-500 || b->GetPosition().y*PTM_RATIO>1268) {
					if (respawnObjects) {
						b->SetTransform(b2Vec2(objectData.startPosition.x/PTM_RATIO,objectData.startPosition.y/PTM_RATIO),-1*CC_DEGREES_TO_RADIANS(objectData.startRotation));
						b->SetLinearVelocity(b2Vec2(objectData.startVelocity.x,objectData.startVelocity.y));
						b->SetAngularVelocity(objectData.startSpin);
					}else {
						b->SetAwake(false);
						[self removeChild:(PhysicsSprite*)b->GetUserData() cleanup:YES];
						b->SetUserData(NULL);
						continue;
					}
				}
				
				objectData.position=ccp(b->GetPosition().x*PTM_RATIO+objectData.spriteOffset.width,b->GetPosition().y*PTM_RATIO+objectData.spriteOffset.height);
				if (!objectData.preventRotation) {
					objectData.rotation=-1*CC_RADIANS_TO_DEGREES(b->GetAngle());
				}
			}
		}
	}
	if (hasFog) {
		
		if (fogReveal) {
			fogRevealTimer+=dt;
			if (fogRevealStart>=0) {
				if (fogRevealTimer>=fogRevealStart) {
					fogRevealStart=-1;
					fogRevealTimer=0;
				}
			}else if (fogRevealDuration>0) {
				if (fogRevealTimer>=fogRevealDuration) {
					fog->setThickness(0);
					fogReveal=NO;
				}else {
					fog->setThickness(1.0f-(fogRevealTimer/fogRevealDuration));
				}				
			}
		}		
		fog->update();
		GLuint texId = fogTexture.name;
		glBindTexture(GL_TEXTURE_2D,texId);
		glTexSubImage2D(GL_TEXTURE_2D, 0,0,0,GRID_COLUMNS,GRID_ROWS,GL_RGBA,GL_UNSIGNED_BYTE,fog->getData(dt));
	}
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
	if (isScreenshot) {
		return;
	}
	
	//apply the accelerometer values to physics engine
	b2Vec2 gravity;
	if (landscapeRight) {
		gravity=b2Vec2(-acceleration.y*15,acceleration.x*15);
	}else {
		gravity=b2Vec2(acceleration.y*15,-acceleration.x*15);
	}	
	world->SetGravity(gravity);
}

-(void)orientationChanged:(BOOL)isLandscapeRight{
	if (isScreenshot) {
		return;
	}
	
	if (hasPhysics && useAccelerometer && landscapeRight!=isLandscapeRight) {
		b2Vec2 oldgravity=world->GetGravity();
		world->SetGravity(b2Vec2(-oldgravity.x,-oldgravity.y));
	}
	landscapeRight=isLandscapeRight;
}

-(void)addRecursive:(NSDictionary *)data:(CCNode *)currentNode{
	//recursively adds an object and its children to the scene
	SceneComponent *currentComponent=[componentsByName objectForKey:[data objectForKey:@"name"]];
	[currentNode addChild:[currentComponent getCocosNode] z:currentComponent.z];
	//NSLog(@"adding recursive %@", currentComponent.name);
	NSArray *children=[data objectForKey:@"children"];
	for (uint i=0; i<[children count]; ++i) {
		[self addRecursive:[children objectAtIndex:i] :[currentComponent getCocosNode]];
	}
}

-(void)removeRecursive:(CCNode *)node{
	for (CCNode *child in [node children]) {
		[self removeRecursive:child];
	}
	[node removeAllChildrenWithCleanup:YES];
}

-(void)stopAnimation{
	if (isScreenshot) {
		return;
	}
	
	if (!animating) {
		return;
	}
	animating=NO;
	//NSLog(@"Page %d: stopAnimation",page);
	//turn off physics
	if (hasPhysics || hasFog) {
		[self unschedule:@selector(update:)];
		if (hasPhysics) {
			layer.isAccelerometerEnabled=NO;
		}		
		/*if (hasFog) {
			[layer getChildByTag:1000].visible=NO;
		}*/
	}
	
	//stop sound
	if (bgSound!=nil) {
		[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	}
	
	//stop animations
	for (uint i=0; i<[components count]; ++i) {
		[[components objectAtIndex:i] stopAnimations];
	}
}


-(void)startAnimation{
	if (isScreenshot) {
		return;
	}
	
	if (animating) {
		return;
	}
	animating=YES;
	
	//NO FADE ON TEXTS IN READ
	/*
	[label runAction:[CCPropertyAction actionWithDuration:0.0f key:@"opacity" from:0 to:255]];
	[repeatButton runAction:[CCPropertyAction actionWithDuration:0.0f key:@"opacity" from:0 to:255]];
	*/
	
	//NSLog(@"Page %d: startAnimation",page);
	//turn on physics
	if (hasPhysics || hasFog) {
		[self schedule:@selector(update:) interval:1.0/60.0];
		if (hasPhysics) {
			layer.isAccelerometerEnabled=useAccelerometer;
		}
		/*if (hasFog) {
			[layer getChildByTag:1000].visible=YES;
		}*/
	}
	//start sound
	if (bgSound!=nil) {
		Misty_Island_Rescue_iPadAppDelegate *appDelegate = [Misty_Island_Rescue_iPadAppDelegate get];
		if (appDelegate.fxPlayer.playing) [appDelegate stopFXPlayback];
		[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:bgVolume];
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:bgSound loop:bgRepeat];
	}
	//start "start-type" animations
	for (uint i=0; i<[components count]; ++i) {
		[[components objectAtIndex:i] runStartAnimations];
	}
}
-(BOOL) isAnimating {
	return animating;
}
-(void)triggerAnimationByName:(NSString *)name{
	if (isScreenshot) {
		return;
	}
	
	[[componentsByName objectForKey:name] triggerAnimations];
}

-(void) onEnterTransitionDidFinish{
	//call appdelegate to clean up after transition
	[super onEnterTransitionDidFinish];
	//NSLog(@"onEnterTransitionDidFinish");
		[[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] sceneTransitionDone];

}

-(void)dealloc{
	if (text) [text release];
	if (isScreenshot) {
		[self removeAllChildrenWithCleanup:YES];
	}else {
		[self removeRecursive:layer];
		[self removeAllChildrenWithCleanup:YES];
		if (world) {
			delete world;
			world=NULL;
		}
		if (fog) {
			delete fog;
			fog=NULL;
		}
		[repeatButton release];
        self.moreAppsButton = nil;
        self.moreAppsOnButton = nil;
		[bgSound release];
		[fogTexture release];
		[layer release];
		[label release];
		for (uint i=0; i<[components count]; ++i) {
			[[components objectAtIndex:i] killAnimations];
		}
		[components release];
		[componentsByName release];
	}	
	[super dealloc];
}


//checks for dynamic, grabbable physics objects
struct QueryCallback : b2QueryCallback {
	QueryCallback(const b2Vec2& point){
		this->point=point;
		fixture=NULL;
	}
	
	bool ReportFixture(b2Fixture* fixture){
		b2Body *body=fixture->GetBody();
		if (body->GetType() == b2_dynamicBody && ((PhysicsSprite*)body->GetUserData()).canGrab) {
			if (fixture->TestPoint(point)){
				this->fixture=fixture;
				return false;
			}
		}
		return true;
	}
	
	b2Vec2 point;
	b2Fixture *fixture;
};

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	if (isScreenshot) {
		return NO;
	}
	
	
	CGPoint point=[touch locationInView:[[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] view]];

	
	CGPoint fogPoint=point;

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
		fogPoint.x/=kiPhoneLayerScale;
		fogPoint.y/=kiPhoneLayerScale;
	}

	if (hasFog) {
		fog->mouseDown((fogPoint.x-layerOffset.x)-(fogX-(fog->getWidth()/2)), fogPoint.y+layerOffset.y+fog->getHeight()-786);
	}
	
	touchedElement=-1;
	
	
	point=[[CCDirector sharedDirector] convertToGL:fogPoint];
	
	CGPoint physicsPoint=point;
	
	physicsPoint.x-=layerOffset.x;
	physicsPoint.y-=layerOffset.y;
	//grab physics object
	if (hasPhysics && touchedElement==-1 && mouseJoint==NULL) {
		touchPoint=b2Vec2(physicsPoint.x/PTM_RATIO,physicsPoint.y/PTM_RATIO);
		b2AABB aabb;
		b2Vec2 d=b2Vec2(0.001f,0.001f);
		aabb.lowerBound=touchPoint-d;
		aabb.upperBound=touchPoint+d;
		
		QueryCallback callback(touchPoint);
		world->QueryAABB(&callback, aabb);
		if (callback.fixture) {
			b2Body *grabbedBody=callback.fixture->GetBody();
			b2MouseJointDef md;
			md.bodyA=groundBody;
			md.bodyB=grabbedBody;
			md.target=touchPoint;
			md.maxForce=1000.0f*grabbedBody->GetMass();
			md.collideConnected=true;
			mouseJoint = (b2MouseJoint*)world->CreateJoint(&md);
		}
	}
	
	

	//repeat button
	CGRect box=CGRectMake(0, 0, repeatButton.contentSize.width, repeatButton.contentSize.height);
	if (mouseJoint==NULL && touchedElement==-1 && repeatButton.visible && CGRectContainsPoint(CGRectApplyAffineTransform(box, [repeatButton nodeToWorldTransform]), point)) {
		touchedElement=-2;
	}
	
	//label
	box=CGRectMake(0, 0, label.contentSize.width, label.contentSize.height);
	if (mouseJoint==NULL && touchedElement==-1 &&  CGRectContainsPoint(CGRectApplyAffineTransform(box, [label nodeToWorldTransform]), point)) {
		touchedElement=-3;
	}
	
    BOOL getCocosPaused=[[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] getCocosPaused];
    
    //more apps button - only for end page
    if (self.moreAppsButton && mouseJoint==NULL && touchedElement==-1 && !getCocosPaused) {
        self.moreAppsOnButton.visible = YES;
        touchedElement=-4;
    }

	
	
	//click scene component
	
	if (mouseJoint==NULL && touchedElement==-1 && !getCocosPaused) {

		for (uint i=0; i<[components count]; ++i) {
			if ([[components objectAtIndex:i] isTouched:point]) {
				touchedElement=i;
				break;
			}
		}
	}
	
	return YES;
}

-(BOOL)isDraggingObject{
	return mouseJoint!=NULL;
}

-(void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
	if (isScreenshot) {
		return;
	}
	
	CGPoint point=[touch locationInView:[[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] view]];

	
	CGPoint fogPoint=point;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
		fogPoint.x/=kiPhoneLayerScale;
		fogPoint.y/=kiPhoneLayerScale;
	}
	
	if (hasFog) {
		fog->mouseMove(fogPoint.x-layerOffset.x-(fogX-(fog->getWidth()/2)), fogPoint.y+layerOffset.y+fog->getHeight()-786);
	}
	
	//move physics object around
	if (hasPhysics && mouseJoint!=NULL) {
		point=[[CCDirector sharedDirector] convertToGL:fogPoint];
		

		point.x-=layerOffset.x;
		point.y-=layerOffset.y;
		if (!CGRectContainsPoint(physicsBox, point)) {
			world->DestroyJoint(mouseJoint);
			mouseJoint=NULL;
			return;
		}		
		touchPoint=b2Vec2(point.x/PTM_RATIO,point.y/PTM_RATIO);
		mouseJoint->SetTarget(touchPoint);
	}
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {	
	if (isScreenshot) {
		return;
	}
	if ([((Misty_Island_Rescue_iPadAppDelegate*)[[UIApplication sharedApplication] delegate]) getReadViewIsPaused]) {
		//NSLog(@"Touching");
		[((Misty_Island_Rescue_iPadAppDelegate*)[[UIApplication sharedApplication] delegate]) unPauseReadView];
	}
	
	
	
	CGPoint point=[touch locationInView:[[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] view]];
	
	
	
	CGPoint fogPoint=point;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
		fogPoint.x/=kiPhoneLayerScale;
		fogPoint.y/=kiPhoneLayerScale;
	}

	
	if (hasFog) {
		fog->mouseUp(fogPoint.x-layerOffset.x-(fogX-(fog->getWidth()/2)), fogPoint.y+layerOffset.y+fog->getHeight()-786);
	}
	
	point=[[CCDirector sharedDirector] convertToGL:fogPoint];

	
	//repeat button
	CGRect box=CGRectMake(0, 0, repeatButton.contentSize.width, repeatButton.contentSize.height);
	if (mouseJoint==NULL && repeatButton.visible && touchedElement==-2 && CGRectContainsPoint(CGRectApplyAffineTransform(box, [repeatButton nodeToWorldTransform]), point)) {
		[[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] forceNarrationOnScene];
		[[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] respawnHotspots];

		repeatButton.visible=NO;
	}
	
	//label
	box=CGRectMake(0, 0, label.contentSize.width, label.contentSize.height);
	if (mouseJoint==NULL && touchedElement==-3  && CGRectContainsPoint(CGRectApplyAffineTransform(box, [label nodeToWorldTransform]), point)) {
		
		[self showText];
	}
    
    //the end page more apps
    if (mouseJoint==NULL && touchedElement==-4) {
        self.moreAppsOnButton.visible = NO;
        [[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] showMoreAppsEndPage];
    }

	
	
	if (touchedElement>-1  && mouseJoint==NULL) {
		//click scene component
		[[components objectAtIndex:touchedElement] handleTouch:point];
	}
	//release physics object
	if (hasPhysics && mouseJoint!=NULL) {
		world->DestroyJoint(mouseJoint);
		mouseJoint=NULL;
	}
}

-(void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{
	if (isScreenshot) {
		return;
	}
	
	if (hasFog) {
		CGPoint fogPoint=[touch locationInView:[[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] view]];
		
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
			fogPoint.x/=kiPhoneLayerScale;
			fogPoint.y/=kiPhoneLayerScale;
		}

		
		
		fog->mouseUp(fogPoint.x-layerOffset.x-(fogX-(fog->getWidth()/2)), fogPoint.y+layerOffset.y+fog->getHeight()-786);
	}
	
	//release physics object
	if (hasPhysics && mouseJoint!=NULL) {
		world->DestroyJoint(mouseJoint);
		mouseJoint=NULL;
	}
}

-(void)turnIntoScreenshot{
    
    //take screenshot
    
        CGSize size = [CCDirector sharedDirector].displaySize;
 		GLuint bufferLength=size.width*size.height*4;
		GLubyte *buffer=(GLubyte *)malloc(bufferLength);
        
#warning remove this line before switching to Cocos2d v2.0
        BOOL isiOS6= ([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending);
        
        if (isiOS6)
            [[CCDirector sharedDirector] drawSceneNoSwap];
        //Read Pixels from OpenGL
        glReadPixels(0, 0, size.width, size.height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
#warning remove this line before switching to Cocos2d v2.0
         if (isiOS6)
             [[[CCDirector sharedDirector] openGLView] swapBuffers];
		CCTexture2D *texture=[[CCTexture2D alloc] initWithData:buffer pixelFormat:kCCTexture2DPixelFormat_RGBA8888 pixelsWide:size.width pixelsHigh:size.height contentSize:[CCDirector sharedDirector].winSize];
		free(buffer);
		
	
    
	//kill everything
	[self stopAnimation];
	isScreenshot=YES;
	[self removeRecursive:layer];
	[self removeAllChildrenWithCleanup:YES];
	if (world) {
		delete world;
		world=NULL;
	}
	if (fog) {
		delete fog;
		fog=NULL;
	}
	[repeatButton release];
	[bgSound release];
	[fogTexture release];
	[layer release];
	[label release];
	for (uint i=0; i<[components count]; ++i) {
		[[components objectAtIndex:i] killAnimations];
	}
	[components release];
	[componentsByName release];
    
    
    //set screenshot as screen
    CCSprite *sprite=[CCSprite spriteWithTexture:texture];
    [texture release];
    sprite.flipY=YES;
    sprite.anchorPoint=CGPointMake(0, 0);
    [self addChild:sprite];
    
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	

}
#pragma mark CocoaBridge to display text overlay

-(void)showText{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
		if ([[Misty_Island_Rescue_iPadAppDelegate get] getSaveReadEnlargeTextSetting]) {
			[[[Misty_Island_Rescue_iPadAppDelegate get] currentRootViewController] showReadOverlayViewWithText:text style:style];
		}
	}
}

@end
@implementation CCDirector (iOS6Extension)
-(void)drawSceneNoSwap{
  	/* calculate "global" dt */
	[self calculateDeltaTime];
	
	/* tick before glClear: issue #533 */
	if( ! isPaused_ ) {
		[[CCScheduler sharedScheduler] tick: dt];
	}
    
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
		
	glPushMatrix();
	
	[self applyOrientation];
	
	// By default enable VertexArray, ColorArray, TextureCoordArray and Texture2D
	CC_ENABLE_DEFAULT_GL_STATES();
    
	/* draw the scene */
	[runningScene_ visit];

	
	
	CC_DISABLE_DEFAULT_GL_STATES();
	
	glPopMatrix();
    
}
@end
