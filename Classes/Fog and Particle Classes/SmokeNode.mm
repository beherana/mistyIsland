//
//  SmokeNode.m
//  Smoke
//
//  Created by Robert Bergkvist on 2010-11-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SmokeNode.h"


@implementation SmokeNode
@synthesize p0,p1,p2,p3,spewSmoke,flippingPage;
-(CGPoint)bezier:(float)t {
#define CUBIC
#ifdef CUBIC
	float tmp = (1.0f-t);
	float t0 = tmp*tmp*tmp;			// (1-t)^3
	float t1 = 3 * t * tmp * tmp;	// 3*t*(1-t)^2
	float t2 = 3 * t * t * tmp;		// 3*t^2(1-t)
	float t3 = t * t * t;			// t^3
#else
#ifdef QUADRIC
	float tmp = (1.0f-t);
	float t0 = tmp*tmp;			// (1-t)^3
	float t1 = 2 * t * tmp;	// 3*t*(1-t)^2
	float t2 = t * t;		// 3*t^2(1-t)
	float t3 = 0;			// t^3	
#else
	float tmp = (1.0f-t);
	float t0 = tmp;			// (1-t)^3
	float t1 = t;	// 3*t*(1-t)^2
	float t2 = 0;
	float t3 = 0;
#endif	// QUADRIC
	
#endif	// CUBIC
	ccVertex2F out = ccpMult(p0,t0);
	out = ccpAdd(out,ccpMult(p1,t1));
	out = ccpAdd(out,ccpMult(p2,t2));
	out = ccpAdd(out,ccpMult(p3,t3));
	return out;
}

-(void) initParticle: (tCCParticle*) particle
{
	
	// timeToLive
	// no negative life. prevent division by 0
	particle->timeToLive = MAX(0, life + lifeVar * CCRANDOM_MINUS1_1() );
	
	// position
	particle->pos.x = centerOfGravity.x + posVar.x * CCRANDOM_MINUS1_1();
	particle->pos.y = centerOfGravity.y + posVar.y * CCRANDOM_MINUS1_1();
	
	// Color
	ccColor4F start;
	start.r = MIN(1, MAX(0, startColor.r + startColorVar.r * CCRANDOM_MINUS1_1() ) );
	start.g = MIN(1, MAX(0, startColor.g + startColorVar.g * CCRANDOM_MINUS1_1() ) );
	start.b = MIN(1, MAX(0, startColor.b + startColorVar.b * CCRANDOM_MINUS1_1() ) );
	start.a = MIN(1, MAX(0, startColor.a + startColorVar.a * CCRANDOM_MINUS1_1() ) );
	
	ccColor4F end;
	end.r = MIN(1, MAX(0, endColor.r + endColorVar.r * CCRANDOM_MINUS1_1() ) );
	end.g = MIN(1, MAX(0, endColor.g + endColorVar.g * CCRANDOM_MINUS1_1() ) );
	end.b = MIN(1, MAX(0, endColor.b + endColorVar.b * CCRANDOM_MINUS1_1() ) );
	end.a = MIN(1, MAX(0, endColor.a + endColorVar.a * CCRANDOM_MINUS1_1() ) );
	
	particle->color = start;
	particle->deltaColor.r = (end.r - start.r) / particle->timeToLive;
	particle->deltaColor.g = (end.g - start.g) / particle->timeToLive;
	particle->deltaColor.b = (end.b - start.b) / particle->timeToLive;
	particle->deltaColor.a = (end.a - start.a) / particle->timeToLive;
	
	// size
	float startS = MAX(0, startSize + startSizeVar * CCRANDOM_MINUS1_1() ); // no negative size
	
	particle->size = startS;
	if( endSize == kCCParticleStartSizeEqualToEndSize )
		particle->deltaSize = 0;
	else {
		float endS = endSize + endSizeVar * CCRANDOM_MINUS1_1();
		endS = MAX(0, endS);
		particle->deltaSize = (endS - startS) / particle->timeToLive;
	}
	
	// rotation
	float startA = startSpin + startSpinVar * CCRANDOM_0_1();
	float endA = endSpin + endSpinVar * CCRANDOM_0_1();
	particle->rotation = startA;
	particle->deltaRotation = (endA - startA) / particle->timeToLive;
	
	// position
	if( positionType_ == kCCPositionTypeFree )
		particle->pos = [self convertToWorldSpace:CGPointZero];
}

-(void) update: (ccTime) dt {
	if (flippingPage) {
		return;
	}
	if( active && emissionRate && spewSmoke) {
		float rate = 1.0f / emissionRate;
		emitCounter += dt;
		while( particleCount < totalParticles && emitCounter > rate ) {
			[self addParticle];
			emitCounter -= rate;
		}
		
		elapsed += dt;
		if(duration != -1 && duration < elapsed)
			[self stopSystem];
	}
	
	particleIdx = 0;
	
	
/*#if CC_ENABLE_PROFILERS
	CCProfilingBeginTimingBlock(_profilingTimer);
#endif*/
	
	
	CGPoint currentPosition = CGPointZero;
	if( positionType_ == kCCPositionTypeFree )
		currentPosition = [self convertToWorldSpace:CGPointZero];
	
	while( particleIdx < particleCount )
	{
		tCCParticle *p = &particles[particleIdx];
		p->timeToLive -= dt;
		if( p->timeToLive > 0 ) {
			// color
			p->color.r = 1.0f;
			p->color.g = 1.0f;
			p->color.b = 1.0f;
			p->color.a += (p->deltaColor.a * dt);
			
			// size
			p->size += (p->deltaSize * dt);
			p->size = MAX( 0, p->size );
			
			// angle
			p->rotation += (p->deltaRotation * dt);
			
			//
			// update values in quad
			//
			
			//CGPoint	newPos;
			// See if we need to go to the next target
//			ccVertex2F _delta = ccpSub(target, p->pos);

#define _performance
#ifdef _performance
				p->pos = [self bezier:(self.life - p->timeToLive)/self.life];
#else
			float len = ccpLength(_delta);
			_delta.x /= len;
			_delta.y /= len;
			_delta = ccpMult(_delta,5.0f);
			p->pos = ccpAdd(p->pos,_delta);				
#endif

			[self updateQuadWithParticle:p newPosition:p->pos];
			
			// update particle counter
			particleIdx++;
			if(p->size < p->deltaSize) p->size += p->deltaSize/5.0f;
		} else {
			// life < 0
			if( particleIdx != particleCount-1 )
				particles[particleIdx] = particles[particleCount-1];
			particleCount--;
			
			if( particleCount == 0 && autoRemoveOnFinish_ ) {
				[self unscheduleUpdate];
				[parent_ removeChild:self cleanup:YES];
				return;
			}
		}
	}
	
/*#if CC_ENABLE_PROFILERS
	CCProfilingEndTimingBlock(_profilingTimer);
#endif*/
	
	[self postStep];	
}

-(void) updateQuadWithParticle:(tCCParticle*)p newPosition:(CGPoint)newPos
{
	// colors
	quads[particleIdx].bl.colors = p->color;
	quads[particleIdx].br.colors = p->color;
	quads[particleIdx].tl.colors = p->color;
	quads[particleIdx].tr.colors = p->color;
	
	// vertices
	float size_2 = p->size/2;
	if( p->rotation ) {
		float x1 = -size_2;
		float y1 = -size_2;
		
		float x2 = size_2;
		float y2 = size_2;
		float x = newPos.x;
		float y = newPos.y;
		
		float r = (float)-CC_DEGREES_TO_RADIANS(p->rotation);
		float cr = cosf(r);
		float sr = sinf(r);
		float ax = x1 * cr - y1 * sr + x;
		float ay = x1 * sr + y1 * cr + y;
		float bx = x2 * cr - y1 * sr + x;
		float by = x2 * sr + y1 * cr + y;
		float cx = x2 * cr - y2 * sr + x;
		float cy = x2 * sr + y2 * cr + y;
		float dx = x1 * cr - y2 * sr + x;
		float dy = x1 * sr + y2 * cr + y;
		
		// bottom-left
		quads[particleIdx].bl.vertices.x = ax;
		quads[particleIdx].bl.vertices.y = ay;
		
		// bottom-right vertex:
		quads[particleIdx].br.vertices.x = bx;
		quads[particleIdx].br.vertices.y = by;
		
		// top-left vertex:
		quads[particleIdx].tl.vertices.x = dx;
		quads[particleIdx].tl.vertices.y = dy;
		
		// top-right vertex:
		quads[particleIdx].tr.vertices.x = cx;
		quads[particleIdx].tr.vertices.y = cy;
	} else {
		// bottom-left vertex:
		quads[particleIdx].bl.vertices.x = newPos.x - size_2;
		quads[particleIdx].bl.vertices.y = newPos.y - size_2;
		
		// bottom-right vertex:
		quads[particleIdx].br.vertices.x = newPos.x + size_2;
		quads[particleIdx].br.vertices.y = newPos.y - size_2;
		
		// top-left vertex:
		quads[particleIdx].tl.vertices.x = newPos.x - size_2;
		quads[particleIdx].tl.vertices.y = newPos.y + size_2;
		
		// top-right vertex:
		quads[particleIdx].tr.vertices.x = newPos.x + size_2;
		quads[particleIdx].tr.vertices.y = newPos.y + size_2;				
	}

}

-(void) draw
{	
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Unneeded states: -
	glColorMask(TRUE,TRUE,TRUE,FALSE);
	
	glBindTexture(GL_TEXTURE_2D, texture_.name);
	
	glBindBuffer(GL_ARRAY_BUFFER, quadsID);
	
	#define kPointSize sizeof(quads[0].bl)
	glVertexPointer(2,GL_FLOAT, kPointSize, 0);
	
	glColorPointer(4, GL_FLOAT, kPointSize, (GLvoid*) offsetof(ccV2F_C4F_T2F,colors) );
	
	glTexCoordPointer(2, GL_FLOAT, kPointSize, (GLvoid*) offsetof(ccV2F_C4F_T2F,texCoords) );
	
	blendFunc_.src = GL_SRC_ALPHA;//GL_ZERO;//SRC_ALPHA;
	blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);	
	glTexEnvi (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND);

//	glBlendFunc( blendFunc_.src, blendFunc_.dst );
//	glTexEnvi (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND);

	// save color mode
	if( particleIdx != particleCount ) {
		NSLog(@"pd:%d, pc:%d", particleIdx, particleCount);
	}
	glDrawElements(GL_TRIANGLES, particleIdx*6, GL_UNSIGNED_SHORT, indices);	
	
	// restore blend state
	glColorMask(TRUE,TRUE,TRUE,TRUE);
	glBlendFunc( CC_BLEND_SRC, CC_BLEND_DST );
	glTexEnvi (GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);

	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
	// restore GL default state
	// -
}
@end
