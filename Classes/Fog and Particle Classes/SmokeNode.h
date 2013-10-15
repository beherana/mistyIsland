//
//  SmokeNode.h
//  Smoke
//
//  Created by Robert Bergkvist on 2010-11-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface SmokeNode : CCQuadParticleSystem {
	ccVertex2F p0;
	ccVertex2F p1;
	ccVertex2F p2;
	ccVertex2F p3;
	BOOL spewSmoke;
	BOOL flippingPage;
}

-(void)updateQuadWithParticle:(tCCParticle*)p newPosition:(CGPoint)newPos;
@property (nonatomic,readwrite,assign) ccVertex2F p0;
@property (nonatomic,readwrite,assign) ccVertex2F p1;
@property (nonatomic,readwrite,assign) ccVertex2F p2;
@property (nonatomic,readwrite,assign) ccVertex2F p3;
@property (nonatomic) BOOL spewSmoke;
@property (nonatomic) BOOL flippingPage;
@end
