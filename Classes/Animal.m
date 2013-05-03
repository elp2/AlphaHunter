//
//  Animal.m
//  AlphaHunter
//
//  Created by Ed Palmer on 01/09/2009.
//  Copyright 2009 chichai.com. All rights reserved.
//

#import "Animal.h"
#define RANDOM_SEED() srandom(time(NULL))
#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + random() % ((__MAX__+1) - (__MIN__)))



@implementation Animal

static float gameSpeed = 1.0f;

#pragma mark -
#pragma mark Movement

-(CGPoint) getNextPosition
{
	return CGPointMake( self.position.x + moveVector_.x * gameSpeed, self.position.y + moveVector_.y * gameSpeed);
}

-(void) pickNewRandomDirection
{
	moveVector_ = CGPointMake( (float)( RANDOM_INT( -1 * kMaxSpeed, kMaxSpeed ) ) * kSpeedScalar, 
							   (float)( RANDOM_INT( -1 * kMaxSpeed, kMaxSpeed ) ) * kSpeedScalar );
	
	ticksSinceTurn_ = 0;
}

-(void) pickNewDirection
{
	double angle = atan2( moveVector_.x, moveVector_.y );
	double speed = sqrt( moveVector_.x * moveVector_.x + moveVector_.y * moveVector_.y );
	double turnAmount = (double)(RANDOM_INT( -1 * maxTurnDegrees_, maxTurnDegrees_ ))* M_PI / 180;
	double newAngle = angle + turnAmount;
	
	CGPoint newMoveVector = CGPointMake( 0, 0 );
	newMoveVector.x = sin(newAngle) * speed;
	newMoveVector.y = cos(newAngle) * speed;

	assert( !isnan( newMoveVector.x ) );
	assert( !isnan( newMoveVector.y ) );
	
	moveVector_ = newMoveVector;
	ticksSinceTurn_ = 0;
}

+(void) setGameSpeed:(float)newGameSpeed
{
	gameSpeed = sqrt( newGameSpeed );
}

-(int) isTimeToTurn
{
	return( ticksSinceTurn_ + RANDOM_INT(0, 90) > 100 );	
}

-(void) updatePosition
{
	ticksSinceTurn_++;
	// if time to change angle
	if( [self isTimeToTurn] ) {
		[self pickNewDirection];
	}
	
	CGPoint nextPosition = [self getNextPosition];
	
	while( ![(GameLayer*)parent_ isLegalMoveFrom: self.position to:nextPosition] ) {
		[self pickNewRandomDirection];
		nextPosition = [self getNextPosition];
	}
	
	self.position = nextPosition;
}


#pragma mark -
#pragma mark Life Management


-(int) isFree
{
	return kAHFreeState == state_;
	
}

-(void)animalResurrecting
{
	self.position = [(GameLayer*)parent_ getAnimalPosition];
	reticle_.visible = NO;
}

-(void)animalResurrected
{
	state_ = kAHFreeState;
	[(GameLayer*)parent_ animalResurrected];
	[self startMoving];
}

-(void)wasCaughtDelay:(double)pDelay limboTime:(double)limboTime
{
	if( kAHCaughtState == state_ )
		return;
	
	NSLog( @"animal wasCaught! %f %f", pDelay, limboTime );
	[self unschedule:@selector(updatePosition)];

	state_ = kAHCaughtState;
	
	reticle_.visible = YES;
	
	CCSequence *deathAndRebirth = [CCSequence actions:[CCScaleTo actionWithDuration:pDelay scale:0.0f], 
													 [CCDelayTime actionWithDuration:limboTime],
													 [CCCallFunc actionWithTarget:self selector:@selector(animalResurrecting)],
													 [CCScaleTo actionWithDuration:1.0f scale:1.0f],
													 [CCCallFunc actionWithTarget:self selector:@selector(animalResurrected)],
													 nil];
	
	[self runAction:deathAndRebirth];
}

-(int) score
{
	switch ( animalType_ ) {
		case kAHBearType:
			return kAHBearScore;			
			break;
		case kAHBeeType:
			return kAHBeeScore;			
			break;
		case kAHCowType:
			return kAHCowScore;
			break;
		case kAHFoxType:
			return kAHFoxScore;
			break;
		case kAHLionType:
			return kAHLionScore;
			break;
		case kAHTigerType:
			return kAHTigerScore;
			break;	

		default:
			break;
	}
	
	return -1;
}

-(int) getType
{
	return animalType_;
}

#pragma mark -
#pragma mark Init 

-(void) startMoving
{
	[self schedule:@selector(updatePosition)];
}

-(void) setAnimalConstants
{
	switch (animalType_) {
		case kAHBearType:
			turnyNess_ = 50;
			maxTurnDegrees_ = 60;			
			break;
		case kAHBeeType:
			turnyNess_ = 50;
			maxTurnDegrees_ = 60;
			break;
		case kAHCowType:
			turnyNess_ = 50;
			maxTurnDegrees_ = 60;
			break;
		case kAHFoxType:
			turnyNess_ = 50;
			maxTurnDegrees_ = 60;
			break;
		case kAHLionType:
			turnyNess_ = 50;
			maxTurnDegrees_ = 60;
			break;
		case kAHTigerType:
			turnyNess_ = 50;
			maxTurnDegrees_ = 60;
			break;
						
		default:
			break;
	}
}

-(id) setGraphics
{
	self = [super initWithFile:@"animals.png" capacity:2];
	
	CGRect rect;
	switch (animalType_) {
		case kAHBearType:
			rect = kAHBearBox;			
			break;
		case kAHBeeType:
			rect = kAHBeeBox;			
			break;
		case kAHCowType:
			rect = kAHCowBox;
			break;
		case kAHFoxType:
			rect = kAHFoxBox;			
			break;
		case kAHLionType:
			rect = kAHLionBox;
			break;
		case kAHTigerType:
			rect = kAHTigerBox;
			break;			
		default:
			break;
	}
	CCSprite *animal = [CCSprite spriteWithBatchNode:self rect:rect];
	[self addChild:animal z:0];
	
	reticle_ = [CCSprite spriteWithBatchNode:self rect:CGRectMake(362,48,100,100)];	
	CGSize size = self.contentSize;
	reticle_.position = ccp( size.width / 2, size.height / 2 );
	[self addChild: reticle_ z: 1];
	reticle_.visible = NO;
	
	return( self );
}

-(id) initWithType:(int)pAnimalType
{
	state_ = kAHFreeState;

	animalType_ = pAnimalType;
	
	self = [self setGraphics];
	assert( nil != self );

	[self setAnimalConstants];
	
	[self pickNewRandomDirection];
	
	return( self );
}

+(id) animalWithType:(int)pAnimalType
{
	return [[self alloc] initWithType:pAnimalType];
}


@end
