//
//  AHParticleExplosion.m
//  AlphaHerderZ
//
//  Created by Edward Palmer on 25/04/2010.
//  Copyright 2010 chichai.com. All rights reserved.
//

#import "AHParticleExplosion.h"
#import "cocos2d.h"
/*
#import "CCTextureCache.h"
#import "CCDirector.h"
//#import "Support/CGPointExtension.h"
*/
@implementation AHParticleExplosion
-(id) init
{
	return [self initWithTotalParticles:300];
}


-(id) initWithTotalParticles:(int)p
{
	if( !(self=[super initWithTotalParticles:p]) )
		return nil;
	
	// duration
	duration = 0.3f;
	
	// gravity
	self.gravity = ccp(0,-90);
	
	// angle
	self.angle = 90;
	self.angleVar = 360;
	
	// speed of particles
	self.speed = 150;
	self.speedVar = 40;
	
	// radial
	self.radialAccel = 0;
	self.radialAccelVar = 0;
	
	// tagential
	self.tangentialAccel = 0;
	self.tangentialAccelVar = 0;
	
	// emitter position
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	self.position = ccp(winSize.width/2, winSize.height/2);
	self.posVar = CGPointZero;
	
	// life of particles
	life = 0.5f;
	lifeVar = 0.0f;
	
	// size, in pixels
	startSize = 15.0f;
	startSizeVar = 10.0f;
	endSize = kParticleStartSizeEqualToEndSize;
	
	// emits per second
	emissionRate = totalParticles/duration;
	
	// color of particles
	startColor.r = 0.7f;
	startColor.g = 0.1f;
	startColor.b = 0.2f;
	startColor.a = 1.0f;
	startColorVar.r = 0.5f;
	startColorVar.g = 0.5f;
	startColorVar.b = 0.5f;
	startColorVar.a = 0.0f;
	endColor.r = 0.5f;
	endColor.g = 0.5f;
	endColor.b = 0.5f;
	endColor.a = 0.0f;
	endColorVar.r = 0.5f;
	endColorVar.g = 0.5f;
	endColorVar.b = 0.5f;
	endColorVar.a = 0.0f;
	
	self.texture = [[CCTextureCache sharedTextureCache] addImage: @"fire.png"];
	
	// additive
	self.blendAdditive = NO;
	
	return self;
}
 
@end
